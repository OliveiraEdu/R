#' Search arXiv API and import results
#' 
#' Requires httr and jsonlite packages. Install with:
#' install.packages(c("httr", "jsonlite"))
#'
#' @param query Search string (e.g., "blockchain AND provenance")
#' @param max_results Maximum results to return (default 100, max 30000)
#' @param categories arXiv categories to search (e.g., c("cs.DC", "q-bio.QM"))
#' @param months Number of months to search (default 6). Overrides date_from/date_to
#' @param date_from Start date (optional, format: YYYYMMDD)
#' @param date_to End date (optional, format: YYYYMMDD)
#' @param sleep_time Seconds to wait between API calls (default 3)
#' @return Data frame with arXiv records
#' @export
search_arxiv <- function(query,
                         max_results = 100,
                         categories = NULL,
                         months = 6,
                         date_from = NULL,
                         date_to = NULL,
                         sleep_time = 3) {
  
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("httr package required. Install with: install.packages('httr')")
  }
  
  base_url <- "http://export.arxiv.org/api/query"
  
  # Calculate date range from months if not explicitly provided
  if (is.null(date_from) || is.null(date_to)) {
    end_date <- Sys.Date()
    start_date <- end_date - (months * 30)
    date_to <- format(end_date, "%Y%m%d")
    date_from <- format(start_date, "%Y%m%d")
  }
  
  # Build search query
  search_query <- query
  
  # Add category filter
  if (!is.null(categories)) {
    cat_str <- paste0("cat:", categories, collapse = " OR cat:")
    search_query <- paste0("(", search_query, ") AND (", cat_str, ")")
  }
  
  # Add date filter
  if (!is.null(date_from)) {
    search_query <- paste0(search_query, " AND submittedDate:[", date_from, " TO ", 
                          ifelse(is.null(date_to), "*", date_to), "]")
  }
  
  # URL encode
  search_query <- URLencode(search_query)
  
  # Calculate batches (max 1000 per call)
  batch_size <- min(1000, max_results)
  n_batches <- ceiling(max_results / batch_size)
  
  all_records <- list()
  
  for (batch in 1:n_batches) {
    start_idx <- (batch - 1) * batch_size
    
    url <- paste0(base_url, "?search_query=", search_query,
                  "&start=", start_idx,
                  "&max_results=", batch_size,
                  "&sortBy=submittedDate&sortOrder=descending")
    
    message(paste("Fetching arXiv batch", batch, "of", n_batches, "..."))
    
    if (batch > 1) Sys.sleep(sleep_time)
    
    response <- tryCatch({
      httr::GET(url, httr::timeout(60))
    }, error = function(e) {
      warning(paste("API request failed:", e$message))
      return(NULL)
    })
    
    if (is.null(response)) next
    if (httr::status_code(response) != 200) {
      warning(paste("API returned status:", httr::status_code(response)))
      next
    }
    
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    
    # Split by entry tags
    entries <- strsplit(content, "<entry>")[[1]]
    entries <- entries[-1]  # Remove header
    
    if (length(entries) == 0) break
    
    for (entry in entries) {
      rec <- list(
        TI = NA, AU = NA, PY = NA, SO = "arXiv", DOI = NA, ID = NA,
        AB = NA, C1 = NA, TC = NA, DB = "arXiv", URL = NA,
        arxiv_id = NA, categories = NA, published = NA
      )
      
      # Extract title
      title_match <- regmatches(entry, regexpr("<title>[^<]+</title>", entry))
      if (length(title_match) > 0) {
        rec$TI <- gsub("\\s+", " ", gsub("<title>|</title>", "", title_match))
      }
      
      # Extract summary/abstract
      summary_match <- regmatches(entry, regexpr("<summary>[^<]+</summary>", entry))
      if (length(summary_match) > 0) {
        rec$AB <- gsub("\\s+", " ", gsub("<summary>|</summary>", "", summary_match))
      }
      
      # Extract authors
      author_matches <- gregexpr("<author><name>[^<]+</name></author>", entry)[[1]]
      if (author_matches[1] > 0) {
        author_list <- regmatches(entry, author_matches)
        if (length(author_list) > 0 && length(author_list[[1]]) > 0) {
          authors <- sapply(author_list[[1]], function(x) {
            gsub("<author><name>|</name></author>", "", x)
          })
          rec$AU <- paste(authors, collapse = "; ")
        }
      }
      
      # Extract published date
      published_match <- regmatches(entry, regexpr("<published>[^<]+</published>", entry))
      if (length(published_match) > 0) {
        rec$published <- gsub("<published>|</published>", "", published_match)
        if (!is.na(rec$published) && nchar(rec$published) >= 4) {
          rec$PY <- as.integer(substr(rec$published, 1, 4))
        }
      }
      
      # Extract identifier
      id_match <- regmatches(entry, regexpr("<id>http://arxiv.org/abs/[^<]+</id>", entry))
      if (length(id_match) > 0) {
        rec$URL <- gsub("<id>|</id>", "", id_match)
        arxiv_match <- regmatches(rec$URL, regexpr("arXiv:\\d+\\.\\d+", rec$URL))
        if (length(arxiv_match) > 0) rec$arxiv_id <- arxiv_match
      }
      
      # Extract categories
      cat_matches <- gregexpr("<category[^>]+term=\"[^\"]+\"", entry)
      if (cat_matches[[1]][1] > 0) {
        cats <- sapply(regmatches(entry, cat_matches)[[1]], function(x) {
          gsub(".*term=\"([^\"]+)\".*", "\\1", x)
        })
        rec$categories <- paste(cats, collapse = "; ")
      }
      
      all_records[[length(all_records) + 1]] <- rec
    }
  }
  
  if (length(all_records) == 0) return(data.frame())
  
  df <- do.call(rbind.data.frame, c(all_records, stringsAsFactors = FALSE))
  message(paste("Imported", nrow(df), "records from arXiv"))
  df
}


#' Import arXiv from saved Atom XML file
#'
#' Uses regex-based parsing (no XML package required)
#'
#' @param path Path to arXiv Atom XML file
#' @return Data frame with arXiv records
#' @export
import_arxiv_xml <- function(path) {
  
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  content <- paste(readLines(path, warn = FALSE), collapse = "\n")
  
  # Split by entry tags
  entries <- strsplit(content, "<entry>")[[1]]
  entries <- entries[-1]
  
  if (length(entries) == 0) return(data.frame())
  
  all_records <- list()
  
  for (entry in entries) {
    rec <- list(
      TI = NA, AU = NA, PY = NA, SO = "arXiv", DOI = NA, ID = NA,
      AB = NA, C1 = NA, TC = NA, DB = "arXiv", URL = NA,
      arxiv_id = NA, categories = NA, published = NA
    )
    
    # Title
    title_match <- regmatches(entry, regexpr("<title>[^<]+</title>", entry))
    if (length(title_match) > 0) {
      rec$TI <- gsub("\\s+", " ", gsub("<title>|</title>", "", title_match))
    }
    
    # Abstract
    summary_match <- regmatches(entry, regexpr("<summary>[^<]+</summary>", entry))
    if (length(summary_match) > 0) {
      rec$AB <- gsub("\\s+", " ", gsub("<summary>|</summary>", "", summary_match))
    }
    
    # Authors
    author_matches <- gregexpr("<author><name>[^<]+</name></author>", entry)[[1]]
    if (author_matches[1] > 0) {
      authors <- sapply(regmatches(entry, author_matches), function(x) {
        gsub("<author><name>|</name></author>", "", x)
      })
      rec$AU <- paste(authors, collapse = "; ")
    }
    
    # Date
    published_match <- regmatches(entry, regexpr("<published>[^<]+</published>", entry))
    if (length(published_match) > 0) {
      rec$published <- gsub("<published>|</published>", "", published_match)
      if (!is.na(rec$published) && nchar(rec$published) >= 4) {
        rec$PY <- as.integer(substr(rec$published, 1, 4))
      }
    }
    
    # Identifier
    id_match <- regmatches(entry, regexpr("<id>http://arxiv.org/abs/[^<]+</id>", entry))
    if (length(id_match) > 0) {
      rec$URL <- gsub("<id>|</id>", "", id_match)
      arxiv_match <- regmatches(rec$URL, regexpr("arXiv:\\d+\\.\\d+", rec$URL))
      if (length(arxiv_match) > 0) rec$arxiv_id <- arxiv_match
    }
    
    # Categories
    cat_matches <- gregexpr("<category[^>]+term=\"[^\"]+\"", entry)[[1]]
    if (cat_matches[1] > 0) {
      cats <- sapply(regmatches(entry, cat_matches), function(x) {
        gsub(".*term=\"([^\"]+)\".*", "\\1", x)
      })
      rec$categories <- paste(cats, collapse = "; ")
    }
    
    all_records[[length(all_records) + 1]] <- rec
  }
  
  df <- do.call(rbind.data.frame, c(all_records, stringsAsFactors = FALSE))
  message(paste("Imported", nrow(df), "records from arXiv XML"))
  df
}


#' Search bioRxiv API
#'
#' Requires httr and jsonlite packages.
#' Install with: install.packages(c("httr", "jsonlite"))
#' Search bioRxiv API
#'
#' Note: bioRxiv API does not support keyword search directly.
#' This function fetches recent papers and filters by keyword locally.
#' Requires httr and jsonlite packages. Install with:
#' install.packages(c("httr", "jsonlite"))
#'
#' @param query Search string (keywords to filter)
#' @param max_results Maximum results to return (default 100)
#' @param months Number of months to search (default 6). Overrides date_from/date_to
#' @param date_from Start date (YYYY-MM-DD), defaults to 6 months ago
#' @param date_to End date (YYYY-MM-DD), defaults to today
#' @param sleep_time Seconds between calls (default 2)
#' @param max_pages Maximum API pages to fetch (default 20, 100 records each)
#' @return Data frame with bioRxiv records
#' @export
search_biorxiv <- function(query,
                          max_results = 100,
                          months = 6,
                          date_from = NULL,
                          date_to = NULL,
                          sleep_time = 2,
                          max_pages = 20) {
  
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("httr package required. Install with: install.packages('httr')")
  }
  
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite package required. Install with: install.packages('jsonlite')")
  }
  
  base_url <- "https://api.biorxiv.org/details/biorxiv"
  
  # Calculate date range from months if not explicitly provided
  if (is.null(date_from) || is.null(date_to)) {
    end_date <- as.Date(format(Sys.Date(), "%Y-%m-%d"))
    start_date <- end_date - (months * 30)
    start_date <- format(start_date, "%Y-%m-%d")
    end_date <- format(end_date, "%Y-%m-%d")
  } else {
    start_date <- date_from
    end_date <- date_to
  }
  
  all_records <- list()
  cursor <- 0
  page_count <- 0
  
  while (length(all_records) < max_results && page_count < max_pages) {
    url <- paste0(base_url, "/", start_date, "/", end_date, "/", cursor)
    
    message(paste("Fetching bioRxiv from cursor", cursor, "..."))
    
    if (cursor > 0) Sys.sleep(sleep_time)
    
    response <- tryCatch({
      httr::GET(url, httr::timeout(60))
    }, error = function(e) {
      warning(paste("API request failed:", e$message))
      return(NULL)
    })
    
    page_count <- page_count + 1
    
    if (is.null(response)) break
    if (response$status_code != 200) {
      warning(paste("API returned status:", response$status_code))
      break
    }
    
    text_content <- httr::content(response, as = "text", encoding = "UTF-8")
    data <- jsonlite::fromJSON(text_content)
    
    collection <- data$collection
    if (length(collection) == 0) break
    
    for (i in seq_len(nrow(collection))) {
      rec <- collection[i, , drop = FALSE]
      
      title <- if ("title" %in% names(rec)) rec$title[[1]] else NA
      abstract <- if ("abstract" %in% names(rec)) rec$abstract[[1]] else NA
      
      if (!is.na(title) && is.character(title)) {
        title_lower <- tolower(title)
        abstract_lower <- tolower(ifelse(is.na(abstract), "", abstract))
        query_lower <- tolower(query)
        
        if (grepl(query_lower, title_lower, fixed = TRUE) || 
            grepl(query_lower, abstract_lower, fixed = TRUE)) {
          
          record <- list(
            TI = NA, AU = NA, PY = NA, SO = "bioRxiv",
            DOI = NA, ID = NA, AB = NA, C1 = NA, TC = NA, DB = "bioRxiv",
            URL = NA, biorxiv_id = NA, posted_date = NA
          )
          
          record$TI <- gsub("\\s+", " ", title)
          if (!is.na(abstract)) record$AB <- gsub("\\s+", " ", abstract)
          
          if ("authors" %in% names(rec) && !is.null(rec$authors[[1]])) {
            if (is.character(rec$authors[[1]])) {
              record$AU <- rec$authors[[1]]
            } else if (is.data.frame(rec$authors[[1]])) {
              record$AU <- paste(rec$authors[[1]]$author_name, collapse = "; ")
            }
          }
          if ("date" %in% names(rec) && !is.null(rec$date[[1]])) {
            record$PY <- as.integer(substr(rec$date[[1]], 1, 4))
          }
          if ("doi" %in% names(rec)) record$DOI <- rec$doi[[1]]
          if ("url" %in% names(rec)) record$URL <- rec$url[[1]]
          if ("posted" %in% names(rec)) record$posted_date <- rec$posted[[1]]
          
          all_records[[length(all_records) + 1]] <- record
          
          if (length(all_records) >= max_results) break
        }
      }
    }
    
    cursor <- cursor + 100
    
    if (nrow(collection) < 100) break
  }
  
  if (length(all_records) == 0) return(data.frame())
  
  df <- do.call(rbind.data.frame, c(all_records, stringsAsFactors = FALSE))
  
  message(paste("Imported", nrow(df), "records from bioRxiv"))
  df
}


#' Import bioRxiv from JSON file
#'
#' Requires jsonlite package. Install with: install.packages("jsonlite")
#'
#' @param path Path to bioRxiv JSON file
#' @return Data frame with bioRxiv records
#' @export
import_biorxiv_json <- function(path) {
  
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite package required. Install with: install.packages('jsonlite')")
  }
  
  data <- jsonlite::fromJSON(path)
  collection <- data$collection
  
  if (length(collection) == 0) return(data.frame())
  
  all_records <- list()
  
  for (i in seq_len(nrow(collection))) {
    rec <- collection[i, , drop = FALSE]
    
    record <- list(
      TI = NA, AU = NA, PY = NA, SO = "bioRxiv",
      DOI = NA, ID = NA, AB = NA, C1 = NA, TC = NA, DB = "bioRxiv",
      URL = NA, biorxiv_id = NA, posted_date = NA
    )
    
    if ("title" %in% names(rec)) record$TI <- rec$title[[1]]
    if ("authors" %in% names(rec) && !is.null(rec$authors[[1]])) {
      if (is.character(rec$authors[[1]])) {
        record$AU <- rec$authors[[1]]
      }
    }
    if ("date" %in% names(rec)) record$PY <- as.integer(substr(rec$date[[1]], 1, 4))
    if ("doi" %in% names(rec)) record$DOI <- rec$doi[[1]]
    if ("abstract" %in% names(rec)) record$AB <- rec$abstract[[1]]
    if ("url" %in% names(rec)) record$URL <- rec$url[[1]]
    
    all_records[[length(all_records) + 1]] <- record
  }
  
  df <- do.call(rbind.data.frame, c(all_records, stringsAsFactors = FALSE))
  df$TI <- gsub("\\s+", " ", df$TI)
  df$AB <- gsub("\\s+", " ", df$AB)
  
  message(paste("Imported", nrow(df), "records from bioRxiv JSON"))
  df
}

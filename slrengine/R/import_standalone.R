#' Import Scopus CSV export
#' @param path Path to Scopus CSV file
#' @return Data frame with Scopus records
#' @export
import_scopus <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE, quote = "\"", encoding = "UTF-8")
  
  # Map Scopus columns to standard format (handles multiple column name variations)
  standardized <- data.frame(
    TI = if ("Title" %in% names(df)) df$Title else NA,
    AU = if ("Authors" %in% names(df)) df$Authors else NA,
    PY = if ("Year" %in% names(df)) as.integer(df$Year) else NA,
    SO = if ("Source title" %in% names(df)) df$`Source title` else NA,
    DOI = if ("DOI" %in% names(df)) df$DOI else NA,
    ID = NA,
    AB = if ("Abstract" %in% names(df)) df$Abstract else NA,
    C1 = if ("Affiliations" %in% names(df)) df$Affiliations else NA,
    TC = NA,
    DB = "Scopus",
    stringsAsFactors = FALSE
  )
  
  standardized
}


#' Import PubMed-style CSV export
#' @param path Path to PubMed CSV file
#' @return Data frame with PubMed records
#' @export
import_pubmed_csv <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE, quote = "\"", encoding = "UTF-8")
  
  # Map PubMed CSV columns to standard format (handles variations in column names)
  standardized <- data.frame(
    TI = if ("Title" %in% names(df)) df$Title else NA,
    AU = if ("Authors" %in% names(df)) df$Authors else NA,
    PY = if ("Publication.Year" %in% names(df)) as.integer(df$Publication.Year) 
         else if ("Publication Year" %in% names(df)) as.integer(df$`Publication Year`) else NA,
    SO = if ("Journal.Book" %in% names(df)) df$Journal.Book 
         else if ("Journal/Book" %in% names(df)) df$`Journal/Book` else NA,
    DOI = if ("DOI" %in% names(df)) df$DOI else NA,
    ID = if ("PMID" %in% names(df)) df$PMID else NA,
    AB = NA,
    C1 = NA,
    TC = NA,
    DB = "PubMed",
    stringsAsFactors = FALSE
  )
  
  standardized
}


#' Import IEEE Xplore CSV export
#' @param path Path to IEEE CSV file
#' @return Data frame with IEEE records
#' @export
import_ieee <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE, quote = "\"", encoding = "UTF-8")
  
  # Map IEEE columns to standard format (handles multiple column name variations)
  standardized <- data.frame(
    TI = if ("Document Title" %in% names(df)) df$`Document Title` else NA,
    AU = if ("Authors" %in% names(df)) df$Authors else NA,
    PY = if ("Publication Year" %in% names(df)) as.integer(df$`Publication Year`) else NA,
    SO = if ("Publication Title" %in% names(df)) df$`Publication Title` else NA,
    DOI = if ("DOI" %in% names(df)) df$DOI else NA,
    ID = NA,
    AB = if ("Abstract" %in% names(df)) df$Abstract else NA,
    C1 = if ("Author Affiliations" %in% names(df)) df$`Author Affiliations` else NA,
    TC = NA,
    DB = "IEEE Xplore",
    stringsAsFactors = FALSE
  )
  
  standardized
}


#' Import Web of Science BibTeX files
#' @param paths Character vector of file paths to .bib files
#' @return Data frame with merged Web of Science records
#' @export
import_wos <- function(paths) {
  
  all_dfs <- list()
  
  for (path in paths) {
    if (!file.exists(path)) {
      warning(paste("File not found:", path))
      next
    }
    
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    
    records <- list()
    current <- NULL
    
    for (line in lines) {
      line <- trimws(line)
      
      if (grepl("^@\\w+", line)) {
        if (!is.null(current) && length(current) > 0) records[[length(records) + 1]] <- current
        current <- list()
        next
      }
      
      if (is.null(current)) next
      
      if (grepl("^}$", line)) {
        records[[length(records) + 1]] <- current
        current <- NULL
        next
      }
      
      if (grepl("^\\w+", line)) {
        parts <- strsplit(line, "=")[[1]]
        if (length(parts) >= 2) {
          field <- trimws(parts[1])
          value <- paste(trimws(parts[-1]), collapse = "=")
          value <- gsub("[{},]", "", value)
          value <- gsub("^\"|\"$", "", value)
          current[[toupper(field)]] <- value
        }
      }
    }
    
    if (length(records) == 0) next
    
    # Create data frame with standard columns
    df <- data.frame(
      TI = sapply(records, function(x) ifelse(is.null(x$TITLE), NA, x$TITLE)),
      AU = sapply(records, function(x) ifelse(is.null(x$AUTHOR), NA, x$AUTHOR)),
      PY = sapply(records, function(x) {
        py <- x$YEAR
        if (is.null(py)) NA else as.integer(py)
      }),
      SO = sapply(records, function(x) ifelse(is.null(x$JOURNAL), ifelse(is.null(x$BOOKTITLE), NA, x$BOOKTITLE), x$JOURNAL)),
      DOI = sapply(records, function(x) ifelse(is.null(x$DOI), NA, x$DOI)),
      ID = NA,
      AB = sapply(records, function(x) ifelse(is.null(x$ABSTRACT), NA, x$ABSTRACT)),
      C1 = sapply(records, function(x) ifelse(is.null(x$AFFILIATION), NA, x$AFFILIATION)),
      TC = sapply(records, function(x) {
        tc <- x$TIMES.CITED
        if (is.null(tc)) NA else as.integer(tc)
      }),
      DB = "WoS",
      stringsAsFactors = FALSE
    )
    
    all_dfs[[length(all_dfs) + 1]] <- df
  }
  
  if (length(all_dfs) == 0) {
    stop("No valid WoS files could be imported")
  }
  
  do.call(rbind, all_dfs)
}


#' Import ACM DL BibTeX
#' @param path Path to ACM BibTeX file
#' @return Data frame with ACM records
#' @export
import_acm <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  
  records <- list()
  current <- NULL
  
  for (line in lines) {
    line <- trimws(line)
    
    if (grepl("^@\\w+", line)) {
      if (!is.null(current) && length(current) > 0) records[[length(records) + 1]] <- current
      current <- list()
      next
    }
    
    if (is.null(current)) next
    
    if (grepl("^}$", line)) {
      records[[length(records) + 1]] <- current
      current <- NULL
      next
    }
    
    if (grepl("^\\w+", line)) {
      parts <- strsplit(line, "=")[[1]]
      if (length(parts) >= 2) {
        field <- trimws(parts[1])
        value <- paste(trimws(parts[-1]), collapse = "=")
        value <- gsub("[{},]", "", value)
        value <- gsub("^\"|\"$", "", value)
        current[[toupper(field)]] <- value
      }
    }
  }
  
  if (length(records) == 0) return(data.frame())
  
  df <- data.frame(
    TI = sapply(records, function(x) ifelse(is.null(x$TITLE), NA, x$TITLE)),
    AU = sapply(records, function(x) ifelse(is.null(x$AUTHOR), NA, x$AUTHOR)),
    PY = sapply(records, function(x) {
      py <- x$YEAR
      if (is.null(py)) NA else as.integer(py)
    }),
    SO = sapply(records, function(x) ifelse(is.null(x$JOURNAL), ifelse(is.null(x$BOOKTITLE), NA, x$BOOKTITLE), x$JOURNAL)),
    DOI = sapply(records, function(x) ifelse(is.null(x$DOI), NA, x$DOI)),
    ID = NA,
    AB = sapply(records, function(x) ifelse(is.null(x$ABSTRACT), NA, x$ABSTRACT)),
    C1 = sapply(records, function(x) ifelse(is.null(x$AFFILIATION), NA, x$AFFILIATION)),
    TC = NA,
    DB = "ACM DL",
    stringsAsFactors = FALSE
  )
  
  df
}


#' Import PubMed text export
#' @param path Path to PubMed text export file
#' @return Data frame with PubMed records
#' @export
import_pubmed <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  lines <- readLines(path, warn = FALSE)
  
  records <- list()
  current <- NULL
  
  for (line in lines) {
    if (startsWith(line, "PMID-")) {
      if (!is.null(current) && length(current) > 0) records[[length(records) + 1]] <- current
      current <- list()
      current$PMID <- trimws(sub("PMID-", "", line))
    } else if (startsWith(line, "TI  -")) {
      current$TI <- trimws(sub("TI  -", "", line))
    } else if (startsWith(line, "AU  -")) {
      au <- trimws(sub("AU  -", "", line))
      current$AU <- if (is.null(current$AU)) au else paste(current$AU, au, sep = "; ")
    } else if (startsWith(line, "DP  -")) {
      dp <- trimws(sub("DP  -", "", line))
      current$PY <- as.integer(sub(".*(\\d{4}).*", "\\1", dp))
    } else if (startsWith(line, "JT  -") || startsWith(line, "TA  -")) {
      current$SO <- trimws(sub("JT  -|TA  -", "", line))
    } else if (startsWith(line, "AB  -")) {
      current$AB <- trimws(sub("AB  -", "", line))
    } else if (startsWith(line, "AD  -")) {
      current$C1 <- trimws(sub("AD  -", "", line))
    } else if (startsWith(line, "LID-")) {
      lid <- trimws(sub("LID-", "", line))
      if (grepl("doi", lid, ignore.case = TRUE)) {
        current$DOI <- sub(".*(10\\..*).*", "\\1", lid)
      }
    }
  }
  if (!is.null(current) && length(current) > 0) records[[length(records) + 1]] <- current
  
  if (length(records) == 0) return(data.frame())
  
  df <- data.frame(
    TI = sapply(records, function(x) ifelse(is.null(x$TI), NA, x$TI)),
    AU = sapply(records, function(x) ifelse(is.null(x$AU), NA, x$AU)),
    PY = sapply(records, function(x) ifelse(is.null(x$PY), NA, x$PY)),
    SO = sapply(records, function(x) ifelse(is.null(x$SO), NA, x$SO)),
    DOI = sapply(records, function(x) ifelse(is.null(x$DOI), NA, x$DOI)),
    ID = sapply(records, function(x) ifelse(is.null(x$PMID), NA, x$PMID)),
    AB = sapply(records, function(x) ifelse(is.null(x$AB), NA, x$AB)),
    C1 = sapply(records, function(x) ifelse(is.null(x$C1), NA, x$C1)),
    TC = NA,
    DB = "PubMed",
    stringsAsFactors = FALSE
  )
  
  df
}


#' Auto-detect file format and import
#' @param path Path to file
#' @return Data frame with imported records
#' @export
import_file <- function(path) {
  ext <- tolower(tools::file_ext(path))
  filename <- tolower(basename(path))
  
  # BibTeX files
  if (ext == "bib") {
    if (grepl("acm", filename)) {
      return(import_acm(path))
    } else {
      return(import_wos(path))
    }
  }
  
  # CSV files - detect format from content/filename
  if (ext == "csv") {
    # Check first line for column names
    first_line <- names(read.csv(path, nrows = 1, stringsAsFactors = FALSE))
    
    if (any(grepl("Document Title|IEEE", first_line[1], ignore.case = TRUE))) {
      return(import_ieee(path))
    } else if (any(grepl("PMID|pubmed", first_line[1], ignore.case = TRUE))) {
      return(import_pubmed_csv(path))
    } else if (any(grepl("scopus", filename))) {
      return(import_scopus(path))
    } else {
      # Default to Scopus format
      return(import_scopus(path))
    }
  }
  
  # PubMed text format
  if (ext == "txt") {
    return(import_pubmed(path))
  }
  
  stop(paste("Unsupported file format:", ext))
}


#' Import multiple database exports and merge
#' @param sources Named list with database names as keys and file paths as values
#' @param remove_duplicates Logical; remove duplicates after merging
#' @return Merged data frame with all records
#' @export
import_databases <- function(sources, remove_duplicates = TRUE) {
  
  valid_sources <- c("wos", "scopus", "pubmed", "ieee", "acm", "pubmed_csv")
  
  dfs <- list()
  
  for (db_name in names(sources)) {
    if (!(db_name %in% valid_sources)) {
      warning(paste("Unknown database:", db_name))
      next
    }
    
    message(paste("Importing", db_name, "..."))
    
    tryCatch({
      if (db_name == "wos") {
        dfs[[db_name]] <- import_wos(sources[[db_name]])
      } else if (db_name == "scopus") {
        dfs[[db_name]] <- import_scopus(sources[[db_name]])
      } else if (db_name == "pubmed") {
        dfs[[db_name]] <- import_pubmed(sources[[db_name]])
      } else if (db_name == "pubmed_csv") {
        dfs[[db_name]] <- import_pubmed_csv(sources[[db_name]])
      } else if (db_name == "ieee") {
        dfs[[db_name]] <- import_ieee(sources[[db_name]])
      } else if (db_name == "acm") {
        dfs[[db_name]] <- import_acm(sources[[db_name]])
      }
      
      if (!is.null(dfs[[db_name]]) && nrow(dfs[[db_name]]) > 0) {
        message(paste("  Imported", nrow(dfs[[db_name]]), "records from", db_name))
      }
    }, error = function(e) {
      warning(paste("Error importing", db_name, ":", e$message))
    })
  }
  
  if (length(dfs) == 0) {
    stop("No databases could be imported")
  }
  
  # Ensure all data frames have the same columns
  std_cols <- c("TI", "AU", "PY", "SO", "DOI", "ID", "AB", "C1", "TC", "DB")
  
  for (i in seq_along(dfs)) {
    for (col in std_cols) {
      if (!(col %in% names(dfs[[i]]))) {
        dfs[[i]][[col]] <- NA
      }
    }
    dfs[[i]] <- dfs[[i]][, std_cols, drop = FALSE]
  }
  
  # Merge all databases
  merged <- do.call(rbind, dfs)
  
  message(paste("Total records before deduplication:", nrow(merged)))
  
  if (remove_duplicates) {
    merged <- deduplicate_records(merged)
  }
  
  merged
}

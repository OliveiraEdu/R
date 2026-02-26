#' Import Web of Science BibTeX files (base R)
#' @param paths Character vector of file paths to .bib files
#' @return Data frame with merged Web of Science records
#' @export
import_wos <- function(paths) {
  
  all_records <- list()
  
  for (path in paths) {
    if (!file.exists(path)) {
      warning(paste("File not found:", path))
      next
    }
    
    records <- parse_bibtex(path, "WoS")
    all_records[[length(all_records) + 1]] <- records
  }
  
  if (length(all_records) == 0) {
    stop("No valid WoS files could be imported")
  }
  
  do.call(rbind, all_records)
}


#' Parse BibTeX format (base R implementation)
parse_bibtex <- function(path, source = "Unknown") {
  lines <- readLines(path, warn = FALSE)
  
  records <- list()
  current_record <- NULL
  current_field <- NULL
  current_value <- NULL
  
  for (line in lines) {
    line <- trimws(line)
    
    if (grepl("^@\\w+", line)) {
      if (!is.null(current_record)) {
        records[[length(records) + 1]] <- current_record
      }
      current_record <- list(DB = source)
      next
    }
    
    if (is.null(current_record)) next
    
    if (grepl("^}$", line)) {
      records[[length(records) + 1]] <- current_record
      current_record <- NULL
      next
    }
    
    if (grepl("^\\w+", line)) {
      parts <- strsplit(line, "=")[[1]]
      if (length(parts) >= 2) {
        field <- trimws(parts[1])
        value <- paste(trimws(parts[-1]), collapse = "=")
        value <- gsub("[{},]", "", value)
        value <- gsub("^\"|\"$", "", value)
        current_record[[field]] <- value
      }
    }
  }
  
  if (length(records) == 0) return(data.frame())
  
  df <- do.call(rbind.data.frame, c(records, stringsAsFactors = FALSE))
  df
}


#' Import Scopus CSV export
#' @param path Path to Scopus CSV file
#' @return Data frame with Scopus records
#' @export
import_scopus <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE, quote = "\"")
  
  standardized <- data.frame(
    TI = df$Title,
    AU = df$Authors,
    PY = as.integer(df$Year),
    SO = df$`Source title`,
    DOI = df$DOI,
    ID = NA,
    AB = df$Abstract,
    C1 = df$Affiliations,
    TC = NA,
    DB = "Scopus",
    stringsAsFactors = FALSE
  )
  
  standardized
}


#' Import PubMed export (simplified)
#' @param path Path to PubMed text export file
#' @return Data frame with PubMed records
#' @export
import_pubmed <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  lines <- readLines(path, warn = FALSE)
  
  records <- list()
  current <- list()
  
  for (line in lines) {
    if (startsWith(line, "PMID-")) {
      if (length(current) > 0) records[[length(records) + 1]] <- current
      current <- list(DB = "PubMed")
      current$PMID <- trimws(sub("PMID-", "", line))
    } else if (startsWith(line, "TI  -")) {
      current$TI <- trimws(sub("TI  -", "", line))
    } else if (startsWith(line, "AU  -")) {
      current$AU <- paste0(ifelse(is.null(current$AU), "", current$AU), "; ", trimws(sub("AU  -", "", line)))
    } else if (startsWith(line, "DP  -")) {
      current$PY <- trimws(sub("DP  -", "", line))
    } else if (startsWith(line, "JT  -") || startsWith(line, "TA  -")) {
      current$SO <- trimws(sub("JT  -|TA  -", "", line))
    } else if (startsWith(line, "AB  -")) {
      current$AB <- trimws(sub("AB  -", "", line))
    } else if (startsWith(line, "AD  -")) {
      current$C1 <- trimws(sub("AD  -", "", line))
    }
  }
  records[[length(records) + 1]] <- current
  
  df <- do.call(rbind.data.frame, c(records, stringsAsFactors = FALSE))
  df
}


#' Import IEEE Xplore CSV
#' @param path Path to IEEE CSV file
#' @return Data frame with IEEE records
#' @export
import_ieee <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE)
  
  standardized <- data.frame(
    TI = df$Title,
    AU = df$Authors,
    PY = as.integer(df$Year),
    SO = df$`Conference Name`,
    DOI = df$DOI,
    ID = NA,
    AB = df$Abstract,
    C1 = df$Affiliations,
    TC = NA,
    DB = "IEEE Xplore",
    stringsAsFactors = FALSE
  )
  
  standardized$SO <- ifelse(is.na(standardized$SO), df$`Journal Name`, standardized$SO)
  
  standardized
}


#' Import ACM DL CSV
#' @param path Path to ACM CSV file
#' @return Data frame with ACM records
#' @export
import_acm <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE)
  
  standardized <- data.frame(
    TI = df$Title,
    AU = df$Authors,
    PY = as.integer(df$Year),
    SO = df$Journal,
    DOI = df$DOI,
    ID = NA,
    AB = df$Abstract,
    C1 = df$Affiliation,
    TC = NA,
    DB = "ACM DL",
    stringsAsFactors = FALSE
  )
  
  standardized
}


#' Import multiple database exports and merge
#' @param sources Named list with database names as keys and file paths as values
#' @param remove_duplicates Logical; remove duplicates after merging
#' @return Merged data frame with all records
#' @export
import_databases <- function(sources, remove_duplicates = TRUE) {
  
  valid_sources <- c("wos", "scopus", "pubmed", "ieee", "acm")
  import_funcs <- list(
    wos = import_wos,
    scopus = import_scopus,
    pubmed = import_pubmed,
    ieee = import_ieee,
    acm = import_acm
  )
  
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
      } else {
        dfs[[db_name]] <- import_funcs[[db_name]](sources[[db_name]])
      }
      message(paste("  Imported", nrow(dfs[[db_name]]), "records from", db_name))
    }, error = function(e) {
      warning(paste("Error importing", db_name, ":", e$message))
    })
  }
  
  if (length(dfs) == 0) {
    stop("No databases could be imported")
  }
  
  # Standardize column names before merging
  for (i in seq_along(dfs)) {
    if (!"DB" %in% names(dfs[[i]])) {
      dfs[[i]]$DB <- names(dfs)[i]
    }
  }
  
  # Merge all databases
  merged <- do.call(rbind, dfs)
  
  message(paste("Total records before deduplication:", nrow(merged)))
  
  if (remove_duplicates) {
    merged <- deduplicate_records(merged)
  }
  
  merged
}

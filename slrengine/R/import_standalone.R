#' Import Scopus CSV export (fixed)
#' @param path Path to Scopus CSV file
#' @return Data frame with Scopus records
#' @export
import_scopus <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE, quote = "\"", encoding = "UTF-8")
  
  # Map Scopus columns to standard format
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


#' Import PubMed export (fixed)
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
  
  # Standardize columns
  df <- data.frame(
    TI = sapply(records, function(x) ifelse(is.null(x$TI), NA, x$TI)),
    AU = sapply(records, function(x) ifelse(is.null(x$AU), NA, x$AU)),
    PY = sapply(records, function(x) ifelse(is.null(x$PY), NA, x$PY)),
    SO = sapply(records, function(x) ifelse(is.null(x$SO), NA, x$SO)),
    DOI = sapply(records, function(x) ifelse(is.null(x$DOI), NA, x$DOI)),
    ID = NA,
    AB = sapply(records, function(x) ifelse(is.null(x$AB), NA, x$AB)),
    C1 = sapply(records, function(x) ifelse(is.null(x$C1), NA, x$C1)),
    TC = NA,
    DB = "PubMed",
    stringsAsFactors = FALSE
  )
  
  df
}


#' Import Web of Science BibTeX files (fixed)
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
    
    lines <- readLines(path, warn = FALSE)
    
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
      SO = sapply(records, function(x) ifelse(is.null(x$JOURNAL), NA, x$JOURNAL)),
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
    SO = if ("Conference Name" %in% names(df)) df$`Conference Name` else NA,
    DOI = df$DOI,
    ID = NA,
    AB = df$Abstract,
    C1 = df$Affiliations,
    TC = NA,
    DB = "IEEE Xplore",
    stringsAsFactors = FALSE
  )
  
  if ("Journal Name" %in% names(df)) {
    standardized$SO <- ifelse(is.na(standardized$SO), df$`Journal Name`, standardized$SO)
  }
  
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

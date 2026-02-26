#' Import Web of Science BibTeX files
#' @param paths Character vector of file paths to .bib files
#' @return Data frame with merged Web of Science records
#' @export
import_wos <- function(paths) {
  if (!requireNamespace("bibliometrix", quietly = TRUE)) {
    stop("bibliometrix package required. Install with: install.packages('bibliometrix')")
  }
  
  dfs <- lapply(paths, function(p) {
    if (!file.exists(p)) {
      warning(paste("File not found:", p))
      return(NULL)
    }
    bibliometrix::convert2df(p, dbsource = "wos", format = "bibtex")
  })
  
  dfs <- Filter(Negate(is.null), dfs)
  
  if (length(dfs) == 0) {
    stop("No valid WoS files could be imported")
  }
  
  do.call(bibliometrix::mergeDbSources, dfs)
}


#' Import Scopus CSV export
#' @param path Path to Scopus CSV file
#' @return Data frame with Scopus records
#' @export
import_scopus <- function(path) {
  if (!requireNamespace("bibliometrix", quietly = TRUE)) {
    stop("bibliometrix package required")
  }
  
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  bibliometrix::convert2df(path, dbsource = "scopus", format = "csv")
}


#' Import PubMed export
#' @param path Path to PubMed text export file
#' @return Data frame with PubMed records
#' @export
import_pubmed <- function(path) {
  if (!requireNamespace("bibliometrix", quietly = TRUE)) {
    stop("bibliometrix package required")
  }
  
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  bibliometrix::convert2df(path, dbsource = "pubmed", format = "pubmed")
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

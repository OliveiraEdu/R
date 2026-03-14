#' Import Scopus CSV export
#' @param path Path to Scopus CSV file
#' @return Data frame with Scopus records
#' @export
import_scopus <- function(path) {
  if (!file.exists(path)) {
    stop(paste("File not found:", path))
  }
  
  df <- read.csv(path, stringsAsFactors = FALSE, fill = TRUE, header = TRUE, quote = "\"", encoding = "UTF-8", colClasses = "character")
  
  # Map Scopus columns to standard format (handles multiple column name variations)
  get_col <- function(df, names_vec) {
    for (nm in names_vec) {
      if (nm %in% names(df)) return(df[[nm]])
      # Try with dots replaced by spaces and vice versa
      nm_dot <- gsub(" ", ".", nm)
      nm_space <- gsub("\\.", " ", nm)
      if (nm_dot %in% names(df)) return(df[[nm_dot]])
      if (nm_space %in% names(df)) return(df[[nm_space]])
    }
    NA
  }
  
   standardized <- data.frame(
      TI = get_col(df, c("Title")),
      AU = get_col(df, c("Authors")),
      PY = as.integer(get_col(df, c("Year"))),
      SO = get_col(df, c("Source title", "Source.title")),
      DOI = get_col(df, c("DOI")),
      ID = as.character(get_col(df, c("EID"))),
      AB = get_col(df, c("Abstract")),
      C1 = get_col(df, c("Affiliations")),
      TC = as.integer(get_col(df, c("Cited by", "Cited.by"))),
      DB = "Scopus",
      LA = NA,
      OA = get_col(df, c("Open Access", "Open.Access")),
      PT = get_col(df, c("Document Type", "Document.Type")),
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
  get_col_pm <- function(df, names_vec) {
    for (nm in names_vec) {
      if (nm %in% names(df)) return(df[[nm]])
    }
    NA
  }
  
  standardized <- data.frame(
    TI = get_col_pm(df, c("Title")),
    AU = get_col_pm(df, c("Authors")),
    PY = as.integer(get_col_pm(df, c("Publication.Year", "Publication Year"))),
    SO = get_col_pm(df, c("Journal.Book", "Journal/Book")),
    DOI = get_col_pm(df, c("DOI")),
    ID = as.character(get_col_pm(df, c("PMID"))),
    AB = NA,
    C1 = NA,
    TC = NA,
    DB = "PubMed",
    LA = get_col_pm(df, c("Language")),
    OA = NA,
    PT = get_col_pm(df, c("Publication Type")),
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
  get_col_ieee <- function(df, names_vec) {
    for (nm in names_vec) {
      if (nm %in% names(df)) return(df[[nm]])
      # Try with dots replaced by spaces and vice versa
      nm_dot <- gsub(" ", ".", nm)
      nm_space <- gsub("\\.", " ", nm)
      if (nm_dot %in% names(df)) return(df[[nm_dot]])
      if (nm_space %in% names(df)) return(df[[nm_space]])
    }
    NA
  }
  
  standardized <- data.frame(
    TI = get_col_ieee(df, c("Document Title")),
    AU = get_col_ieee(df, c("Authors")),
    PY = as.integer(get_col_ieee(df, c("Publication Year"))),
    SO = get_col_ieee(df, c("Publication Title")),
    DOI = get_col_ieee(df, c("DOI")),
    ID = as.character(get_col_ieee(df, c("KEY", "DOI", "Document Number"))),
    AB = get_col_ieee(df, c("Abstract")),
    C1 = get_col_ieee(df, c("Author Affiliations")),
    TC = as.integer(get_col_ieee(df, c("Article Citation Count"))),
    DB = "IEEE Xplore",
    LA = NA,
    OA = NA,
    PT = NA,
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
       ID = as.character(sapply(records, function(x) ifelse(is.null(x$KEY), NA, x$KEY))),
      AB = sapply(records, function(x) ifelse(is.null(x$ABSTRACT), NA, x$ABSTRACT)),
      C1 = sapply(records, function(x) ifelse(is.null(x$AFFILIATION), NA, x$AFFILIATION)),
      TC = sapply(records, function(x) {
        tc <- x$TIMES.CITED
        if (is.null(tc)) NA else as.integer(tc)
      }),
      DB = "WoS",
      LA = sapply(records, function(x) ifelse(is.null(x$LANGUAGE), NA, x$LANGUAGE)),
      OA = sapply(records, function(x) ifelse(is.null(x$OA), NA, x$OA)),
      PT = sapply(records, function(x) ifelse(is.null(x$TYPE), NA, x$TYPE)),
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
     ID = as.character(sapply(records, function(x) ifelse(is.null(x$KEY), NA, x$KEY))),
    AB = sapply(records, function(x) ifelse(is.null(x$ABSTRACT), NA, x$ABSTRACT)),
    C1 = sapply(records, function(x) ifelse(is.null(x$AFFILIATION), NA, x$AFFILIATION)),
    TC = NA,
    DB = "ACM DL",
    LA = NA,
    OA = NA,
    PT = NA,
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
    ID = as.character(sapply(records, function(x) ifelse(is.null(x$PMID), NA, x$PMID))),
    AB = sapply(records, function(x) ifelse(is.null(x$AB), NA, x$AB)),
    C1 = sapply(records, function(x) ifelse(is.null(x$C1), NA, x$C1)),
    TC = NA,
    DB = "PubMed",
    LA = NA,
    OA = NA,
    PT = NA,
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
#' @param config_path Path to config.yaml file (optional)
#' @return Merged data frame with all records
#' @export
import_databases <- function(sources, remove_duplicates = TRUE, config_path = "config.yaml") {
   
# Load config.yaml if provided
config <- tryCatch({
  yaml::read_yaml(config_path)
}, error = function(e) {
  warning(paste("Could not load config.yaml:", e$message, "Importing all databases anyway"))
  list()
})

# Define valid database sources
valid_sources <- c("arxiv", "ieee", "acm", "scopus", "wos", "pubmed", "biorxiv", "pubmed_csv")

# Check if config exists and has sources
if (is.list(config) && "sources" %in% names(config) && length(config$sources) > 0) {
  # Create enabled status for each database from config
  # config$sources is a list of named lists, each with $enabled field
  enabled_dbs <- sapply(names(config$sources), function(db) {
    if (db %in% names(config$sources)) {
      config$sources[[db]]$enabled
    } else {
      # Database not in config, assume enabled
      TRUE
    }
  })
  
  # Check each database before importing
  for (db_name in names(sources)) {
    if (!(db_name %in% valid_sources)) {
      warning(paste("Unknown database:", db_name))
      next
    }
    
    # Check if database is enabled in config
    db_enabled <- enabled_dbs[db_name]
    if (!isTRUE(db_enabled)) {
      message(paste("Skipping disabled database:", db_name))
      next
    }
  }
}
  
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
  std_cols <- c("TI", "AU", "PY", "SO", "DOI", "ID", "AB", "C1", "TC", "DB", 
                "LA", "OA", "PT")
  
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

#' Data extraction module for included studies
#' @param df Data frame with included studies
#' @return Data frame with extracted data
#' @export
extract_data <- function(df) {
  
  n <- nrow(df)
  
  # Initialize extraction columns
  extraction <- data.frame(
    Study_ID = paste0("REV", sprintf("%03d", 1:n)),
    stringsAsFactors = FALSE
  )
  
  # Basic bibliographic info
  extraction$Title <- df$TI
  extraction$Authors <- sapply(df$AU, function(x) {
    if (is.na(x) || x == "") return(NA)
    authors <- strsplit(x, ",")[[1]]
    if (length(authors) > 0) return(paste0(authors[1], " et al."))
    NA
  })
  extraction$Year <- df$PY
  extraction$Source <- df$SO
  extraction$DOI <- df$DOI
  extraction$URL <- df$URL
  
  # Research Focus
  extraction$Research_Focus <- sapply(df$TI, function(ti) {
    if (is.na(ti)) return("Unknown")
    ti_lower <- tolower(ti)
    focus <- c()
    if (any(grepl("blockchain|distributed ledger", ti_lower))) focus <- c(focus, "Blockchain")
    if (any(grepl("provenance|data lineage|chain of custody", ti_lower))) focus <- c(focus, "Provenance")
    if (any(grepl("madmp|data management plan|dmp", ti_lower))) focus <- c(focus, "maDMP")
    if (length(focus) == 0) focus <- "Other"
    paste(focus, collapse = "; ")
  })
  
  # System Name (extract from title if mentioned)
  extraction$System_Name <- sapply(df$TI, function(ti) {
    if (is.na(ti)) return(NA)
    # Common blockchain provenance systems
    systems <- c("Hyperledger", "Fabric", "Iroha", "Ethereum", "ChainAnchor", 
                 "Provenance", "OpenProvenance", "W3C PROV", "IPFS", "BigchainDB")
    found <- systems[sapply(systems, function(s) grepl(s, ti, ignore.case = TRUE))]
    if (length(found) > 0) paste(found, collapse = ", ") else NA
  })
  
  # Blockchain Platform
  extraction$Blockchain_Platform <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not specified")
    text_lower <- tolower(text)
    platforms <- c()
    if (any(grepl("hyperledger fabric|fabric", text_lower))) platforms <- c(platforms, "Fabric")
    if (any(grepl("hyperledger iroha|iroha", text_lower))) platforms <- c(platforms, "Iroha")
    if (any(grepl("ethereum", text_lower))) platforms <- c(platforms, "Ethereum")
    if (any(grepl("hyperledger", text_lower))) platforms <- c(platforms, "Hyperledger")
    if (any(grepl("bigchaindb", text_lower))) platforms <- c(platforms, "BigchainDB")
    if (any(grepl("multichain", text_lower))) platforms <- c(platforms, "Multi-chain")
    if (length(platforms) == 0) platforms <- "Not specified"
    paste(unique(platforms), collapse = "; ")
  })
  
  # Provenance Model
  extraction$Provenance_Model <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not specified")
    text_lower <- tolower(text)
    models <- c()
    if (any(grepl("prov-o|w3c prov|prov model", text_lower))) models <- c(models, "PROV-O")
    if (any(grepl("prov-dm|prov-dm", text_lower))) models <- c(models, "PROV-DM")
    if (any(grepl("opm|open provenance model", text_lower))) models <- c(models, "OPM")
    if (any(grepl("custom|proprietary", text_lower))) models <- c(models, "Custom")
    if (length(models) == 0) models <- "None"
    paste(unique(models), collapse = "; ")
  })
  
  # maDMP Support
  extraction$maDMP_Support <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("None")
    text_lower <- tolower(text)
    if (any(grepl("madmp|rdamp|data management plan", text_lower))) {
      if (any(grepl("full|complete|implement", text_lower))) return("Full")
      return("Partial")
    }
    "None"
  })
  
  # Evaluation Method
  extraction$Evaluation_Method <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not clear")
    text_lower <- tolower(text)
    methods <- c()
    if (any(grepl("experiment|performance evaluation|benchmark", text_lower))) methods <- c(methods, "Experiment")
    if (any(grepl("case study", text_lower))) methods <- c(methods, "Case study")
    if (any(grepl("user study|user evaluation|survey", text_lower))) methods <- c(methods, "User study")
    if (any(grepl("proof of concept|demonstration|poc", text_lower))) methods <- c(methods, "Proof of concept")
    if (length(methods) == 0) methods <- "Not clear"
    paste(unique(methods), collapse = "; ")
  })
  
  # Key Findings (placeholder - manual extraction required)
  extraction$Key_Findings <- NA
  
  # Limitations (placeholder - manual extraction required)
  extraction$Limitations <- NA
  
  # Quality Score (placeholder for MMAT)
  extraction$Quality_Score <- NA
  
  extraction
}


#' Export extraction form for manual completion
#' @param extraction Data frame from extract_data()
#' @param path Output file path
#' @export
export_extraction_form <- function(extraction, path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
  writexl::write_xlsx(extraction, path)
  message(paste("Exported extraction form to:", path))
}


#' Import completed extraction form
#' @param path Path to completed Excel file
#' @return Data frame with extracted data
#' @export
import_extraction_data <- function(path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
  df <- readxl::read_excel(path)
  message(paste("Imported extraction data from:", path))
  df
}


#' Generate summary statistics of extracted data
#' @param extraction Data frame from extract_data()
#' @return List with summary statistics
#' @export
extraction_summary <- function(extraction) {
  list(
    total_studies = nrow(extraction),
    by_year = table(extraction$Year, useNA = "ifany"),
    by_research_focus = table(extraction$Research_Focus, useNA = "ifany"),
    by_blockchain_platform = table(extraction$Blockchain_Platform, useNA = "ifany"),
    by_provenance_model = table(extraction$Provenance_Model, useNA = "ifany"),
    by_madmp_support = table(extraction$maDMP_Support, useNA = "ifany"),
    by_evaluation = table(extraction$Evaluation_Method, useNA = "ifany")
  )
}

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
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    focus <- c()
    keywords <- config$PICOC_criteria$Provenance$keywords
    if (any(sapply(keywords, function(k) grepl(k, ti_lower, ignore.case = TRUE)))) focus <- c(focus, "Provenance")
    keywords <- config$PICOC_criteria$Blockchain_Platform$keywords
    if (any(sapply(keywords, function(k) grepl(k, ti_lower, ignore.case = TRUE)))) focus <- c(focus, "Blockchain")
    keywords <- config$PICOC_criteria$maDMP_Support$keywords
    if (any(sapply(keywords, function(k) grepl(k, ti_lower, ignore.case = TRUE)))) focus <- c(focus, "maDMP")
    if (length(focus) == 0) focus <- "Other"
    paste(focus, collapse = "; ")
  })
  
  # System Name (extract from title if mentioned)
  extraction$System_Name <- sapply(df$TI, function(ti) {
    if (is.na(ti)) return(NA)
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    systems <- config$PICOC_criteria$System_Name$keywords
    found <- systems[sapply(systems, function(s) grepl(s, ti, ignore.case = TRUE))]
    if (length(found) > 0) paste(found, collapse = ", ") else NA
  })
  
  # Blockchain Platform
  extraction$Blockchain_Platform <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not specified")
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    platforms <- config$PICOC_criteria$Blockchain_Platform$keywords
    text_lower <- tolower(text)
    detected <- c()
    for (p in platforms) {
      if (any(grepl(p, text_lower, ignore.case = TRUE))) detected <- c(detected, p)
    }
    if (length(detected) == 0) detected <- "Not specified"
    paste(detected, collapse = "; ")
  })
  
  # Storage Integration (Protocol 4.0)
  extraction$Storage_Integration <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not specified")
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    text_lower <- tolower(text)
    storage <- c()
    keywords <- config$PICOC_criteria$Storage_Integration$keywords
    if (any(sapply(keywords, function(k) grepl(k, text_lower, ignore.case = TRUE)))) {
      # Check for IPFS + blockchain combination
      if (any(grepl("blockchain", text_lower)) && any(grepl("ipfs", text_lower))) {
        storage <- c(storage, "IPFS + blockchain")
      } else if (any(grepl("ipfs", text_lower))) {
        storage <- c(storage, "IPFS")
      }
    }
    # Check for external database
    if (any(grepl("external database|external db|off-chain|database", text_lower))) {
      storage <- c(storage, "External DB")
    }
    # Check for OrbitDB
    if (any(grepl("orbitdb", text_lower))) {
      storage <- c(storage, "OrbitDB")
    }
    # Check for Hybrid (using config keywords)
    if (any(grepl("hybrid", text_lower)) && any(sapply(config$PICOC_criteria$Storage_Integration$keywords, function(k) grepl(k, text_lower, ignore.case = TRUE)))) {
      storage <- c(storage, "Hybrid")
    }
    if (length(storage) == 0) storage <- "Not specified"
    paste(unique(storage), collapse = "; ")
  })
  
  # Permission Model (Protocol 4.0)
  extraction$Permission_Model <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not specified")
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    text_lower <- tolower(text)
    model <- c()
    keywords <- config$PICOC_criteria$Permission_Model$keywords
    if (any(grepl(keywords, text_lower, ignore.case = TRUE))) {
      # Check for permissioned blockchain platforms
      if (any(grepl("fabric|iroha|corda|hyperledger", text_lower))) {
        model <- c(model, "Permissioned")
      }
    }
    # Check for permissionless/public blockchain
    if (any(grepl("permissionless|public.*blockchain|unlicensed", text_lower))) {
      if (!any(grepl("private|permissioned", text_lower))) {
        model <- c(model, "Permissionless")
      }
    }
    # Check for hybrid blockchain (using config keywords)
    if (any(grepl("hybrid", text_lower)) && any(sapply(config$PICOC_criteria$Permission_Model$keywords, function(k) grepl(k, text_lower, ignore.case = TRUE)))) {
      model <- c(model, "Hybrid")
    }
    if (length(model) == 0) model <- "Not specified"
    paste(unique(model), collapse = "; ")
  })
  
  # Provenance Model
  extraction$Provenance_Model <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not specified")
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    text_lower <- tolower(text)
    models <- c()
    keywords <- config$PICOC_criteria$Provenance_Model$keywords
    if (any(grepl(keywords, text_lower, ignore.case = TRUE))) {
      # Check for PROV-O
      if (any(grepl("prov-o|w3c prov|prov model", text_lower))) {
        models <- c(models, "PROV-O")
      }
      # Check for PROV-DM
      if (any(grepl("prov-dm", text_lower))) {
        models <- c(models, "PROV-DM")
      }
      # Check for OPM
      if (any(grepl("opm|open provenance model", text_lower))) {
        models <- c(models, "OPM")
      }
      # Check for custom/proprietary
      if (any(grepl("custom|proprietary", text_lower))) {
        models <- c(models, "Custom")
      }
    }
    if (length(models) == 0) models <- "None"
    paste(unique(models), collapse = "; ")
  })
  
  # maDMP Support
  extraction$maDMP_Support <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("None")
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    text_lower <- tolower(text)
    keywords <- config$PICOC_criteria$maDMP_Support$keywords
    if (any(grepl(keywords, text_lower, ignore.case = TRUE))) {
      if (any(grepl("full|complete|implement", text_lower))) return("Full")
      return("Partial")
    }
    "None"
  })
  
  # Evaluation Method
  extraction$Evaluation_Method <- sapply(paste(df$TI, df$AB), function(text) {
    if (is.na(text)) return("Not clear")
    config <- yaml::read_yaml("/workspaces/R/slrengine/config.yaml")
    text_lower <- tolower(text)
    methods <- c()
    keywords <- config$PICOC_criteria$Evaluation_Method$keywords
    if (any(grepl(keywords, text_lower, ignore.case = TRUE))) {
      # Check for experiment/performance evaluation/benchmark
      if (any(grepl("experiment|performance evaluation|benchmark", text_lower))) {
        methods <- c(methods, "Experiment")
      }
      # Check for case study
      if (any(grepl("case study", text_lower))) {
        methods <- c(methods, "Case study")
      }
      # Check for user study/evaluation/survey
      if (any(grepl("user study|user evaluation|survey", text_lower))) {
        methods <- c(methods, "User study")
      }
      # Check for proof of concept/demonstration
      if (any(grepl("proof of concept|demonstration|poc", text_lower))) {
        methods <- c(methods, "Proof of concept")
      }
    }
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
  write.csv(extraction, path, fileEncoding = "UTF-8", row.names = FALSE)
  message(paste("Exported extraction form to:", path))
}


#' Import completed extraction form
#' @param path Path to completed CSV file
#' @return Data frame with extracted data
#' @export
import_extraction_data <- function(path) {
  df <- read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
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
    by_storage_integration = table(extraction$Storage_Integration, useNA = "ifany"),
    by_permission_model = table(extraction$Permission_Model, useNA = "ifany"),
    by_provenance_model = table(extraction$Provenance_Model, useNA = "ifany"),
    by_madmp_support = table(extraction$maDMP_Support, useNA = "ifany"),
    by_evaluation = table(extraction$Evaluation_Method, useNA = "ifany")
  )
}

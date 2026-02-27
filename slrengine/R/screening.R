#' Apply eligibility criteria for screening
#' @param df Data frame with bibliographic records
#' @param criteria List of inclusion/exclusion criteria functions
#' @return Data frame with screening results added
#' @export
apply_eligibility_criteria <- function(df, criteria = NULL) {
  
  if (is.null(criteria)) {
    criteria <- get_default_criteria()
  }
  
  if (!"TI" %in% names(df)) df$TI <- ""
  if (!"AB" %in% names(df)) df$AB <- ""
  if (!"PY" %in% names(df)) df$PY <- NA
  if (!"SO" %in% names(df)) df$SO <- ""
  
  df$screening_id <- seq_len(nrow(df))
  df$screening_status <- "include"  # Default to include
  df$screening_notes <- ""
  df$screening_reason <- ""
  
  # Apply each criterion - exclude if ANY criterion fails
  for (criterion_fn in criteria) {
    result <- criterion_fn(df)
    
    # Update status for records that fail this criterion
    failed_ids <- which(!result$include)
    if (length(failed_ids) > 0) {
      df$screening_status[failed_ids] <- "exclude"
      df$screening_reason[failed_ids] <- result$reason
    }
  }
  
  df
}


#' Default eligibility criteria from PRISMA protocol
#' @param protocol_version Protocol version ("1.0" or "3.0")
#' @return List of criteria functions
get_default_criteria <- function(protocol_version = "1.0") {
  
  if (protocol_version == "3.0") {
    return(get_protocol_3_criteria())
  }
  
  list(
    # I1: English language
    function(df) {
      lang <- df$LA
      include <- is.na(lang) | tolower(lang) == "en"
      list(include = include, reason = "I1: Language")
    },
    
    # I2: Publication type (journal, conference, arXiv)
    function(df) {
      source <- tolower(df$SO)
      pt <- tolower(df$PT)
      include <- (!is.na(source) & source != "") | tolower(pt) %in% c("j", "c", "p")
      list(include = include, reason = "I2: Publication type")
    },
    
    # I3: Date range 2018-2026
    function(df) {
      year <- as.integer(df$PY)
      include <- !is.na(year) & year >= 2018 & year <= 2026
      list(include = include, reason = "I3: Date range")
    },
    
    # I4: Technical implementation
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      keywords <- c("blockchain", "distributed ledger", "provenance", "data lineage",
                    "reproducibility", "verification", "smart contract", "ipfs",
                    "dmps?", "data management plan", "fair", "metadata")
      pattern <- paste(keywords, collapse = "|")
      include <- grepl(pattern, tolower(text), perl = TRUE)
      list(include = include, reason = "I4: Technical implementation")
    },
    
    # I5: Domain relevance
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      keywords <- c("scientific", "research data", "data management",
                    "provenance", "metadata", "reproducibility", "data sharing",
                    "genomics", "climate", "lifecycle", "workflow", "dataset")
      pattern <- paste(keywords, collapse = "|")
      include <- grepl(pattern, tolower(text), perl = TRUE)
      list(include = include, reason = "I5: Domain relevance")
    },
    
    # E1: Exclude opinion pieces
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      exclude <- grepl("editorial|opinion|commentary|perspective",
                      tolower(text), perl = TRUE)
      list(include = !exclude, reason = "E1: Opinion piece")
    },
    
    # E2: Exclude non-research contexts
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      exclude <- grepl("supply chain|financial|bitcoin|cryptocurrency|trading|banking",
                      tolower(text), perl = TRUE)
      list(include = !exclude, reason = "E2: Non-research context")
    }
  )
}


#' Protocol 3.0 eligibility criteria (broader search)
get_protocol_3_criteria <- function() {
  list(
    # I1: English language
    function(df) {
      lang <- df$LA
      include <- is.na(lang) | tolower(lang) == "en"
      list(include = include, reason = "I1: Language")
    },
    
    # I2: Publication type - include preprints (arXiv, bioRxiv)
    function(df) {
      source <- tolower(df$SO)
      pt <- tolower(df$PT)
      is_preprint <- tolower(source) %in% c("arxiv", "biorxiv", "medrxiv")
      include <- (!is.na(source) & source != "") | 
                 tolower(pt) %in% c("j", "c", "p") |
                 is_preprint
      list(include = include, reason = "I2: Publication type (incl. preprints)")
    },
    
    # I3: Date range 2018-2026
    function(df) {
      year <- as.integer(df$PY)
      include <- !is.na(year) & year >= 2018 & year <= 2026
      list(include = include, reason = "I3: Date range")
    },
    
    # I4: Technical implementation (broader for Protocol 3.0)
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      keywords <- c("blockchain", "distributed ledger", "DLT", "smart contract",
                    "IPFS", "provenance", "data lineage", "immutable",
                    "tamper-evident", "data management", "FAIR", "metadata",
                    "reproducibility", "verification", "integrity")
      pattern <- paste(keywords, collapse = "|")
      include <- grepl(pattern, tolower(text), perl = TRUE)
      list(include = include, reason = "I4: Technical implementation")
    },
    
    # I5: Domain relevance (broader for scientific data)
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      keywords <- c("scientific data", "research data", "scholarly data",
                    "data management", "data sharing", "data repository",
                    "open science", "open data", "provenance", "metadata",
                    "genomics", "climate", "workflow", "dataset", "maDMP",
                    "data management plan", "DMP")
      pattern <- paste(keywords, collapse = "|")
      include <- grepl(pattern, tolower(text), perl = TRUE)
      list(include = include, reason = "I5: Domain relevance")
    },
    
    # E1: Exclude opinion pieces
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      exclude <- grepl("editorial|opinion|commentary|perspective",
                      tolower(text), perl = TRUE)
      list(include = !exclude, reason = "E1: Opinion piece")
    },
    
    # E2: Exclude non-research contexts
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      exclude <- grepl("supply chain|financial|bitcoin|cryptocurrency|trading|banking",
                      tolower(text), perl = TRUE)
      list(include = !exclude, reason = "E2: Non-research context")
    },
    
    # E3: Preprint flag (mark but don't exclude)
    function(df) {
      source <- tolower(df$SO)
      is_preprint <- source %in% c("arxiv", "biorxiv", "medrxiv")
      # Mark preprints but don't exclude
      list(include = TRUE, reason = "E3: Preprint flag", is_preprint = is_preprint)
    }
  )
}


#' Manual title/abstract screening with reviewer tracking
#' @param df Data frame with records to screen
#' @param reviewers Character vector of reviewer names
#' @param output_path Path to save screening results
#' @param protocol_version Protocol version ("1.0" or "3.0")
#' @return Data frame with screening decisions
#' @export
title_abstract_screening <- function(df, reviewers = c("Reviewer1", "Reviewer2"), 
                                     output_path = NULL,
                                     protocol_version = "1.0") {
  
  # Ensure required columns exist
  if (!"TI" %in% names(df)) df$TI <- NA
  if (!"AU" %in% names(df)) df$AU <- NA
  if (!"PY" %in% names(df)) df$PY <- NA
  if (!"SO" %in% names(df)) df$SO <- NA
  if (!"DOI" %in% names(df)) df$DOI <- NA
  if (!"AB" %in% names(df)) df$AB <- NA
  if (!"DB" %in% names(df)) df$DB <- NA
  
  df$screening_id <- seq_len(nrow(df))
  
  # Initialize screening columns for each reviewer
  for (reviewer in reviewers) {
    df[[paste0("screening_", reviewer)]] <- NA
  }
  df$screening_decision <- NA
  df$screening_disagreement <- FALSE
  df$screening_notes <- ""
  df$is_preprint <- df$DB %in% c("arXiv", "bioRxiv", "medRxiv")
  
  # For automated screening, apply criteria based on protocol version
  df <- apply_eligibility_criteria(df, get_default_criteria(protocol_version))
  
  # Mark initial decision based on screening_status
  df$screening_decision <- ifelse(is.na(df$screening_status) | df$screening_status == "include", "include", "exclude")
  
  if (!is.null(output_path)) {
    saveRDS(df, output_path)
    message(paste("Screening results saved to:", output_path))
  }
  
  attr(df, "reviewers") <- reviewers
  df
}


#' Export screening results for manual review
#' @param df Screened data frame
#' @param path Output file path (.xlsx)
#' @export
export_screening_results <- function(df, path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required. Install with: install.packages('writexl')")
  }
  
  # Select relevant columns
  cols <- c("screening_id", "TI", "AU", "PY", "SO", "DOI", "AB",
            "screening_decision", "screening_reason", "screening_notes")
  cols <- cols[cols %in% names(df)]
  
  export_df <- df[, cols, drop = FALSE]
  
  # Export as UTF-8 CSV
  write.csv(export_df, path, fileEncoding = "UTF-8", row.names = FALSE)
  message(paste("Exported to:", path))
}


#' Calculate screening statistics
#' @param df Screened data frame
#' @return List with screening statistics
#' @export
screening_statistics <- function(df) {
  if (!"screening_decision" %in% names(df)) {
    stop("Data frame must have screening decisions")
  }
  
  total <- nrow(df)
  included <- sum(df$screening_decision == "include", na.rm = TRUE)
  excluded <- sum(df$screening_decision == "exclude", na.rm = TRUE)
  
  list(
    total_records = total,
    included = included,
    excluded = excluded,
    inclusion_rate = round(included / total * 100, 2)
  )
}

#' Full-text assessment workflow for SLR
#' @param df Data frame with records passing title/abstract screening
#' @param criteria Full-text eligibility criteria
#' @return Data frame with full-text assessment results
#' @export
fulltext_assessment <- function(df, criteria = NULL) {
  
  if (is.null(criteria)) {
    criteria <- get_fulltext_criteria()
  }
  
  df$fulltext_id <- seq_len(nrow(df))
  df$fulltext_status <- NA
  df$fulltext_reason <- ""
  df$fulltext_notes <- ""
  
  # Apply full-text criteria
  for (criterion in criteria) {
    result <- criterion(df)
    
    # Mark exclusions
    excluded_ids <- which(!result$include & is.na(df$fulltext_status))
    df$fulltext_status[excluded_ids] <- "exclude"
    df$fulltext_reason[excluded_ids] <- result$reason
  }
  
  # Default to include
  df$fulltext_status[is.na(df$fulltext_status)] <- "include"
  
  df
}


#' Full-text eligibility criteria
get_fulltext_criteria <- function() {
  list(
    # Must have technical implementation details
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      # Look for implementation indicators
      keywords <- c("system", "framework", "architecture", "implementation",
                    "prototype", "approach", "method", "algorithm", "protocol")
      pattern <- paste(keywords, collapse = "|")
      include <- grepl(pattern, tolower(text), perl = TRUE)
      list(include = include, reason = "E3: No technical implementation")
    },
    
    # Must address scientific/research data context
    function(df) {
      text <- paste0(df$TI, " ", df$AB)
      keywords <- c("scientific", "research", "data", "provenance",
                    "metadata", "workflow", "experiment", "dataset")
      pattern <- paste(keywords, collapse = "|")
      include <- grepl(pattern, tolower(text), perl = TRUE)
      list(include = include, reason = "E2: Non-research context")
    },
    
    # Check for duplicate (would be caught in deduplication)
    function(df) {
      # Already handled in deduplication
      list(include = rep(TRUE, nrow(df)), reason = "")
    }
  )
}


#' Export records for full-text retrieval
#' @param df Data frame with records to retrieve
#' @param path Output file path
#' @export
export_fulltext_list <- function(df, path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
  export_df <- data.frame(
    ID = seq_len(nrow(df)),
    Title = df$TI,
    Authors = df$AU,
    Year = df$PY,
    Journal = df$SO,
    DOI = df$DOI,
    URL = df$URL,
    stringsAsFactors = FALSE
  )
  
  write.csv(export_df, path, fileEncoding = "UTF-8", row.names = FALSE)
  message(paste("Exported", nrow(export_df), "records to:", path))
}


#' Import full-text assessment decisions
#' @param df Data frame
#' @param assessment_file Path to Excel file with assessment decisions
#' @return Updated data frame
#' @export
import_fulltext_decisions <- function(df, assessment_file) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
  decisions <- readxl::read_excel(assessment_file)
  
  # Merge decisions
  if ("fulltext_decision" %in% names(decisions)) {
    df$fulltext_status <- decisions$fulltext_status[match(seq_len(nrow(df)), decisions$ID)]
    df$fulltext_reason <- decisions$fulltext_reason[match(seq_len(nrow(df)), decisions$ID)]
  }
  
  df
}


#' Generate inclusion/exclusion log
#' @param df Data frame with screening and full-text decisions
#' @return Data frame with exclusion log
#' @export
generate_exclusion_log <- function(df) {
  excluded <- df[df$screening_decision == "exclude" | df$fulltext_status == "exclude", ]
  
  log <- data.frame(
    ID = seq_len(nrow(excluded)),
    Title = excluded$TI,
    DOI = excluded$DOI,
    Exclusion_Stage = ifelse(is.na(excluded$fulltext_status), "Title/Abstract", "Full-Text"),
    Reason = ifelse(is.na(excluded$fulltext_reason), excluded$screening_reason, excluded$fulltext_reason),
    stringsAsFactors = FALSE
  )
  
  log
}

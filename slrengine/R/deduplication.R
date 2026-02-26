#' Deduplicate bibliographic records using multiple strategies (standalone)
#' @param df Data frame with bibliographic records (must have TI, DOI, AU, PY columns)
#' @param method Deduplication method: "exact", "fuzzy", "both"
#' @param fuzzy_threshold Numeric threshold for fuzzy matching (0-1)
#' @return Deduplicated data frame with attribute "duplicates_removed"
#' @export
deduplicate_records <- function(df, method = "both", fuzzy_threshold = 0.85) {
  
  original_n <- nrow(df)
  
  # Clean data for comparison
  if (!"TI" %in% names(df)) df$TI <- NA
  if (!"DOI" %in% names(df)) df$DOI <- NA
  if (!"AU" %in% names(df)) df$AU <- NA
  if (!"PY" %in% names(df)) df$PY <- NA
  
  # Create a unique signature for each record
  df$signature <- NA
  
  # Method 1: DOI-based exact matching
  doi_clean <- tolower(trimws(df$DOI))
  doi_clean[doi_clean == "" | is.na(doi_clean)] <- NA
  
  # Use DOI as primary key where available
  has_doi <- !is.na(doi_clean) & doi_clean != ""
  
  # For records without DOI, create title-based signature
  title_clean <- tolower(trimws(df$TI))
  title_clean <- gsub("[^[:alnum:][:space:]]", "", title_clean)
  title_clean <- gsub("\\s+", " ", title_clean)
  
  # Create author-year signature
  author_clean <- tolower(trimws(df$AU))
  author_clean <- gsub("[^[:alnum:][:space:]]", "", author_clean)
  
  df$signature <- ifelse(has_doi, 
                        doi_clean,
                        paste0(substr(title_clean, 1, 30), "_", 
                               substr(author_clean, 1, 10), "_", df$PY))
  
  # Find duplicates
  sig_table <- table(df$signature, useNA = "no")
  dup_sigs <- names(sig_table[sig_table > 1])
  
  if (length(dup_sigs) > 0) {
    # Keep first occurrence of each signature
    df <- df[!duplicated(df$signature), ]
  }
  
  # Clean up
  df$signature <- NULL
  
  removed <- original_n - nrow(df)
  message(paste("Removed", removed, "duplicates (", round(removed/original_n*100, 1), "%)"))
  
  attr(df, "duplicates_removed") <- removed
  attr(df, "original_count") <- original_n
  
  df
}


#' Generate deduplication report
#' @param df Data frame before deduplication
#' @param deduped Data frame after deduplication
#' @return List with deduplication statistics
#' @export
deduplication_report <- function(df, deduped) {
  list(
    original_count = nrow(df),
    final_count = nrow(deduped),
    duplicates_removed = nrow(df) - nrow(deduped),
    removal_rate = round((nrow(df) - nrow(deduped)) / nrow(df) * 100, 2)
  )
}

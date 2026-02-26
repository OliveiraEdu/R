#' Deduplicate bibliographic records using multiple strategies
#' @param df Data frame with bibliographic records (must have TI, DOI, AU, PY columns)
#' @param method Deduplication method: "exact", "fuzzy", "both"
#' @param fuzzy_threshold Numeric threshold for fuzzy matching (0-1)
#' @return Deduplicated data frame with attribute "duplicates_removed"
#' @export
deduplicate_records <- function(df, method = "both", fuzzy_threshold = 0.85) {
  
  if (!requireNamespace("bibliometrix", quietly = TRUE)) {
    stop("bibliometrix package required for deduplication")
  }
  
  original_n <- nrow(df)
  
  # Method 1: Exact matching using bibliometrix
  if (method %in% c("exact", "both")) {
    message("Performing exact duplicate detection...")
    
    # Use DOI for exact matching if available
    if ("DOI" %in% names(df) && any(!is.na(df$DOI) & df$DOI != "")) {
      df$DI <- df$DOI
    }
    
    # Also use title for matching
    if ("TI" %in% names(df)) {
      df$TI <- tolower(trimws(df$TI))
    }
  }
  
  # Bibliometrix built-in duplicate removal
  # First, add a unique ID
  df$SR_original <- paste(
    ifelse(is.na(df$TI), "", substr(df$TI, 1, 30)),
    ifelse(is.na(df$AU), "", substr(df$AU, 1, 20)),
    ifelse(is.na(df$PY), "", as.character(df$PY)),
    sep = " "
  )
  
  # Manual exact DOI matching
  doi_dups <- find_doi_duplicates(df)
  
  # Manual title matching (after cleaning)
  title_dups <- find_title_duplicates(df, threshold = fuzzy_threshold)
  
  # Combine duplicate groups
  all_dups <- combine_duplicate_groups(list(doi_dups, title_dups))
  
  # Remove duplicates, keeping first occurrence
  df <- df[!(df$SR_original %in% all_dups$to_remove), ]
  
  # Clean up temporary columns
  df$SR_original <- NULL
  df$DI <- NULL
  
  removed <- original_n - nrow(df)
  message(paste("Removed", removed, "duplicates (", round(removed/original_n*100, 1), "%)"))
  
  attr(df, "duplicates_removed") <- removed
  attr(df, "original_count") <- original_n
  
  df
}


#' Find duplicates based on DOI
#' @param df Data frame
#' @return Data frame with duplicate pairs
find_doi_duplicates <- function(df) {
  if (!"DOI" %in% names(df)) {
    return(data.frame(id1 = character(), id2 = character(), stringsAsFactors = FALSE))
  }
  
  doi_clean <- tolower(trimws(df$DOI))
  doi_clean[doi_clean == "" | is.na(doi_clean)] <- NA
  
  # Find groups of same DOI
  doi_groups <- split(seq_len(nrow(df)), doi_clean)
  doi_groups <- doi_groups[sapply(doi_groups, length) > 1 & !is.na(names(doi_groups))]
  
  if (length(doi_groups) == 0) {
    return(data.frame(id1 = character(), id2 = character(), stringsAsFactors = FALSE))
  }
  
  dups <- lapply(doi_groups, function(ids) {
    data.frame(
      id1 = ids[1],
      id2 = ids[-1],
      method = "DOI",
      stringsAsFactors = FALSE
    )
  })
  
  do.call(rbind, dups)
}


#' Find duplicates based on title similarity
#' @param df Data frame
#' @param threshold Similarity threshold (0-1)
#' @return Data frame with duplicate pairs
find_title_duplicates <- function(df, threshold = 0.85) {
  if (!"TI" %in% names(df) || nrow(df) < 2) {
    return(data.frame(id1 = character(), id2 = character(), stringsAsFactors = FALSE))
  }
  
  # Clean titles
  titles <- clean_title(df$TI)
  
  # Calculate similarity matrix
  n <- nrow(df)
  dups <- list()
  
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      if (!is.na(titles[i]) && !is.na(titles[j]) && titles[i] != "" && titles[j] != "") {
        sim <- string_similarity(titles[i], titles[j])
        if (sim >= threshold) {
          dups[[length(dups) + 1]] <- data.frame(
            id1 = i,
            id2 = j,
            similarity = sim,
            method = "title",
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }
  
  if (length(dups) == 0) {
    return(data.frame(id1 = integer(), id2 = integer(), stringsAsFactors = FALSE))
  }
  
  do.call(rbind, dups)
}


#' Clean title for comparison
clean_title <- function(titles) {
  titles <- tolower(trimws(titles))
  titles <- gsub("[^[:alnum:][:space:]]", "", titles)
  titles <- gsub("\\s+", " ", titles)
  titles
}


#' Calculate string similarity using Jaccard on word tokens
string_similarity <- function(s1, s2) {
  words1 <- strsplit(s1, " ")[[1]]
  words2 <- strsplit(s2, " ")[[1]]
  
  intersection <- length(intersect(words1, words2))
  union <- length(union(words1, words2))
  
  if (union == 0) return(0)
  intersection / union
}


#' Combine multiple duplicate detection results
#' @param dup_list List of duplicate data frames
#' @return Data frame with records to remove
combine_duplicate_groups <- function(dup_list) {
  all_ids <- integer()
  
  for (dup_df in dup_list) {
    if (nrow(dup_df) > 0 && "id2" %in% names(dup_df)) {
      all_ids <- c(all_ids, dup_df$id2)
    }
  }
  
  data.frame(
    to_remove = unique(all_ids),
    stringsAsFactors = FALSE
  )
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

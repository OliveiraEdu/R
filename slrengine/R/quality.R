#' Quality Assessment using Modified MMAT
#' @param extraction Data frame with extracted studies
#' @return Data frame with MMAT quality scores
#' @export
quality_assessment <- function(extraction) {
  
  # Initialize quality assessment columns
  qa <- extraction
  
  # MMAT Questions for all study types (simplified)
  qa$MMAT_1_ClearRQ <- NA  # Clear research questions?
  qa$MMAT_2_AppropriateMethod <- NA  # Appropriate methodology?
  qa$MMAT_3_RigorousData <- NA  # Rigorous data collection?
  qa$MMAT_4_SoundAnalysis <- NA  # Sound analysis?
  qa$MMAT_5_Conclusions <- NA  # Well-supported conclusions?
  qa$MMAT_Overall <- NA
  
  # Overall quality interpretation
  qa$Quality_Rating <- NA
  
  qa
}


#' Auto-populate quality assessment based on indicators
#' @param qa Data frame from quality_assessment()
#' @return Updated quality assessment
#' @export
auto_quality_indicators <- function(qa) {
  
  # Score based on available indicators in title/abstract
  for (i in seq_len(nrow(qa))) {
    text <- paste(qa$Title[i], collapse = " ")
    
    # MMAT 1: Clear research questions
    # Indicators: specific research question in title, methodology mentioned
    if (grepl("what|how|why|does|effect|impact|compare", tolower(text), perl = TRUE)) {
      qa$MMAT_1_ClearRQ[i] <- "Yes"
    } else {
      qa$MMAT_1_ClearRQ[i] <- "Can't tell"
    }
    
    # MMAT 2: Appropriate methodology
    # Indicators: methodology terms
    method_terms <- c("method", "approach", "framework", "system", "architecture",
                     "design", "implementation", "prototype", "evaluation", "experiment")
    if (any(grepl(paste(method_terms, collapse = "|"), tolower(text)))) {
      qa$MMAT_2_AppropriateMethod[i] <- "Yes"
    } else {
      qa$MMAT_2_AppropriateMethod[i] <- "Can't tell"
    }
    
    # MMAT 3: Rigorous data collection
    # Hard to assess from title/abstract - mark as Can't tell
    qa$MMAT_3_RigorousData[i] <- "Can't tell"
    
    # MMAT 4: Sound analysis
    # Indicators: evaluation, results, analysis terms
    analysis_terms <- c("result", "analysis", "evaluate", "performance", "benchmark",
                        "comparison", "experiment", "data")
    if (any(grepl(paste(analysis_terms, collapse = "|"), tolower(text)))) {
      qa$MMAT_4_SoundAnalysis[i] <- "Yes"
    } else {
      qa$MMAT_4_SoundAnalysis[i] <- "Can't tell"
    }
    
    # MMAT 5: Conclusions
    # Indicators: conclusion, summary, findings
    if (grepl("conclusion|findings|show|result|demonstrate", tolower(text), perl = TRUE)) {
      qa$MMAT_5_Conclusions[i] <- "Yes"
    } else {
      qa$MMAT_5_Conclusions[i] <- "Can't tell"
    }
  }
  
  # Calculate overall score
  qa <- calculate_mmat_score(qa)
  
  qa
}


#' Calculate MMAT overall score
#' @param qa Data frame with MMAT questions
#' @return Updated quality assessment
calculate_mmat_score <- function(qa) {
  
  mmat_cols <- c("MMAT_1_ClearRQ", "MMAT_2_AppropriateMethod", 
                "MMAT_3_RigorousData", "MMAT_4_SoundAnalysis", "MMAT_5_Conclusions")
  
  for (i in seq_len(nrow(qa))) {
    scores <- sapply(mmat_cols, function(col) {
      val <- qa[i, col]
      if (is.na(val)) return(NA)
      switch(val, "Yes" = 1, "No" = 0, "Can't tell" = 0.5)
    })
    
    qa$MMAT_Overall[i] <- mean(scores, na.rm = TRUE)
    
    # Quality rating
    overall <- qa$MMAT_Overall[i]
    if (is.na(overall)) {
      qa$Quality_Rating[i] <- NA
    } else if (overall >= 0.75) {
      qa$Quality_Rating[i] <- "High"
    } else if (overall >= 0.5) {
      qa$Quality_Rating[i] <- "Medium"
    } else {
      qa$Quality_Rating[i] <- "Low"
    }
  }
  
  qa
}


#' Export quality assessment form
#' @param qa Data frame with quality assessment
#' @param path Output file path
#' @export
export_quality_form <- function(qa, path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
  writexl::write_xlsx(qa, path)
  message(paste("Exported quality assessment to:", path))
}


#' Generate quality assessment report
#' @param qa Data frame with quality assessment
#' @return List with quality statistics
#' @export
quality_report <- function(qa) {
  list(
    total_studies = nrow(qa),
    by_rating = table(qa$Quality_Rating, useNA = "ifany"),
    mean_score = mean(qa$MMAT_Overall, na.rm = TRUE),
    sd_score = sd(qa$MMAT_Overall, na.rm = TRUE),
    item_yes_rates = sapply(
      c("MMAT_1_ClearRQ", "MMAT_2_AppropriateMethod", 
        "MMAT_3_RigorousData", "MMAT_4_SoundAnalysis", "MMAT_5_Conclusions"),
      function(col) {
        sum(qa[, col] == "Yes", na.rm = TRUE) / sum(!is.na(qa[, col])) * 100
      }
    )
  )
}

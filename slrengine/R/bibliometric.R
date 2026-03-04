#'
#' Bibliometric Analysis Module for SLR Engine
#'
#' Provides bibliometrix-style analysis functions without external dependencies.
#' Functions include: citation analysis, author metrics, journal impact, keyword co-occurrence.
#'
#' @name bibliometric
#' @description Bibliometric analysis functions inspired by bibliometrix package
#'

#' Perform comprehensive bibliometric analysis
#'
#' @param df Data frame with bibliographic records (from extraction phase)
#' @return List with bibliometric metrics
#' @export
bibliometric_analysis <- function(df) {
  if (!is.data.frame(df)) {
    stop("Input must be a data frame")
  }
  
  results <- list()
  
  # Basic counts
  results$total_articles <- nrow(df)
  results$year_range <- range(df$Year, na.rm = TRUE)
  results$missing_year <- sum(is.na(df$Year))
  
  # Author analysis
  results$author_metrics <- author_analysis(df)
  
  # Source/Journal analysis
  results$source_metrics <- source_analysis(df)
  
  # Citation data (if available)
  if ("TC" %in% colnames(df)) {
    results$citation_metrics <- citation_analysis(df)
  }
  
  # Keyword analysis (if available) - supports both TI and Title columns
  if ("TI" %in% colnames(df) || "Title" %in% colnames(df)) {
    results$keyword_metrics <- keyword_analysis(df)
  }
  
  # Collaboration analysis
  results$collab_metrics <- collaboration_analysis(df)
  
  # Year trends
  results$year_trends <- yearly_trends(df)
  
  class(results) <- "bibliometric"
  results
}


#' Author-level bibliometric analysis
#'
#' @param df Data frame with Authors column
#' @return List with author metrics
#' @export
author_analysis <- function(df) {
  if (!"Authors" %in% colnames(df) && !"AU" %in% colnames(df)) {
    return(NULL)
  }
  
  au_col <- if ("Authors" %in% colnames(df)) "Authors" else "AU"
  
  author_list <- strsplit(df[[au_col]], ";\\s*")
  all_authors <- unlist(author_list)
  all_authors <- trimws(all_authors)
  all_authors <- all_authors[nchar(all_authors) > 0]
  
  author_table <- table(all_authors)
  top_authors <- sort(author_table, decreasing = TRUE)[1:min(20, length(author_table))]
  
  top_authors_df <- data.frame(
    Author = names(top_authors),
    Papers = as.integer(top_authors),
    stringsAsFactors = FALSE
  )
  
  n_authors_per_paper <- sapply(author_list, length)
  
  list(
    total_authors = length(unique(all_authors)),
    author_papers = top_authors_df,
    mean_authors_per_paper = mean(n_authors_per_paper, na.rm = TRUE),
    max_authors = max(n_authors_per_paper, na.rm = TRUE),
    solo_authorships = sum(n_authors_per_paper == 1, na.rm = TRUE)
  )
}


#' Source/Journal bibliometric analysis
#'
#' @param df Data frame with Source column
#' @return List with source metrics
#' @export
source_analysis <- function(df) {
  source_col <- if ("Source" %in% colnames(df)) "Source" else "SO"
  
  if (!source_col %in% colnames(df)) {
    return(NULL)
  }
  
  source_table <- table(df[[source_col]], useNA = "ifany")
  top_sources <- sort(source_table, decreasing = TRUE)[1:min(30, length(source_table))]
  
  top_sources_df <- data.frame(
    Source = names(top_sources),
    Count = as.integer(top_sources),
    stringsAsFactors = FALSE
  )
  
  list(
    total_sources = length(source_table),
    top_sources = top_sources_df
  )
}


#' Citation analysis
#'
#' @param df Data frame with TC (total citations) column
#' @return List with citation metrics
#' @export
citation_analysis <- function(df) {
  if (!"TC" %in% colnames(df)) {
    return(NULL)
  }
  
  tc <- as.numeric(df$TC)
  tc[is.na(tc)] <- 0
  
  list(
    total_citations = sum(tc, na.rm = TRUE),
    mean_citations = mean(tc, na.rm = TRUE),
    median_citations = median(tc, na.rm = TRUE),
    max_citations = max(tc, na.rm = TRUE),
    cited_articles = sum(tc > 0, na.rm = TRUE),
    uncited_articles = sum(tc == 0, na.rm = TRUE)
  )
}


#' Keyword analysis from titles and abstracts
#'
#' @param df Data frame with TI (title) and optionally AB (abstract) columns
#' @param n_keywords Number of top keywords to return (default 30)
#' @return Data frame with keyword frequencies
#' @export
keyword_analysis <- function(df, n_keywords = 30) {
  # Support both standard column names and extraction form names
  text_col <- if ("TI" %in% colnames(df)) "TI" else if ("Title" %in% colnames(df)) "Title" else NULL
  
  if (is.null(text_col)) {
    return(NULL)
  }
  
  # Combine title and abstract if available
  texts <- df[[text_col]]
  if ("AB" %in% colnames(df) || "Abstract" %in% colnames(df)) {
    ab_col <- if ("AB" %in% colnames(df)) "AB" else "Abstract"
    texts <- paste(texts, df[[ab_col]], sep = " ")
  }
  
  # Common stopwords
  stopwords <- c("the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
                 "of", "with", "by", "from", "as", "is", "was", "are", "were", "been",
                 "be", "have", "has", "had", "do", "does", "did", "will", "would", 
                 "could", "should", "may", "might", "must", "shall", "can", "need",
                 "this", "that", "these", "those", "it", "its", "they", "their",
                 "we", "our", "you", "your", "he", "she", "him", "her", "his",
                 "which", "what", "who", "whom", "where", "when", "why", "how",
                 "all", "each", "every", "both", "few", "more", "most", "other",
                 "some", "such", "no", "nor", "not", "only", "own", "same", "so",
                 "than", "too", "very", "just", "also", "now", "here", "there",
                 "using", "used", "based", "approach", "method", "methods", "paper",
                 "study", "research", "proposed", "presented", "show", "shown",
                 "result", "results", "work", "new", "novel", "different")
  
  # Extract words
  words <- tolower(texts)
  words <- gsub("[^a-z\\s]", " ", words)
  words <- strsplit(words, "\\s+")
  words <- unlist(words)
  words <- words[nchar(words) > 2]
  words <- words[!words %in% stopwords]
  
  # Count frequencies
  word_table <- table(words)
  top_keywords <- sort(word_table, decreasing = TRUE)[1:min(n_keywords, length(word_table))]
  
  data.frame(
    Keyword = names(top_keywords),
    Frequency = as.integer(top_keywords),
    stringsAsFactors = FALSE
  )
}


#' Collaboration analysis
#'
#' @param df Data frame with Authors column
#' @return List with collaboration metrics
#' @export
collaboration_analysis <- function(df) {
  au_col <- if ("Authors" %in% colnames(df)) "Authors" else "AU"
  
  if (!au_col %in% colnames(df)) {
    return(NULL)
  }
  
  author_list <- strsplit(df[[au_col]], ";\\s*")
  n_authors <- sapply(author_list, length)
  
  # Single vs multi-author
  single <- sum(n_authors == 1, na.rm = TRUE)
  double <- sum(n_authors == 2, na.rm = TRUE)
  multi <- sum(n_authors > 2, na.rm = TRUE)
  
  # Calculate collaboration index (sum of (n-1) for each paper)
  collab_index <- sum(n_authors - 1, na.rm = TRUE)
  
  list(
    single_author = single,
    two_authors = double,
    multi_author = multi,
    collaboration_index = collab_index,
    collaboration_rate = (double + multi) / length(n_authors) * 100
  )
}


#' Yearly publication trends
#'
#' @param df Data frame with Year column
#' @return Data frame with yearly counts
#' @export
yearly_trends <- function(df) {
  if (!"Year" %in% colnames(df)) {
    return(NULL)
  }
  
  year_table <- table(df$Year, useNA = "ifany")
  trend_df <- data.frame(
    Year = as.integer(names(year_table)),
    Publications = as.integer(year_table),
    stringsAsFactors = FALSE
  )
  trend_df <- trend_df[order(trend_df$Year), ]
  
  # Calculate growth rate
  if (nrow(trend_df) > 1) {
    trend_df$Growth <- c(NA, diff(trend_df$Publications))
    trend_df$GrowthRate <- c(NA, round(diff(trend_df$Publications) / trend_df$Publications[-nrow(trend_df)] * 100, 1))
  }
  
  trend_df
}


#' Summary method for bibliometric objects
#'
#' @param object bibliometric object
#' @param ... Additional arguments
#' @export
summary.bibliometric <- function(object, ...) {
  cat("\n=== BIBLIOMETRIC ANALYSIS SUMMARY ===\n\n")
  
  cat("Documents: ", object$total_articles, "\n")
  cat("Year range: ", object$year_range[1], "-", object$year_range[2], "\n")
  
  if (!is.null(object$author_metrics)) {
    cat("\n--- Author Metrics ---\n")
    cat("Total unique authors:", object$author_metrics$total_authors, "\n")
    cat("Mean authors per paper:", round(object$author_metrics$mean_authors_per_paper, 2), "\n")
    cat("\nTop 10 Authors:\n")
    top_auth <- head(object$author_metrics$author_papers, 10)
    print(top_auth)
  }
  
  if (!is.null(object$source_metrics)) {
    cat("\n--- Source/Journal Metrics ---\n")
    cat("Total sources:", object$source_metrics$total_sources, "\n")
    cat("\nTop 10 Sources:\n")
    top_src <- head(object$source_metrics$top_sources, 10)
    print(top_src)
  }
  
  if (!is.null(object$citation_metrics)) {
    cat("\n--- Citation Metrics ---\n")
    cat("Total citations:", object$citation_metrics$total_citations, "\n")
    cat("Mean citations:", round(object$citation_metrics$mean_citations, 2), "\n")
    cat("Max citations:", object$citation_metrics$max_citations, "\n")
    cat("Cited articles:", object$citation_metrics$cited_articles, "\n")
    cat("Uncited articles:", object$citation_metrics$uncited_articles, "\n")
  }
  
  if (!is.null(object$collab_metrics)) {
    cat("\n--- Collaboration Metrics ---\n")
    cat("Single author:", object$collab_metrics$single_author, "\n")
    cat("Two authors:", object$collab_metrics$two_authors, "\n")
    cat("Multi-author (>2):", object$collab_metrics$multi_author, "\n")
    cat("Collaboration rate:", round(object$collab_metrics$collaboration_rate, 1), "%\n")
  }
  
  cat("\n")
}


#' Export bibliometric analysis to CSV files
#'
#' @param bm bibliometric object
#' @param output_dir Output directory path
#' @export
export_bibliometric <- function(bm, output_dir = "slr_results") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Export keywords
  if (!is.null(bm$keyword_metrics)) {
    write.csv(bm$keyword_metrics, 
              file.path(output_dir, "bibliometric_keywords.csv"),
              row.names = FALSE, fileEncoding = "UTF-8")
  }
  
  # Export sources
  if (!is.null(bm$source_metrics)) {
    write.csv(bm$source_metrics$top_sources,
              file.path(output_dir, "bibliometric_sources.csv"),
              row.names = FALSE, fileEncoding = "UTF-8")
  }
  
  # Export authors
  if (!is.null(bm$author_metrics)) {
    write.csv(bm$author_metrics$author_papers,
              file.path(output_dir, "bibliometric_authors.csv"),
              row.names = FALSE, fileEncoding = "UTF-8")
  }
  
  # Export trends
  if (!is.null(bm$year_trends)) {
    write.csv(bm$year_trends,
              file.path(output_dir, "bibliometric_trends.csv"),
              row.names = FALSE, fileEncoding = "UTF-8")
  }
  
  message("Bibliometric exports saved to ", output_dir)
}

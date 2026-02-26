#!/usr/bin/env Rscript
# Test script for SLR engine - verify imports with existing data

library(dplyr)

# Source the import functions
source("slrengine/R/import_standalone.R")
source("slrengine/R/deduplication.R")
source("slrengine/R/screening.R")
source("slrengine/R/extraction.R")

cat("=== Testing SLR Engine Import Functions ===\n\n")

# Test 1: Import Scopus data
cat("Test 1: Importing Scopus data...\n")
tryCatch({
  scopus_df <- import_scopus("bibliometrix/scopus.csv")
  cat(paste("  SUCCESS: Imported", nrow(scopus_df), "records from Scopus\n"))
  cat("  Columns:", paste(names(scopus_df), collapse=", "), "\n\n")
}, error = function(e) {
  cat(paste("  ERROR:", e$message, "\n\n"))
})

# Test 2: Import PubMed data  
cat("Test 2: Importing PubMed data...\n")
tryCatch({
  pubmed_df <- import_pubmed("bibliometrix/pubmed-reproducib-set.txt")
  cat(paste("  SUCCESS: Imported", nrow(pubmed_df), "records from PubMed\n"))
  cat("  Columns:", paste(names(pubmed_df), collapse=", "), "\n\n")
}, error = function(e) {
  cat(paste("  ERROR:", e$message, "\n\n"))
})

# Test 3: Import WoS BibTeX
cat("Test 3: Importing Web of Science BibTeX...\n")
tryCatch({
  wos_files <- c("bibliometrix/savedrecs.bib")
  wos_df <- import_wos(wos_files)
  cat(paste("  SUCCESS: Imported", nrow(wos_df), "records from WoS\n"))
  cat("  Columns:", paste(names(wos_df), collapse=", "), "\n\n")
}, error = function(e) {
  cat(paste("  ERROR:", e$message, "\n\n"))
})

# Test 4: Full pipeline with available data
cat("Test 4: Testing full import pipeline...\n")
tryCatch({
  sources <- list(
    scopus = "bibliometrix/scopus.csv",
    pubmed = "bibliometrix/pubmed-reproducib-set.txt",
    wos = c("bibliometrix/savedrecs.bib")
  )
  
  merged <- import_databases(sources, remove_duplicates = TRUE)
  cat(paste("  SUCCESS: Merged dataset has", nrow(merged), "records\n\n"))
}, error = function(e) {
  cat(paste("  ERROR:", e$message, "\n\n"))
})

# Test 5: Screening
cat("Test 5: Testing screening functions...\n")
tryCatch({
  # Create minimal test data
  test_df <- data.frame(
    TI = c("Blockchain for scientific data provenance",
           "Supply chain management with blockchain",
           "Machine learning for cancer detection",
           "Data management plan for research",
           "Opinion: Future of blockchain"),
    AU = c("Smith J", "Doe A", "Brown B", "Wilson C", "Editorial"),
    PY = c(2022, 2023, 2021, 2024, 2023),
    SO = c("Journal A", "Journal B", "Conference C", "Journal D", "Editorial"),
    DOI = c("10.1000/abc", "10.1000/def", "10.1000/ghi", "10.1000/jkl", NA),
    AB = c("We propose a blockchain system for scientific data",
           "Supply chain blockchain application",
           "ML cancer detection method",
           "Data management plan framework",
           "Opinion piece about blockchain"),
    stringsAsFactors = FALSE
  )
  
  screened <- title_abstract_screening(test_df)
  stats <- screening_statistics(screened)
  
  cat(paste("  Total:", stats$total_records, "\n"))
  cat(paste("  Included:", stats$included, "\n"))
  cat(paste("  Excluded:", stats$excluded, "\n\n"))
}, error = function(e) {
  cat(paste("  ERROR:", e$message, "\n\n"))
})

cat("=== Testing Complete ===\n")

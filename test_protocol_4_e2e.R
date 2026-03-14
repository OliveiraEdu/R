#!/usr/bin/env Rscript
# End-to-End Protocol 4.0 Test

library(dplyr)
source("slrengine/R/report.R")

source("slrengine/R/import_standalone.R")
source("slrengine/R/deduplication.R")
source("slrengine/R/screening.R")
source("slrengine/R/fulltext.R")
source("slrengine/R/extraction.R")
source("slrengine/R/quality.R")
source("slrengine/R/prisma.R")
source("slrengine/R/load_config.R")
source("slrengine/R/pipeline.R")

cat("=== Protocol 4.0 End-to-End Test ===\n\n")

# Step 1: Load config
cat("Step 1: Loading configuration...\n")
config <- load_config("config.yaml")
cat("  Config loaded successfully\n")

# Step 2: Import databases
cat("\nStep 2: Importing databases...\n")

# Load ACM
cat("  Loading ACM...\n")
acm_data <- import_acm("data/acm(1).bib")
cat("    Imported", nrow(acm_data), "ACM records\n")

# Load IEEE
cat("  Loading IEEE...\n")
ieee_data <- import_ieee("data/export2026.03.04-06.39.06.csv")
cat("    Imported", nrow(ieee_data), "IEEE records\n")

# Load Scopus
cat("  Loading Scopus...\n")
scopus_data <- import_scopus("data/scopus_export_Mar 4-2026_7908dfa2-8919-4954-ab75-db6f3cc6a1ed.csv")
cat("    Imported", nrow(scopus_data), "Scopus records\n")

# Combine
merged <- rbind(acm_data, ieee_data, scopus_data)
cat("  Total records:", nrow(merged), "\n\n")

# Step 3: Run full pipeline with Protocol 4.0
cat("Step 3: Running full SLR pipeline with Protocol 4.0...\n")

result <- run_slr_pipeline(
  sources = list(acm = "data/acm(1).bib", 
                 ieee = "data/export2026.03.04-06.39.06.csv",
                 scopus = "data/scopus_export_Mar 4-2026_7908dfa2-8919-4954-ab75-db6f3cc6a1ed.csv"),
  protocol_version = "4.0",
  output_dir = "test_protocol_4_e2e"
)

cat("\n=== Protocol 4.0 Results ===\n")
cat("  Protocol version:", result$protocol_version, "\n")
cat("  Strategy:", result$strategy, "\n")
cat("  Focus:", result$focus, "\n")
cat("  Date range:", result$date_range, "\n")
cat("  Search strings count:", length(result$search_strings), "\n")

# Show first search string
cat("\n  Example search string (ieee):")
cat("\n", result$search_strings$ieee, "\n")

# Show concepts used
cat("\n  Concepts used:\n")
for (cat_name in names(result$concepts)) {
  cat("    ", cat_name, ": ", paste(result$concepts[[cat_name]], collapse = ", "), "\n")
}

# Show filters used
cat("\n  Filters applied:\n")
for (db_name in names(result$filters)) {
  cat("    ", db_name, ": ", result$filters[[db_name]], "\n")
}

cat("\n\n=== E2E Test Complete ===\n")

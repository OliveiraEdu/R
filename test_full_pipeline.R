#!/usr/bin/env Rscript
# Full SLR pipeline - processes all database sources

library(dplyr)

source("slrengine/R/import_standalone.R")
source("slrengine/R/import_arxiv.R")
source("slrengine/R/deduplication.R")
source("slrengine/R/screening.R")
source("slrengine/R/fulltext.R")
source("slrengine/R/extraction.R")
source("slrengine/R/quality.R")
source("slrengine/R/prisma.R")
source("slrengine/R/report.R")

cat("=== Full SLR Pipeline Test ===\n\n")

# Step 1: Import databases from all sources
cat("Step 1: Importing databases...\n")

imported_list <- list()

# Web of Science
wos_files <- list.files("data", pattern = "savedrecs.*\\.bib$", full.names = TRUE)
if (length(wos_files) > 0) {
  for (f in wos_files) {
    cat("  Loading:", f, "\n")
    imported_list[[length(imported_list) + 1]] <- import_wos(f)
  }
}

# ACM Digital Library
acm_files <- list.files("data", pattern = "acm.*\\.bib$", full.names = TRUE)
if (length(acm_files) > 0) {
  for (f in acm_files) {
    cat("  Loading:", f, "\n")
    imported_list[[length(imported_list) + 1]] <- import_acm(f)
  }
}

# IEEE Xplore
ieee_files <- list.files("data", pattern = "export.*\\.csv$", full.names = TRUE)
ieee_files <- ieee_files[!grepl("savedrecs|acm|scopus|pubmed", ieee_files)]
if (length(ieee_files) > 0) {
  for (f in ieee_files) {
    cat("  Loading:", f, "\n")
    tryCatch({
      imported_list[[length(imported_list) + 1]] <- import_ieee(f)
    }, error = function(e) {
      cat("    Failed to import:", e$message, "\n")
    })
  }
}

# Scopus - handles various naming patterns
scopus_files <- list.files("data", pattern = "scopus|csv-machine-ac-set", full.names = TRUE, ignore.case = TRUE)
scopus_files <- scopus_files[grep("scopus", scopus_files, ignore.case = TRUE)]
if (length(scopus_files) > 0) {
  for (f in scopus_files) {
    cat("  Loading Scopus:", f, "\n")
    tryCatch({
      imported_list[[length(imported_list) + 1]] <- import_scopus(f)
    }, error = function(e) {
      cat("    Failed to import:", e$message, "\n")
    })
  }
}

# PubMed - handles various naming patterns, skip timeline files
pubmed_files <- list.files("data", pattern = "pubmed|csv-machine-ac-set", full.names = TRUE, ignore.case = TRUE)
# Exclude already processed Scopus files, timeline summaries, and duplicates
pubmed_files <- pubmed_files[!pubmed_files %in% scopus_files]
pubmed_files <- pubmed_files[!grepl("Timeline", pubmed_files, ignore.case = TRUE)]
pubmed_files <- pubmed_files[!grepl("\\([0-9]\\)\\.", pubmed_files)]  # Avoid (1).csv duplicates
if (length(pubmed_files) > 0) {
  for (f in pubmed_files) {
    cat("  Loading PubMed:", f, "\n")
    tryCatch({
      imported_list[[length(imported_list) + 1]] <- import_pubmed_csv(f)
    }, error = function(e) {
      cat("    Failed to import:", e$message, "\n")
    })
  }
}

# arXiv (API search)
arxiv_query <- "(blockchain OR \"distributed ledger\") AND (provenance OR \"data lineage\" OR \"scientific data\" OR \"research data\" OR metadata OR reproducibility)"
if (requireNamespace("httr", quietly = TRUE)) {
  cat("  Searching arXiv API...\n")
  tryCatch({
    arxiv_results <- search_arxiv(arxiv_query, max_results = 200, months = 24)
    if (nrow(arxiv_results) > 0) {
      imported_list[[length(imported_list) + 1]] <- arxiv_results
      cat("    Imported", nrow(arxiv_results), "from arXiv\n")
    }
  }, error = function(e) {
    cat("    arXiv search failed:", e$message, "\n")
  })
}

# bioRxiv (API search) - DISABLED
# To enable: change FALSE to TRUE
if (FALSE && requireNamespace("httr", quietly = TRUE) && requireNamespace("jsonlite", quietly = TRUE)) {
  cat("  Searching bioRxiv API...\n")
  tryCatch({
    biorxiv_results <- search_biorxiv(biorxiv_query, max_results = 200, months = 12, max_pages = 5)
    if (nrow(biorxiv_results) > 0) {
      imported_list[[length(imported_list) + 1]] <- biorxiv_results
      cat("    Imported", nrow(biorxiv_results), "from bioRxiv\n")
    }
  }, error = function(e) {
    cat("    bioRxiv search failed:", e$message, "\n")
  })
}

# Check if we have data
if (length(imported_list) == 0) {
  stop("No data files found in data/ folder. Please add database export files.")
}

# Standardize columns
std_cols <- c("TI", "AU", "PY", "SO", "DOI", "ID", "AB", "C1", "TC", "DB")
for (i in seq_along(imported_list)) {
  for (col in std_cols) {
    if (!(col %in% names(imported_list[[i]]))) {
      imported_list[[i]][[col]] <- NA
    }
  }
}

# Merge all
merged <- dplyr::bind_rows(imported_list)
cat("\n  Total records before deduplication:", nrow(merged), "\n")

# Deduplicate
merged <- deduplicate_records(merged)
cat("  Total records after deduplication:", nrow(merged), "\n")

# Report sources
db_counts <- table(merged$DB, useNA = "ifany")
cat("\n  Database sources:\n")
for (db in names(db_counts)) {
  cat("    -", db, ":", db_counts[db], "records\n")
}

cat("\n")

# Step 2: Title/Abstract screening
cat("Step 2: Title/Abstract screening...\n")
screened <- title_abstract_screening(merged)
included_ta <- screened[screened$screening_decision == "include", ]
cat(paste("  Included after T/A screening:", nrow(included_ta), "\n"))
cat(paste("  Excluded:", nrow(screened) - nrow(included_ta), "\n\n"))

# Step 3: Full-text assessment
cat("Step 3: Full-text assessment...\n")
fulltext <- fulltext_assessment(included_ta)
included_ft <- fulltext[fulltext$fulltext_status == "include", ]
cat(paste("  Included after full-text:", nrow(included_ft), "\n\n"))

# Step 4: Data extraction
cat("Step 4: Data extraction...\n")
extraction <- extract_data(included_ft)
cat(paste("  Extracted studies:", nrow(extraction), "\n\n"))

# Step 5: Quality assessment
cat("Step 5: Quality assessment...\n")
qa <- quality_assessment(extraction)
qa <- auto_quality_indicators(qa)
cat("  Quality scores calculated\n\n")

# Step 6: PRISMA flow diagram
cat("Step 6: Generating PRISMA data...\n")

# Calculate exclusion reasons from screening
screening_reasons <- table(screened$screening_reason[screened$screening_decision == "exclude"])
excluded_technical <- as.integer(screening_reasons["I4: Technical implementation"])
excluded_domain <- as.integer(screening_reasons["I5: Domain relevance"])
excluded_opinion <- as.integer(screening_reasons["E1: Opinion piece"])
excluded_nonresearch <- as.integer(screening_reasons["E2: Non-research context"])

# Get database sources
db_sources <- unique(merged$DB[!is.na(merged$DB)])

prisma <- generate_prisma_flow(
  records_all = nrow(merged) + attr(merged, "duplicates_removed"),
  records_screened = nrow(merged),
  records_excluded_ta = nrow(merged) - nrow(included_ta),
  records_assessed_ft = nrow(included_ta),
  records_excluded_ft = nrow(included_ta) - nrow(included_ft),
  records_included = nrow(extraction),
  excluded_technical = excluded_technical,
  excluded_domain = excluded_domain,
  excluded_opinion = excluded_opinion,
  excluded_nonresearch = excluded_nonresearch,
  databases = db_sources
)

cat("\n=== PRISMA Flow Summary ===\n")
cat(paste("Records identified:", prisma$identified$database_searches, "\n"))
cat(paste("After duplicates removed:", prisma$screened$after_duplicates, "\n"))
cat(paste("Excluded at title/abstract:", prisma$screened$excluded_ta, "\n"))
cat(paste("Assessed for full-text:", prisma$fulltext$assessed_ft, "\n"))
cat(paste("Excluded at full-text:", prisma$fulltext$excluded_ft, "\n"))
cat(paste("Studies included:", prisma$included, "\n"))

# Summary
cat("\n=== Extraction Summary ===\n")
summary <- extraction_summary(extraction)
cat(paste("Total studies:", summary$total_studies, "\n"))

# Quality summary
cat("\n=== Quality Summary ===\n")
qual <- quality_report(qa)
cat(paste("Mean quality score:", round(qual$mean_score, 2), "\n"))

# Step 7: Save all outputs
cat("\nStep 7: Saving outputs...\n")
dir.create("slr_results", showWarnings = FALSE)
saveRDS(merged, "slr_results/01_merged_raw.rds")
saveRDS(screened, "slr_results/02_screened.rds")
saveRDS(fulltext, "slr_results/03_fulltext.rds")
saveRDS(extraction, "slr_results/04_extraction.rds")
write.csv(extraction, "slr_results/04_extraction_form.csv", row.names = FALSE)
saveRDS(qa, "slr_results/05_quality.rds")
write.csv(qa, "slr_results/05_quality_assessment.csv", row.names = FALSE)

# Generate PRISMA flow diagram data
write.csv(prisma$identified, "slr_results/06_prisma_flow.csv", row.names = FALSE)
write(prisma$flow_diagram, "slr_results/06_prisma_flow.tex")

# Generate summary tables
summary_df <- extraction_summary(extraction)
write.csv(summary_df$by_year, "slr_results/07_summary_tables.csv", row.names = FALSE)

# Generate gap analysis
gaps <- gap_analysis(extraction)
write.csv(gaps, "slr_results/08_gap_analysis.csv", row.names = FALSE)

# Generate reports
generate_markdown_report(prisma, extraction, qa, "slr_results/09_report.md")
generate_latex_report(prisma, extraction, qa, "slr_results/09_report.tex")

cat("  All outputs saved to slr_results/\n")

cat("\n=== Pipeline Complete ===\n")

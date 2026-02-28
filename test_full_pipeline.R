#!/usr/bin/env Rscript
# Full pipeline test with data folder

library(dplyr)

source("slrengine/R/import_standalone.R")
source("slrengine/R/deduplication.R")
source("slrengine/R/screening.R")
source("slrengine/R/fulltext.R")
source("slrengine/R/extraction.R")
source("slrengine/R/quality.R")
source("slrengine/R/prisma.R")
source("slrengine/R/report.R")

cat("=== Full SLR Pipeline Test ===\n\n")

# Step 1: Import databases from data folder
cat("Step 1: Importing databases...\n")

# Import each WoS file separately, then combine
wos1 <- import_wos("data/savedrecs(7).bib")
wos2 <- import_wos("data/savedrecs(8).bib")
wos3 <- import_wos("data/savedrecs(9).bib")
acm <- import_acm("data/acm(1).bib")

# Standardize columns
std_cols <- c("TI", "AU", "PY", "SO", "DOI", "ID", "AB", "C1", "TC", "DB")
for (df in list(wos1, wos2, wos3, acm)) {
  for (col in std_cols) {
    if (!(col %in% names(df))) df[[col]] <- NA
  }
}

# Merge all
merged <- dplyr::bind_rows(wos1, wos2, wos3, acm)
merged <- deduplicate_records(merged)

cat(paste("  Total records after deduplication:", nrow(merged), "\n\n"))

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
prisma <- generate_prisma_flow(
  records_all = nrow(merged) + attr(merged, "duplicates_removed"),
  records_screened = nrow(merged),
  records_excluded_ta = nrow(merged) - nrow(included_ta),
  records_assessed_ft = nrow(included_ta),
  records_excluded_ft = nrow(included_ta) - nrow(included_ft),
  records_included = nrow(extraction)
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

cat("\n=== Pipeline Complete ===\n")

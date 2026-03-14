# Test Protocol 4.4 - Config-Driven Search Strings

## Purpose
Test that Protocol 4.4 search strings are properly generated from config.yaml using the config-driven architecture.

## Test Cases
1. Verify config.yaml has all 5 PICOC_criteria sections
2. Verify search strings use config values
3. Verify search strings use title operators (not abstracts)
4. Verify all database platforms are supported

## Quick Test
```bash
Rscript -e '
source("slrengine/R/pipeline.R")
cat("\n=== Protocol 4.4 Search Strings ===\n")
result <- generate_search_strings("4.0")
for (db in names(result)) {
  cat(paste0("[", db, "]: ", result[[db]], "\n"))
}
cat("\n=== Config Validation ===\n")
required <- c("maDMP_Support", "Provenance", "Blockchain_Platform", "Openness", "Scientific_Data")
missing <- setdiff(required, names(config$PICOC_criteria))
if (length(missing) == 0) {
  cat("All 5 PICOC_criteria sections present in config.yaml\n")
} else {
  cat("Missing sections:", paste(missing, collapse = ", "), "\n")
}
'
```

## Full Test Script
Run `Rscript test_full_pipeline.R` for end-to-end testing with mock data.
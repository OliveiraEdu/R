# AGENTS.md - Guidelines for Agents Working in This Repository

## Project Overview

This repository contains an R-based Systematic Literature Review (SLR) Engine for conducting PRISMA 2020 compliant reviews on blockchain-enabled provenance for scientific data management. The main package is in `slrengine/`.

---

## 1. Build/Lint/Test Commands

### Running the Application

```bash
# Run full pipeline test with all database sources
Rscript test_full_pipeline.R

# Run basic engine tests
Rscript test_engine.R
```

### Running Single Tests

```bash
# Test a specific import function
Rscript -e '
source("slrengine/R/import_standalone.R")
ieee <- import_ieee("data/export2026.03.04-06.39.06.csv")
print(paste("Imported", nrow(ieee), "IEEE records"))
'

# Test deduplication
Rscript -e "
source(\"slrengine/R/import_standalone.R\")
source(\"slrengine/R/deduplication.R\")
df <- data.frame(TI=c(\"A\",\"B\",\"A\"), DOI=c(\"10.1000/1\",\"10.1000/2\",NA), AU=c(\"X\",\"Y\",\"X\"), PY=c(2020,2021,2020))
deduped <- deduplicate_records(df)
print(paste(\"Removed\", nrow(df)-nrow(deduped), \"duplicates\"))
"

# Test screening
Rscript -e "
source(\"slrengine/R/import_standalone.R\")
source(\"slrengine/R/screening.R\")
df <- import_wos(\"data/savedrecs(7).bib\")
screened <- title_abstract_screening(df)
print(paste(\"Included:\", sum(screened\$screening_decision == \"include\")))
"

# Test PRISMA generation
Rscript -e "
source(\"slrengine/R/prisma.R\")
prisma <- generate_prisma_flow(100, 90, 50, 30, 10, 20)
print(paste(\"Included:\", prisma\$included))
"

# Run R syntax check on a file
Rscript -e 'source("slrengine/R/import_standalone.R"); print("Syntax OK")'
```

---

## 2. Code Style Guidelines

### General Principles

- Write concise, readable R code
- Use the tidyverse style where applicable
- Prefer base R functions over external dependencies when practical
- All exported functions must have roxygen2-style documentation

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | snake_case.R | `import_standalone.R` |
| Functions | snake_case() | `import_databases()` |
| Variables | snake_case | `merged_data` |
| Constants | UPPER_SNAKE | `MAX_RECORDS` |

### Code Formatting

```r
# Use <- for assignment (not = in function calls)
x <- 5
result <- my_function(x)

# Space after comma
c(1, 2, 3)

# Function definitions with newlines between arguments
my_function <- function(arg1,
                      arg2 = default,
                      arg3 = NULL) {
  # Function body
}

# Pipe operators have space before and after %>%
df %>%
  filter(condition) %>%
  select(col1, col2)
```

### Error Handling

```r
# Use tryCatch for critical operations
tryCatch({
  df <- import_scopus(path)
  message("Import successful")
}, error = function(e) {
  warning(paste("Import failed:", e$message))
  return(NULL)
})

# Validate inputs at function start
validate_input <- function(df) {
  if (!is.data.frame(df)) stop("Input must be a data frame")
  if (nrow(df) == 0) stop("Input data frame is empty")
  TRUE
}
```

### Documentation

Every exported function must have roxygen2-style documentation:

```r
#' Function Title
#'
#' Description of what the function does
#'
#' @param df Input data frame description
#' @return Description of return value
#' @export
#' @examples
#' df <- data.frame(x = 1:10)
#' my_function(df)
```

---

## 3. Repository Structure

```
/workspaces/R/
├── slrengine/              # Main R package
│   ├── DESCRIPTION         # Package metadata
│   ├── NAMESPACE           # Exports
│   ├── CHANGELOG.md       # Version history
│   └── R/                  # Source files
│       ├── import_standalone.R
│       ├── import_arxiv.R    # arXiv and bioRxiv API
│       ├── deduplication.R
│       ├── screening.R
│       ├── fulltext.R
│       ├── extraction.R
│       ├── quality.R
│       ├── prisma.R
│       ├── report.R
│       └── pipeline.R
├── data/                   # Database exports
│   ├── ieee_*.csv, wos_*.bib, acm_*.bib, scopus_*.csv, pubmed_*.csv
├── slr_results/            # Pipeline output (generated)
├── test_engine.R           # Basic tests
├── test_full_pipeline.R    # Full pipeline test
└── AGENTS.md              # Agent guidelines
```

---

## 4. Development Workflow

### Adding New Functionality

1. Create new R file in `slrengine/R/`
2. Add exported functions with roxygen2 documentation
3. Export functions in `NAMESPACE`
4. Update `DESCRIPTION` if new dependencies added
5. Update CHANGELOG.md with changes
6. Test with `test_engine.R` or `test_full_pipeline.R`

### Running Tests

```bash
Rscript test_full_pipeline.R    # Full pipeline test
Rscript test_engine.R          # Basic engine tests
```

---

## 5. Key Dependencies

| Package | Purpose | Required |
|---------|---------|----------|
| dplyr | Data manipulation | Yes |
| httr | HTTP requests (arXiv API) | Yes |
| jsonlite | JSON parsing (bioRxiv API) | Yes |

Note: `bibliometrix` is optional - standalone import functions exist as fallback.

---

## 6. Protocol Versions

### Protocol 1.0 (Narrow)
- 3-concept search: Provenance + Technology + DMP
- Peer-reviewed sources only

### Protocol 3.0 (Broad)
- 2-concept search: Technology + Scientific Data
- Includes preprint servers (arXiv, bioRxiv)

---

## 7. Common Patterns

### Import Pipeline
```r
sources <- list(wos = "data/wos.bib", acm = "data/acm.bib")
merged <- import_databases(sources)
```

### Screening Pipeline
```r
screened <- title_abstract_screening(merged)
included <- screened[screened$screening_decision == "include", ]
```

### Extraction Pipeline
```r
extraction <- extract_data(included)
qa <- auto_quality_indicators(quality_assessment(extraction))
```

---

## 8. Important Notes

- Always use `stringsAsFactors = FALSE` when creating data frames
- Check for NA values before operations
- Standard column names: TI, AU, PY, SO, DOI, AB, C1, TC, DB
- Use `DB` column to identify sources (arXiv, bioRxiv, WoS, ACM, etc.)

---

*Last Updated: March 2026*

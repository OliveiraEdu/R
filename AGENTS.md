# AGENTS.md - Guidelines for Agents Working in This Repository

## Project Overview

This repository contains an R-based Systematic Literature Review (SLR) Engine for conducting PRISMA 2020 compliant reviews on blockchain-enabled provenance for scientific data management. The main package is in `slrengine/`.

---

## 1. Build/Lint/Test Commands

### Running the Application

```bash
# Run full pipeline test with existing data
Rscript test_full_pipeline.R

# Run basic engine tests
Rscript test_engine.R
```

### R Package Testing

```bash
# Check if R is available and version
R --version

# Run R interactively
R

# Run R script with specific file
Rscript <script_name>.R

# Check installed packages
R --quiet -e 'installed.packages()[,"Package"]'
```

### Code Checking (R-specific)

```bash
# Check R syntax only (no package required)
R CMD check --no-manual slrengine/

# The R console in batch mode
R --quiet -e 'source("test_engine.R")'
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
| Data frames | descriptive | `screened_records` |

### Import Guidelines

```r
# Preferred: Load only what you need from packages
library(dplyr)    # For data manipulation

# Avoid: import.packages() inside functions (slower)
# Prefer: library() at top of script
```

### Code Formatting

```r
# Use <- for assignment (not = in function calls)
x <- 5
result <- my_function(x)

# Space after comma, no space before
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
  if (!is.data.frame(df)) {
    stop("Input must be a data frame")
  }
  if (nrow(df) == 0) {
    stop("Input data frame is empty")
  }
  TRUE
}
```

### Documentation

Every exported function must have:

```r
#' Function Title
#'
#' Description of what the function does
#'
#' @param df Input data frame description
#' @param param2 Description of second parameter
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
│   └── R/                  # Source files
│       ├── import_standalone.R
│       ├── deduplication.R
│       ├── screening.R
│       ├── fulltext.R
│       ├── extraction.R
│       ├── quality.R
│       ├── prisma.R
│       └── pipeline.R
├── slr/                    # Protocol and queries
│   ├── PRISMA_2020_ROTOCOL.md
│   └── SEARCH_QUERIES.md
├── bibliometrix/           # Test data (WoS, Scopus, PubMed exports)
├── test_engine.R           # Basic tests
└── test_full_pipeline.R    # Full pipeline test
```

---

## 4. Development Workflow

### Adding New Functionality

1. Create new R file in `slrengine/R/`
2. Add exported functions with roxygen2 documentation
3. Export functions in `NAMESPACE`
4. Update `DESCRIPTION` if new dependencies added
5. Test with `test_engine.R` or `test_full_pipeline.R`

### Running Tests

```bash
# Test import functions
Rscript -e '
source("slrengine/R/import_standalone.R")
scopus <- import_scopus("bibliometrix/scopus.csv")
print(paste("Imported", nrow(scopus), "records"))
'

# Test deduplication
Rscript -e '
source("slrengine/R/import_standalone.R")
source("slrengine/R/deduplication.R")
df <- data.frame(TI=c("A","B","A"), DOI=c("10.1000/1","10.1000/2",NA), AU=c("X","Y","X"), PY=c(2020,2021,2020))
deduped <- deduplicate_records(df)
print(paste("Removed", nrow(df)-nrow(deduped), "duplicates"))
'
```

---

## 5. Key Dependencies

| Package | Purpose | Required |
|---------|---------|----------|
| dplyr | Data manipulation | Yes |

Output format: CSV UTF-8 (no external dependencies required)
LaTeX export available for PRISMA flow diagram.

Note: `bibliometrix` is optional - standalone import functions exist as fallback.

---

## 6. Common Patterns

### Import Pipeline
```r
sources <- list(
  wos = c("data/wos.bib"),
  scopus = "data/scopus.csv",
  pubmed = "data/pubmed.txt"
)
merged <- import_databases(sources, remove_duplicates = TRUE)
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

## 7. Important Notes

- Always use `stringsAsFactors = FALSE` when creating data frames
- Check for NA values before operations
- The pipeline expects standard column names: TI, AU, PY, SO, DOI, AB, C1, TC, DB
- PRISMA protocol is in `slr/PRISMA_2020_ROTOCOL.md`

---

*Last Updated: February 2026*

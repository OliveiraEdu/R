# SLR Engine - User Manual

Systematic Literature Review Engine for Blockchain-Enabled Provenance Research

---

## 1. Overview

The SLR Engine is an R-based tool for conducting Systematic Literature Reviews following PRISMA 2020 guidelines. It handles:
- Database import (Web of Science, Scopus, PubMed, IEEE Xplore, ACM DL)
- Deduplication
- Title/abstract screening
- Full-text assessment
- Data extraction
- Quality assessment (MMAT)
- PRISMA reporting

---

## 2. Prerequisites

### R Installation
```r
# Install R from https://cran.r-project.org/
```

### Required R Packages
```r
install.packages(c("dplyr", "writexl"))
```

### Data Files Required
Export your database searches as:
- **Web of Science**: BibTeX format (.bib)
- **Scopus**: CSV format
- **PubMed**: MEDLINE/text format (.txt)
- **IEEE Xplore**: CSV format
- **ACM DL**: CSV format

---

## 3. Quick Start

### Step 1: Prepare Your Data
Place your exported database files in a folder (e.g., `data/`).

### Step 2: Run the Complete Pipeline

```r
# Load the engine functions
source("slrengine/R/import_standalone.R")
source("slrengine/R/deduplication.R")
source("slrengine/R/screening.R")
source("slrengine/R/fulltext.R")
source("slrengine/R/extraction.R")
source("slrengine/R/quality.R")
source("slrengine/R/prisma.R")

# Define your data sources
sources <- list(
  wos = c("data/wos_export.bib"),
  scopus = "data/scopus_export.csv",
  pubmed = "data/pubmed_export.txt"
)

# Run the pipeline
merged <- import_databases(sources, remove_duplicates = TRUE)
screened <- title_abstract_screening(merged)
fulltext <- fulltext_assessment(screened[screened$screening_decision == "include", ])
extraction <- extract_data(fulltext)
qa <- auto_quality_indicators(quality_assessment(extraction))

# Generate PRISMA flow
prisma <- generate_prisma_flow(
  records_all = nrow(merged) + attr(merged, "duplicates_removed"),
  records_screened = nrow(merged),
  records_excluded_ta = nrow(merged) - sum(screened$screening_decision == "include"),
  records_assessed_ft = nrow(screened[screened$screening_decision == "include", ]),
  records_excluded_ft = nrow(screened[screened$screening_decision == "include", ]) - nrow(fulltext[fulltext$fulltext_status == "include", ]),
  records_included = nrow(extraction)
)
```

---

## 4. Search Queries

Before importing data, run these searches in each database:

### IEEE Xplore
```
("provenance" OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
```

### ACM Digital Library
```
(provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
```

### Scopus
```
(provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
```

### Web of Science
```
(provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
```

### Google Scholar
```
"blockchain provenance scientific data"
```

**Filters for all databases:**
- Date range: 2018-2026
- Language: English

See `slr/SEARCH_QUERIES.md` for complete details.

---

## 5. Manual Review Workflow

### Title/Abstract Screening
1. Export screening results:
```r
# After running title_abstract_screening()
# Export for manual review
write.csv(screened, "output/screening_review.csv")
```

2. Review each record in the exported file
3. Update `screening_decision` column (include/exclude)
4. Import updated decisions if needed

### Full-Text Assessment
1. Export included studies for full-text retrieval:
```r
# Get studies needing full-text
ft_studies <- screened[screened$screening_decision == "include", ]
write.csv(ft_studies[, c("TI", "AU", "DOI", "SO")], "output/fulltext_list.csv")
```

2. After obtaining full texts, assess each using criteria in the protocol
3. Update `fulltext_status` column

### Data Extraction
1. Export extraction form:
```r
extraction <- extract_data(ft_included)
writexl::write_xlsx(extraction, "output/extraction_form.xlsx")
```

2. Manually complete the extraction fields:
   - Key_Findings
   - Limitations
   - Quality_Score (MMAT rating)

---

## 6. Output Files

The engine produces:
| File | Description |
|------|-------------|
| `screening_results.rds` | All records with screening decisions |
| `extraction_form.xlsx` | Data extraction template |
| `quality_assessment.xlsx` | MMAT quality scores |
| `prisma_flow.xlsx` | PRISMA flow diagram data |

---

## 7. Troubleshooting

### Import Errors
- **Column mismatch**: Ensure CSV files have headers matching standard field names
- **File not found**: Check file paths are correct relative to working directory

### Deduplication Issues
- The engine uses DOI and title+author+year for matching
- Check `attr(merged, "duplicates_removed")` for count

### Screening Too Aggressive/Conservative
- Edit `get_default_criteria()` in `screening.R` to adjust keywords
- Add custom criteria functions for your specific needs

---

## 8. Protocol Compliance

This engine implements the PRISMA 2020 protocol in `slr/PRISMA_2020_ROTOCOL.md`:

- ✅ Inclusion/Exclusion criteria (I1-I5, E1-E5)
- ✅ Date range filtering (2018-2026)
- ✅ Multi-database search
- ✅ Deduplication
- ✅ Two-stage screening
- ✅ Data extraction form
- ✅ MMAT quality assessment
- ✅ PRISMA flow diagram

---

## 9. Support

For issues or questions, refer to:
- PRISMA 2020 Statement: https://www.prisma-statement.org/
- bibliometrix package: https://www.bibliometrix.org/

---

*Generated: February 2026*
*Version: 1.0*

# Protocol 4.0 Usage Guide

## Overview

Protocol 4.0 (Focused) is designed for **high-precision literature searches** targeting blockchain-enabled provenance for scientific data management. It uses a **title-focused search strategy** to maximize relevance and minimize irrelevant results.

---

## Core Concepts

Protocol 4.0 searches across **5 core concepts** in the title field:

1. **maDMP Support** (`maDMP_Support`)
2. **Provenance** (`Provenance`)
3. **Blockchain Platform** (`Blockchain_Platform`)
4. **Openness** (`Openness`)
5. **Scientific Data** (`Scientific_Data`)

---

## Quick Start

### Prerequisites

Before running a Protocol 4.0 search, ensure you have:

- A valid database account (IEEE, ACM, WoS, Scopus, or PubMed)
- The `slrengine` R package installed
- Configuration file (`config.yaml`) updated with your settings

### Basic Usage

```r
# Load the package
library(slrengine)

# Load your configuration
config <- yaml::read_yaml("config.yaml")

# Run the full SLR pipeline with Protocol 4.0
results <- run_slr_pipeline(config = config)

# Access results
print(results$extraction)
print(results$quality)
```

---

## Customization

### Adjust Date Ranges

Edit `config.yaml` under `search_config`:

```yaml
search_config:
  date_range:
    start: "2018-01-01"
    end: "2024-12-31"
```

### Change Search Concepts

Modify the concepts in `config.yaml`:

```yaml
PICOC_criteria:
  maDMP_Support:
    keywords: ["MaDMP", "managed DMP", "data management plan"]
  Blockchain_Platform:
    keywords: ["Blockchain", "Distributed ledger", "Distributed computing"]
```

### Select Databases

Specify which databases to search:

```yaml
database_settings:
  sources: ["ieee", "acm", "wos", "scopus", "pubmed"]
```

---

## Understanding the Pipeline

### Step 1: Database Import

Protocol 4.0 searches multiple databases:

| Database | Platform | Operator |
|----------|----------|----------|
| IEEE | `platform_ieee` | `AND` |
| ACM | `platform_acm` | `AND` |
| WoS | `platform_wos` | `AND` |
| Scopus | `platform_scopus` | `AND` |
| PubMed | `platform_pubmed` | `AND` |
| arXiv | `platform_arxiv` | `AND` |
| bioRxiv | `platform_biorxiv` | `AND` |

### Step 2: Search String Generation

The `build_protocol_4_string()` function generates title-focused search strings:

```r
# Generate search strings for all concepts
search_strings <- generate_search_strings(config)

# Example output
# "ti:(('maDMP Support' OR 'maDMP Support' OR 'MaDMP' OR ...) AND ..."
```

### Step 3: Data Extraction

After import, the pipeline:

1. Applies **title-only filtering** (Protocol 4.0 strategy)
2. Performs **deduplication** across databases
3. Extracts relevant fields (TI, AU, PY, SO, DOI, AB)

### Step 4: Screening

Protocol 4.0 uses **eligibility criteria** to include/exclude papers:

- **Title Match**: Must contain at least one Protocol 4 concept
- **Full Text Review**: Additional criteria applied
- **Scoring**: Quality indicators assigned

### Step 5: Output

The pipeline produces:

- **Imported records** (all databases)
- **Deduplicated dataset**
- **Screened results** (included/excluded)
- **Extraction results** (structured data)
- **Quality indicators** (auto-assigned scores)
- **PRISMA flow diagram** (visual summary)

---

## Configuration Reference

### `config.yaml` Structure

```yaml
# Protocol 4.0 Configuration
PICOC_criteria:
  maDMP_Support:
    keywords: ["MaDMP", "managed DMP"]
  Provenance:
    keywords: ["Provenance", "Traceability"]
  Blockchain_Platform:
    keywords: ["Blockchain", "Distributed ledger"]
  Openness:
    keywords: ["Open Science", "Open Data"]
  Scientific_Data:
    keywords: ["Scientific data", "Data management"]

database_settings:
  sources: ["ieee", "acm", "wos", "scopus", "pubmed", "arxiv", "biorxiv"]
  include_preprints: true

search_config:
  date_range:
    start: "2018-01-01"
    end: "2024-12-31"
  max_records_per_db: 1000

output:
  format: "csv"
  directory: "output/"
```

---

## Tips & Best Practices

### 1. Start Broad, Then Narrow

- **Phase 1**: Run Protocol 3.0 (broad) first
- **Phase 2**: Switch to Protocol 4.0 for focused results
- **Phase 3**: Adjust keywords based on initial findings

### 2. Monitor Deduplication Rate

High deduplication (>50%) may indicate:
- Too broad search terms
- Overlapping databases
- Need for more specific filters

### 3. Check Quality Indicators

Review `results$quality` to identify:
- Papers with missing fields
- Low-quality sources
- Incomplete data extraction

### 4. Export Results

```r
# Export to CSV
write.csv(results$extraction, "extraction_results.csv")

# Export PRISMA flow
prisma <- results$prisma_flow
ggsave("prisma_flow.png", prisma)
```

---

## Troubleshooting

### Issue: Zero Results

**Possible causes:**
- Date range too narrow
- Keywords too specific
- No matching papers in selected databases

**Solution:**
- Broaden date range
- Add synonyms to keywords
- Check database settings

### Issue: High Deduplication

**Possible causes:**
- Multiple databases overlap significantly
- Preprints (arXiv, bioRxiv) in addition to peer-reviewed sources

**Solution:**
- Consider removing preprints from search
- Adjust database selection
- Review deduplication settings

### Issue: Quality Scores Too Low

**Possible causes:**
- Papers with incomplete metadata
- Non-standard formatting in source databases

**Solution:**
- Increase sample size for better statistics
- Filter out low-quality sources
- Manually review and correct extraction

---

## Support

For questions or issues:

1. Check this guide first
2. Review `config.yaml` structure
3. Test with small sample sets
4. Contact development team

---

*Last Updated: March 14, 2026*
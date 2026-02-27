# Database Search Queries - SLR Protocol

**Systematic Review:** Blockchain-Enabled Provenance for Scientific Data Management  
**Date:** February 26, 2026  
**Protocol Version:** 1.0  
**Review Period:** 2018-2026

---

## Search Concepts

| Concept | Search Terms | Boolean Operators |
|---------|-------------|-------------------|
| **A: Provenance** | provenance, "data lineage", reproducibility, verification, "chain of custody" | OR |
| **B: Technology** | blockchain, "distributed ledger", decentralized, IPFS, "content addressable", "distributed hash table" | OR |
| **C: Data Management** | DMP, "data management plan", maDMP, FAIR, "metadata standards", "data sharing" | OR |

**Combined Formula:** `(A) AND (B) AND (C)`

---

## IEEE Xplore

### Search String
```
("provenance" OR "data lineage" OR reproducibility OR verification OR "chain of custody") 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS OR "content addressable") 
AND (DMP OR "data management plan" OR maDMP OR FAIR OR "metadata standards")
```

### Fine-Grained Filters

| Filter Category | Specific Setting | Value/Selection |
|----------------|------------------|-----------------|
| **Year Range** | Publication Year | 2018 - 2026 |
| **Document Type** | Content Type | Conference Papers, Journal Articles |
| **Sub-Topic** | Additional Filter | "Computer Science" (optional) |
| **Language** | | English |
| **Subscription** | | Include all available |

### Advanced Search Tips
- Use `Abstract` field for broader results
- Use `Document Title` field for stricter results
- Enable "Include preview-only content" if available

### Export Settings
- **Format:** CSV (Full Record)
- **Fields:** Include Abstract, Keywords, Author Affiliations

### Date Executed: ____________

### Records Retrieved: ____________

---

## ACM Digital Library

### Search String
```
(provenance OR "data lineage" OR reproducibility OR verification OR "chain of custody") 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS OR "content addressable") 
AND (DMP OR "data management plan" OR maDMP OR FAIR OR "metadata standards")
```

### Fine-Grained Filters

| Filter Category | Specific Setting | Value/Selection |
|----------------|------------------|-----------------|
| **Year** | Publication Date | 2018 - 2026 |
| **Content Type** | Source Type | Conference Proceedings, Journals |
| **Venue** | | Full-length papers, Short papers |
| **Access Type** | | All available |
| **Language** | | English |

### Advanced Search Tips
- Use `Title` field for precise matching
- Use `Abstract` field for broader coverage
- Enable "Full Text & Metadata" search

### Export Settings
- **Format:** CSV (preferred) or BibTeX
- **Citation Style:** ACM fmt
- **Include:** References, Abstract, Keywords

### Date Executed: ____________

### Records Retrieved: ____________

---

## Scopus

### Search String
```
(provenance OR "data lineage" OR reproducibility OR verification OR "chain of custody") 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS OR "content addressable") 
AND (DMP OR "data management plan" OR maDMP OR FAIR OR "metadata standards")
```

### Fine-Grained Filters

| Filter Category | Specific Setting | Value/Selection |
|----------------|------------------|-----------------|
| **Year** | Publication Year | 2018 - 2026 |
| **Subject Area** | Subject | Computer Science, Decision Sciences, Information Systems |
| **Document Type** | | Article, Conference Paper, Review |
| **Source Type** | | Journal, Conference Proceedings |
| **Language** | | English |
| **Access Type** | | All available |

### Advanced Search Tips
- Use `TITLE-ABS-KEY` for combined field search
- Use `TITLE` for stricter results
- Use `ABS` for abstract-only search
- Enable "Include keywords" for broader coverage

### Export Settings
- **Format:** CSV (Full record)
- **Fields to export:** All available
- **Citation format:** CSV with all metadata

### Date Executed: ____________

### Records Retrieved: ____________

---

## Web of Science (Core Collection)

### Search String
```
(provenance OR "data lineage" OR reproducibility OR verification OR "chain of custody") 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS OR "content addressable") 
AND (DMP OR "data management plan" OR maDMP OR FAIR OR "metadata standards")
```

### Fine-Grained Filters

| Filter Category | Specific Setting | Value/Selection |
|----------------|------------------|-----------------|
| **Publication Years** | | 2018 - 2026 |
| **Web of Science Categories** | | Computer Science, Information Science |
| **Document Types** | | Article, Proceedings Paper, Review |
| **Languages** | | English |
| **Indexes** | | SCI-Expanded, SSCI, A&HCI, CPCI-S, CPCI-SSH |

### Advanced Search Tips
- Use `TS=` (Topic) for combined title/abstract/keywords
- Use `TI=` for title-only search
- Use `AB=` for abstract-only
- Refine by "Cited References" count for higher impact

### Export Settings
- **Format:** BibTeX (preferred) or CSV
- **Full Record:** Include cited references, abstract, keywords
- **Citation format:** BibTeX

### Date Executed: ____________

### Records Retrieved: ____________

---

## Google Scholar

### Search String (Simplified)
```
"blockchain provenance scientific data"
```

### Alternative Expanded Search
```
(provenance OR "data lineage" OR reproducibility) AND (blockchain OR "distributed ledger" OR IPFS) AND ("data management" OR "scientific data")
```

### Fine-Grained Settings

| Setting | Value |
|---------|-------|
| **Time Period** | 2018 - 2026 |
| **Sort by** | Relevance |
| **Results per page** | 20-100 |
| **Maximum results** | 200 (first page selections are most relevant) |

### Advanced Tips
- Use quotes for exact phrases
- Use `-` to exclude terms (e.g., `-supply chain`)
- Click "Cite" for each result to get BibTeX
- Use "Related articles" for discovery

### Export Method
1. Search with simplified string
2. Click "Cite" under each result
3. Select BibTeX format
4. Copy to .bib file

### Date Executed: ____________

### Records Retrieved: ____________

---

## PubMed (Optional - for biomedical context)

### Search String
```
(provenance[Title/Abstract] OR "data lineage"[Title/Abstract] OR reproducibility[Title/Abstract]) 
AND (blockchain[Title/Abstract] OR "distributed ledger"[Title/Abstract] OR IPFS[Title/Abstract]) 
AND ("data management plan"[Title/Abstract] OR maDMP[Title/Abstract] OR FAIR[Title/Abstract])
```

### Fine-Grained Filters

| Filter Category | Specific Setting | Value/Selection |
|----------------|------------------|-----------------|
| **Publication Dates** | | 2018/01/01 - 2026/12/31 |
| **Article Types** | | Classical Article, Clinical Trial, Journal Article, Review |
| **Species** | | Humans (optional) |
| **Languages** | | English |

### Export Settings
- **Format:** MEDLINE or RIS
- **Fields:** Abstract, MeSH Terms, Keywords

### Date Executed: ____________

### Records Retrieved: ____________

---

## Additional Sources

### arXiv (Preprints)
- URL: https://arxiv.org/
- Search: blockchain provenance data management
- Export: BibTeX

### OSF (Open Science Framework)
- URL: https://osf.io/
- Search: blockchain data management
- Export: RIS

### Dimensions (Alternative)
- URL: https://app.dimensions.ai/
- Similar filters to Scopus
- Export: CSV, BibTeX

---

## Search String Syntax Reference

### Field Tags by Database

| Database | Title | Abstract | Keywords | All Fields |
|----------|-------|----------|----------|------------|
| IEEE Xplore | ti: | abs: | kw: | all: |
| ACM DL | title: | abstract: | | all: |
| Scopus | TITLE | ABS | KEY | TITLE-ABS-KEY |
| WoS | TI= | AB= | DE= | TS= |
| Google Scholar | "exact phrase" | | | (implicit) |

### Boolean Operators
- **AND:** Both terms must appear
- **OR:** Either term can appear
- **NOT:** Exclude term (use carefully)

### Truncation/Wildcards
- **\***: Multiple characters (e.g., `blockchain*`)
- **?**: Single character (e.g., `wom?n`)
- **$**: Optional characters (database specific)

---

## Export Instructions Summary

| Database | Recommended Format | Filename Pattern |
|----------|-------------------|------------------|
| IEEE Xplore | CSV (Full Record) | `ieee_YYYYMMDD.csv` |
| ACM DL | CSV or BibTeX | `acm_YYYYMMDD.csv` / `.bib` |
| Scopus | CSV (Full Record) | `scopus_YYYYMMDD.csv` |
| Web of Science | BibTeX | `wos_YYYYMMDD.bib` |
| Google Scholar | BibTeX | `scholar_YYYYMMDD.bib` |
| arXiv | BibTeX | `arxiv_YYYYMMDD.bib` |

---

## Quality Checklist Before Export

- [ ] Date filter applied (2018-2026)
- [ ] Document type filter applied
- [ ] Language filter applied (English)
- [ ] Export includes abstract
- [ ] Export includes keywords
- [ ] Export includes author affiliations
- [ ] Export includes DOI
- [ ] Filename includes execution date

---

## Notes

1. **Language Restriction:** All searches exclude non-English publications
2. **Duplicate Removal:** Handled by SLR Engine
3. **Search Re-run:** If >30 days before processing, re-run searches
4. **Protocol Deviations:** Document any in final report

---

# Protocol 3.0: Broad Search Strategy

## Overview

Protocol 3.0 uses a broader search strategy to capture edge cases and emerging research:
- **Technology + Scientific Data** (2 concepts) instead of 3
- Includes preprint servers (arXiv, bioRxiv) for recent research
- Focus on capturing all relevant work before narrow filtering

## Search Concepts

| Concept | Search Terms | Boolean Operators |
|---------|-------------|-------------------|
| **Technology** | blockchain, "distributed ledger", "DLT", "smart contract", Hyperledger, Fabric, Corda, Ethereum, IPFS | OR |
| **Scientific Data** | "scientific data", "research data", "data management", "data sharing", "open science", "open data", FAIR | OR |

**Combined Formula:** `(Technology) AND (Scientific Data)`

---

## IEEE Xplore (Protocol 3.0)

```
(blockchain OR "distributed ledger" OR "distributed ledger technology" OR DLT OR 
"smart contract" OR "smart contracts" OR Hyperledger OR Iroha OR Fabric OR Corda OR 
Ethereum OR IPFS OR "content addressable" OR "content addressing") 
AND ("scientific data" OR "research data" OR "scholarly data" OR "data management" OR 
"data sharing" OR "data repository" OR "open science" OR "open data" OR FAIR)
```

### Filters
| Filter | Value |
|--------|-------|
| Year | 2018-2026 |
| Document Type | Conference, Journal |
| Language | English |

---

## ACM Digital Library (Protocol 3.0)

```
(blockchain OR "distributed ledger" OR "DLT" OR "smart contract" OR 
Hyperledger OR Fabric OR Corda OR Ethereum OR IPFS) 
AND ("scientific data" OR "research data" OR "data management" OR 
"data sharing" OR "open science" OR FAIR)
```

---

## arXiv (Protocol 3.0)

Search via API with categories:
- **cs.DC** (Distributed computing)
- **cs.LG** (Machine learning)
- **cs.AI** (Artificial intelligence)
- **q-bio.QM** (Quantitative methods)

### API Usage
```r
source("slrengine/R/import_arxiv.R")
arxiv_results <- search_arxiv(
  query = "(blockchain OR \"distributed ledger\" OR Hyperledger) AND 
           (\"scientific data\" OR \"research data\" OR \"data management\")",
  max_results = 100,
  categories = c("cs.DC", "cs.LG", "cs.AI"),
  months = 6
)
```

---

## bioRxiv (Protocol 3.0)

Search via API (fetches recent papers, filters locally):

```r
source("slrengine/R/import_arxiv.R")
biorxiv_results <- search_biorxiv(
  query = "blockchain",
  max_results = 100,
  months = 6
)
```

Note: bioRxiv API doesn't support keyword search directly. The function fetches recent papers and filters by keyword locally.

---

## Protocol Version Selection

Use `generate_search_strings()` in the SLR Engine:

```r
# Protocol 1.0 (narrow)
strings <- generate_search_strings("1.0")

# Protocol 3.0 (broad)
strings <- generate_search_strings("3.0")
```

---

*Protocol 3.0 Added: February 2026*

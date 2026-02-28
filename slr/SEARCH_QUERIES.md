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

---

# Protocol 4.0: Focused RQ, Title-Focused Search

## Overview

Protocol 4.0 uses a title-focused search strategy for the specific research question on blockchain-anchored maDMPs:

**RQ:** *How can machine-actionable Data Management Plans (maDMPs) be anchored on a permissioned blockchain to enable verifiable provenance tracking for scientific data?*

Key features:
- **Title-focused** → higher precision, more relevant results
- **Narrow scope** → focused on maDMP + blockchain provenance intersection
- **Comparison tables** → supports novelty claims

## Search Concepts

| Concept | Search Terms | Boolean Operators |
|---------|-------------|-------------------|
| **maDMP** | "machine-actionable", maDMP, "data management", DMP | OR |
| **Provenance** | provenance, "data lineage", "chain of custody", verification | OR |
| **Platform** | platform, repository, storage, blockchain, IPFS, decentralized | OR |
| **Semantic** | PROV-O, semantic, FAIR, reproducibility | OR |
| **Scientific Data** | "scientific data", "research data", "open science", metadata | OR |

**Combined Formula:** `(maDMP OR Provenance OR Semantic OR Scientific Data) AND (Platform)`

---

## IEEE Xplore (Protocol 4.0)

**Interface:** Advanced Search → Command Search

**Search String:**
```
(("Document Title":"machine-actionable" OR "Document Title":"maDMP" OR "Document Title":"data management" OR "Document Title":DMP OR "Document Title":provenance OR "Document Title":"data lineage" OR "Document Title":"chain of custody" OR "Document Title":verification OR "Document Title":"scientific data" OR "Document Title":"research data" OR "Document Title":"open science" OR "Document Title":metadata OR "Document Title":"PROV-O" OR "Document Title":semantic OR "Document Title":desci OR "Document Title":FAIR OR "Document Title":reproducibility OR "Document Title":reproducible) AND ("Document Title":platform OR "Document Title":repository OR "Document Title":storage OR "Document Title":blockchain OR "Document Title":IPFS OR "Document Title":decentralized))
```

**Filters:** Document Type: Conference OR Journal; Year: 2018-2026

---

## Scopus (Protocol 4.0)

**Interface:** Advanced Search

**Search String:**
```
(TITLE("machine-actionable") OR TITLE("maDMP") OR TITLE("data management") OR TITLE("DMP") OR TITLE("provenance") OR TITLE("data lineage") OR TITLE("chain of custody") OR TITLE("verification") OR TITLE("scientific data") OR TITLE("research data") OR TITLE("open science") OR TITLE("metadata") OR TITLE("PROV-O") OR TITLE("semantic") OR TITLE("desci") OR TITLE("FAIR") OR TITLE("reproducibility") OR TITLE("reproducible")) AND (TITLE("platform") OR TITLE("repository") OR TITLE("storage") OR TITLE("blockchain") OR TITLE("IPFS") OR TITLE("decentralized"))
```

**Filters:** Subject Area: Computer Science; Doc Type: Article, Conference Paper; Year: 2018-2026

---

## Web of Science (Protocol 4.0)

**Interface:** Advanced Search → Query Builder

**Search String:**
```
TI=("machine-actionable" OR "maDMP" OR "data management" OR "DMP" OR "provenance" OR "data lineage" OR "chain of custody" OR "verification" OR "scientific data" OR "research data" OR "open science" OR "metadata" OR "PROV-O" OR "semantic" OR "desci" OR "FAIR" OR "reproducibility" OR "reproducible") AND TI=("platform" OR "repository" OR "storage" OR "blockchain" OR "IPFS" OR "decentralized")
```

**Filters:** Categories: Computer Science, Information Science; Doc Types: Article, Conference Paper; Year: 2018-2026

---

## PubMed (Protocol 4.0)

**Interface:** Advanced Search

**Search String:**
```
(("machine-actionable"[ti] OR "maDMP"[ti] OR "data management"[ti] OR "DMP"[ti] OR "provenance"[ti] OR "data lineage"[ti] OR "chain of custody"[ti] OR "verification"[ti] OR "scientific data"[ti] OR "research data"[ti] OR "open science"[ti] OR "metadata"[ti] OR "PROV-O"[ti] OR "semantic"[ti] OR "desci"[ti] OR "FAIR"[ti] OR "reproducibility"[ti] OR "reproducible"[ti]) AND ("platform"[ti] OR "repository"[ti] OR "storage"[ti] OR "blockchain"[ti] OR "IPFS"[ti] OR "decentralized"[ti]))
```

**Filters:** Publication Types: Article, Review, Clinical Trial; Year: 2018-2026

---

## ACM Digital Library (Protocol 4.0)

**Interface:** Advanced Search → Edit Query

**Search String:**
```
(Title:"machine-actionable" OR Title:maDMP OR Title:"data management" OR Title:DMP OR Title:provenance OR Title:"data lineage" OR Title:"chain of custody" OR Title:verification OR Title:"scientific data" OR Title:"research data" OR Title:"open science" OR Title:metadata OR Title:PROV-O OR Title:semantic OR Title:desci OR Title:FAIR OR Title:reproducibility OR Title:reproducible) AND (Title:platform OR Title:repository OR Title:storage OR Title:blockchain OR Title:IPFS OR Title:decentralized)
```

**Filters:** Content Type: Conference Papers, Journal Articles; Year: 2018-2026

---

## arXiv (Protocol 4.0)

**Interface:** https://arxiv.org/search/

**Search String:**
```
(ti:"machine-actionable" OR ti:maDMP OR ti:"data management" OR ti:DMP OR ti:provenance OR ti:"data lineage" OR ti:"chain of custody" OR ti:verification OR ti:"scientific data" OR ti:"research data" OR ti:"open science" OR ti:metadata OR ti:PROV-O OR ti:semantic OR ti:desci OR ti:FAIR OR ti:reproducibility OR ti:reproducible) AND (ti:platform OR ti:repository OR ti:storage OR ti:blockchain OR ti:IPFS OR ti:decentralized)
```

**Filters:** Categories: cs.DC, cs.CY, q-bio.QM; Year: 2018-2026

---

## Protocol Version Selection

Use `generate_search_strings()` in the SLR Engine:

```r
# Protocol 1.0 (narrow - 3 concepts)
strings <- generate_search_strings("1.0")

# Protocol 3.0 (broad - 2 concepts, preprints)
strings <- generate_search_strings("3.0")

# Protocol 4.0 (focused - title-focused)
strings <- generate_search_strings("4.0")
```

---

*Protocol 4.0 Added: February 28, 2026*

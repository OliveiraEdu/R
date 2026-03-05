# PRISMA 2020 Protocol: Systematic Review of Blockchain-Anchored maDMP for Scientific Data Provenance

**Protocol Version:** 4.4  
**Date:** March 05, 2026  
**Status:** Revised - Refined RQ and eligibility and exclusion criteria.

---

## 1. Administrative Information

### 1.1 Title
**Blockchain-Anchored Machine-Actionable Data Management Plans for Scientific Data Provenance: A Systematic Review**

### 1.2 Review Team
- **Primary Reviewer:** [To be completed]
- **Secondary Reviewer:** [To be completed]
- **Third Reviewer (disputes):** [To be completed]

### 1.3 Protocol Registration
- **Planned registration:** OSF (osf.io)
- **Registration date:** [To be completed]

---

## 2. Rationale

### 2.1 Problem Statement

The reproducibility crisis in scientific research has been widely documented, with studies indicating that over 70% of researchers have failed to reproduce another scientist's work. This problem stems from inadequate provenance tracking across the data lifecycle. Existing repository infrastructure lacks cryptographic guarantees for data lineage and authorship attribution.

Machine-actionable Data Management Plans (maDMPs) represent a promising approach to formalize data management commitments, but current implementations lack:
1. Cryptographic immutability for verification
2. Automated provenance tracking across the data lifecycle
3. Integration between DMP commitments and actual data outputs

### 2.2 Research Gap

While prior work has explored:
- Blockchain for general scientific data storage
- PROV-O provenance models
- maDMP standards (RDA specification)

**No prior work has systematically explored the integration of maDMPs with permissioned blockchain infrastructure to provide verifiable, cryptographically-secured provenance tracking.**

This systematic review maps the current landscape to identify:
1. Existing approaches to blockchain-based scientific data provenance
2. maDMP implementations and their limitations
3. Technical gaps that d-OSPv2 addresses

---

## 3. Research Question

### 3.1 Primary Research Question

**RQ:** *How can machine-actionable Data Management Plans (maDMPs) be anchored on a permissioned blockchain to enable verifiable provenance tracking for scientific data?*

### 3.2 Sub-Questions (derived from primary RQ)

| SQ | Question | Purpose |
|----|----------|---------|
| SQ1 | What blockchain platforms have been used for scientific data provenance? | Map technology landscape |
| SQ2 | How do existing systems model and represent provenance? | Identify semantic approaches |
| SQ3 | What are the architectural patterns for combining blockchain with external storage? | Understand dual-ledger approaches |
| SQ4 | How do permissioned blockchains compare to permissionless for scientific data use cases? | Evaluate trust models |
| SQ5 | What evaluation methods have been used to assess blockchain provenance systems? | Inform evaluation design |

### 3.3 Why This Single RQ is Appropriate

| Criterion | Addressed |
|-----------|------------|
| **Focused** | Narrowly scoped to maDMP + blockchain integration |
| **Answerable** | d-OSPv2 implementation provides proof-of-concept |
| **Novelty** | No prior work combines these specific elements |
| **Impact** | Addresses reproducibility crisis directly |
| **SLR manageable** | Yields focused, comparable results |

---

## 4. Eligibility Criteria

### 4.1 Inclusion Criteria

| # | Criterion | Specification |
|---|-----------|---------------|
| I1 | Language | English language publications |
| I2 | Publication type | Peer-reviewed journal articles, conference proceedings, arXiv preprints |
| I3 | Date range | Publications from 2018 to 2026 |
| I4 | Technical implementation | Must describe a technical system, framework, or methodology (not just conceptual) |
| I5 | Domain relevance | Must address **maDMP** OR (**blockchain/DLT/platform** AND **scientific/research data**) |

### 4.2 Exclusion Criteria

| # | Criterion | Rationale |
|---|-----------|-----------|
| E1 | Opinion pieces, editorials | Not empirical/technical contributions |
| E2 | Non-research contexts | Supply chains, financial applications, non-scientific use cases |
| E3 | No technical implementation | Conceptual frameworks without implementation details |
| E4 | No blockchain/platform component | Must address blockchain, DLT, IPFS, or platform/storage for scientific data |

**Notes:**
- E4 (Duplicate publications) - Handled at deduplication stage
- E5 (Full text unavailable) - Handled at full-text assessment stage
- E6-E7 from older versions merged into I5 and E4

---

## 5. Information Sources

### 5.1 Database Search Execution (Pending)

Execute searches using the validated strings in Section 6.3. Record results in the table below:

| Database | Date Executed | Results | Executed By |
|----------|---------------|---------|-------------|
| IEEE Xplore | | | |
| Scopus | | | |
| Web of Science | | | |
| PubMed | | | |
| arXiv | | | |
| ACM Digital Library | | | |
| **TOTAL** | | | |

**Note:** Results will be recorded after search execution using the validated syntax in Section 6.3.

### 5.2 Search Scope Rationale

The validated search strings specifically target the intersection of:
- maDMP concepts (DMP, machine-actionable, RDA standards)
- Provenance tracking (provenance, lineage, verification)
- Blockchain/platform infrastructure for scientific data

This intersection represents the precise gap d-OSPv2 addresses.

---

## 6. Search Strategy

### 6.1 Primary Search String (Title-Focused)

This refined search string was validated in IEEE Xplore and yields highly relevant results:

```
(
  "Document Title":"machine-actionable" OR "Document Title":"maDMP" OR 
  "Document Title":"data management" OR "Document Title":DMP OR 
  "Document Title":provenance OR "Document Title":"data lineage" OR 
  "Document Title":"chain of custody" OR "Document Title":verification OR 
  "Document Title":"scientific data" OR "Document Title":"research data" OR 
  "Document Title":"open science" OR "Document Title":metadata OR 
  "Document Title":"PROV-O" OR "Document Title":semantic OR 
  "Document Title":desci OR "Document Title":FAIR OR 
  "Document Title":reproducibility OR "Document Title":reproducible
) 
AND 
(
  "Document Title":platform OR "Document Title":repository OR 
  "Document Title":storage OR "Document Title":blockchain OR 
  "Document Title":IPFS OR "Document Title":decentralized
)
```

**Key advantages:**
- Title-focused → higher precision, more relevant results
- Broad coverage of related concepts (FAIR, reproducibility, provenance, semantic)
- Includes platform/storage terms for system papers

### 6.2 Alternative Search Strings (for validation)

If primary string yields < 50 papers, use broader:

```
(blockchain OR "distributed ledger" OR IPFS) 
AND (provenance OR "data lineage" OR verification)
AND ("scientific data" OR "research data" OR "open science")
```

### 6.3 Database-Specific Search Strings (Validated Syntax)

The following strings use the validated title-focused syntax for each database.

#### 1. IEEE Xplore

**Interface:** Advanced Search → Command Search
```
(("Document Title":"machine-actionable" OR "Document Title":"maDMP" OR "Document Title":"data management" OR "Document Title":DMP OR "Document Title":provenance OR "Document Title":"data lineage" OR "Document Title":"chain of custody" OR "Document Title":verification OR "Document Title":"scientific data" OR "Document Title":"research data" OR "Document Title":"open science" OR "Document Title":metadata OR "Document Title":"PROV-O" OR "Document Title":semantic OR "Document Title":semantic OR "Document Title":desci OR "Document Title":FAIR OR "Document Title":reproducibility OR "Document Title":reproducible) AND ("Document Title":platform OR "Document Title":repository OR "Document Title":storage OR "Document Title":blockchain OR "Document Title":IPFS OR "Document Title":decentralized))
```
**Filters:** Document Type: Conference OR Journal; Year: 2018-2026

---

#### 2. Scopus

**Interface:** Advanced Search

```
(TITLE("machine-actionable") OR TITLE("maDMP") OR TITLE("data management") OR TITLE("DMP") OR TITLE("provenance") OR TITLE("data lineage") OR TITLE("chain of custody") OR TITLE("verification") OR TITLE("scientific data") OR TITLE("research data") OR TITLE("open science") OR TITLE("metadata") OR TITLE("PROV-O") OR TITLE("semantic") OR TITLE("desci") OR TITLE("FAIR") OR TITLE("reproducibility") OR TITLE("reproducible")) AND (TITLE("platform") OR TITLE("repository") OR TITLE("storage") OR TITLE("blockchain") OR TITLE("IPFS") OR TITLE("decentralized"))
```
**Note:** Scopus is sensitive to syntax—use double quotes for phrases and parentheses for grouping.
**Filters:** Subject Area: Computer Science; Doc Type: Article, Conference Paper; Year: 2018-2026

---

#### 3. Web of Science (WoS)

**Interface:** Advanced Search → Query Builder

```
TI=("machine-actionable" OR "maDMP" OR "data management" OR "DMP" OR "provenance" OR "data lineage" OR "chain of custody" OR "verification" OR "scientific data" OR "research data" OR "open science" OR "metadata" OR "PROV-O" OR "semantic" OR "desci" OR "FAIR" OR "reproducibility" OR "reproducible") AND TI=("platform" OR "repository" OR "storage" OR "blockchain" OR "IPFS" OR "decentralized")
```
**Note:** WoS uses `TI=` field tag for Title.
**Filters:** Categories: Computer Science, Information Science; Doc Types: Article, Conference Paper; Year: 2018-2026

---

#### 4. PubMed

**Interface:** Advanced Search

```
(("machine-actionable"[ti] OR "maDMP"[ti] OR "data management"[ti] OR "DMP"[ti] OR "provenance"[ti] OR "data lineage"[ti] OR "chain of custody"[ti] OR "verification"[ti] OR "scientific data"[ti] OR "research data"[ti] OR "open science"[ti] OR "metadata"[ti] OR "PROV-O"[ti] OR "semantic"[ti] OR "desci"[ti] OR "FAIR"[ti] OR "reproducibility"[ti] OR "reproducible"[ti]) AND ("platform"[ti] OR "repository"[ti] OR "storage"[ti] OR "blockchain"[ti] OR "IPFS"[ti] OR "decentralized"[ti]))
```
**Note:** PubMed uses trailing `[ti]` tags for title search.
**Filters:** Publication Types: Article, Review, Clinical Trial; Year: 2018-2026

---

#### 5. arXiv

**Interface:** https://arxiv.org/search/

```
(ti:"machine-actionable" OR ti:maDMP OR ti:"data management" OR ti:DMP OR ti:provenance OR ti:"data lineage" OR ti:"chain of custody" OR ti:verification OR ti:"scientific data" OR ti:"research data" OR ti:"open science" OR ti:metadata OR ti:PROV-O OR ti:semantic OR ti:desci OR ti:FAIR OR ti:reproducibility OR ti:reproducible) AND (ti:platform OR ti:repository OR ti:storage OR ti:blockchain OR ti:IPFS OR ti:decentralized)
```
**Note:** arXiv uses `ti:` prefix for title search.
**Filters:** Categories: cs.DC, cs.CY, q-bio.QM; Year: 2018-2026

---

#### 6. ACM Digital Library

**Interface:** Advanced Search → Edit Query

```
(Title:"machine-actionable" OR Title:maDMP OR Title:"data management" OR Title:DMP OR Title:provenance OR Title:"data lineage" OR Title:"chain of custody" OR Title:verification OR Title:"scientific data" OR Title:"research data" OR Title:"open science" OR Title:metadata OR Title:PROV-O OR Title:semantic OR Title:desci OR Title:FAIR OR Title:reproducibility OR Title:reproducible) AND (Title:platform OR Title:repository OR Title:storage OR Title:blockchain OR Title:IPFS OR Title:decentralized)
```
**Note:** ACM can be sensitive to hyphenated words—quoting is essential.
**Filters:** Content Type: Conference Papers, Journal Articles; Year: 2018-2026

**Field-Specific Query:**
```
[Title: ("machine-actionable" OR maDMP OR "data management plan")] 
AND [Abstract: (blockchain OR "distributed ledger" OR Hyperledger)]
AND [Abstract: (provenance OR "data lineage")]
AND [Anywhere: ("scientific data" OR "research data")]
```

---

#### Scopus

**Interface:** Advanced Search
**Search String:**
```
("machine-actionable" OR "maDMP" OR "data management plan") 
AND (blockchain OR "distributed ledger" OR Hyperledger OR Iroha OR Fabric)
AND (provenance OR "data lineage" OR "chain of custody")
AND ("scientific data" OR "research data" OR "open science")
```
**Filters to Apply:**
- Subject Area: Computer Science (select ALL)
- Document Type: Article OR Conference Paper
- Year: 2018-2026

**Field-Specific Query (Scopus uses field codes):**
```
TITLE-ABS-KEY("machine-actionable" OR maDMP) 
AND TITLE-ABS-KEY(blockchain OR "distributed ledger" OR Hyperledger)
AND TITLE-ABS-KEY(provenance OR "data lineage")
AND TITLE-ABS-KEY("scientific data" OR "research data")
```

---

#### Web of Science (Core Collection)

**Interface:** Advanced Search → Query Builder
**Search String:**
```
("machine-actionable" OR "maDMP" OR "data management plan") 
AND (blockchain OR "distributed ledger" OR Hyperledger OR Iroha OR Fabric)
AND (provenance OR "data lineage" OR verification)
AND ("scientific data" OR "research data" OR "open science")
```
**Filters to Apply:**
- Web of Science Categories: Computer Science (all), Information Science
- Document Types: Article OR Conference Paper OR Early Access
- Year: 2018-2026

**Field-Specific Query (WoS uses two-letter field tags):**
```
TS=("machine-actionable" OR maDMP OR "data management plan") 
AND TS=(blockchain OR "distributed ledger" OR Hyperledger OR Iroha)
AND TS=(provenance OR "data lineage" OR verification)
AND TS=("scientific data" OR "research data")
```

**Note:** TS= searches Title, Abstract, Author Keywords, and Keywords Plus.

---

#### Google Scholar

**Interface:** Basic Search
**Search String:**
```
"machine-actionable" OR maDMP blockchain provenance "scientific data"
```
**Limitations:**
- No advanced operators allowed
- Maximum 256 characters
- Results sorted by relevance only
- Limit to first 200 results

**Alternative Phrase-Based Search:**
```
"blockchain" "provenance" "data management plan" "scientific"
```

---

#### arXiv

**Interface:** https://arxiv.org/search/
**Search String:**
```
(blockchain OR "distributed ledger" OR IPFS OR "smart contract") 
AND (provenance OR "data lineage" OR verification)
AND ("scientific data" OR "research data" OR "open science")
```
**Filters to Apply:**
- Categories: cs.DC (Distributed, Parallel, and Cluster Computing), cs.CY (Computers and Society), q-bio.QM (Quantitative Methods)
- Year: 2018-2026

**Advanced Query:**
```
all:blockchain all:provenance all:"scientific data"
OR all:blockchain all:"data lineage" all:research
OR all:"distributed ledger" all:verification all:data
```

---

#### bioRxiv (Optional - for life sciences)

**Interface:** https://www.biorxiv.org/search/
**Search String:**
```
(blockchain OR "distributed ledger") AND (provenance OR "data management") AND (data OR dataset)
```
**Filters to Apply:**
- Year: 2018-2026

### 6.4 Known-Include Validation

Before full search execution, validate strings against known-include papers:

| # | Paper | Expected Found |
|---|-------|----------------|
| 1 | ProvChain (Liang et al., 2018) | Should find (blockchain + provenance) |
| 2 | MedRec (Azaria et al., 2016) | May find (blockchain + healthcare data) |
| 3 | DGChain (Gonzalez, 2024) | Should find (blockchain + scientific data) |
| 4 | SciLedger (IEEE, 2025) | Should find (blockchain + scientific data) |
| 5 | BlockIPFS (2025) | Should find (IPFS + blockchain) |
| 6 | DMPTool integration studies | Should find (maDMP) |
| 7 | Nature Sci Data - Blockchain (2025) | Should find |
| 8 | This paper (d-OSPv2) | Should find |

**Validation criterion:** String must find at least 6/8 known-includes.

---

## 7. Selection Process

### 7.1 Screening Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    SELECTION PROCESS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐                                          │
│  │  Database        │                                          │
│  │  Searches        │                                          │
│  │  (n=1,955)      │                                          │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                          │
│  │  Remove          │                                          │
│  │  Duplicates      │                                          │
│  │  (n≈1,700)      │                                          │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐     ┌─────────────────┐                │
│  │  Title/Abstract   │────►│  Excluded       │                │
│  │  Screening        │     │  (n≈1,500)      │                │
│  │  (n≈1,700)        │     └─────────────────┘                │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐     ┌─────────────────┐                │
│  │  Full-Text       │────►│  Excluded       │                │
│  │  Assessment      │     │  (n≈100)        │                │
│  │  (n≈200)         │     └─────────────────┘                │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                          │
│  │  Studies         │                                          │
│  │  Included        │                                          │
│  │  (n≈30-50)       │                                          │
│  └──────────────────┘                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Screening Criteria

**Stage 1: Title/Abstract Screening**

Include if:
- Addresses blockchain AND scientific data management AND (provenance OR DMP/maDMP), OR
- Addresses maDMP implementation with any technical system

Exclude if:
- Clearly about non-scientific applications (supply chain, finance), OR
- Opinion/editorial without technical content, OR
- Not in English, OR
- Clearly absence plataform or storage component

**Stage 2: Full-Text Assessment**

Include if:
- Describes technical system/framework with implementation, AND
- Addresses scientific/research data context, AND
- Addresses either provenance tracking OR data management planning

Exclude if:
- Non-research data context, OR
- Duplicate of another included study

### 7.3 Reviewer Agreement

| Stage | Process |
|-------|---------|
| Title/Abstract | Two independent reviewers |
| Full-Text | Two independent reviewers |
| Disagreements | Resolution by third reviewer or discussion |

---

## 8. Data Extraction

### 8.1 Extraction Form

| Field | Description |
|-------|-------------|
| Study_ID | Unique identifier (e.g., REV001) |
| Title | Full title |
| Authors | First author et al. |
| Year | Publication year |
| Source | Journal/Conference name |
| DOI/URL | Persistent identifier |
| Research_Focus | Primary focus: Blockchain / Provenance / maDMP / Combined |
| System_Name | Name of system described |
| Blockchain_Platform | Iroha / Fabric / Ethereum / Multi-chain / Custom |
| Storage_Integration | IPFS / IPFS + blockchain / External DB / Not specified |
| Provenance_Model | PROV-O / PROV-DM / Custom / None |
| maDMP_Support | Full / Partial / None |
| Permission_Model | Permissioned / Permissionless / Hybrid |
| Evaluation_Method | Experiment / Case study / User study / None described |
| Key_Findings | Main technical contributions |
| Limitations | Reported limitations |
| Quality_Score | MMAT rating (1-5) |

### 8.2 Quality Assessment

**Tool:** Modified MMAT (Mixed Methods Appraisal Tool)

**Rating:**
- 5: Excellent - clear methodology, rigorous evaluation, well-supported conclusions
- 4: Good - minor methodological gaps
- 3: Acceptable - some methodological concerns
- 4: Poor - significant gaps
- 1: Very Poor - cannot assess quality

---

## 9. Synthesis Method

### 9.1 Approach

| Synthesis Type | Method |
|----------------|--------|
| Quantitative | Not applicable (heterogeneous studies) |
| Qualitative | Narrative synthesis + thematic analysis |
| Tabulation | Summary tables by category |

### 9.2 Thematic Categories

| Category | Description |
|----------|-------------|
| **Blockchain Platform** | Systems using Iroha, Fabric, Ethereum, multi-chain |
| **Storage Architecture** | IPFS integration, external DB, hybrid approaches |
| **Provenance Model** | PROV-O implementation, custom models, no semantics |
| **maDMP Compliance** | RDA standard adherence level |
| **Permission Model** | Permissioned vs permissionless trade-offs |
| **Evaluation Rigor** | Empirical vs demonstration-only |

### 9.3 Comparison Framework

For rigorous novelty comparison, we will construct a **technical differentiation table**:

| System | Blockchain | Storage | Provenance Model | maDMP | Permissioned | Evaluation |
|--------|-----------|---------|------------------|-------|--------------|------------|
| ProvChain | ? | ? | ? | ? | ? | ? |
| MedRec | ? | ? | ? | ? | ? | ? |
| d-OSPv2 | Iroha | IPFS | PROV-O | Full | Yes | Experiments |

This directly addresses Reviewer concern: "provide rigorous comparison tables with specific technical differentiators"

### 9.4 Gap Analysis (aligned with RQ)

| Gap Identified | Evidence Source | d-OSPv2 Contribution |
|----------------|-----------------|---------------------|
| No blockchain-anchored maDMP | SLR findings | Full implementation |
| No permissioned blockchain for provenance | SLR findings | Hyperledger Iroha |
| No PROV-O on permissioned chain | SLR findings | Full PROV-O mapping |

---

## 10. Reporting

### 10.1 PRISMA 2020 Flow Diagram

Will be completed with actual numbers after search execution.

### 10.2 Required Tables

| Table | Content |
|-------|---------|
| Table 1 | Search strategy by database |
| Table 2 | Study characteristics (all included) |
| Table 3 | Quality assessment results |
| Table 4 | Technical comparison matrix |
| Table 5 | Gap analysis |

---

## 11. Timeline

| Phase | Estimated Duration |
|-------|-------------------|
| Database searches | 0.5 day |
| Title/Abstract screening | 1-2 days |
| Full-Text assessment | 2-3 days |
| Data extraction | 2-3 days |
| Quality assessment | 1 day |
| Synthesis and analysis | 3-5 days |
| Report writing | 3-5 days |

**Estimated total:** 2-3 weeks

---

## 12. Protocol Justification

### 12.1 Why This Focused Approach is Rigorous

| Criterion | How Addressed |
|-----------|---------------|
| **PRISMA compliance** | Full PRISMA 2020 methodology followed |
| **Focused scope** | Single RQ enables deep, rigorous comparison |
| **Manageable search** | ~2,000 records (vs 19,731) enables thorough screening |
| **Novelty support** | Technical comparison tables directly support novelty claims |
| **Evaluation alignment** | Sub-questions inform evaluation design |

### 12.2 Comparison: Version 3.0 vs 4.0

| Aspect | v3.0 | v4.0 |
|--------|------|------|
| Research Questions | 3 RQs | 1 RQ + 5 sub-questions |
| Search Results | 19,731 | ~1,955 |
| Search Complexity | Complex multi-group | Focused intersection |
| Novelty Support | Weak | Strong (comparison tables) |
| SLR Manageability | Impractical | Practical |

---

## 13. References

1. Page MJ, McKenzie JE, Bossuyt PM, et al. The PRISMA 2020 statement: an updated guideline for reporting systematic reviews. BMJ. 2021;372:n71. doi:10.1136/bmj.n71

2. Moher D, Liberati A, Tetzlaff J, Altman DG. The PRISMA Group. Preferred Reporting Items for Systematic Reviews and Meta-Analyses: The PRISMA Statement. PLoS Med. 2009;6(7):e1000097.

3. vom Brocke J, Simons A, Niehaves B, et al. Reconstructing the giant: On the importance of rigour in documenting the literature search process. ECIS. 2009.

4. Kitchenham B, Charters S. Guidelines for performing Systematic Literature Reviews in Software Engineering. Technical Report EBSE-2007-01. Keele University; 2007.

5. Okoli C, Schabram K. A Guide to Conducting a Systematic Literature Review of Information Systems Research. CAIS. 2010;37(1).

---

## Appendix A: Search String Execution

### A.1 IEEE Xplore
1. Go to: https://ieeexplore.ieee.org/
2. Click: Advanced Search → Command Search
3. Query: 
   ```
   ("machine-actionable" OR "maDMP" OR "data management plan" OR DMP) 
   AND (blockchain OR "distributed ledger" OR "Hyperledger" OR Iroha OR Fabric)
   AND (provenance OR "data lineage" OR "chain of custody" OR verification)
   AND ("scientific data" OR "research data" OR "open science")
   ```
4. Filters: Document Type: Conference OR Journal; Year: 2018-2026
5. Results: [Execute and record]

### A.2 ACM Digital Library
1. Go to: https://dl.acm.org/
2. Click: Advanced Search → Edit Query
3. Query: 
   ```
   ("machine-actionable" OR "maDMP" OR "data management plan") 
   AND (blockchain OR "distributed ledger" OR Hyperledger OR Iroha OR Fabric)
   AND (provenance OR "data lineage" OR "chain of custody")
   AND ("scientific data" OR "research data" OR "open science")
   ```
4. Filters: Content Type: Conference Papers, Journal Articles; Year: 2018-2026
5. Results: [Execute and record]

### A.3 Scopus
1. Go to: https://www.scopus.com/
2. Click: Advanced Search
3. Query (field codes): 
   ```
   TITLE-ABS-KEY("machine-actionable" OR maDMP OR "data management plan") 
   AND TITLE-ABS-KEY(blockchain OR "distributed ledger" OR Hyperledger OR Iroha)
   AND TITLE-ABS-KEY(provenance OR "data lineage" OR verification)
   AND TITLE-ABS-KEY("scientific data" OR "research data")
   ```
4. Filters: Subject Area: Computer Science; Document Type: Article, Conference Paper; Year: 2018-2026
5. Results: [Execute and record]

### A.4 Web of Science
1. Go to: https://webofscience.com/
2. Click: Advanced Search → Query Builder
3. Query (field tags): 
   ```
   TS=("machine-actionable" OR maDMP OR "data management plan") 
   AND TS=(blockchain OR "distributed ledger" OR Hyperledger OR Iroha OR Fabric)
   AND TS=(provenance OR "data lineage" OR verification)
   AND TS=("scientific data" OR "research data" OR "open science")
   ```
4. Filters: Categories: Computer Science, Information Science; Doc Types: Article, Conference Paper, Early Access; Year: 2018-2026
5. Results: [Execute and record]

### A.5 arXiv
1. Go to: https://arxiv.org/search/
2. Query: 
   ```
   (blockchain OR "distributed ledger" OR IPFS OR "smart contract") 
   AND (provenance OR "data lineage" OR verification)
   AND ("scientific data" OR "research data" OR "open science")
   ```
3. Filters: Categories: cs.DC, cs.CY, q-bio.QM; Year: 2018-2026
4. Results: [Execute and record]

---

### A.6 Results Recording

Execute searches and record results in the table below:

| Database | Date | Results | Executed By |
|----------|------|---------|-------------|
| IEEE Xplore | | | |
| ACM DL | | | |
| Scopus | | | |
| WoS | | | |
| arXiv | | | |

---

## Protocol Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-26 | Initial protocol draft |
| 2.0 | 2026-02-27 | Updated search strategy, expanded terms |
| 3.0 | 2026-02-27 | Added search results (19,731), pragmatic approach |
| 4.0 | 2026-02-28 | Revised: Single focused RQ, narrowed search |
| 4.1 | 2026-02-28 | Added database-specific search strings with syntax |
| 4.2 | 2026-02-28 | Validated title-focused search string (IEEE Xplore) |
| 4.3 | 2026-02-28 | Added validated syntax for 6 databases (IEEE, Scopus, WoS, PubMed, arXiv, ACM) |
| 4.4 | 2026-03-05 | Updated eligibility and exclusion criteria |

---

**Protocol prepared:** March 05, 2026  
**Version:** 4.4  
**To be registered on:** OSF (osf.io)

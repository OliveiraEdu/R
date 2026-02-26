PRISMA 2020 Protocol: Systematic Review of Blockchain-Enabled Provenance for Scientific Data Management
Protocol Version: 1.0  
Date: February 26, 2026  
Status: Draft - Pending Registration  
***1. Administrative Information
1.1 Title
Blockchain-Enabled Provenance for Scientific Data Management: A Systematic Review
1.2 Review Team
Primary Reviewer: [To be completed]
Secondary Reviewer: [To be completed]
Third Reviewer (disputes): [To be completed]
1.3 Protocol Registration
Planned registration: OSF (osf.io)
Registration date: [To be completed]
***2. Rationale
The reproducibility crisis in scientific research has been widely documented, with studies indicating that over 70% of researchers have failed to reproduce another scientist's work. This problem stems from inadequate provenance tracking across the data lifecycle. Existing repository infrastructure lacks cryptographic guarantees for data lineage and authorship attribution.
This systematic review aims to map the current landscape of blockchain-based provenance systems for scientific data management, with specific focus on:
Provenance tracking approaches using blockchain technology
Machine-actionable Data Management Plans (maDMPs) implementations
Integration of semantic provenance models (W3C PROV-O) with blockchain
The review will identify gaps that d-OSPv2 addresses and provide evidence for the uniqueness of our contribution.
***3. Research Questions
| RQ | Question |
|-----|----------|
| RQ1 | How can provenance semantics be integrated into maDMP workflows to enable automated verification of data management commitments? |
| RQ2 | What architectural patterns enable cryptographic provenance tracking while maintaining scalability and privacy requirements? |
| RQ3 | How does decentralized provenance infrastructure compare to centralized alternatives in terms of performance, completeness, and usability? |
***4. Eligibility Criteria
4.1 Inclusion Criteria
| # | Criterion | Specification |
|---|-----------|---------------|
| I1 | Language | English language publications |
| I2 | Publication type | Peer-reviewed journal articles, conference proceedings, arXiv preprints |
| I3 | Date range | Publications from 2018 to 2026 |
| I4 | Technical implementation | Must describe a technical system, framework, or methodology (not just conceptual) |
| I5 | Domain relevance | Must address blockchain, provenance tracking, or maDMP for scientific/research data |
4.2 Exclusion Criteria
| # | Criterion | Rationale |
|---|-----------|-----------|
| E1 | Opinion pieces, editorials | Not empirical/technical contributions |
| E2 | Non-research contexts | Supply chains, financial applications, non-scientific use cases |
| E3 | No technical implementation | Conceptual frameworks without implementation details |
| E4 | Duplicate publications | Same work reported in multiple venues |
| E5 | Full text unavailable | Cannot assess technical content |
| E6 | ThESIS not meeting inclusion criteria I4-I5 | Does not address blockchain for scientific data provenance |
***5. Information Sources
5.1 Database Search
| Database | Platform | Search Date |
|----------|----------|-------------|
| IEEE Xplore | ieeexplore.ieee.org | [To be completed] |
| ACM Digital Library | dl.acm.org | [To be completed] |
| Scopus | scopus.com | [To be completed] |
| Web of Science | webofscience.com | [To be completed] |
| Google Scholar | scholar.google.com | [To be completed] |
5.2 Additional Sources
Reference lists of included studies (backward citation tracking)
Forward citation tracking of key papers
Preprint servers: arXiv, bioRxiv
***6. Search Strategy
6.1 Search Concepts
| Concept | Terms |
|---------|-------|
| A: Provenance | provenance, "data lineage", reproducibility, verification, "chain of custody" |
| B: Technology | blockchain, "distributed ledger", decentralized, IPFS, "content addressable", "distributed hash table" |
| C: Data Management | DMP, "data management plan", maDMP, FAIR, "metadata standards", "data sharing" |
6.2 Search Strings by Database
IEEE Xplore:
("provenance" OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
ACM Digital Library:
(provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
Scopus:
(provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
Web of Science:
(provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
Google Scholar:
Use simplified search: "blockchain provenance scientific data"
Limit to first 200 results (relevance ranking)
6.3 Search Modifications
| Database | Modification |
|----------|--------------|
| IEEE Xplore | Add: documenttype:conference OR documenttype:journal |
| ACM DL | Add: filter:content-type:conference OR filter:content-type:journal |
| Scopus | Add: AND (SUBJAREA:COMP OR SUBJAREA:DATA) |
| WoS | Add: AND (WC:Computer Science OR WC:Information Science) |
***7. Selection Process
7.1 Screening Workflow
┌─────────────────────────────────────────────────────────────────┐
│                    SELECTION PROCESS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐                                          │
│  │  Database        │                                          │
│  │  Searches        │                                          │
│  │  (n=XXX)        │                                          │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                          │
│  │  Remove          │                                          │
│  │  Duplicates      │                                          │
│  │  (n=XXX)        │                                          │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐     ┌─────────────────┐                  │
│  │  Title/Abstract  │────►│  Excluded       │                  │
│  │  Screening       │     │  (n=XXX)        │                  │
│  │  (n=XXX)         │     └─────────────────┘                  │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐     ┌─────────────────┐                  │
│  │  Full-Text       │────►│  Excluded       │                  │
│  │  Assessment      │     │  (n=XXX)        │                  │
│  │  (n=XXX)         │     └─────────────────┘                  │
│  └────────┬─────────┘                                          │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                          │
│  │  Studies         │                                          │
│  │  Included        │                                          │
│  │  (n=XXX)         │                                          │
│  └──────────────────┘                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
7.2 Screening Criteria
Stage 1: Title/Abstract Screening
Include if:
Addresses blockchain for scientific data management, OR
Addresses provenance tracking for research data, OR
Addresses machine-actionable DMPs
Exclude if:
Clearly about non-scientific applications, OR
Opinion/editorial without technical content, OR
Not in English
Stage 2: Full-Text Assessment
Include if:
Describes technical system/framework, AND
Addresses scientific/research data context
Exclude if:
No implementation details, OR
Non-research context (supply chain, finance), OR
Duplicate of another included study
7.3 Reviewer Agreement
| Stage | Process |
|-------|---------|
| Title/Abstract | Two independent reviewers |
| Full-Text | Two independent reviewers |
| Disagreements | Resolution by third reviewer or discussion |
***8. Data Extraction
8.1 Extraction Form
| Field | Description |
|-------|-------------|
| Study_ID | Unique identifier (e.g., REV001) |
| Title | Full title |
| Authors | First author et al. |
| Year | Publication year |
| Source | Journal/Conference name |
| DOI/URL | Persistent identifier |
| Research_Focus | Primary focus: Blockchain / Provenance / maDMP |
| System_Name | Name of system described (if any) |
| Blockchain_Platform | Iroha / Ethereum / Fabric / Multi-chain / None / Not specified |
| Provenance_Model | PROV-O / PROV-DM / Custom / None |
| maDMP_Support | Full / Partial / None |
| Evaluation_Method | Experiment / Case study / User study / None / Not clear |
| Key_Findings | Main technical contributions |
| Limitations | Reported limitations |
| Quality_Score | MMAT rating |
8.2 Quality Assessment
Tool: Modified MMAT (Mixed Methods Appraisal Tool)
Domains:
Clear research questions
Appropriate methodology
Rigorous data collection
Sound analysis
Well-supported conclusions
***9. Synthesis Method
9.1 Approach
| Synthesis Type | Method |
|----------------|--------|
| Quantitative | Not applicable (heterogeneous studies) |
| Qualitative | Narrative synthesis + thematic analysis |
| Tabulation | Summary tables by category |
9.2 Thematic Categories
| Category | Description |
|----------|-------------|
| Blockchain Platform | Systems using Iroha, Fabric, Ethereum, etc. |
| Provenance Model | PROV-O, custom models, no semantics |
| maDMP Integration | Systems supporting machine-actionable DMPs |
| Evaluation Type | Empirical vs. conceptual |
| Application Domain | Genomics, climate, general scientific |
9.3 Analysis Framework
| Dimension | Analysis |
|-----------|----------|
| Technical architecture | Compare blockchain + storage combinations |
| Provenance coverage | Map PROV-O relationships implemented |
| maDMP compliance | Assess RDA standard adherence |
| Evaluation rigor | Rate quality of evidence |
| Gap identification | Map missing combinations |
***10. Reporting
10.1 PRISMA 2020 Flow Diagram
Will be completed with actual numbers after search execution.
10.2 Required Tables
| Table | Content |
|-------|---------|
| Table 1 | Search strategy by database |
| Table 2 | Study characteristics |
| Table 3 | Quality assessment results |
| Table 4 | Thematic synthesis by category |
| Table 5 | Gap analysis |
***11. Timeline
| Phase | Estimated Duration |
|-------|-------------------|
| Database searches | 1 week |
| Deduplication | 1 day |
| Title/Abstract screening | 1 week |
| Full-Text assessment | 2 weeks |
| Data extraction | 2 weeks |
| Quality assessment | 1 week |
| Synthesis and analysis | 2 weeks |
| Report writing | 2 weeks |
Estimated total: 8-10 weeks
***12. Deviations from Protocol
Any deviations from this protocol will be documented and justified in the final report.
***13. References
Page MJ, McKenzie JE, Bossuyt PM, et al. The PRISMA 2020 statement: an updated guideline for reporting systematic reviews. BMJ. 2021;372:n71. doi:10.1136/bmj.n71
Moher D, Liberati A, Tetzlaff J, Altman DG. The PRISMA Group. Preferred Reporting Items for Systematic Reviews and Meta-Analyses: The PRISMA Statement. PLoS Med. 2009;6(7):e1000097. doi:10.1371/journal.pmed.1000097
***Appendix A: Draft Search Strings (to be executed)
=== IEEE Xplore ===
Search: ("provenance" OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
=== ACM DL ===
Search: (provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
=== Scopus ===
Search: (provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
=== Web of Science ===
Search: (provenance OR "data lineage" OR reproducibility OR verification) 
AND (blockchain OR "distributed ledger" OR decentralized OR IPFS) 
AND (DMP OR "data management plan" OR maDMP OR FAIR)
***Protocol prepared: February 26, 2026  
To be registered on: OSF (osf.io)  
Version: 1.0
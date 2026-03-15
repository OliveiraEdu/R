# Changelog

All notable changes to the SLR Engine will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-03-14

### Added
- **IEEE Xplore Integration**: Full support for IEEE Xplore database with `import_ieee()` function
- **Protocol 4.0 Support**: Focused RQ with title-focused search strings
  - 5-concept search: maDMP + provenance + technology + openness + scientific data
  - Config-driven search string builder with database-specific syntax
  - Title-focused operators for IEEE, Scopus, WoS, PubMed, ACM, arXiv, Scholar
- **Protocol 3.0 Support**: Broad search strategy with preprint servers
  - arXiv API integration (`search_arxiv()`) with 6-month default window
  - bioRxiv API integration (`search_biorxiv()`) with 6-month default window
  - Preprint-aware screening criteria
- **Enhanced Data Fields**:
  - `ID`: Author keywords (Scopus, IEEE, WoS, ACM)
  - `OA`: Open Access status (Scopus, WoS)
  - `LA`: Language (WoS)
  - `PT`: Publication Type/Document Type (Scopus)
  - `TC`: Citation counts (IEEE)
- **New Extraction Fields (Protocol 4.0)**:
  - `Storage_Integration`: IPFS, IPFS + blockchain, External DB, Hybrid
  - `Permission_Model`: Permissioned, Permissionless, Hybrid
- **Enhanced Reporting**:
  - PRISMA flow with percentages
  - Storage Integration and Permission Model tables
  - Cross-tabulation analysis
  - Top publication sources
  - MMAT items with Yes/No counts
  - Thematic synthesis
  - Detailed Key Findings and Implications sections
  - Comprehensive Limitations list
- **Bibliometric Analysis**:
  - Keywords including author keywords from ID column
  - Open Access (OA) metrics
  - Publication Type (PT) metrics
  - New exports: `bibliometric_oa.csv`, `bibliometric_pubtypes.csv`
- **Static-File Workflow**: All imports now use pre-exported CSV/BIB files for reproducibility
- **Config-Driven Pipeline**: `config.yaml` controls search strings and database settings
- **Comprehensive Documentation**:
  - USER_MANUAL.md with static-file workflow instructions
  - docs/PROTOCOL_4.0_USAGE.md for Protocol 4.0 details
- **Full Pipeline Validation**:
  - 13,248 records processed across 7 sources
  - 6,525 duplicates removed (49.3% rate)
  - 247 studies included after screening and assessment
  - PRISMA 2020 compliant outputs generated

### Changed
- Updated USER_MANUAL.md to reflect static-file workflow (removed live API search references)
- Updated test_full_pipeline.R to use data/ folder
- Updated AGENTS.md with comprehensive development guidelines
- Enhanced NAMESPACE for full package exports

### Fixed
- Syntax error in pipeline.R (duplicate code)
- Database-specific title operator syntax validation

---

## [1.0.0] - 2026-02-27

### Added
- **Database Import**: Support for Web of Science (BibTeX), Scopus (CSV), PubMed (text), IEEE Xplore (CSV), ACM DL (CSV)
- **Deduplication Engine**: DOI-based and title+author+year matching with configurable thresholds
- **Title/Abstract Screening**: Automated eligibility criteria matching with PRISMA protocol keywords
- **Full-Text Assessment**: Two-stage screening workflow
- **Data Extraction**: Automated extraction of research focus, blockchain platform, provenance model, maDMP support, evaluation method
- **Quality Assessment**: MMAT-based quality scoring with automated indicators
- **PRISMA Reporting**: Flow diagram generation with CSV, LaTeX, and Mermaid flowchart outputs
- **Automated Reports**: Markdown and LaTeX report generation with full synthesis

### Output Formats
- CSV UTF-8 for all tabular data
- LaTeX for PRISMA flow diagram and full reports
- Markdown with Mermaid flowcharts for documentation
- RDS files for intermediate pipeline results

### Dependencies
- dplyr (required)
- Base R for all I/O operations (no external dependencies for core functions)

### Architecture
- Standalone import functions (no bibliometrix dependency required)
- Modular design with separate R files for each pipeline stage
- Pipeline orchestration via `run_slr_pipeline()`

---

## [1.0.0] - 2026-02-27

### Added
- **Database Import**: Support for Web of Science (BibTeX), Scopus (CSV), PubMed (text), IEEE Xplore (CSV), ACM DL (CSV)
- **Deduplication Engine**: DOI-based and title+author+year matching with configurable thresholds
- **Title/Abstract Screening**: Automated eligibility criteria matching with PRISMA protocol keywords
- **Full-Text Assessment**: Two-stage screening workflow
- **Data Extraction**: Automated extraction of research focus, blockchain platform, provenance model, maDMP support, evaluation method
- **Quality Assessment**: MMAT-based quality scoring with automated indicators
- **PRISMA Reporting**: Flow diagram generation with CSV, LaTeX, and Mermaid flowchart outputs
- **Automated Reports**: Markdown and LaTeX report generation with full synthesis

### Output Formats
- CSV UTF-8 for all tabular data
- LaTeX for PRISMA flow diagram and full reports
- Markdown with Mermaid flowcharts for documentation
- RDS files for intermediate pipeline results

### Dependencies
- dplyr (required)
- Base R for all I/O operations (no external dependencies for core functions)

### Architecture
- Standalone import functions (no bibliometrix dependency required)
- Modular design with separate R files for each pipeline stage
- Pipeline orchestration via `run_slr_pipeline()`

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-02-27 | Initial release with full pipeline |
| | | - Database import (WoS, Scopus, PubMed, IEEE, ACM) |
| | | - Deduplication engine |
| | | - Screening workflow |
| | | - Data extraction |
| | | - Quality assessment (MMAT) |
| | | - PRISMA reporting (CSV, LaTeX, Markdown) |
| | | - Automated report generation |

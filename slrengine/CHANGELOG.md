# Changelog

All notable changes to the SLR Engine will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for PubMed CSV format via `import_pubmed_csv()`
- Auto-detection of file formats via `import_file()`
- Updated data/ directory with sample database exports
- **arXiv API integration**: `search_arxiv()` for searching arXiv preprints via API
- **bioRxiv API integration**: `search_biorxiv()` for searching bioRxiv preprints via API

### Changed
- Updated test_full_pipeline.R to use data/ folder

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

# Main pipeline for Systematic Literature Review

#' Run complete SLR pipeline
#' @param sources Named list of database file paths
#' @param output_dir Output directory for results
#' @param arxiv_search Search string for arXiv (optional)
#' @param biorxiv_search Search string for bioRxiv (optional)
#' @param protocol_version Protocol version ("1.0" or "3.0")
#' @return List with all pipeline outputs
#' @export
run_slr_pipeline <- function(sources, 
                            output_dir = "slr_results",
                            arxiv_search = NULL,
                            biorxiv_search = NULL,
                            protocol_version = "1.0") {
  
  message("=== Starting SLR Pipeline ===\n")
  message(paste("Protocol version:", protocol_version, "\n"))
  
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Step 1: Import databases
  message("Step 1: Importing databases...")
  
  # Import traditional databases
  merged <- import_databases(sources, remove_duplicates = TRUE)
  
  # Import from preprint servers if specified
  preprint_records <- data.frame()
  
  if (!is.null(arxiv_search)) {
    message("  Searching arXiv...")
    source("slrengine/R/import_arxiv.R")
    arxiv_data <- tryCatch({
      search_arxiv(arxiv_search, max_results = 100)
    }, error = function(e) {
      warning(paste("arXiv search failed:", e$message))
      data.frame()
    })
    if (nrow(arxiv_data) > 0) {
      arxiv_data$DB <- "arXiv"
      preprint_records <- rbind(preprint_records, arxiv_data)
      message(paste("    Retrieved", nrow(arxiv_data), "arXiv records"))
    }
  }
  
  if (!is.null(biorxiv_search)) {
    message("  Searching bioRxiv...")
    source("slrengine/R/import_arxiv.R")
    biorxiv_data <- tryCatch({
      search_biorxiv(biorxiv_search, max_results = 100)
    }, error = function(e) {
      warning(paste("bioRxiv search failed:", e$message))
      data.frame()
    })
    if (nrow(biorxiv_data) > 0) {
      biorxiv_data$DB <- "bioRxiv"
      preprint_records <- rbind(preprint_records, biorxiv_data)
      message(paste("    Retrieved", nrow(biorxiv_data), "bioRxiv records"))
    }
  }
  
  # Merge preprint records with main dataset
  if (nrow(preprint_records) > 0) {
    merged <- tryCatch({
      dplyr::bind_rows(merged, preprint_records)
    }, error = function(e) {
      warning(paste("Failed to merge preprint records:", e$message))
      merged
    })
  }
  
  merged <- deduplicate_records(merged)
  saveRDS(merged, file.path(output_dir, "01_merged_raw.rds"))
  message(paste("  Total records:", nrow(merged), "\n"))
  
  # Step 2: Title/Abstract screening
  message("Step 2: Title/Abstract screening...")
  screened <- title_abstract_screening(merged)
  screened <- screened[screened$screening_decision == "include", ]
  saveRDS(screened, file.path(output_dir, "02_screened.rds"))
  message(paste("  Included after screening:", nrow(screened), "\n"))
  
  # Step 3: Full-text assessment
  message("Step 3: Full-text assessment...")
  fulltext <- fulltext_assessment(screened)
  fulltext_included <- fulltext[fulltext$fulltext_status == "include", ]
  saveRDS(fulltext, file.path(output_dir, "03_fulltext.rds"))
  message(paste("  Included after full-text:", nrow(fulltext_included), "\n"))
  
  # Step 4: Data extraction
  message("Step 4: Data extraction...")
  extraction <- extract_data(fulltext_included)
  saveRDS(extraction, file.path(output_dir, "04_extraction.rds"))
  
  # Export extraction form for manual completion
  export_extraction_form(extraction, file.path(output_dir, "04_extraction_form.csv"))
  message(paste("  Extracted:", nrow(extraction), "studies\n"))
  
  # Step 5: Quality assessment
  message("Step 5: Quality assessment...")
  qa <- quality_assessment(extraction)
  qa <- auto_quality_indicators(qa)
  saveRDS(qa, file.path(output_dir, "05_quality.rds"))
  message(paste("  Quality scores calculated\n"))
  
  # Step 6: Generate PRISMA report
  message("Step 6: Generating PRISMA report...")
  
  prisma <- generate_prisma_flow(
    records_all = nrow(merged) + attr(merged, "duplicates_removed"),
    records_screened = nrow(merged),
    records_excluded_ta = nrow(merged) - nrow(screened),
    records_assessed_ft = nrow(screened),
    records_excluded_ft = nrow(screened) - nrow(fulltext_included),
    records_included = nrow(extraction)
  )
  
  export_prisma_flow(prisma, file.path(output_dir, "06_prisma_flow.csv"))
  export_prisma_flow_latex(prisma, file.path(output_dir, "06_prisma_flow.tex"))

  # Generate summary tables
  export_summary_tables(extraction, file.path(output_dir, "07_summary_tables.csv"))

  # Gap analysis
  gaps <- gap_analysis(extraction)
  write.csv(gaps, file.path(output_dir, "08_gap_analysis.csv"), 
            fileEncoding = "UTF-8", row.names = FALSE)

  # Generate reports
  message("Generating reports...")
  generate_markdown_report(prisma, extraction, qa, file.path(output_dir, "09_report.md"))
  generate_latex_report(prisma, extraction, qa, file.path(output_dir, "09_report.tex"))

  message("\n=== Pipeline Complete ===")
  message(paste("Results saved to:", output_dir))
  
  list(
    merged = merged,
    screened = screened,
    fulltext = fulltext,
    extraction = extraction,
    quality = qa,
    prisma = prisma,
    output_dir = output_dir
  )
}


#' Generate search strings for databases
#' @param protocol_version Protocol version string
#' @return List with search strings by database
#' @export
generate_search_strings <- function(protocol_version = "1.0") {
  
  # Base concepts (Protocol 1.0 - narrow)
  concepts <- list(
    provenance = c("provenance", "\"data lineage\"", "reproducibility", "verification", "\"chain of custody\""),
    technology = c("blockchain", "\"distributed ledger\"", "decentralized", "IPFS", "\"content addressable\""),
    data_management = c("DMP", "\"data management plan\"", "maDMP", "FAIR", "\"metadata standards\"")
  )
  
  # Protocol 3.0 - Broad search strategy
  broad_concepts <- list(
    technology = c(
      "blockchain", "\"distributed ledger\"", "\"distributed ledger technology\"", "DLT",
      "\"smart contract\"", "\"smart contracts\"",
      "Hyperledger", "Iroha", "Fabric", "Corda", "Ethereum",
      "IPFS", "\"content addressable\"", "\"content addressing\""
    ),
    scientific_data = c(
      "\"scientific data\"", "\"research data\"", "\"scholarly data\"",
      "\"data management\"", "\"data sharing\"", "\"data repository\"",
      "\"open science\"", "\"open data\"", "FAIR"
    ),
    provenance = c(
      "provenance", "\"data lineage\"", "\"chain of custody\"",
      "\"tamper-evident\"", "immutable", "integrity", "verification",
      "reproducibility", "\"reproducible research\""
    ),
    dmp = c(
      "DMP", "\"data management plan\"", "maDMP", "\"machine-actionable\"",
      "\"DMPTool\"", "DMPonline", "Argos", "DAMAP"
    )
  )
  
  # Build narrow search strings (Protocol 1.0)
  narrow_strings <- list(
    ieee = paste0(
      "(", paste(concepts$provenance, collapse = " OR "), ") ",
      "AND (", paste(concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(concepts$data_management, collapse = " OR "), ")"
    ),
    acm = paste0(
      "(", paste(concepts$provenance, collapse = " OR "), ") ",
      "AND (", paste(concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(concepts$data_management, collapse = " OR "), ")"
    ),
    scopus = paste0(
      "(", paste(concepts$provenance, collapse = " OR "), ") ",
      "AND (", paste(concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(concepts$data_management, collapse = " OR "), ")"
    ),
    wos = paste0(
      "(", paste(concepts$provenance, collapse = " OR "), ") ",
      "AND (", paste(concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(concepts$data_management, collapse = " OR "), ")"
    ),
    scholar = "\"blockchain provenance scientific data\""
  )
  
  # Build broad search strings (Protocol 3.0 - Phase 1)
  broad_strings <- list(
    ieee = paste0(
      "(", paste(broad_concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(broad_concepts$scientific_data, collapse = " OR "), ")"
    ),
    acm = paste0(
      "(", paste(broad_concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(broad_concepts$scientific_data, collapse = " OR "), ")"
    ),
    scopus = paste0(
      "(", paste(broad_concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(broad_concepts$scientific_data, collapse = " OR "), ")"
    ),
    wos = paste0(
      "(", paste(broad_concepts$technology, collapse = " OR "), ") ",
      "AND (", paste(broad_concepts$scientific_data, collapse = " OR "), ")"
    ),
    arxiv = paste0(
      "(", paste(broad_concepts$technology[c(1,2,7,8)], collapse = " OR "), ") ",
      "AND (", paste(broad_concepts$scientific_data, collapse = " OR "), ")"
    ),
    biorxiv = paste0(
      "(", paste(broad_concepts$technology[c(1,2)], collapse = " OR "), ") ",
      "AND (", paste(c(broad_concepts$scientific_data[c(1,2,4)], broad_concepts$provenance[c(1)]), collapse = " OR "), ")"
    ),
    scholar = "\"blockchain provenance scientific data\""
  )
  
  # Protocol 4.0 - Title-focused search (narrow scope, high precision)
  protocol_4_concepts <- list(
    madmp = c("\"machine-actionable\"", "maDMP", "\"data management\"", "DMP"),
    provenance = c("provenance", "\"data lineage\"", "\"chain of custody\"", "verification"),
    technology = c("platform", "repository", "storage", "blockchain", "IPFS", "decentralized"),
    semantic = c("PROV-O", "semantic", "FAIR", "reproducibility", "reproducible"),
    scientific_data = c("\"scientific data\"", "\"research data\"", "\"open science\"", "metadata")
  )
  
  # Build Protocol 4.0 title-focused strings (from validated search)
  protocol_4_strings <- list(
    ieee = paste0(
      '("Document Title":"machine-actionable" OR "Document Title":"maDMP" OR "Document Title":"data management" OR "Document Title":DMP OR "Document Title":provenance OR "Document Title":"data lineage" OR "Document Title":"chain of custody" OR "Document Title":verification OR "Document Title":"scientific data" OR "Document Title":"research data" OR "Document Title":"open science" OR "Document Title":metadata OR "Document Title":"PROV-O" OR "Document Title":semantic OR "Document Title":desci OR "Document Title":FAIR OR "Document Title":reproducibility OR "Document Title":reproducible) AND ("Document Title":platform OR "Document Title":repository OR "Document Title":storage OR "Document Title":blockchain OR "Document Title":IPFS OR "Document Title":decentralized)'
    ),
    scopus = paste0(
      '(TITLE("machine-actionable") OR TITLE("maDMP") OR TITLE("data management") OR TITLE("DMP") OR TITLE("provenance") OR TITLE("data lineage") OR TITLE("chain of custody") OR TITLE("verification") OR TITLE("scientific data") OR TITLE("research data") OR TITLE("open science") OR TITLE("metadata") OR TITLE("PROV-O") OR TITLE("semantic") OR TITLE("desci") OR TITLE("FAIR") OR TITLE("reproducibility") OR TITLE("reproducible")) AND (TITLE("platform") OR TITLE("repository") OR TITLE("storage") OR TITLE("blockchain") OR TITLE("IPFS") OR TITLE("decentralized"))'
    ),
    wos = paste0(
      'TI=("machine-actionable" OR "maDMP" OR "data management" OR "DMP" OR "provenance" OR "data lineage" OR "chain of custody" OR "verification" OR "scientific data" OR "research data" OR "open science" OR "metadata" OR "PROV-O" OR "semantic" OR "desci" OR "FAIR" OR "reproducibility" OR "reproducible") AND TI=("platform" OR "repository" OR "storage" OR "blockchain" OR "IPFS" OR "decentralized")'
    ),
    pubmed = paste0(
      '("machine-actionable"[ti] OR "maDMP"[ti] OR "data management"[ti] OR "DMP"[ti] OR "provenance"[ti] OR "data lineage"[ti] OR "chain of custody"[ti] OR "verification"[ti] OR "scientific data"[ti] OR "research data"[ti] OR "open science"[ti] OR "metadata"[ti] OR "PROV-O"[ti] OR "semantic"[ti] OR "desci"[ti] OR "FAIR"[ti] OR "reproducibility"[ti] OR "reproducible"[ti]) AND ("platform"[ti] OR "repository"[ti] OR "storage"[ti] OR "blockchain"[ti] OR "IPFS"[ti] OR "decentralized"[ti])'
    ),
    acm = paste0(
      '(Title:"machine-actionable" OR Title:maDMP OR Title:"data management" OR Title:DMP OR Title:provenance OR Title:"data lineage" OR Title:"chain of custody" OR Title:verification OR Title:"scientific data" OR Title:"research data" OR Title:"open science" OR Title:metadata OR Title:PROV-O OR Title:semantic OR Title:desci OR Title:FAIR OR Title:reproducibility OR Title:reproducible) AND (Title:platform OR Title:repository OR Title:storage OR Title:blockchain OR Title:IPFS OR Title:decentralized)'
    ),
    arxiv = paste0(
      '(ti:"machine-actionable" OR ti:maDMP OR ti:"data management" OR ti:DMP OR ti:provenance OR ti:"data lineage" OR ti:"chain of custody" OR ti:verification OR ti:"scientific data" OR ti:"research data" OR ti:"open science" OR ti:metadata OR ti:PROV-O OR ti:semantic OR ti:desci OR ti:FAIR OR ti:reproducibility OR ti:reproducible) AND (ti:platform OR ti:repository OR ti:storage OR ti:blockchain OR ti:IPFS OR ti:decentralized)'
    ),
    scholar = "\"machine-actionable\" OR maDMP blockchain provenance \"scientific data\""
  )
  
  # Protocol 4.0 filters
  protocol_4_filters <- list(
    ieee = "Document Type: Conference OR Journal; Year: 2018-2026",
    scopus = "Subject Area: Computer Science; Doc Type: Article, Conference Paper; Year: 2018-2026",
    wos = "Categories: Computer Science, Information Science; Doc Types: Article, Conference Paper; Year: 2018-2026",
    pubmed = "Publication Types: Article, Review, Clinical Trial; Year: 2018-2026",
    acm = "Content Type: Conference Papers, Journal Articles; Year: 2018-2026",
    arxiv = "Categories: cs.DC, cs.CY, q-bio.QM; Year: 2018-2026",
    scholar = "Limit first 200 results"
  )
  
  # arXiv categories
  arxiv_categories <- c("cs.DC", "q-bio.QM", "stat.ML", "cs.LG", "cs.AI")
  
  # Return based on protocol version
  if (protocol_version == "1.0") {
    search_strings <- narrow_strings
  } else if (protocol_version == "3.0") {
    search_strings <- broad_strings
  } else if (protocol_version == "4.0") {
    search_strings <- protocol_4_strings
  } else {
    search_strings <- narrow_strings
  }
  
  # Return full protocol config
  if (protocol_version == "4.0") {
    list(
      protocol_version = protocol_version,
      concepts = protocol_4_concepts,
      filters = protocol_4_filters,
      arxiv_categories = arxiv_categories,
      date_range = "2018-2026",
      search_strings = search_strings,
      strategy = "title-focused",
      focus = "maDMP + blockchain provenance intersection"
    )
  } else if (protocol_version == "3.0") {
    list(
      protocol_version = protocol_version,
      concepts_narrow = concepts,
      concepts_broad = broad_concepts,
      narrow = narrow_strings,
      broad = broad_strings,
      filters = filters,
      arxiv_categories = arxiv_categories,
      date_range = "2018-2026",
      search_strings = search_strings,
      strategy = "abstract-focused",
      focus = "Technology + Scientific Data (broad)"
    )
  } else {
    list(
      protocol_version = protocol_version,
      concepts = concepts,
      narrow = narrow_strings,
      filters = filters,
      arxiv_categories = arxiv_categories,
      date_range = "2018-2026",
      search_strings = search_strings,
      strategy = "abstract-focused",
      focus = "Provenance + Technology + DMP (narrow)"
    )
  }
}

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
  
  # Filters
  filters <- list(
    ieee = "documenttype:conference OR documenttype:journal",
    acm = "filter:content-type:conference OR filter:content-type:journal",
    scopus = "SUBJAREA:COMP OR SUBJAREA:DATA",
    wos = "WC:Computer Science OR WC:Information Science",
    scholar = "No specific filters",
    arxiv = "cat:cs.DC OR cat:q-bio.QM OR cat:stat.ML",
    biorxiv = "No category filter"
  )
  
  # arXiv categories
  arxiv_categories <- c("cs.DC", "q-bio.QM", "stat.ML", "cs.LG", "cs.AI")
  
  # Return based on protocol version
  if (protocol_version == "1.0") {
    search_strings <- narrow_strings
  } else if (protocol_version == "3.0") {
    search_strings <- broad_strings
  } else {
    search_strings <- narrow_strings
  }
  
  list(
    protocol_version = protocol_version,
    concepts_narrow = concepts,
    concepts_broad = broad_concepts,
    narrow = narrow_strings,
    broad = broad_strings,
    filters = filters,
    arxiv_categories = arxiv_categories,
    date_range = "2018-2026",
    search_strings = search_strings
  )
}

# Main pipeline for Systematic Literature Review

#' Run complete SLR pipeline
#' @param sources Named list of database file paths
#' @param output_dir Output directory for results
#' @return List with all pipeline outputs
#' @export
run_slr_pipeline <- function(sources, output_dir = "slr_results") {
  
  message("=== Starting SLR Pipeline ===\n")
  
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Step 1: Import databases
  message("Step 1: Importing databases...")
  merged <- import_databases(sources, remove_duplicates = TRUE)
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
  export_extraction_form(extraction, file.path(output_dir, "04_extraction_form.xlsx"))
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
  
  export_prisma_flow(prisma, file.path(output_dir, "06_prisma_flow.xlsx"))
  
  # Generate summary tables
  export_summary_tables(extraction, file.path(output_dir, "07_summary_tables.xlsx"))
  
  # Gap analysis
  gaps <- gap_analysis(extraction)
  if (!requireNamespace("writexl", quietly = TRUE)) {
    warning("writexl not available, skipping gap analysis export")
  } else {
    writexl::write_xlsx(list(Gap_Analysis = gaps), file.path(output_dir, "08_gap_analysis.xlsx"))
  }
  
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
  
  # Base concepts
  concepts <- list(
    provenance = c("provenance", "\"data lineage\"", "reproducibility", "verification", "\"chain of custody\""),
    technology = c("blockchain", "\"distributed ledger\"", "decentralized", "IPFS", "\"content addressable\""),
    data_management = c("DMP", "\"data management plan\"", "maDMP", "FAIR", "\"metadata standards\"")
  )
  
  # Build search strings
  search_strings <- list(
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
  
  # Add filters
  filters <- list(
    ieee = "documenttype:conference OR documenttype:journal",
    acm = "filter:content-type:conference OR filter:content-type:journal",
    scopus = "SUBJAREA:COMP OR SUBJAREA:DATA",
    wos = "WC:Computer Science OR WC:Information Science",
    scholar = "No specific filters"
  )
  
  list(
    protocol_version = protocol_version,
    concepts = concepts,
    search_strings = search_strings,
    filters = filters,
    date_range = "2018-2026"
  )
}

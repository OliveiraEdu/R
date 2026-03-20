# Main pipeline for Systematic Literature Review

#' Run complete SLR pipeline
#' @param sources Named list of database file paths
#' @param output_dir Output directory for results
#' @param arxiv_search Search string for arXiv (optional)
#' @param biorxiv_search Search string for bioRxiv (optional)
#' @param protocol_version Protocol version ("1.0", "3.0", "4.0", or "4.4")
#' @return List with all pipeline outputs
#' @export
run_slr_pipeline <- function(sources, 
                            output_dir = "slr_results",
                            arxiv_search = NULL,
                            biorxiv_search = NULL,
                            protocol_version = "1.0") {
  
  message("=== Starting SLR Pipeline ===\n")
  message(paste("Protocol version:", protocol_version, "\n"))
  
  # Normalize protocol version (4.4 maps to 4.0 for search strings)
  if (protocol_version == "4.4") {
    search_protocol <- "4.0"
    message("  (Using Protocol 4.0 search strategy for version 4.4)\n")
  } else {
    search_protocol <- protocol_version
  }
  
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

  # Bibliometric analysis
  message("Step 7: Bibliometric analysis...")
  source("slrengine/R/bibliometric.R")
  bm <- bibliometric_analysis(extraction)
  export_bibliometric(bm, output_dir)
  message("  Bibliometric analysis complete\n")

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
  
  # Load config from working directory
  config_path <- file.path(normalizePath("."), "config.yaml")
  config <- yaml::read_yaml(config_path)
  
  # Protocol 3.0 - Broad search strategy
  # Extract from config.yaml
  broad_concepts <- list(
    technology = config$PICOC_criteria$Blockchain_Platform$keywords,
    scientific_data = config$PICOC_criteria$Scientific_Data$keywords,
    provenance = config$PICOC_criteria$Provenance$keywords
  )
  
  # Build narrow search strings (Protocol 1.0) - config-driven
  # Map config categories to concept names
  concepts <- list(
    provenance = config$PICOC_criteria$Provenance$keywords,
    technology = config$PICOC_criteria$Blockchain_Platform$keywords,
    data_management = c(config$PICOC_criteria$maDMP_Support$keywords,
                        config$PICOC_criteria$Scientific_Data$keywords)
  )
  
  # Build narrow search strings (Protocol 1.0) - config-driven
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
  

# Protocol 3.0 filters
  filters_3.0 <- list(
    ieee = "Document Type: Conference OR Journal; Year: 2025-2026",
    scopus = "Subject Area: Computer Science; Doc Type: Article, Conference Paper; Year: 2025-2026",
    wos = "Categories: Computer Science, Information Science; Doc Types: Article, Conference Paper; Year: 2025-2026",
    pubmed = "Publication Types: Article, Review; Year: 2025-2026",
    acm = "Content Type: Conference Papers, Journal Articles; Year: 2025-2026",
    arxiv = "Categories: cs.DC, cs.CY, q-bio.QM; Year: 2025-2026",
    scholar = "Limit first 200 results"
  )
# Protocol 4.0 - Title-focused search (narrow scope, high precision)
# Build Protocol 4 concepts from config
protocol_4_concepts <- list(
  maDMP_Support = config$PICOC_criteria$maDMP_Support$keywords,
  Provenance_Model = config$PICOC_criteria$Provenance_Model$keywords,

  Blockchain_Platform = config$PICOC_criteria$Blockchain_Platform$keywords,
  Openness = config$PICOC_criteria$Openness$keywords,
  Scientific_Data = config$PICOC_criteria$Scientific_Data$keywords
)

# Load database-specific operators and filters from config
title_operators <- config$title_operators
enclosure_style <- config$enclosure_style
protocol_4_filters <- config$protocol_4_filters

# Build Protocol 4 search strings for all databases
protocol_4_strings <- list(
  ieee = build_protocol_4_string(title_operators$ieee, protocol_4_concepts, enclosure_style$ieee),
  scopus = build_protocol_4_string(title_operators$scopus, protocol_4_concepts, enclosure_style$scopus),
  wos = build_protocol_4_string(title_operators$wos, protocol_4_concepts, enclosure_style$wos),
  pubmed = build_protocol_4_string(title_operators$pubmed, protocol_4_concepts, enclosure_style$pubmed),
  acm = build_protocol_4_string(title_operators$acm, protocol_4_concepts, enclosure_style$acm),
  arxiv = build_protocol_4_string(title_operators$arxiv, protocol_4_concepts, enclosure_style$arxiv),
  scholar = build_protocol_4_scholar(protocol_4_concepts)
)
  arxiv_categories <- c("cs.DC", "q-bio.QM", "stat.ML", "cs.LG", "cs.AI")
   # Return based on protocol version
   if (protocol_version == "1.0") {
     search_strings <- narrow_strings
   } else if (protocol_version == "3.0") {
     search_strings <- broad_strings
   } else if (protocol_version == "4.0" || protocol_version == "4.4") {
     search_strings <- protocol_4_strings
   } else {
     search_strings <- narrow_strings
   }
   
   # Protocol 4.4 uses the same search strings as 4.0
   effective_version <- if (protocol_version == "4.4") "4.0" else protocol_version
   
   # Return full protocol config
   if (effective_version == "4.0") {
     list(
       protocol_version = protocol_version,
       concepts = protocol_4_concepts,
       filters = protocol_4_filters,
       arxiv_categories = arxiv_categories,
       date_range = "2025-2026",
       search_strings = search_strings,
       strategy = "title-focused",
       focus = "maDMP + blockchain provenance intersection"
     )
   } else if (effective_version == "3.0") {
     list(
       protocol_version = protocol_version,
       concepts_narrow = concepts,
       concepts_broad = broad_concepts,
       narrow = narrow_strings,
       broad = broad_strings,
       filters = filters_3.0,
       arxiv_categories = arxiv_categories,
       date_range = "2025-2026",
       search_strings = search_strings,
       strategy = "abstract-focused",
       focus = "Technology + Scientific Data (broad)"
     )
   } else {
     list(
       protocol_version = protocol_version,
       concepts = concepts,
       narrow = narrow_strings,
       filters = protocol_4_filters,
       arxiv_categories = arxiv_categories,
       date_range = "2025-2026",
       search_strings = search_strings,
       strategy = "abstract-focused",
       focus = "Provenance + Technology + DMP (narrow)"
     )
   }
 }

# Helper function: Build Protocol 4 search string for databases with title operators
build_protocol_4_string <- function(title_op, protocol_4_concepts, platform) {
  # protocol_4_concepts is a list of character vectors
  # Build OR groups for each concept category
  or_groups <- lapply(protocol_4_concepts, function(concept) {
    paste0("(", paste(concept, collapse = " OR "), ")")
  })
  
  # Combine all OR groups with AND
  full_search <- paste0(title_op, ": ", paste(do.call(c, or_groups), collapse = " AND "))
  
  # Add platform-specific filters if needed
  if (isTRUE(platform)) {
    full_search <- paste0("(", full_search, ")")
  }
  
  return(full_search)
}

# Helper function: Build Protocol 4 search string for Google Scholar
build_protocol_4_scholar <- function(protocol_4_concepts) {
  # Join all concepts from all categories and wrap in quotes for Google Scholar
  all_concepts <- do.call(c, protocol_4_concepts)
  concepts_str <- paste(all_concepts, collapse = " ")
  return(paste0('"', concepts_str, '"'))
}

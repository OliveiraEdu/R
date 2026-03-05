#' Generate Markdown Report from SLR Results
#' @param prisma_data PRISMA flow data
#' @param extraction Data frame from extract_data()
#' @param qa Quality assessment data
#' @param output_path Output file path (.md)
#' @param title Report title
#' @param date Report date
#' @export
generate_markdown_report <- function(prisma_data, extraction, qa, output_path,
                                    title = "Systematic Review Findings Report",
                                    date = format(Sys.Date(), "%B %d, %Y")) {
  
  # Calculate database string for report
  db_string <- if (!is.null(prisma_data$databases)) {
    paste(prisma_data$databases, collapse = ", ")
  } else {
    "multiple databases"
  }
  
  # Calculate additional statistics
  year_range <- paste(min(extraction$Year, na.rm = TRUE), max(extraction$Year, na.rm = TRUE), sep = "-")
  top_sources <- sort(table(extraction$Source), decreasing = TRUE)[1:10]
  top_platforms <- sort(table(extraction$Blockchain_Platform), decreasing = TRUE)
  
  # Cross-tabulation: Platform x Provenance
  platform_prov <- table(extraction$Blockchain_Platform, extraction$Provenance_Model)
  
  lines <- c(
    paste0("# ", title),
    "",
    paste0("**Date:** ", date),
    "**Review Protocol:** PRISMA 2020 Guidelines",
    "",
    "---",
    "",
    "## Executive Summary",
    "",
    paste0("This systematic review identified **", prisma_data$included, " studies** meeting inclusion criteria. "),
    paste0("The review followed PRISMA 2020 guidelines and covered the period ", year_range, ". "),
    paste0("The studies were sourced from ", db_string, ", focusing on blockchain-enabled provenance for scientific data management."),
    "",
    "---",
    "",
    "## 1. PRISMA Flow Diagram",
    "",
    "### 1.1 Flow Statistics",
    "",
    "| Stage | Count | Percentage |",
    "|-------|-------|------------|",
    paste0("| Records identified | ", prisma_data$identified$database_searches, " | 100% |"),
    paste0("| After duplicates removed | ", prisma_data$screened$after_duplicates, " | ", round(prisma_data$screened$after_duplicates/prisma_data$identified$database_searches*100, 1), "% |"),
    paste0("| Screened | ", prisma_data$screened$screened, " | 100% |"),
    paste0("| Excluded at title/abstract | ", prisma_data$screened$excluded_ta, " | ", round(prisma_data$screened$excluded_ta/prisma_data$screened$screened*100, 1), "% |"),
    paste0("| Assessed for full-text | ", prisma_data$fulltext$assessed_ft, " | ", round(prisma_data$fulltext$assessed_ft/prisma_data$screened$screened*100, 1), "% |"),
    paste0("| Excluded at full-text | ", prisma_data$fulltext$excluded_ft, " | ", round(prisma_data$fulltext$excluded_ft/prisma_data$fulltext$assessed_ft*100, 1), "% |"),
    paste0("| **Studies included** | **", prisma_data$included, "** | **", round(prisma_data$included/prisma_data$identified$database_searches*100, 1), "%** |"),
    "",
    "### 1.2 Mermaid Flowchart",
    "",
    "```mermaid",
    "flowchart TD",
    paste0("    A[Records Identified<br/>n=", prisma_data$identified$database_searches, "] --> B[Duplicate Records Removed<br/>n=", prisma_data$screened$after_duplicates, "]"),
    paste0("    B --> C[Records Screened<br/>n=", prisma_data$screened$screened, "]"),
    paste0("    C --> D[Excluded by Title/Abstract<br/>n=", prisma_data$screened$excluded_ta, "]"),
    paste0("    D --> E[Records Eligible<br/>n=", prisma_data$screened$screened - prisma_data$screened$excluded_ta, "]"),
    paste0("    E --> F[Full-Text Assessed<br/>n=", prisma_data$fulltext$assessed_ft, "]"),
    paste0("    F --> G[Excluded Full-Text<br/>n=", prisma_data$fulltext$excluded_ft, "]"),
    paste0("    G --> H[Studies Included<br/>n=", prisma_data$included, "]"),
    "    style A fill:#e1f5fe",
    "    style C fill:#fff3e0",
    "    style F fill:#fff3e0",
    "    style H fill:#e8f5e9",
    "```",
    "",
    "### 1.3 Exclusion Reasons",
    "",
    "| Reason | Count |",
    "|--------|-------|",
    paste0("| Wrong topic (technical implementation) | ", ifelse(is.null(prisma_data$screened$excluded_technical), 0, prisma_data$screened$excluded_technical), " |"),
    paste0("| Wrong topic (domain relevance) | ", ifelse(is.null(prisma_data$screened$excluded_domain), 0, prisma_data$screened$excluded_domain), " |"),
    paste0("| Opinion piece | ", ifelse(is.null(prisma_data$screened$excluded_opinion), 0, prisma_data$screened$excluded_opinion), " |"),
    paste0("| Non-research context | ", ifelse(is.null(prisma_data$screened$excluded_nonresearch), 0, prisma_data$screened$excluded_nonresearch), " |"),
    "",
    "---",
    "",
    "## 2. Methods",
    "",
    "### 2.1 Search Strategy",
    "",
    paste0("This systematic review searched the following databases: ", 
           paste(ifelse(is.null(prisma_data$databases), c("ACM Digital Library", "Web of Science"), prisma_data$databases), collapse = ", "), ". "),
    "Search strings were developed following PRISMA 2020 guidelines with three concept groups:",
    "",
    "- **Concept 1:** Blockchain/DLT (blockchain, distributed ledger, smart contract, DLT)",
    "- **Concept 2:** Provenance (provenance, data lineage, chain of custody, verification)",
    "- **Concept 3:** Scientific Data (scientific data, research data, data management, FAIR)",
    "",
    "### 2.2 Eligibility Criteria",
    "",
    "| Criterion | Description |",
    "|-----------|-------------|",
    "| Language | English |",
    "| Publication type | Journal articles, conference papers, preprints |",
    "| Date range | 2018-2026 |",
    "| Topic | Blockchain/DLT for scientific data provenance |",
    "| Domain | Research data management, data sharing, reproducibility |",
    "",
    "### 2.3 Screening Process",
    "",
    "1. Records imported from databases and duplicates removed",
    "2. Title and abstract screening using automated keyword-based eligibility criteria",
    "3. Full-text assessment for all included records",
    "4. Data extraction for included studies",
    "5. Quality assessment using Mixed Methods Appraisal Tool (MMAT)",
    "",
    "### 2.4 Data Extraction",
    "",
    "Extracted variables include: Research focus, Blockchain platform, Provenance model, maDMP support, Evaluation method, Storage integration, Permission model.",
    "",
    "### 2.5 Quality Assessment",
    "",
    "Quality was assessed using the MMAT with five criteria: Clear research questions, Appropriate methodology, Rigorous data collection, Sound analysis, and Well-supported conclusions.",
    "",
    "---",
    "",
    "## 3. Study Characteristics",
    "",
    paste0("### 3.1 Distribution by Research Focus (n=", nrow(extraction), ")"),
    "",
    generate_md_table_from_vector(table(extraction$Research_Focus), "Research Focus", "Count"),
    "",
    "### 3.2 Distribution by Blockchain Platform",
    "",
    generate_md_table_from_vector(table(extraction$Blockchain_Platform), "Platform", "Count"),
    "",
    "### 3.3 Distribution by Provenance Model",
    "",
    generate_md_table_from_vector(table(extraction$Provenance_Model), "Model", "Count"),
    "",
    "### 3.4 Distribution by maDMP Support",
    "",
    generate_md_table_from_vector(table(extraction$maDMP_Support), "maDMP Support", "Count"),
    "",
    "### 3.5 Distribution by Evaluation Method",
    "",
    generate_md_table_from_vector(table(extraction$Evaluation_Method), "Evaluation Method", "Count"),
    "",
    "### 3.6 Publication Year Distribution",
    "",
    generate_md_table_from_vector(table(extraction$Year), "Year", "Count"),
    "",
    "---",
    "",
    "## 4. Detailed Analysis",
    "",
    "### 4.1 Top Publication Sources (Journals/Conferences)",
    "",
    "| Source | Count |",
    "|--------|-------|",
    paste0("| ", names(top_sources[1]), " | ", top_sources[1], " |")
  )
  
  for (i in 2:min(10, length(top_sources))) {
    lines <- c(lines, paste0("| ", names(top_sources[i]), " | ", top_sources[i], " |"))
  }
  
  lines <- c(lines, "")
  
  # Storage Integration (if available)
  if ("Storage_Integration" %in% names(extraction)) {
    lines <- c(lines,
      "### 4.2 Storage Integration Patterns",
      "",
      generate_md_table_from_vector(table(extraction$Storage_Integration), "Storage Type", "Count"),
      ""
    )
  }
  
  # Permission Model (if available)
  if ("Permission_Model" %in% names(extraction)) {
    lines <- c(lines,
      "### 4.3 Permission Model Distribution",
      "",
      generate_md_table_from_vector(table(extraction$Permission_Model), "Permission Model", "Count"),
      ""
    )
  }
  
  # Cross-tabulation: Platform x Provenance
  platform_prov <- table(extraction$Blockchain_Platform, extraction$Provenance_Model)
  if (nrow(platform_prov) > 0 && ncol(platform_prov) > 0) {
    lines <- c(lines,
      "### 4.4 Cross-Tabulation: Blockchain Platform × Provenance Model",
      "",
      "| Platform | ", paste(colnames(platform_prov), collapse = " | "), " |",
      "|----------|", paste(rep("---", ncol(platform_prov)), collapse = "|"), "|"
    )
    
    for (i in 1:nrow(platform_prov)) {
      lines <- c(lines, paste0("| ", rownames(platform_prov)[i], " | ", paste(platform_prov[i,], collapse = " | "), " |"))
    }
    lines <- c(lines, "")
  }
  
  # System names identified
  systems <- extraction$System_Name[!is.na(extraction$System_Name)]
  if (length(systems) > 0) {
    top_systems <- sort(table(systems), decreasing = TRUE)[1:10]
    lines <- c(lines,
      "### 4.5 Systems/Frameworks Identified",
      "",
      "| System/Framework | Mentions |",
      "|------------------|----------|"
    )
    for (i in seq_along(top_systems)) {
      lines <- c(lines, paste0("| ", names(top_systems)[i], " | ", top_systems[i], " |"))
    }
    lines <- c(lines, "")
  }

  lines <- c(lines,
    "---",
    "",
    "## 5. Quality Assessment",
    "",
    "### 5.1 Quality Ratings Distribution",
    "",
    "| Rating | Description | Count |",
    "|--------|-------------|-------|",
    "| Excellent | Score 5 - clear methodology, rigorous evaluation | ", sum(qa$Quality_Rating == "Excellent", na.rm = TRUE), " |",
    "| Good | Score 4 - minor methodological gaps | ", sum(qa$Quality_Rating == "Good", na.rm = TRUE), " |",
    "| Acceptable | Score 3 - some concerns | ", sum(qa$Quality_Rating == "Acceptable", na.rm = TRUE), " |",
    "| Poor | Score 2 - significant gaps | ", sum(qa$Quality_Rating == "Poor", na.rm = TRUE), " |",
    "| Very Poor | Score 1 - cannot assess | ", sum(qa$Quality_Rating == "Very Poor", na.rm = TRUE), " |",
    "",
    paste0("**Mean Quality Score:** ", round(mean(qa$MMAT_Overall, na.rm = TRUE), 2), " / 1.0"),
    paste0("**Mean Rating (1-5):** ", round(mean(qa$Quality_Score, na.rm = TRUE), 2), " / 5.0"),
    "",
    "### 5.2 MMAT Item Scores",
    "",
    "| MMAT Item | Yes | Can't tell | Rate |",
    "|-----------|-----|------------|------|",
    "| Clear Research Questions | ", sum(qa$MMAT_1_ClearRQ == "Yes", na.rm = TRUE), " | ", sum(qa$MMAT_1_ClearRQ == "Can't tell", na.rm = TRUE), " | ", round(sum(qa$MMAT_1_ClearRQ == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_1_ClearRQ)) * 100, 1), "% |",
    "| Appropriate Methodology | ", sum(qa$MMAT_2_AppropriateMethod == "Yes", na.rm = TRUE), " | ", sum(qa$MMAT_2_AppropriateMethod == "Can't tell", na.rm = TRUE), " | ", round(sum(qa$MMAT_2_AppropriateMethod == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_2_AppropriateMethod)) * 100, 1), "% |",
    "| Rigorous Data Collection | ", sum(qa$MMAT_3_RigorousData == "Yes", na.rm = TRUE), " | ", sum(qa$MMAT_3_RigorousData == "Can't tell", na.rm = TRUE), " | ", round(sum(qa$MMAT_3_RigorousData == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_3_RigorousData)) * 100, 1), "% |",
    "| Sound Analysis | ", sum(qa$MMAT_4_SoundAnalysis == "Yes", na.rm = TRUE), " | ", sum(qa$MMAT_4_SoundAnalysis == "Can't tell", na.rm = TRUE), " | ", round(sum(qa$MMAT_4_SoundAnalysis == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_4_SoundAnalysis)) * 100, 1), "% |",
    "| Well-supported Conclusions | ", sum(qa$MMAT_5_Conclusions == "Yes", na.rm = TRUE), " | ", sum(qa$MMAT_5_Conclusions == "Can't tell", na.rm = TRUE), " | ", round(sum(qa$MMAT_5_Conclusions == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_5_Conclusions)) * 100, 1), "% |",
    "",
    "**Quality Scale (per Protocol Section 8.2):** 5 = Excellent, 4 = Good, 3 = Acceptable, 2 = Poor, 1 = Very Poor",
    "",
    "---",
    "",
    "## 6. Thematic Synthesis",
    "",
    "### 6.1 Research Themes Identified",
    "",
    "| Theme | Description | Studies |",
    "|-------|-------------|---------|",
    "| Blockchain Infrastructure | Papers focusing on blockchain platforms, DLT architecture | ", sum(grepl("Blockchain", extraction$Research_Focus)), " |",
    "| Provenance Tracking | Papers on data lineage, verification, chain of custody | ", sum(grepl("Provenance", extraction$Research_Focus)), " |",
    "| maDMP | Papers on machine-actionable data management plans | ", sum(grepl("maDMP", extraction$Research_Focus, ignore.case = TRUE)), " |",
    "| Combined Approach | Papers addressing multiple themes | ", sum(grepl(";", extraction$Research_Focus)), " |",
    "",
    "### 6.2 Technical Architecture Patterns",
    "",
    "| Pattern | Description | Count |",
    "|---------|-------------|-------|",
    "| Permissioned Blockchain | Systems using Hyperledger Fabric/Iroha | ", sum(grepl("Fabric|Iroha", extraction$Blockchain_Platform, ignore.case = TRUE)), " |",
    "| Permissionless Blockchain | Systems using Ethereum/public chains | ", sum(grepl("Ethereum", extraction$Blockchain_Platform, ignore.case = TRUE)), " |",
    "| PROV-O Based | Systems using W3C PROV ontology | ", sum(grepl("PROV-O", extraction$Provenance_Model, ignore.case = TRUE)), " |",
    "| Custom Provenance | Systems with proprietary provenance models | ", sum(grepl("Custom", extraction$Provenance_Model, ignore.case = TRUE)), " |",
    "",
    "---",
    "",
    "## 6. Included Studies",
    ""
  )
  
  # Add study table with more columns
  study_cols <- c("Study_ID", "Title", "Year", "Authors", "Source", "Research_Focus", "Blockchain_Platform", "Provenance_Model", "maDMP_Support", "Evaluation_Method")
  study_cols <- study_cols[study_cols %in% names(extraction)]
  study_table <- extraction[, study_cols]
  
  lines <- c(lines, 
    paste0("| ", paste(study_cols, collapse = " | "), " |"),
    paste0("| ", paste(rep("---", length(study_cols)), collapse = " | "), " |")
  )
  
  for (i in 1:min(nrow(study_table), 100)) {
    row <- study_table[i, ]
    values <- sapply(study_cols, function(col) {
      val <- row[[col]]
      if (is.na(val)) return("-")
      if (nchar(val) > 40) return(paste0(substr(val, 1, 37), "..."))
      val
    })
    lines <- c(lines, paste0("| ", paste(values, collapse = " | "), " |"))
  }
  
  if (nrow(study_table) > 100) {
    lines <- c(lines, "", paste0("*... and ", nrow(study_table) - 100, " more studies (see extraction form for complete list)*"))
  }
  
  lines <- c(lines,
    "",
    "---",
    "",
    "## 7. Gap Analysis",
    ""
  )
  
  # Add gap analysis
  gaps <- gap_analysis(extraction)
  lines <- c(lines,
    "| Research Gap | Evidence | Studies |",
    "|--------------|----------|---------|"
  )
  
  for (i in 1:min(nrow(gaps), 15)) {
    lines <- c(lines, paste0("| ", gaps$Combination[i], " | ", gaps$Description[i], " | ", gaps$Count[i], " |"))
  }
  
  lines <- c(lines,
    "",
    "---",
    "",
    "## 8. Key Findings and Implications",
    "",
    paste0("### 8.1 Summary of Current State"),
    "",
    paste0("- The review identified **", nrow(extraction), " studies** addressing blockchain for scientific data provenance"),
    paste0("- Research spans from ", min(extraction$Year, na.rm = TRUE), " to ", max(extraction$Year, na.rm = TRUE)),
    paste0("- Most studies (", round(sum(grepl("Blockchain", extraction$Research_Focus))/nrow(extraction)*100, 1), "%) focus on blockchain infrastructure"),
    "- Limited integration of formal provenance models (PROV-O)",
    "- Few studies address maDMP specifically",
    "",
    "### 8.2 Research Gaps",
    "",
    "- Lack of permissioned blockchain solutions for scientific data",
    "- Limited PROV-O implementation for provenance tracking",
    "- Gap in maDMP + blockchain integration",
    "- Need for evaluation studies comparing approaches",
    "",
    "---",
    "",
    "## 9. Limitations",
    "",
    "- **Language restriction:** English publications only",
    "- **Database coverage:** May miss specialized sources",
    "- **Classification based on title/abstract:** May have errors",
    "- **Rapidly evolving field:** Snapshot as of review date",
    "- **Automated extraction:** Key findings require manual verification",
    "",
    "---",
    "",
    "## 10. Conclusions",
    "",
    paste0("This systematic review identified **", prisma_data$included, " relevant studies** examining blockchain-enabled provenance for scientific data management. "),
    "The literature shows growing interest in blockchain for research data integrity, with a concentration on permissionless platforms. ",
    "However, significant gaps remain in permissioned blockchain solutions, PROV-O integration, and maDMP support. ",
    "This review provides a foundation for understanding the current landscape and identifying opportunities for future research, ",
    "particularly in addressing the reproducibility crisis through cryptographically-secured provenance tracking.",
    "",
    "---",
    "",
    paste0("*Report generated: ", date, "*"),
    "*Full extraction data available in: 04_extraction_form.csv*"
  )
  
  writeLines(lines, output_path)
  message(paste("Generated Markdown report:", output_path))
}


#' Helper: Generate markdown table from named vector
generate_md_table_from_vector <- function(vec, col1_name, col2_name) {
  lines <- c(paste0("| ", col1_name, " | ", col2_name, " |"),
             paste0("|------------|------|"))
  for (i in seq_along(vec)) {
    lines <- c(lines, paste0("| ", names(vec)[i], " | ", vec[i], " |"))
  }
  c(lines, "")
}


#' Generate LaTeX Report from SLR Results
#' @param prisma_data PRISMA flow data
#' @param extraction Data frame from extract_data()
#' @param qa Quality assessment data
#' @param output_path Output file path (.tex)
#' @param title Report title
#' @export
generate_latex_report <- function(prisma_data, extraction, qa, output_path,
                                 title = "Systematic Review Findings Report") {
  
  year_range <- paste(min(extraction$Year, na.rm = TRUE), max(extraction$Year, na.rm = TRUE), sep = "-")
  top_sources <- sort(table(extraction$Source), decreasing = TRUE)[1:10]
  platform_prov <- table(extraction$Blockchain_Platform, extraction$Provenance_Model)
  
  lines <- c(
    "\\documentclass{article}",
    "\\usepackage[utf8]{inputenc}",
    "\\usepackage{graphicx}",
    "\\usepackage{longtable}",
    "\\usepackage{booktabs}",
    "\\usepackage{hyperref}",
    "\\usepackage{amsmath}",
    "\\usepackage{geometry}",
    "\\geometry{a4paper,margin=1in}",
    "",
    "\\title{", title, "}",
    "\\date{\\today}",
    "",
    "\\begin{document}",
    "",
    "\\maketitle",
    "",
    "\\section{Executive Summary}",
    "",
    paste0("This systematic review identified \\textbf{", prisma_data$included, " studies} meeting inclusion criteria. "),
    paste0("The review followed PRISMA 2020 guidelines and covered the period ", year_range, ". "),
    paste0("The studies were sourced from ", paste(ifelse(is.null(prisma_data$databases), "multiple databases", prisma_data$databases), collapse = ", "), ", focusing on blockchain-enabled provenance for scientific data management."),
    "",
    "\\section{PRISMA Flow}",
    "",
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{PRISMA Flow Diagram}",
    "\\begin{tabular}{lrr}",
    "\\toprule",
    "Stage & Count & Percentage \\\\",
    "\\midrule",
    paste0("Records identified & ", prisma_data$identified$database_searches, " & 100\\\\% \\\\"),
    paste0("After duplicates removed & ", prisma_data$screened$after_duplicates, " & ", round(prisma_data$screened$after_duplicates/prisma_data$identified$database_searches*100, 1), "\\% \\\\"),
    paste0("Excluded at title/abstract & ", prisma_data$screened$excluded_ta, " & ", round(prisma_data$screened$excluded_ta/prisma_data$screened$screened*100, 1), "\\% \\\\"),
    paste0("Assessed for full-text & ", prisma_data$fulltext$assessed_ft, " & ", round(prisma_data$fulltext$assessed_ft/prisma_data$screened$screened*100, 1), "\\% \\\\"),
    paste0("Excluded at full-text & ", prisma_data$fulltext$excluded_ft, " & ", round(prisma_data$fulltext$excluded_ft/prisma_data$fulltext$assessed_ft*100, 1), "\\% \\\\"),
    paste0("\\textbf{Studies included} & \\textbf{", prisma_data$included, "} & \\textbf{", round(prisma_data$included/prisma_data$identified$database_searches*100, 1), "\\%} \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    "",
    "\\section{Study Characteristics}",
    ""
  )
  
  # Research focus table
  focus_table <- table(extraction$Research_Focus)
  lines <- c(lines,
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Distribution by Research Focus}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Research Focus & Count \\\\",
    "\\midrule"
  )
  
  for (i in seq_along(focus_table)) {
    lines <- c(lines, paste0(names(focus_table)[i], " & ", focus_table[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # Blockchain platform table
  platform_table <- table(extraction$Blockchain_Platform)
  lines <- c(lines,
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Distribution by Blockchain Platform}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Platform & Count \\\\",
    "\\midrule"
  )
  
  for (i in seq_along(platform_table)) {
    lines <- c(lines, paste0(names(platform_table)[i], " & ", platform_table[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # Provenance model table
  prov_table <- table(extraction$Provenance_Model)
  lines <- c(lines,
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Distribution by Provenance Model}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Model & Count \\\\",
    "\\midrule"
  )
  
  for (i in seq_along(prov_table)) {
    lines <- c(lines, paste0(names(prov_table)[i], " & ", prov_table[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # maDMP support table
  madmp_table <- table(extraction$maDMP_Support)
  lines <- c(lines,
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Distribution by maDMP Support}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "maDMP Support & Count \\\\",
    "\\midrule"
  )
  
  for (i in seq_along(madmp_table)) {
    lines <- c(lines, paste0(names(madmp_table)[i], " & ", madmp_table[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # Year distribution
  year_table <- table(extraction$Year)
  lines <- c(lines,
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Publication Year Distribution}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Year & Count \\\\",
    "\\midrule"
  )
  
  for (i in seq_along(year_table)) {
    lines <- c(lines, paste0(names(year_table)[i], " & ", year_table[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # Storage Integration (if available)
  if ("Storage_Integration" %in% names(extraction)) {
    storage_table <- table(extraction$Storage_Integration)
    lines <- c(lines,
      "\\begin{table}[htbp]",
      "\\centering",
      "\\caption{Storage Integration Patterns}",
      "\\begin{tabular}{lr}",
      "\\toprule",
      "Storage Type & Count \\\\",
      "\\midrule"
    )
    
    for (i in seq_along(storage_table)) {
      lines <- c(lines, paste0(names(storage_table)[i], " & ", storage_table[i], " \\\\"))
    }
    
    lines <- c(lines,
      "\\bottomrule",
      "\\end{tabular}",
      "\\end{table}",
      ""
    )
  }
  
  # Permission Model (if available)
  if ("Permission_Model" %in% names(extraction)) {
    perm_table <- table(extraction$Permission_Model)
    lines <- c(lines,
      "\\begin{table}[htbp]",
      "\\centering",
      "\\caption{Permission Model Distribution}",
      "\\begin{tabular}{lr}",
      "\\toprule",
      "Permission Model & Count \\\\",
      "\\midrule"
    )
    
    for (i in seq_along(perm_table)) {
      lines <- c(lines, paste0(names(perm_table)[i], " & ", perm_table[i], " \\\\"))
    }
    
    lines <- c(lines,
      "\\bottomrule",
      "\\end{tabular}",
      "\\end{table}",
      ""
    )
  }
  
  # Quality assessment
  qual_table <- table(qa$Quality_Rating, useNA = "ifany")
  lines <- c(lines,
    "\\section{Quality Assessment}",
    "",
    paste0("Mean Quality Score: ", round(mean(qa$MMAT_Overall, na.rm = TRUE), 2), " / 1.0"),
    paste0("Mean Rating (1-5 scale): ", round(mean(qa$Quality_Score, na.rm = TRUE), 2), " / 5.0"),
    "",
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Quality Ratings (1-5 Scale per MMAT)}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Rating & Count \\\\",
    "\\midrule"
  )
  
  ratings_order <- c("Excellent", "Good", "Acceptable", "Poor", "Very Poor")
  for (rating in ratings_order) {
    count <- sum(qa$Quality_Rating == rating, na.rm = TRUE)
    if (count > 0) {
      lines <- c(lines, paste0(rating, " & ", count, " \\\\"))
    }
  }
  
  # Add NA if any
  na_count <- sum(is.na(qa$Quality_Rating))
  if (na_count > 0) {
    lines <- c(lines, paste0("NA & ", na_count, " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # MMAT items with Yes/No counts
  lines <- c(lines,
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{MMAT Item Scores (1 = Yes, 0.5 = Can't tell, 0 = No)}",
    "\\begin{tabular}{lrrr}",
    "\\toprule",
    "MMAT Item & Yes & Can't tell & Rate \\\\",
    "\\midrule",
    paste0("Clear Research Questions & ", sum(qa$MMAT_1_ClearRQ == "Yes", na.rm = TRUE), " & ", sum(qa$MMAT_1_ClearRQ == "Can't tell", na.rm = TRUE), " & ", round(sum(qa$MMAT_1_ClearRQ == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_1_ClearRQ)) * 100, 1), "\\% \\\\"),
    paste0("Appropriate Methodology & ", sum(qa$MMAT_2_AppropriateMethod == "Yes", na.rm = TRUE), " & ", sum(qa$MMAT_2_AppropriateMethod == "Can't tell", na.rm = TRUE), " & ", round(sum(qa$MMAT_2_AppropriateMethod == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_2_AppropriateMethod)) * 100, 1), "\\% \\\\"),
    paste0("Rigorous Data Collection & ", sum(qa$MMAT_3_RigorousData == "Yes", na.rm = TRUE), " & ", sum(qa$MMAT_3_RigorousData == "Can't tell", na.rm = TRUE), " & ", round(sum(qa$MMAT_3_RigorousData == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_3_RigorousData)) * 100, 1), "\\% \\\\"),
    paste0("Sound Analysis & ", sum(qa$MMAT_4_SoundAnalysis == "Yes", na.rm = TRUE), " & ", sum(qa$MMAT_4_SoundAnalysis == "Can't tell", na.rm = TRUE), " & ", round(sum(qa$MMAT_4_SoundAnalysis == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_4_SoundAnalysis)) * 100, 1), "\\% \\\\"),
    paste0("Well-supported Conclusions & ", sum(qa$MMAT_5_Conclusions == "Yes", na.rm = TRUE), " & ", sum(qa$MMAT_5_Conclusions == "Can't tell", na.rm = TRUE), " & ", round(sum(qa$MMAT_5_Conclusions == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_5_Conclusions)) * 100, 1), "\\% \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )
  
  # Key Findings
  lines <- c(lines,
    "\\section{Key Findings and Implications}",
    "",
    "\\subsection{Summary of Current State}",
    "",
    paste0("\\begin{itemize}"),
    paste0("    \\item The review identified \\textbf{", nrow(extraction), " studies} addressing blockchain for scientific data provenance"),
    paste0("    \\item Research spans from ", min(extraction$Year, na.rm = TRUE), " to ", max(extraction$Year, na.rm = TRUE)),
    paste0("    \\item Most studies (", round(sum(grepl("Blockchain", extraction$Research_Focus))/nrow(extraction)*100, 1), "\\%) focus on blockchain infrastructure"),
    "    \\item Limited integration of formal provenance models (PROV-O)",
    "    \\item Few studies address maDMP specifically",
    paste0("\\end{itemize}"),
    "",
    "\\subsection{Research Gaps}",
    "",
    "\\begin{itemize}",
    "    \\item Lack of permissioned blockchain solutions for scientific data",
    "    \\item Limited PROV-O implementation for provenance tracking",
    "    \\item Gap in maDMP + blockchain integration",
    "    \\item Need for evaluation studies comparing approaches",
    "\\end{itemize}",
    ""
  )
  
  # Limitations
  lines <- c(lines,
    "\\section{Limitations}",
    "",
    "\\begin{itemize}",
    "    \\item \\textbf{Language restriction:} English publications only",
    "    \\item \\textbf{Database coverage:} May miss specialized sources",
    "    \\item \\textbf{Classification:} Based on title/abstract may have errors",
    "    \\item \\textbf{Rapidly evolving field:} Snapshot as of review date",
    "    \\item \\textbf{Automated extraction:} Key findings require manual verification",
    "\\end{itemize}",
    ""
  )
  
  # Conclusions
  lines <- c(lines,
    "\\section{Conclusions}",
    "",
    paste0("This systematic review identified \\textbf{", prisma_data$included, " relevant studies} examining blockchain-enabled provenance for scientific data management. "),
    "The literature shows growing interest in blockchain for research data integrity, with a concentration on permissionless platforms. ",
    "However, significant gaps remain in permissioned blockchain solutions, PROV-O integration, and maDMP support. ",
    "This review provides a foundation for understanding the current landscape and identifying opportunities for future research, ",
    "particularly in addressing the reproducibility crisis through cryptographically-secured provenance tracking.",
    "",
    "\\section{Included Studies}",
    "",
    "See Appendix A: Extraction Form (04_extraction_form.csv) for complete list of studies.",
    "",
    "\\section*{Appendix A: Top Publication Sources}",
    "\\addcontentsline{toc}{section}{Appendix A: Top Publication Sources}",
    "",
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Top 10 Publication Sources}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Source & Count \\\\",
    "\\midrule"
  )
  
  for (i in 1:min(10, length(top_sources))) {
    src_name <- names(top_sources)[i]
    if (nchar(src_name) > 40) src_name <- paste0(substr(src_name, 1, 37), "...")
    lines <- c(lines, paste0(src_name, " & ", top_sources[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    "",
    "\\end{document}"
  )
  
  writeLines(lines, output_path)
  message(paste("Generated LaTeX report:", output_path))
}

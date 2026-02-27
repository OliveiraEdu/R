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
    paste0("This systematic review identified ", prisma_data$included, " studies meeting inclusion criteria. "),
    "The review followed PRISMA 2020 guidelines and covered the period 2018-2026.",
    "",
    "---",
    "",
    "## 1. PRISMA Flow Diagram",
    "",
    "### 1.1 Flow Statistics",
    "",
    "| Stage | Count |",
    "|-------|-------|",
    paste0("| Records identified | ", prisma_data$identified$database_searches, " |"),
    paste0("| After duplicates removed | ", prisma_data$screened$after_duplicates, " |"),
    paste0("| Screened | ", prisma_data$screened$screened, " |"),
    paste0("| Excluded at title/abstract | ", prisma_data$screened$excluded_ta, " |"),
    paste0("| Assessed for full-text | ", prisma_data$fulltext$assessed_ft, " |"),
    paste0("| Excluded at full-text | ", prisma_data$fulltext$excluded_ft, " |"),
    paste0("| **Studies included** | **", prisma_data$included, "** |"),
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
    "---",
    "",
    "## 2. Study Characteristics",
    "",
    "### 2.1 Distribution by Research Focus",
    "",
    generate_md_table_from_vector(table(extraction$Research_Focus), "Research Focus", "Count"),
    "",
    "### 2.2 Distribution by Blockchain Platform",
    "",
    generate_md_table_from_vector(table(extraction$Blockchain_Platform), "Platform", "Count"),
    "",
    "### 2.3 Distribution by Provenance Model",
    "",
    generate_md_table_from_vector(table(extraction$Provenance_Model), "Model", "Count"),
    "",
    "### 2.4 Distribution by maDMP Support",
    "",
    generate_md_table_from_vector(table(extraction$maDMP_Support), "maDMP Support", "Count"),
    "",
    "### 2.5 Distribution by Evaluation Method",
    "",
    generate_md_table_from_vector(table(extraction$Evaluation_Method), "Evaluation Method", "Count"),
    "",
    "### 2.6 Publication Year Distribution",
    "",
    generate_md_table_from_vector(table(extraction$Year), "Year", "Count"),
    "",
    "---",
    "",
    "## 3. Quality Assessment",
    "",
    "### 3.1 Quality Ratings",
    "",
    generate_md_table_from_vector(table(qa$Quality_Rating, useNA = "ifany"), "Rating", "Count"),
    "",
    "### 3.2 MMAT Item Scores",
    "",
    "| MMAT Item | Yes Rate |",
    "|-----------|----------|",
    paste0("| Clear Research Questions | ", round(sum(qa$MMAT_1_ClearRQ == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_1_ClearRQ)) * 100, 1), "% |"),
    paste0("| Appropriate Methodology | ", round(sum(qa$MMAT_2_AppropriateMethod == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_2_AppropriateMethod)) * 100, 1), "% |"),
    paste0("| Rigorous Data Collection | ", round(sum(qa$MMAT_3_RigorousData == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_3_RigorousData)) * 100, 1), "% |"),
    paste0("| Sound Analysis | ", round(sum(qa$MMAT_4_SoundAnalysis == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_4_SoundAnalysis)) * 100, 1), "% |"),
    paste0("| Well-supported Conclusions | ", round(sum(qa$MMAT_5_Conclusions == "Yes", na.rm = TRUE) / sum(!is.na(qa$MMAT_5_Conclusions)) * 100, 1), "% |"),
    "",
    paste0("**Mean Quality Score:** ", round(mean(qa$MMAT_Overall, na.rm = TRUE), 2)),
    "",
    "---",
    "",
    "## 4. Included Studies",
    ""
  )
  
  # Add study table
  study_cols <- c("Study_ID", "Title", "Year", "Research_Focus", "Blockchain_Platform", "Provenance_Model", "maDMP_Support")
  study_cols <- study_cols[study_cols %in% names(extraction)]
  study_table <- extraction[, study_cols]
  
  lines <- c(lines, 
             "| ", paste(study_cols, collapse = " | "), " |",
             "| ", paste(rep("---", length(study_cols)), collapse = " | "), " |"
  )
  
  for (i in 1:min(nrow(study_table), 50)) {
    row <- study_table[i, ]
    values <- sapply(study_cols, function(col) {
      val <- row[[col]]
      if (is.na(val)) return("")
      if (nchar(val) > 50) return(paste0(substr(val, 1, 47), "..."))
      val
    })
    lines <- c(lines, paste0("| ", paste(values, collapse = " | "), " |"))
  }
  
  if (nrow(study_table) > 50) {
    lines <- c(lines, "", paste0("*... and ", nrow(study_table) - 50, " more studies*"))
  }
  
  lines <- c(lines,
    "",
    "---",
    "",
    "## 5. Gap Analysis",
    ""
  )
  
  # Add gap analysis
  gaps <- gap_analysis(extraction)
  lines <- c(lines,
    "| Platform x Model | Count |",
    "|-----------------|-------|"
  )
  
  for (i in 1:min(nrow(gaps), 20)) {
    lines <- c(lines, paste0("| ", gaps$Combination[i], " | ", gaps$Count[i], " |"))
  }
  
  lines <- c(lines,
    "",
    "---",
    "",
    "## 6. Limitations",
    "",
    "- Language restriction: English publications only",
    "- Database coverage may miss specialized sources",
    "- Classification based on title/abstract may have errors",
    "- Rapidly evolving field - snapshot as of review date",
    "",
    "---",
    "",
    "## 7. Conclusions",
    "",
    paste0("This systematic review identified ", prisma_data$included, " relevant studies. "),
    "Key findings include the distribution of research across blockchain platforms, provenance models, ",
    "and maDMP support. Further qualitative analysis is needed to draw specific conclusions.",
    "",
    "---",
    "",
    paste0("*Report generated: ", date, "*")
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
  
  lines <- c(
    "\\documentclass{article}",
    "\\usepackage[utf8]{inputenc}",
    "\\usepackage{graphicx}",
    "\\usepackage{longtable}",
    "\\usepackage{booktabs}",
    "\\usepackage{hyperref}",
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
    paste0("This systematic review identified ", prisma_data$included, " studies meeting inclusion criteria."),
    "",
    "\\section{PRISMA Flow}",
    "",
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{PRISMA Flow Diagram}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Stage & Count \\\\",
    "\\midrule",
    paste0("Records identified & ", prisma_data$identified$database_searches, " \\\\"),
    paste0("After duplicates removed & ", prisma_data$screened$after_duplicates, " \\\\"),
    paste0("Screened & ", prisma_data$screened$screened, " \\\\"),
    paste0("Excluded at title/abstract & ", prisma_data$screened$excluded_ta, " \\\\"),
    paste0("Assessed for full-text & ", prisma_data$fulltext$assessed_ft, " \\\\"),
    paste0("Excluded at full-text & ", prisma_data$fulltext$excluded_ft, " \\\\"),
    paste0("\\textbf{Studies included} & \\textbf{", prisma_data$included, "} \\\\"),
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
  
  # Quality assessment
  lines <- c(lines,
    "\\section{Quality Assessment}",
    "",
    paste0("Mean Quality Score: ", round(mean(qa$MMAT_Overall, na.rm = TRUE), 2)),
    "",
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Quality Ratings}",
    "\\begin{tabular}{lr}",
    "\\toprule",
    "Rating & Count \\\\",
    "\\midrule"
  )
  
  qual_table <- table(qa$Quality_Rating, useNA = "ifany")
  for (i in seq_along(qual_table)) {
    lines <- c(lines, paste0(ifelse(is.na(names(qual_table)[i]), "NA", names(qual_table)[i]), " & ", qual_table[i], " \\\\"))
  }
  
  lines <- c(lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    "",
    "\\section{Conclusions}",
    "",
    paste0("This systematic review identified ", prisma_data$included, " relevant studies."),
    "",
    "\\end{document}"
  )
  
  writeLines(lines, output_path)
  message(paste("Generated LaTeX report:", output_path))
}

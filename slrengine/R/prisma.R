#' Generate PRISMA 2020 Flow Diagram data
#' @param records_all Total records identified
#' @param records_screened Records after duplicates removed
#' @param records_excluded_ta Records excluded at title/abstract
#' @param records_assessed_ft Records assessed for full-text
#' @param records_excluded_ft Records excluded at full-text
#' @param records_included Final included studies
#' @return List with PRISMA flow data
#' @export
generate_prisma_flow <- function(records_all, records_screened, 
                                  records_excluded_ta, records_assessed_ft,
                                  records_excluded_ft, records_included) {
  
  list(
    identified = list(
      database_searches = records_all,
      added_through_other = 0
    ),
    screened = list(
      after_duplicates = records_screened,
      screened = records_screened,
      excluded_ta = records_excluded_ta
    ),
    fulltext = list(
      assessed_ft = records_assessed_ft,
      excluded_ft = records_excluded_ft
    ),
    included = records_included
  )
}


#' Export PRISMA flow diagram data
#' @param prisma_data List from generate_prisma_flow()
#' @param path Output file path (.csv)
#' @export
export_prisma_flow <- function(prisma_data, path) {
  # Create summary table
  df <- data.frame(
    Stage = c(
      "Records identified through database searching",
      "Records after duplicates removed",
      "Records screened",
      "Records excluded at title/abstract",
      "Reports assessed for full-text",
      "Reports excluded (reasons)",
      "Studies included"
    ),
    Count = c(
      prisma_data$identified$database_searches,
      prisma_data$screened$after_duplicates,
      prisma_data$screened$screened,
      prisma_data$screened$excluded_ta,
      prisma_data$fulltext$assessed_ft,
      prisma_data$fulltext$excluded_ft,
      prisma_data$included
    ),
    stringsAsFactors = FALSE
  )
  
  write.csv(df, path, fileEncoding = "UTF-8", row.names = FALSE)
  message(paste("Exported PRISMA flow data to:", path))
}


#' Export PRISMA flow diagram as LaTeX table
#' @param prisma_data List from generate_prisma_flow()
#' @param path Output file path (.tex)
#' @export
export_prisma_flow_latex <- function(prisma_data, path) {
  
  # Calculate derived values
  records_identified <- prisma_data$identified$database_searches + prisma_data$identified$added_through_other
  after_dups <- prisma_data$screened$after_duplicates
  screened <- prisma_data$screened$screened
  excluded_ta <- prisma_data$screened$excluded_ta
  assessed_ft <- prisma_data$fulltext$assessed_ft
  excluded_ft <- prisma_data$fulltext$excluded_ft
  included <- prisma_data$included
  
  latex_code <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{PRISMA 2020 Flow Diagram}\n",
    "\\label{tab:prisma-flow}\n",
    "\\begin{tabular}{llr}\n",
    "\\hline\n",
    "\\textbf{Stage} & & \\textbf{Number of records} \\\\ \n",
    "\\hline\n",
    "\\hline\n",
    "\\textit{Identification of studies via databases} &  &  \\\\ \n",
    "  \\hspace{1em} Records identified from: &  &  \\\\ \n",
    "    \\hspace{2em} Database searching & ", records_identified, " &  \\\\ \n",
    "    \\hspace{2em} Other sources & ", prisma_data$identified$added_through_other, " &  \\\\ \n",
    "\\hline\n",
    "\\textit{Screening} &  &  \\\\ \n",
    "  \\hspace{1em} After duplicates removed & ", after_dups, " &  \\\\ \n",
    "  \\hspace{1em} Screened & ", screened, " &  \\\\ \n",
    "  \\hspace{1em} Excluded at title/abstract & ", excluded_ta, " &  \\\\ \n",
    "\\hline\n",
    "\\textit{Eligibility} &  &  \\\\ \n",
    "  \\hspace{1em} Reports assessed for full-text & ", assessed_ft, " &  \\\\ \n",
    "  \\hspace{1em} Reports excluded (reasons) & ", excluded_ft, " &  \\\\ \n",
    "\\hline\n",
    "\\textit{Included} &  &  \\\\ \n",
    "  \\hspace{1em} Studies included & ", included, " &  \\\\ \n",
    "\\hline\n",
    "\\end{tabular}\n",
    "\\end{table}"
  )
  
  writeLines(latex_code, path)
  message(paste("Exported PRISMA flow LaTeX to:", path))
}


#' Generate study characteristics table
#' @param extraction Data frame from extract_data()
#' @return Data frame with study characteristics
#' @export
generate_characteristics_table <- function(extraction) {
  
  # Summary by year
  by_year <- table(extraction$Year)
  
  # Summary by research focus
  by_focus <- table(extraction$Research_Focus)
  
  # Summary by blockchain platform
  by_platform <- table(extraction$Blockchain_Platform)
  
  # Summary by provenance model
  by_model <- table(extraction$Provenance_Model)
  
  # Summary by maDMP support
  by_madmp <- table(extraction$maDMP_Support)
  
  # Summary by evaluation
  by_eval <- table(extraction$Evaluation_Method)
  
  list(
    by_year = by_year,
    by_research_focus = by_focus,
    by_blockchain_platform = by_platform,
    by_provenance_model = by_model,
    by_madmp_support = by_madmp,
    by_evaluation = by_eval
  )
}


#' Export all summary tables
#' @param extraction Data frame from extract_data()
#' @param path Output file path (.csv)
#' @export
export_summary_tables <- function(extraction, path) {
  char <- generate_characteristics_table(extraction)
  
  # Export as single combined CSV
  all_data <- data.frame()
  
  for (name in names(char)) {
    df <- data.frame(
      Category = names(char[[name]]),
      Count = as.integer(char[[name]]),
      stringsAsFactors = FALSE
    )
    df$Table <- name
    all_data <- rbind(all_data, df)
  }
  
  # Reorder columns
  all_data <- all_data[, c("Table", "Category", "Count")]
  
  write.csv(all_data, path, fileEncoding = "UTF-8", row.names = FALSE)
  message(paste("Exported summary tables to:", path))
}


#' Gap analysis based on thematic categories
#' @param extraction Data frame from extract_data()
#' @return Data frame with gap analysis
#' @export
gap_analysis <- function(extraction) {
  
  # Create matrix of coverage
  platforms <- unique(unlist(strsplit(extraction$Blockchain_Platform, "; ")))
  models <- unique(unlist(strsplit(extraction$Provenance_Model, "; ")))
  
  gaps <- data.frame(
    Category = character(),
    Combination = character(),
    Count = integer(),
    stringsAsFactors = FALSE
  )
  
  # Analyze missing combinations
  all_platforms <- c("Fabric", "Iroha", "Ethereum", "Hyperledger", "BigchainDB", "Multi-chain", "Not specified")
  all_models <- c("PROV-O", "PROV-DM", "OPM", "Custom", "None")
  
  for (plat in all_platforms) {
    for (mod in all_models) {
      count <- sum(grepl(plat, extraction$Blockchain_Platform) & grepl(mod, extraction$Provenance_Model))
      gaps <- rbind(gaps, data.frame(
        Category = "Platform x Provenance Model",
        Combination = paste(plat, "x", mod),
        Count = count,
        stringsAsFactors = FALSE
      ))
    }
  }
  
  gaps
}

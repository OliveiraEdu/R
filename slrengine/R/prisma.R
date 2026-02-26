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
#' @param path Output file path
#' @export
export_prisma_flow <- function(prisma_data, path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
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
  
  writexl::write_xlsx(df, path)
  message(paste("Exported PRISMA flow data to:", path))
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
#' @param path Output directory path
#' @export
export_summary_tables <- function(extraction, path) {
  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("writexl package required")
  }
  
  char <- generate_characteristics_table(extraction)
  
  # Export each table to separate sheets
  sheets <- list(
    "Characteristics" = as.data.frame(do.call(cbind, lapply(char, function(x) {
      df <- as.data.frame(x)
      names(df) <- c("Category", "Count")
      df
    }))),
    "By_Year" = as.data.frame(char$by_year),
    "By_Focus" = as.data.frame(char$by_research_focus),
    "By_Platform" = as.data.frame(char$by_blockchain_platform),
    "By_Model" = as.data.frame(char$by_provenance_model),
    "By_maDMP" = as.data.frame(char$by_madmp_support),
    "By_Evaluation" = as.data.frame(char$by_eval)
  )
  
  writexl::write_xlsx(sheets, path)
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

#' Load YAML configuration file for SLR Engine
#'
#' Reads the configuration file and validates all required fields.
#' Returns a list containing the configuration data.
#'
#' @param path Path to the YAML configuration file (default: "config.yaml")
#' @return List containing all configuration data
#' @export
#' @examples
#' config <- load_config("config.yaml")
load_config <- function(path = "config.yaml") {
  # Validate input
  if (!is.character(path)) {
    message("Error: path must be a character string")
    return(NULL)
  }
  
  # Check if file exists
  if (!file.exists(path)) {
    message(paste("Error: Configuration file not found:", path))
    return(NULL)
  }
  
   # Read YAML file
   tryCatch({
     config_data <- yaml::yaml.load_file(path)
   }, error = function(e) {
     message(paste("Error: Failed to read YAML file:", e$message))
     return(NULL)
   })
  
  # Validate required fields
  validation_result <- validate_config(config_data)
  
  if (!isTRUE(validation_result)) {
    message("Error: Configuration validation failed. See messages above.")
    return(NULL)
  }
  
  return(config_data)
}

#' Validate the loaded configuration
#'
#' Checks all date ranges have start and end, verifies categories are present,
#' and ensures common constants are defined.
#'
#' @param config List containing configuration data
#' @return TRUE if valid, FALSE otherwise
#' @export
#' @examples
#' config <- list(
#'   sources = list(wos = list(start_year = 2020, end_year = 2023, categories = c("cs", "biotech"))),
#'   categories = c("cs", "biotech"),
#'   constants = list(MAX_RECORDS = 10000, BATCH_SIZE = 1000)
#' )
#' validate_config(config)
validate_config <- function(config) {
  messages <- character()
  valid <- TRUE
  
  # Check if config is a list
  if (!is.list(config)) {
    messages <- c(messages, "Error: Configuration must be a list")
    valid <- FALSE
    return(valid)
  }
  
  # Validate date ranges
  if (!is.null(config$sources) && is.list(config$sources)) {
    for (source in names(config$sources)) {
      source_config <- config$sources[[source]]
      
      if (is.list(source_config)) {
        if (is.null(source_config$start_year) || is.na(source_config$start_year)) {
          messages <- c(messages, paste("Error: source", source, "missing start_year"))
          valid <- FALSE
        }
        if (is.null(source_config$end_year) || is.na(source_config$end_year)) {
          messages <- c(messages, paste("Error: source", source, "missing end_year"))
          valid <- FALSE
        }
        if (!is.numeric(source_config$start_year) || !is.numeric(source_config$end_year)) {
          messages <- c(messages, paste("Error: source", source, "start_year and end_year must be numeric"))
          valid <- FALSE
        }
        if (source_config$start_year > source_config$end_year) {
          messages <- c(messages, paste("Error: source", source, "start_year must be <= end_year"))
          valid <- FALSE
        }
      }
    }
  }
  
  # Validate categories
  if (!is.null(config$categories) && !is.character(config$categories)) {
    messages <- c(messages, "Error: categories must be a character vector")
    valid <- FALSE
  } else if (is.null(config$categories)) {
    messages <- c(messages, "Error: categories field is missing")
    valid <- FALSE
  } else if (length(config$categories) == 0) {
    messages <- c(messages, "Error: categories field is empty")
    valid <- FALSE
  }
  
  # Validate source categories (can be character or list)
  if (!is.null(config$sources) && is.list(config$sources)) {
    for (source in names(config$sources)) {
      source_config <- config$sources[[source]]
      if (!is.null(source_config$categories)) {
        cat_check <- !is.null(source_config$categories) && is.list(source_config$categories)
        if (!is.character(source_config$categories) && !cat_check) {
          messages <- c(messages, paste("Error: source", source, "categories must be character or list"))
          valid <- FALSE
        }
      }
    }
  }
  
  # Validate common constants
  if (!is.null(config$constants) && is.list(config$constants)) {
    required_constants <- c("MAX_RECORDS", "BATCH_SIZE")
    for (const in required_constants) {
      if (!is.null(config$constants[[const]]) && !is.numeric(config$constants[[const]])) {
        messages <- c(messages, paste("Error: constant", const, "must be numeric"))
        valid <- FALSE
      }
    }
  }
  
  if (!valid) {
    for (msg in messages) {
      message(msg)
    }
  }
  
  return(valid)
}

#' Get date range for a specific source
#'
#' Retrieves the start and end years for a given source from the configuration.
#' Always loads config internally at the start of each function.
#'
#' @param source Name of the source (e.g., "wos", "acm")
#' @param start_year Year to check as start year (default: NA)
#' @param end_year Year to check as end year (default: NA)
#' @return List with start and end years
#' @export
#' @examples
#' config <- load_config("config.yaml")
#' get_date_range("wos")
get_date_range <- function(source = "wos", start_year = NA, end_year = NA) {
  # Validate source argument
  if (!is.character(source)) {
    stop("source must be a character string")
  }
  
  # Always load config internally - no global state dependency
  config <- load_config()
  
  # Extract source configuration
  source_config <- config$sources[[source]]
  
  # Build result list
  result <- list(
    start_year = if (!is.na(start_year)) start_year else source_config$start_year,
    end_year = if (!is.na(end_year)) end_year else source_config$end_year
  )
  
  return(result)
}

#' Get categories for a specific source
#'
#' Retrieves the categories for a given source from the configuration.
#' Always loads config internally at the start of each function.
#'
#' @param source Name of the source (e.g., "wos", "acm")
#' @return Character vector of categories
#' @export
#' @examples
#' config <- load_config("config.yaml")
#' get_categories("wos")
get_categories <- function(source = "wos") {
  # Validate source argument
  if (!is.character(source)) {
    stop("source must be a character string")
  }
  
  # Always load config internally - no global state dependency
  config <- load_config()
  
  # Extract source configuration
  source_config <- config$sources[[source]]
  
  # Get categories from source config or global categories
  categories <- if (!is.null(source_config$categories)) {
    source_config$categories
  } else {
    config$categories
  }
  
  return(categories)
}

#' Get dynamic date range for preprint servers
#'
#' Calculates dates based on current system date - dynamic and testable.
#' Used for arXiv and bioRxiv to fetch recent papers.
#'
#' @param source Source name (e.g., "arxiv", "biorxiv")
#' @param duration_months Number of months to look back (default: 12)
#' @return List with start_date and end_date as character strings (YYYY-MM-DD)
#' @export
#' @examples
#' get_dynamic_date_range("arxiv", 12)
get_dynamic_date_range <- function(source = "arxiv", duration_months = 12) {
  # Calculate end date as today
  end_date <- Sys.Date()
  
  # Calculate start date (duration_months * 30 days back)
  start_date <- end_date - (duration_months * 30)
  
  # Format dates as character strings
  start_date_str <- format(start_date, "%Y-%m-%d")
  end_date_str <- format(end_date, "%Y-%m-%d")
  
  return(list(
    start_date = start_date_str,
    end_date = end_date_str,
    duration_months = duration_months,
    calculated_on = format(Sys.Date(), "%Y-%m-%d")
  ))
}
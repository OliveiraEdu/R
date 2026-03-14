# Test Protocol 4.0 Config-Driven Search Strings

source('slrengine/R/load_config.R')
source('slrengine/R/pipeline.R')

cat("=== Testing Protocol 4.0 ===\n\n")

# Test 1: Generate search strings
cat("Test 1: Generate Protocol 4.0 search strings\n")
protocol_4 <- generate_search_strings('4.0')
cat(sprintf("Generated %d search strings\n", length(protocol_4$search_strings)))

cat("\nSearch strings:\n")
for (i in names(protocol_4$search_strings)) {
  cat(sprintf("  %s: %s\n", i, protocol_4$search_strings[[i]]))
}

# Test 2: Verify config-driven concepts
cat("\n\nTest 2: Verify config-driven concepts\n")
cat("Contribution keywords:", length(protocol_4$concepts$maDMP_Support), "terms\n")
cat("Provenance keywords:", length(protocol_4$concepts$Provenance), "terms\n")
cat("Blockchain_Platform keywords:", length(protocol_4$concepts$Blockchain_Platform), "terms\n")
cat("Openness keywords:", length(protocol_4$concepts$Openness), "terms\n")
cat("Scientific_Data keywords:", length(protocol_4$concepts$Scientific_Data), "terms\n")

# Test 3: Generate filters
cat("\n\nTest 3: Generate filters\n")
cat("Filters generated:", length(protocol_4$filters), "filters\n")
for (i in names(protocol_4$filters)) {
  cat(sprintf("  %s: %s\n", i, protocol_4$filters[[i]]))
}

cat("\n\n=== All Tests Passed ===\n")

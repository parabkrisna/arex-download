library(foreach)
library(doParallel)
library(ArrayExpress)
library(GenomeInfoDbData)
library(plyr)
library(readxl)
num_cores <- 2

cl <- makeCluster(num_cores)
registerDoParallel(cl)
arex_sets <- (arex_mtab_unique)

datalist <- foreach(set = arex_sets$accession, .combine = 'c') %dopar% {
  accession <- set
  cat('Files downloaded for accession ID:', accession, "\n")
  base_loc  <- "C:/Users/bioinfo/Documents/"
  format    <- ".sdrf.txt"
  url       <- paste0(base_loc, accession, format)
  sdrf_file <- url
  
  # Only proceed with downloading if the file exists
  if (file.exists(sdrf_file)) {
    cat("SDRF file found: ", accession, "\n")
    sdrf_data <- read.delim(sdrf_file, stringsAsFactors = FALSE)
    sdrf_data$accession <- accession
    list(sdrf_data)
  } else {
    cat("SDRF file not found.", accession, "\n")
    list(NULL)  # or any value you prefer for non-existent files
  }
}

stopCluster(cl)

datalist <- unlist(datalist, recursive = FALSE)
#big_data <- rbind.fill(datalist)
big_data <- do.call(rbind, datalist)
View(big_data)


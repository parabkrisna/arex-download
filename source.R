
# Load libraries
library(jsonlite)
library(httr)
library(dplyr)
library(rjson)
library(jsonlite)
library(RCurl)
library(readxl)
library(dplyr)
library(writexl)
library(xlsx)

if (!requireNamespace("ArrayExpress", quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install("ArrayExpress")
}
library("ArrayExpress")

if (!requireNamespace("GenomeInfoDbData", quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install("GenomeInfoDbData")
}
library("GenomeInfoDbData")

sets = queryAE(keywords = "obesity", species = "homo+sapiens")

array_accession_data<-as.data.frame(sets)
View(array_accession_data)
# Geo accession document
obesity_geo_curation_19may2023_originaldoc_ <- read_excel("C:/R_data/obesity_geo_curation_19may2023(originaldoc).xlsx ", 
                                                          sheet = "Series_all") ### change path to GEO data
GEO_accession_data<-as.data.frame(obesity_geo_curation_19may2023_originaldoc_)
View(GEO_accession_data)
# Load libraries
library(readxl)

# Identify mtab vs geod
categorize_id <- function(identify) {
  identify <- as.character(identify)
  geo_id <- "E-GEOD"
  ar_id <- "E-MTAB"
  
  if (grepl(geo_id, identify)) {
    return("E-GEOD")
  } else if (grepl(ar_id, identify)) {
    return("E-MTAB")
  } else {
    return("other")
  }
}

Category <- sapply(array_accession_data$accession,categorize_id)
array_accession_data$Category<-Category

#func extract num seq
extract_numbers <- function(identifier) {
  return(paste0(gsub("\\D", "", as.character(identifier)), collapse = ""))
}

# Extract ID sequence from arrayex accession
array_accession_data$`Stripping ID` <- (array_accession_data$accession)
`Strip ID` <- sapply(array_accession_data$`Stripping ID`, extract_numbers)
array_accession_data$`Strip ID`<-`Strip ID`

# Extract ID sequence from GSE
GEO_accession_data$`Stripping ID` <- GEO_accession_data$`GEO_accession`
`Strip ID` <- sapply(GEO_accession_data$`Stripping ID`, extract_numbers)
GEO_accession_data$`Strip ID`<-`Strip ID`
# Common data
merged_data <- merge(array_accession_data, GEO_accession_data, by = "Strip ID")

# Uncommon data
unmatched_data <- array_accession_data[!(array_accession_data$`Strip ID` %in% GEO_accession_data$`Strip ID`), ]

# functo for unique geo accession entries
check_geo_entries <- function(check_geo) {
  check_geo <- as.character(check_geo)
  geo_id <- "E-GEOD"
  
  if (grepl(geo_id, check_geo)) {
    return("E-GEOD")
  } else {
    return(NA)
  }
}

unmatched_data$GEO_check <- sapply(unmatched_data$Category, check_geo_entries)
unique_geo <- unmatched_data[!is.na(unmatched_data$GEO_check), ]

# Check for unique arex accession entries
check_arex_entries <- function(check_arex) {
  check_arex <- as.character(check_arex)
  ar_id <- "E-MTAB"
  
  if (grepl(ar_id, check_arex)) {
    return("E-MTAB")
  } else {
    return(NA)
  }
}

unmatched_data$ArEx_check <- sapply(unmatched_data$Category, check_arex_entries)
unique_array_express <- unmatched_data[!is.na(unmatched_data$ArEx_check), ]

# Clearing unused columns and creating files
gse_arex_common <- merged_data %>% select(-Category, -`Strip ID`)
arex_geod_unique <- unique_geo %>% select(-Category, -`Strip ID`, -`Stripping ID`, -GEO_check)
arex_mtab_unique <- unique_array_express %>% select(-Category, -`Strip ID`, -`Stripping ID`, -GEO_check, -ArEx_check)
array_accession_data <- array_accession_data %>% select(-Category, -`Strip ID`, -`Stripping ID`)
# View(gse_arex_common)
# View(arex_geod_unique)
# View(arex_mtab_unique )
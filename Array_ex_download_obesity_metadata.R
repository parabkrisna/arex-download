#install.packages(c("dplyr", "readxl", "writexl",'xlsx'))
#install.packages('xlsx')
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
# Base URL
base_url <- "https://www.ebi.ac.uk/biostudies/api/v1/search?"
data_df<-data.frame()
# parameters used in query builder
facet_organism <- "&facet.organism=homo+sapiens" #query builder
query <- "&query=obesity"
num_pages <- 13  # Set the number of pages to iter

# Iter pages
for (page in 1:num_pages) {
  # differing page nos each iter
  full_url <- paste0(base_url, facet_organism, query, "&page=", page)
  full_url <- URLencode(full_url)
  response <- fromJSON(getURL(full_url))
  hits <- response$hits
  #hits<-as.data.frame(hits)
  acc_data <- do.call(rbind, lapply(hits,as.data.frame))
  
  data_df<-rbind(data_df,acc_data)
}
View(data_df)
#binding to a 2D dataframe
array_accession_data<-as.data.frame(data_df)
View(array_accession_data)
# Geo accession document, with existing studies collected beforehand from GEO database, to cross check common and uncommon entries
file_existing <- read_excel("C:/file_existing_studies.xlsx", 
                                                          sheet = "xxx")
GEO_accession_data<-as.data.frame(file_existing)
View(GEO_accession_data)
# Load libraries
library(readxl)

# Identify mtab vs geod, mtab is arrayexpress identifier, geod is GEO identifier
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
View(gse_arex_common)
View(arex_geod_unique)
View(arex_mtab_unique )

# save csv
write.csv(gse_arex_common, "common_data_geo_arex.csv", row.names = FALSE)
write.csv(arex_geod_unique, "geod_data_on_arex_not_in_gse.csv", row.names = FALSE)
write.csv(arex_mtab_unique, "array_express_unique_mtab.csv", row.names = FALSE)
write.csv(array_accession_data, "biostudies.csv", row.names = FALSE)

# save xcel
write.xlsx(gse_arex_common, "common_data_geo_arex.xlsx", row.names = FALSE)
write.xlsx(arex_geod_unique, "geod_data_on_arex_not_in_gse.xlsx", row.names = FALSE)
write.xlsx(arex_mtab_unique, "array_express_unique_mtab.xlsx", row.names = FALSE)
write.xlsx(array_accession_data, "biostudies.xlsx", row.names = FALSE)


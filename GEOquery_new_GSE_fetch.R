
library(readxl)
misc <- read.delim("C:/Users/bioinfo/Downloads/gse.csv")
misc <- data.frame(misc)
#View(misc)

# # Install and load necessary packages
# install.packages("GEOquery")
# install.packages("XML")
# install.packages("httr")
# install.packages("rvest")
# install.packages("openxlsx")
library(GEOquery)
library(XML)
library(httr)
library(rvest)
library(openxlsx)

gse_list <- misc$gse_id  # Example list of GSEIDs

#setwd("C:/Users/krisna/Documents")

new_accession<-as.data.frame(gse_list)
#View(new_accession)

# Geo accession document
obesity_geo_curation_19may2023_originaldoc_ <- read_excel("C:/Users/bioinfo/Desktop/obesity_geo_curation_19may2023(originaldoc).xlsx", 
                                                          sheet = "Series_all")
GEO_accession_data<-as.data.frame(obesity_geo_curation_19may2023_originaldoc_)
#View(GEO_accession_data)

# Common data
common <- new_accession[(new_accession$gse_list 
                         %in% GEO_accession_data$GEO_accession), ]
#View(common)

# Uncommon data
update_list <- new_accession[!(new_accession$gse_list 
                               %in% GEO_accession_data$GEO_accession), ]

updated_df <- data.frame(update_list)

trial_list <- head(update_list)
trial_list

# Fetching metadata for new GSEIDs
metadata_list <- lapply(trial_list, function(gse_id) {
  gse <- getGEO(gse_id, destdir = ".", getGPL = FALSE) # destdir for working directory (current)
  metadata <- pData(gse[[1]])
  metadata$GSEID <- gse_id
  return(list(metadata = metadata, GSEID = gse_id)) # return both metadata and GSEID
})

write.xlsx(metadata_list, "GEO_metadata_new.xlsx")


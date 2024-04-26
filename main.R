source("source.R")
install.packages("foreach")
install.packages("doParallel")
library(doParallel)
library(foreach)
library(ArrayExpress)
library(GenomeInfoDbData)
library(plyr)
library(readxl)
# library(dplyr) if running source file
# library(writexl)
# library(xlsx)
#install.packages("plyr")
#fetch sdrf #sample arex_mtab_unique
arex_sets <- (arex_mtab_unique)
datalist = list()
bin_list = list()

#setup parallel backend to use many processors
cores=detectCores()
cl <- makeCluster(cores[1]-1) #not to overload your computer
registerDoParallel(cl)

foreach (set in arex_sets$accession) {
  accession <- set
  # invisible(getAE(accession, path = getwd(), type = "full",
  #                 extract = FALSE, sourcedir = path, overwrite = FALSE))
  cat('Files downloaded for accession ID:',accession, "\n")
  base_loc  <- "C:/Users/bioinfo/Documents/"
  format    <- ".sdrf.txt"
  url       <- paste0(base_loc, accession, format)
  sdrf_file <- url
  
  if (file.exists (sdrf_file)) {
    cat("SDRF file exists: ", accession, "\n")
    sdrf_data =  read.delim(sdrf_file, stringsAsFactors = FALSE)
    sdrf_data$j <- accession
    datalist[[accession]] <- sdrf_data
  } else {
    cat("SDRF file not found.", accession,"\n")
    bin_list[[accession]] = accession
  }
}
#print(bin_list)
#big_data = do.call(rbind, datalist)
big_data = rbind.fill(datalist)
bin_data = rbind(bin_list)
View(big_data)
View(bin_data)
#save to csv
write.csv(big_data, "arex_sample.csv", row.names = FALSE)
write.xlsx(bin_data, "arex_sample.xlsx", row.names = FALSE)

# library(foreach)
# library(doParallel)
# 
# #setup parallel backend to use many processors
# cores=detectCores()
# cl <- makeCluster(cores[1]-1) #not to overload your computer
# registerDoParallel(cl)
# 
# finalMatrix <- foreach(i=1:150000, .combine=cbind) %dopar% {
#   tempMatrix = functionThatDoesSomething() #calling a function
#   #do other things if you want
#   
#   tempMatrix #Equivalent to finalMatrix = cbind(finalMatrix, tempMatrix)
# }
# #stop cluster
# stopCluster(cl)
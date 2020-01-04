# downloading OSF components for UKRN Advanced methods workshop
# Cassandra Gould van Praag, January 2020 (cassandrea.gouldvanpraag@psych.ox.ac.uk)

# This script will create a directory called "AdvancedMethodsWorkshop-OSF" in the 
# same location as this script. Subdirectories will then be created for each compnent.
# Requires osfr package. You may first need to install devtools from the Rstudio "install package function"
# Then in Rstudio console > devtools::install_github('CenterForOpenScience/osfr')

library(osfr) 

root <- getwd()
root<-file.path(root,'AdvancedMethodsWorkshop-OSF')

guid_mainProj <- 'gupxv' #osf global unique ID
data_mainProj <- osf_retrieve_node(guid_mainProj)

# get each component in the project
data_mainProj <- osf_ls_nodes(data_mainProj,n_max=Inf)
# print(data_mainProj,n=Inf)
# turn the tipple it into a dataframe to make it a bit easier to access our columns
tmp <- data.frame(data_mainProj)
# get just the columns we need for download ("meta" is huge)
# name of the columns we are keeping
keepCol <- c('name','id')
data_mainProj_info <- tmp[keepCol]
# print(data_mainProj_info)

# loop through rows describing components
for (comp in 1:nrow(data_mainProj_info)) {
  compName <- data_mainProj_info[comp, "name"]
  compID  <- data_mainProj_info[comp, "id"]
  writeLines(sprintf('\n -- COMPONENT NAME: %s; Compnent ID: %s', compName,compID))
  
  # make a directory for downloaded files to sit in, named after this component (supress "direc toy already exists" and other warnings)
  dir.create(file.path(root,compName),recursive = TRUE, showWarnings = FALSE)
  
  # retrieve that component and get the files 
  data_comp <- osf_retrieve_node(compID)
  data_comp <- osf_ls_files(data_comp,n_max=Inf)
  #print(data_comp,n=Inf)
  
  # tidy up and get our columns as before
  tmp2 <- data.frame(data_comp)
  data_comp_info <- tmp2[keepCol]
  #print(data_comp_info)
  
  # check to see if the file list is empty. Skip this component if empty
  #https://stackoverflow.com/questions/35366187/how-to-write-if-else-statements-if-dataframe-is-empty
  if (dim(data_comp_info)[1] == 0) {
    writeLines(sprintf('!! -- WARNING: No files to download (maybe not stored directly on OSF)? \n -- You will need to download these files manually.'))
    next
  }
  
  # loop through the file list and download each individually
  for (f in 1:nrow(data_comp_info)) {
    fname <- data_comp_info[f, "name"]
    fid <- data_comp_info[f, "id"]
    file <- osf_retrieve_file(fid)
    writeLines(sprintf(' -- Downloading file: %s; file ID: %s', fname,fid))
    osf_download(file,file.path(root,compName))
  
    #readline(prompt="Press [enter] to continue")
  }

}

writeLines(' -- Download complete. See you in Cumberland Lodge! :)')

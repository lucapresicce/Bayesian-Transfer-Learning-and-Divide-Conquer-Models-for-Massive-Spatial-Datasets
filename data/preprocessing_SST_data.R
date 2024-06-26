#  SCRIPT: CallFunc_ReadNcdf.r
#
#  DESCRIPTION
#   - Illustrates how the ReadNcdf function is called from within a simple R script to generically read all elements
#      (metadata attributes and data) of any arbitrary NetCDF classic (v3+) data file.
#   - All file metadata and data elements are read into memory arrays for access.
#   - Illustrations of how to access the range of data structures are provided.
#
#  DEPENDENCIES  
#  - Invokes the function ReadNcdf()      source file: funcReadNcdf.r
#  - This function uses the "RNetCDF" package, v1.6 1-2 , based on NetCDF 3+ library#
#
#  USAGE
#     The script automatically invokes the ReadNcdf function to capture and expose attributes and data of the user-selected
#     .nc file.  How to use:
#     1) Install the  "RNetCDF" package from the CRAN R-Project  (http://cran.r-project.org/web/packages/RNetCDF/index.html)
#     2) Open the "CallFunc_ReadNcdf.r script, and edit any parameters in the USER INPUTS section (eg. filename, path).
#     3) run the script.
#
#  INPUTS   (in "USER INPUTS" code block section below)
#     fpath: specifies the working directory where the source NetCDF file is located (eg. "C:/Users/vtsontos/Documents/R" )
#     fname: file name of source NetCDF data file  (eg. "capsss20120105.nc" )
#     printFlag: if set to TRUE, list NetCDF file summary information on screen (Default setting = FALSE )
#     nOutputElements: number of data array (VarData) elements to output per data variable (eg. 10)
#     nOutputRows: number of data rows output to screen before pause and user prompt (eg. 20)
#
#  OUTPUTS
#     - all NetCDF file elements read into R data structures in memory for usage
#     - dimAtts, gAtts, carAtts: structure arrays with respective dimensional, global and variable attributes with associated values  
#     - varData: structure array containing the data values for all variables by variable element
#     - optional (if printFlag = TRUE)
#           * print listing of all global file and variable attributes to screen with associated values
#           * print sample data for each data variable (number elements output per variable = nOutputElements) 
#
#  NOTES
#      1. This read software was created using R version 2.14.2 (2012-02-29)
#      2. Please email all comments and questions concerning these routines
#           to podaac@podaac.jpl.nasa.gov.
#
#  CREATED:
#       10/11/2012: Vardis Tsontos, PO.DAAC, NASA-JPL CalTech
#
#======================================================================
# Copyright (c) 2012, California Institute of Technology
#======================================================================
# setwd(".../Bayesian-Transfer-Learning-and-Divide-Conquer-Models-for-Massive-Spatial-Datasets/data")

rm(list = ls())
library("RNetCDF")

# ****** User Inputs Section ***********              # User inputs entered here

path = "~/MetaApproaches/AccelerateSMK/SST data"      # Enter the data full directory path
name = "erdMH1sstd8dayR20190SQ_Lon0360_1c8e_9984_b03b_U1716255438371.nc"        # Enter the filename of the source NetCDF data file
printFlag = TRUE                                      # Set to TRUE or FALSE if file content listing info is desired
nOutputElements = 10                                  # number of VarData array elements to output per data variable
nOutputRows = 20                                      # number of data rows output to screen before pause and user prompt

# ************** MAIN ********************** 
source("funcReadNcdf.R")                            # compiles the function from its source code .r file
ReadNcdf(path, name, printFlag)                       # calls the function and passes user defined arguements


# print example Data outputs for all variables illustrating how data elements are accessed at the command line
if (printFlag == TRUE) {
  for (cnt in 1:nVars){
    cat(varAtts[[cnt]]$name,": ",varData[[cnt]][1:nOutputElements], "\n");
    if (cnt > nOutputRows){
      readline(prompt = "Paused. Press <Enter> to continue...")}   
  }
}


# *************  END ***********************


# pick data from lon: -180 to -80 and lat: -90 to 90
lat_ind <- which((varData$lat >= -90) & (varData$lat <= 90))
lon_ind <- which((varData$lon <= 360 & varData$lon > 0))
SST_pick <- varData$sst[lon_ind, lat_ind]

# output dataset
sst_pick_ind <- which(!is.na(SST_pick), arr.ind=TRUE)
SST_data <- SST_pick[sst_pick_ind]
lon_data <- varData$lon[lon_ind][sst_pick_ind[, 1]]
lat_data <- varData$lat[lat_ind][sst_pick_ind[, 2]]

# scaling data (the script does not)
# NC_FLOAT sst:scale_factor = 0.000717184972018003 ;
# NC_FLOAT sst:add_offset = -2 ;

SSTdata <- data.frame(sst = SST_data, lon = lon_data, lat = lat_data)
save(SSTdata, file = "data/SST_data_2022_06_21.RData")

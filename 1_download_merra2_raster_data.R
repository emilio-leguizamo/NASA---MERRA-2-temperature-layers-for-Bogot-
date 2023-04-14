#install.packages("httr")
#install.packages(c("ncdf4","raster","rgdal"))
install.packages("terra")
install.packages("ncdf4.helpers")

library(httr)
library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(terra)
library(ncdf4.helpers)

rm(list = ls())

netrc_path <- "C:\\Users\\EMILIOLE\\_nectr.netrc"
cookie_path <- "C:\\Users\\EMILIOLE\\.urs_cookies"
dir <- "$SET FILE DIRECTORY"


    ##########################
    ##  Air temperature at  ##
    ##  different altitudes ##
    ##########################

files <- read.delim(PASTE(dir,"\\temperature_subset_M2I6NPANA_5.12.4_20230404_205834_.txt", sep=""))
n <- dim(files)

for (x in 1:n) { 
  file_name <- paste("merra2_airtemp_",substring(files[x,1],109,116),".nc4",sep="")
  downloaded_file_path <- paste(dir,"\\air_temperature\\",file_name)
  
  # Before using the script
  #Set up your ~/.netrc file as listed here: https://wiki.earthdata.nasa.gov/display/EL/How+To+Access+Data+With+cURL+And+Wget
  
  set_config(config(followlocation=1,netrc=1,netrc_file=netrc_path,cookie=cookie_path,cookiefile=cookie_path,cookiejar=cookie_path))
  httr::GET(url = files[x,1],
            write_disk(downloaded_file_path, overwrite = TRUE))
}

  ##########################
  ##  Air temperature at  ##
  ##     surface level    ##
  ##########################

files <- read.delim(paste(dir,"\\onepixel_surface_temp_M2I1NXLFO_5.12.4_20230405_195506_.txt", sep=""))
n <- dim(files)

for (x in 1:n) { 
  file_name <- paste("merra2_airtemp_",substring(files[x,1],159,166),".nc",sep="")
  downloaded_file_path <- paste(dir,"\\surface_temperature\\",file_name)
  set_config(config(followlocation=1,netrc=1,netrc_file=netrc_path,cookie=cookie_path,cookiefile=cookie_path,cookiejar=cookie_path))
  httr::GET(url = files[x,1],
            write_disk(downloaded_file_path, overwrite = TRUE))
}



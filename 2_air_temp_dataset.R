#install.packages(c("ncdf4","raster","rgdal"))
install.packages("reshape2")
install.packages("dplyr")

library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(reshape2)
library(dplyr)

rm(list = ls())

dir <- "$SET FILE DIRECTORY"

##########################
##  Air temperature at  ##
##  different altitudes ##
##########################

files <- read.delim(PASTE(dir,"\\temperature_subset_M2I6NPANA_5.12.4_20230404_205834_.txt", sep=""))
n <- dim(files)

final_df <- data.frame()

# Loop for aggregating image data to inputs in a dataframe

for (x in 1:n) { 

  file_name <- paste("merra2_airtemp_",substring(files[x,1],109,116),".nc4",sep="")
  downloaded_file_path <- paste(dir,"\\air_temperature\\",file_name)
  nc_data<-nc_open(downloaded_file_path)
  
# Display data levels (note it has 4 dimensions: lat, lon, lev and time) 
  lev <- ncvar_get(nc_data,"lev")
  lev
  
  time <- ncvar_get(nc_data,"time")
  head(time)
  
  # get longitude and latitude
  lon <- ncvar_get(nc_data,"lon")
  head(lon)
  
  lat <- ncvar_get(nc_data,"lat")
  head(lat)
  
# Generate data array and transform to 2 dim data set  
  tmp_array <- ncvar_get(nc_data,"T")
  dim(tmp_array)
  
  tmp <- array(data = tmp_array, dim = c(3, 3, 42, 4))
  
  df <- melt(tmp, id.vars = c("Var1", "Var2"), variable.name = "Var3", value.name = "Temp")
  colnames(df) <- c("lon", "lat", "lev", "t", "air_temperature")
  
# Recode altitude levels
  
  df <- df%>%mutate(lon = recode(lon, "1"=-74.375, "2"=-73.750, "3"=-73.125))
  df <- df%>%mutate(lat = recode(lat, "1"=4, "2"=4.5, "3"=5))
  df <- df%>%mutate(t = recode(t, "1"=0, "2"=6, "3"=12, "4"=18))
  df <- df%>%mutate(lev = recode(lev, "1"=1000, "2"=975, "3"=950, "4"=925, "5"=900, "6"=875,
                                 "7"=850, "8"=825, "9"=800, "10"=775, "11"=750, "12"=725, "13"=700,
                                 "14"=650, "15"=600, "16"=550, "17"=500, "18"=450, "19"=400, "20"=350,
                                 "21"=300, "22"=250, "23"=200, "24"=150, "25"=100, "26"=70, "27"=50,
                                 "28"=40, "29"=30, "30"=20, "31"=10, "32"=7, "33"=5, "34"=4,"35"=3,
                                 "36"=2, "37"=1, "38"=0.7, "39"=0.5, "40"=0.4, "41"=0.3, "42"=0.1))
  
# Select pixels to keep  
  df_bta <- df%>%filter(lon==-74.375 & lat==4.5)
  
# Reshape to wide for daily data
  df_bta <- reshape(df_bta, idvar = c("lev", "lat", "lon"), timevar = "t", direction = "wide")
  
  # Keep relevant levels of altitude
  df_bta <- df_bta%>%filter(lev<=825& lev>=500)
  
  df_bta$mean_air_temp <-rowMeans(df_bta[,4:7])
  df_bta$date <- substring(files[x,1],109,116)
  df_bta$year <- substring(files[x,1],109,112)
  df_bta$month <- substring(files[x,1],113,114)
  df_bta$day <- substring(files[x,1],115,116)
  
  final_df <- rbind(final_df,df_bta)
}

write.csv(final_df,paste(dir,"air_temp_bog_2015_2023.csv"))

##########################
##  Air temperature at  ##
##     surface level    ##
##########################

files <- read.delim(paste(dir,"\\onepixel_surface_temp_M2I1NXLFO_5.12.4_20230405_195506_.txt"))

n <- dim(files)

final_df_st <- data.frame()

# Loop generating files for different interest variables at the surface level

for (y in c("TLML", "SPEEDLML", "QLML", "PS", "HLML")) {
 
   df_st <- data.frame()
   
   # Loop for aggregating image data to inputs in a data frame
   
  for (x in 1:n) { 
    file_name <- paste("merra2_airtemp_",substring(files[x,1],159,166),".nc",sep="")
    downloaded_file_path <- paste(dir,"\\surface_temperature\\",file_name)
    
    # Display data dimensions (3 dimensions: lon, lat and time)
    nc_data<-nc_open(downloaded_file_path)
    nc_data
    
    time <- ncvar_get(nc_data,"time")
    head(time)
    
    # Get longitude and latitude
    lon <- ncvar_get(nc_data,"lon")
    head(lon)
    
    lat <- ncvar_get(nc_data,"lat")
    head(lat)
    
    # Image to data array
    tmp_array <- as.data.frame(ncvar_get(nc_data,y))

    # Additional variables for the analysis
    tmp_array$hour=c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)
    tmp_array$year <- substring(files[x,1],159,162)
    tmp_array$day <- substring(files[x,1],163,164)
    tmp_array$month <- substring(files[x,1],165,166)
    tmp_array$date <- substring(files[x,1],159,166)
    
    df_st <- rbind(df_st,tmp_array)
  }
  
  # Merge datasets of multiple variables
  if (y=="TLML"){
    final_df_st<- df_st 
  } else if (y!="TLML"){
    final_df_st <- merge(final_df_st, df_st, by=c("date", "day", "month", "year", "hour"))
  }
  
}

colnames(final_df_st) <- c("date", "day", "month", "year", "hour","TLML", "SPEEDLML", "QLML", "PS", "HLML")


# Save file
write.csv(final_df,paste(dir,"surface_vars_bog_2015_2023.csv"))



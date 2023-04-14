# NASA-MERRA-2-temperature-layers-for-Bogota

This R script downloads data from NASA's MERRA-2 global atmospheric reanalysis. 
Two variable collecitons are downloaded: Air temprature for different pressure levels (inst6_3d_ana_Np (M2I6NPANA)) and Air temperature at surface level (inst1_2d_lfo_Nx (M2I1NXLFO)).
The images for these variables colletions are then filterd and aggregated to create a dataset suitable for statistical analysis.

NOTE: Before running the script, set up your ~/.netrc file as suggested by [earthdata.nasa].(https://wiki.earthdata.nasa.gov/display/EL/How+To+Access+Data+With+cURL+And+Wget)

Supplementary material about the available variables of MERRA 2 can be found [here](https://goldsmr4.gesdisc.eosdis.nasa.gov/data/MERRA2_MONTHLY/M2C0NXASM.5.12.4/doc/MERRA2.README.pdf).

[1_download_merra2_raster_data.R](https://github.com/emilio-leguizamo/NASA-MERRA-2-download-and-transform-to-dataframe/blob/main/1_download_merra2_raster_data.R): Downloads images form NASA's GES DISC repository, make sure to have an active user and have requested downlad links for the data (save the .txt file with the links in the main directory before running the code). 

[2_air_temp_dataset.R](https://github.com/emilio-leguizamo/NASA-MERRA-2-download-and-transform-to-dataframe/blob/main/2_air_temp_dataset.R): This file loops over the downloaded images and extracts key information to compose a data frame that can be used for statistical analysis. 

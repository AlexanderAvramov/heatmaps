#####################################################################################################################
# creator:  alexander a. avramov
# date:     2021.06.23
# purpose:  to process US census zip code shapefile
# note:     please note the data come from the United States Census
#           the data are found at:
#           https://census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html
#####################################################################################################################

########################################################################################################
# set up working directory, clear env, load packages
########################################################################################################
getwd()
setwd('..')
getwd()

rm(list = ls())

library(sf)
library(ggplot2)
library(data.table)
library(rgdal)

options(scipen = 99999)

########################################################################################################
# import data
########################################################################################################
zip <- readOGR("input/tl_2020_us_zcta510/tl_2020_us_zcta510.shp")


########################################################################################################
# fortify data
########################################################################################################
# create unique identifier for the upcoming merge
zip.orig <- zip@data
zip.orig$id <- rownames(zip.orig)
head(zip.orig)

# fortify the entire spatial polygons data frame into a new object
zip.data <- fortify(zip)
head(zip.data) 
# notice that the zip code is missing, but the id we created is not - we use this to merge back the zip
# code information

# merge the fortified object with the original data set
head(zip.data)
head(zip.orig)
zip.data2 <- merge(zip.data,zip.orig, by = "id")


####################################################
# export data
####################################################
saveRDS(zip.data2, file = "output/processed shapefiles/zip.RDS")

  
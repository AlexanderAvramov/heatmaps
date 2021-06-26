#####################################################################################################################
# creator:  alexander a. avramov
# date:     2021.06.23
# purpose:  to process US census roads shapefile
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
roads <- readOGR("input/tl_2020_us_primaryroads/tl_2020_us_primaryroads.shp")


########################################################################################################
# fortify data
########################################################################################################
# create unique identifier for the upcoming merge
roads.orig <- roads@data
roads.orig$id <- rownames(roads.orig)
head(roads.orig)


# fortify the entire spatial polygons data frame into a new object
roads.data <- fortify(roads)
head(roads.data) 


# merge the fortified object with the original data set
head(roads.data)
head(roads.orig)
roads.data2 <- merge(roads.data,roads.orig, by = "id")


####################################################
# export data
####################################################
saveRDS(roads.data2, file = "output/processed shapefiles/roads.RDS")

  
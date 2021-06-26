#####################################################################################################################
# creator:  alexander a. avramov
# date:     2021.06.23
# purpose:  to process US census states shapefile
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
state <- readOGR("input/tl_2020_us_state/tl_2020_us_state.shp")


########################################################################################################
# fortify data
########################################################################################################
# create unique identifier for the upcoming merge
state.orig <- state@data
state.orig$id <- rownames(state.orig)


# fortify the entire spatial polygons data frame into a new object
state.data <- fortify(state)
head(state.data) 


# merge the fortified object with the original data set
head(state.data)
head(state.orig)
state.data2 <- merge(state.data,state.orig, by = "id")


####################################################
# export data
####################################################
saveRDS(state.data2, file = "output/processed shapefiles/state.RDS")

  
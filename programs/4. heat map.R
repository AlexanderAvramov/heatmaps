#####################################################################################################################
# creator:  alexander a. avramov
# date:     2021.06.23
# purpose:  to create some simple heat maps
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

library(dplyr)
library(tidyr)
library(ggplot2)
library(readxl)
library(data.table)

options(scipen = 99999)

########################################################################################################
# import shapefiles
########################################################################################################
zip.data <- readRDS("output/processed shapefiles/zip.RDS") %>%
  mutate(zipcode = as.numeric(as.character(ZCTA5CE10)))


roads <- readRDS("output/processed shapefiles/roads.RDS")


state.map <- readRDS("output/processed shapefiles/state.RDS")


########################################################################################################
# import randomly created (fake) sales data by zip code and division's headquarters location
########################################################################################################
sales <- read_excel("input/sales.xlsx")


location <- read_excel("input/locations.xlsx")


########################################################################################################
# heat map
########################################################################################################

# define the boundaries of the mapping area
bound.lat <- c(37.286666,39.114690)
bound.lon <- c(-79.545963, -75.877144)


# merge the sales information with the zip data & limit to boundaries
map.data <- zip.data %>%
  left_join(sales, by = "zipcode") %>%
  ungroup() %>%
  filter(lat %inrange% bound.lat & long %inrange% bound.lon) %>%
  mutate(abs_diff_share = ifelse(is.na(abs_diff_share),0,abs_diff_share))


# limit the HQ location data to within boundaries
map.location <- location %>%
  filter(lat %inrange% bound.lat & lon %inrange% bound.lon)


# only take interstate roads and limit to within boundaries
roads.map <- roads %>%
  filter(lat %inrange% bound.lat & long %inrange% bound.lon) %>%
  filter(RTTYP %in% c("I"))


# compute average lat - lon for each zip code and pick the top 3 w/ biggest difference
zipcode_lat_lon <- (map.data %>%
  group_by(zipcode,abs_diff_share) %>%
  summarize(lat = mean(lat,na.rm=T), long = mean(long,na.rm=T)) %>%
  ungroup() %>%
  arrange(desc(abs_diff_share)))[1:3,]


# create the map
va.map <- ggplot() +
  
  # create the base for the map
  geom_polygon(data=map.data, aes(x=long,y=lat,group=group),fill='white',color='grey30',size=1.5,show.legend = F) +
  coord_fixed(xlim = bound.lon, ylim = bound.lat, ratio=1)+
  theme_void() +
  
  # add shading for the absolute difference and fix scales
  geom_polygon(data = map.data, aes(x=long,y=lat,group=group,fill=abs_diff_share)) +
  scale_fill_gradient2("Absolute Difference", breaks = c(0,.1,.2,.3,.4,.5,.6,.7,.8,.9)) +
  
  # add the locations of the HQs
  geom_point(data=map.location,aes(x=lon,y=lat),color='black',size=5)+
  annotate('text',x=map.location$lon, y=map.location$lat-0.07,label=map.location$name) +
  
  # add the roads
  geom_path(data=roads.map, aes(x=long,y=lat,group=group),color='red',size=1.05,alpha=0.08) +
  
  # add the state boundaries
  geom_polygon(data=state.map,aes(x=long,y=lat,group=group),fill=NA,color = "#666666",size=.75,alpha=1) +
  
  # add a big city or two in the area
  annotate("text",y=38.05865082759645, x=-78.50040488037158, label = "Charlottesville") + 
  
  # add the zip codes with largest differences 
  annotate("text", x = zipcode_lat_lon$long, y = zipcode_lat_lon$lat, label = zipcode_lat_lon$zipcode, size= 2) +

  # tidy up a bit
  guides(fill = guide_colorbar(barwidth = 25, barheight = 2)) +
  theme(plot.title = element_text(hjust=0.5,size=20,face="bold"),legend.position="bottom")+
  ggtitle("Company's Virginia Sales by Division and Zip Code \n Shaded by Absolute Difference in Share of Sales")


# export the map
ggsave("output/maps/va_heat_map.pdf",va.map,width=11,height=7.5,units='in')

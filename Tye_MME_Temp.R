###############################################################
# MME_WaterTemp
# 20200108
# SPT
###############################################################

rm(list=ls())

#remotes::install_github("USGS-R/lakeattributes")

library(plyr)
library(dplyr)
library(ggplot2)
library(sp)
library(rgeos)
library(sf)
library(remotes)
library(lakeattributes)
library(rworldmap)
library(rworldxtra)
library(ggmap)
library(data.table)
library(ggrepel)
library(tidyverse)
library(gganimate)

###############################################################

setwd("/Users/simontye/Documents/Research/Projects/MME_Temp/2020_MME_Temp")

MN.Fish  <- read.csv(file = "data/raw/Tye_Fishkill_MN.csv", head = TRUE, sep = ",")
MN.Site  <- read.csv(file = "data/raw/MN_Site_County.csv", head = TRUE, sep = ",")
WI.Fish  <- read.csv(file = "data/raw/fish_kill_data_10_24_2018.csv", head = TRUE, sep = ",")
WI.Site  <- read.csv(file = "data/raw/WI_Site.csv", head = TRUE, sep = ",")
Site.ID  <- read.csv(file = "data/raw/Site_ID.csv", head = TRUE, sep = ",")
#thermal  <- read.csv(file = "data/raw/thermal_metrics.csv")

###############################################################
### Preparing MN database
###############################################################
### This code finds the closest waterbody (centroid) to the GPS coordinates for each MME from Phelps et al. (2019)

# Subset event number and coordinates from MN.Fish data
MN.Fish.Columns <- c(1, 69:70)
MN.Fish.GPS <- MN.Fish[, MN.Fish.Columns]
MN.Fish.GPS$Long <- as.numeric(as.character(MN.Fish.GPS$Long))

# Remove events without coordinates
MN.Fish.GPS <- na.omit(MN.Fish.GPS)

# Save event order for later
MN.Fish.Events <- MN.Fish.GPS[, 1]

# Calculate spatial points
MN.Fish.SP <- SpatialPoints(MN.Fish.GPS[, 2:3])
MN.Site.SP  <- SpatialPoints(Site.ID[, 9:10])

# Find nearest lake centroid for each event based on Phelps' GPS coordinates
MN.Nearest <- apply(gDistance(MN.Fish.SP, MN.Site.SP, byid = TRUE), 2, which.min)

# Add event number and nearest site_id to MN.Fish.GPS 
MN.Fish.GPS$Event <- as.vector(MN.Fish.Events)
MN.Fish.GPS$Site  <- as.vector(MN.Nearest)

# Merge fishkill event locations and estimated site_id locations
MN.Fish.1 <- merge(MN.Fish.GPS, Site.ID, by = "Site", all.x = TRUE, all.y = TRUE)

# Subset data that was correctly matched
MN.Fish.2 <- subset(MN.Fish.1, !is.na(MN.Fish.1$Lat.x))

# Create final MN database
MN.Fish.Final <- merge(MN.Fish.2, MN.Fish, by= "Event", all.x = TRUE, all.y = TRUE)

# Transfer site_id data
MN.Fish.Final$Station.Name <- MN.Fish.Final$GNIS_Nm

# Rename columns to match WI data
colnames(MN.Fish.Final)[c(12:13)] <- c("Lat", "Long")

# Remove unnecessary columns and original coordinates
# so that all temperature estimates are based on waterbody centroids
MN.Fish.Final[,c("Lat.x", "Long.x", "Prmnn_I", "GNIS_ID", "GNIS_Nm", "ReachCd",
                 "FType", "FCode", "Lat", "Long", "Site", "WBIC")] <- NULL

# Change column format
MN.Fish.Final$Long <- as.numeric(as.character(MN.Fish.Final$Long))

# Remove unnecessary dataframes
rm(MN.Fish, MN.Fish.1, MN.Fish.2, MN.Fish.GPS, MN.Fish.SP,
   MN.Site, MN.Site.SP, MN.Fish.Columns,
   MN.Fish.Events, MN.Nearest)

###############################################################
### Preparing WI database
###############################################################
### This code changes WBIC to site_id and adds the coordinates of waterbody centroids 

# Merge WI site data and NHD information
WI.Fish.1 <- merge(WI.Site, Site.ID, by = "site_id", all.x = FALSE, all.y = TRUE)

# Merge WI site data and Till et al. (2019) dataset
WI.Fish.2 <- merge(WI.Fish.1, WI.Fish, by = "WBIC", all.x = FALSE, all.y = TRUE)

# Remove sites without data
WI.Fish.Final <- subset(WI.Fish.2, !is.na(WI.Fish.2$Event))

# Remove unnecessary columns
WI.Fish.Final[,c("Event", "X", "Site", "Prmnn_I", "GNIS_ID", "GNIS_Nm", "ReachCd", "FType", "FCode",
                 "WBIC", "Panfish", "X..FIsh.Species.Confirmed", "Game.Fish" )] <- NULL

# Remove unnecessary dataframes
rm(WI.Fish, WI.Fish.1, WI.Fish.2, WI.Site, Site.ID)

###############################################################
### Combine MN and WI datasets
###############################################################
# Combine MN and WI datasets
Fish.Final <- merge(MN.Fish.Final, WI.Fish.Final, all.x = TRUE, all.y = TRUE)

# Calculate the family and species number columns
Fish.Final$Acipenseridae  <- ifelse(Fish.Final$Sturgeon == 1, 1, 0)
Fish.Final$Amiidae        <- ifelse(Fish.Final$Bowfin == 1, 1,
                               ifelse(Fish.Final$Dogfish == 1, 1, 0))
Fish.Final$Catostomidae   <- ifelse(Fish.Final$Bigmouth.Buffalo == 1, 1,
                               ifelse(Fish.Final$Shorthead.Redhorse == 1, 1,
                                      ifelse(Fish.Final$Suckerfish == 1, 1,
                                             ifelse(Fish.Final$White.Sucker == 1, 1, 0))))
Fish.Final$Centrarchidae  <- ifelse(Fish.Final$Bass == 1, 1,
                               ifelse(Fish.Final$Bluegill == 1, 1,
                                      ifelse(Fish.Final$Crappie == 1, 1,
                                             ifelse(Fish.Final$Largemouth.Bass == 1, 1,
                                                    ifelse(Fish.Final$Pumpkinseed == 1, 1,
                                                           ifelse(Fish.Final$Rock.Bass == 1, 1,
                                                                  ifelse(Fish.Final$Smallmouth.Bass == 1, 1,
                                                                         ifelse(Fish.Final$Sunfish == 1, 1,
                                                                                ifelse(Fish.Final$Sunnies == 1, 1, 0)))))))))
Fish.Final$Clupeidae      <- ifelse(Fish.Final$Gizzard.Shad == 1, 1, 0)
Fish.Final$Cyprinidae     <- ifelse(Fish.Final$Carp == 1, 1,
                               ifelse(Fish.Final$Chub == 1, 1,
                                      ifelse(Fish.Final$Dace == 1, 1,
                                             ifelse(Fish.Final$Golden.Shiner == 1, 1,
                                                    ifelse(Fish.Final$Minnow == 1, 1, 0)))))
Fish.Final$Esocidae       <- ifelse(Fish.Final$Muskies == 1, 1,
                               ifelse(Fish.Final$Northern.Pike == 1, 1,
                                      ifelse(Fish.Final$Pike == 1, 1, 0)))
Fish.Final$Gasterosteidae <- ifelse(Fish.Final$Stickleback == 1, 1, 0)
Fish.Final$Gobiidae       <- ifelse(Fish.Final$Round.Goby == 1, 1, 0)
Fish.Final$Ictaluridae    <- ifelse(Fish.Final$Bullhead == 1, 1,
                               ifelse(Fish.Final$Catfish == 1, 1,
                                      ifelse(Fish.Final$Channel.Catfish == 1, 1,
                                             ifelse(Fish.Final$Stonecat == 1, 1, 0))))
Fish.Final$Lepisosteidae  <- ifelse(Fish.Final$Gar == 1, 1, 0)
Fish.Final$Osmeridae      <- ifelse(Fish.Final$Rainbow.Smelt == 1, 1, 0)
Fish.Final$Percidae       <- ifelse(Fish.Final$Darter == 1, 1,
                               ifelse(Fish.Final$Perch == 1, 1,
                                      ifelse(Fish.Final$Sauger == 1, 1,
                                             ifelse(Fish.Final$Walleye == 1, 1,
                                                    ifelse(Fish.Final$Yellow.Perch == 1, 1, 0)))))
Fish.Final$Salmonidae     <- ifelse(Fish.Final$Brown.Trout == 1, 1,
                               ifelse(Fish.Final$Cisco == 1, 1,
                                      ifelse(Fish.Final$Trout == 1, 1,
                                             ifelse(Fish.Final$Whitefish == 1, 1, 0))))
### Combine Drum and Freshwater.Drum?
Fish.Final$Sciaenidae     <- ifelse(Fish.Final$Drum == 1, 1,
                               ifelse(Fish.Final$Freshwater.Drum == 1, 1, 0))


# Export MN.Fish.Final dataset
write.csv(Fish.Final, "data/raw/Fish_Final_20200108.csv", row.names = TRUE)

###############################################################
### Test maps
###############################################################

# Subset data and reformat for maps
Fish.Map <- subset(Fish.Final, select = c(Lat, Long, Year))
Fish.Map$Year <- ifelse(Fish.Map$Year > 2000, Fish.Map$Year, NA)
Fish.Map <- na.omit(Fish.Map)
Fish.Map$Event <- c(1:635)
Fish.Map$Year <- as.numeric(Fish.Map$Year)

###############################################################

# Heat map
ggmap(map) +
  stat_density2d(data = Fish.Map, aes(x = Lat, y = Long, fill = ..level.., alpha = ..level..), size = 0.3, bins = 20, geom = "polygon") +
  borders("state") +
  scale_fill_gradient(low = "green", high = "red") + 
  scale_alpha(range = c(0, 0.8), guide = FALSE)

###############################################################
###############################################################
###############################################################







###############################################################
# MME_WaterTemp
# 2020.03.15
# SPT
###############################################################
### Progress report

# 1. Reformatted Phelps et al. (2019) dataset to match Till et al. (2019).

# 2. Since we need to know which lakes were affected for the water temperature assessments,
#    I matched the GPS coordinates from Phelps to the nearest waterbody centroid
#    This worked for 229/284 events in the dataset. I still need to fix those 60 events.

# 3. Then I matched up fish taxa across datasets, merged both datasets, and created columns
#    for each fish family since species-specific assessments aren't too feasible.

# 4. Lastly, I exported the merged dataset for review and made that quick map

# 5. Once I finish verifying those missing sites, double-checking that all the pertient columns are filled,
#    and deciding on a fish kill delineation, we should be close to being able to dive into the temperature stuff.
#    For now, I left the fish kill magnitude column of Till et al. (2019) as is (i.e., basically categorized as
#    excludable, low, medium, or high magnitude events), and created columns in the Phelps et al. (2019) dataset
#    with the minimum and maximum observed dead fish from the online MN database.

# 6. If you change the working directory and add the zipped files to that directory, this should all run. Only snag
#    Would be manually installing the "lakeattributes" package. The code to do that is hashed out below. It's some
#    ugly code as is, but it works. I'll redo it in Markdown when we get further.

###############################################################

# Reset global enviroment
rm(list=ls())

# Install USGS Lake Attributes
#remotes::install_github("USGS-R/lakeattributes")

# Load packages
library(plyr)
library(dplyr)
library(ggplot2)
library(remotes)
library(lakeattributes)
library(data.table)
library(tidyverse)
library(rworldmap)
library(rworldxtra)
library(sp)
library(rgeos)
library(sf)
library(usmap)
library(ggmap)
library(ggrepel)
library(ggspatial)
library(rgdal)
library(stringr)
library(lubridate)
library(raster)
library(naniar)

###############################################################

# Set working directory
setwd("/Users/simontye/Documents/Research/Projects/MME_Temp/2020_MME_Temp")

# Load files
MN.Fish  <- read.csv(file = "data/raw/MN_Fish_Final.csv", head = TRUE, sep = ",")
MN.Site  <- read.csv(file = "data/raw/MN_Site_County.csv", head = TRUE, sep = ",")
WI.Fish  <- read.csv(file = "data/raw/WI_Fish_Final.csv", head = TRUE, sep = ",")
WI.Site  <- read.csv(file = "data/raw/WI_Site.csv", head = TRUE, sep = ",")
Site.ID  <- read.csv(file = "data/raw/Site_ID.csv", head = TRUE, sep = ",")
thermal  <- read.csv(file = "data/raw/thermal_metrics.csv")
thermal  <- inner_join(thermal, Site.ID, by = "site_id")

###############################################################
### Preparing MN database
###############################################################
### This code finds the closest waterbody centroid to the GPS coordinates for each MME from Phelps et al. (2019)
### Finds 229/284 events; need to look up GPS coordinates or event details for remaining events.

# Subset event number and coordinates from MN.Fish data
MN.Fish.Columns <- c(1, 70:71)
MN.Fish.GPS <- MN.Fish[, MN.Fish.Columns]
MN.Fish.GPS$Lat <- as.numeric(as.character(MN.Fish.GPS$Lat))

# Remove events without coordinates (284 events total; 240 events with coordinates)
MN.Fish.GPS <- na.omit(MN.Fish.GPS)

# Save event order for later
MN.Fish.Events <- MN.Fish.GPS[, 1]

# Calculate spatial points
MN.Fish.SP  <- SpatialPoints(MN.Fish.GPS[, 2:3])
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

# Save original GPS points
colnames(MN.Fish.Final)[c(82:83)] <- c("Lat_OG", "Long_OG")

# Remove unnecessary columns
MN.Fish.Final[,c("Site", "Lat.x", "Long.x", "Prmnn_I",
                 "GNIS_ID", "GNIS_Nm", "ReachCd",
                 "FType", "FCode", "WBIC", "GPS", "Notes")] <- NULL

# Change column format
MN.Fish.Final$Lat_OG <- as.numeric(as.character(MN.Fish.Final$Lat_OG))

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

# Remove sites without data (none removed)
WI.Fish.Final <- subset(WI.Fish.2, !is.na(WI.Fish.2$Event))

# Remove unnecessary columns
WI.Fish.Final[,c("WBIC", "X", "Site", "Prmnn_I", "GNIS_ID",
                 "GNIS_Nm", "ReachCd", "FType", "FCode",
                 "Snail", "Crayfish", "Frogs")] <- NULL

# Remove unnecessary dataframes
rm(WI.Fish, WI.Fish.1, WI.Fish.2, WI.Site, Site.ID)

###############################################################
### Combine MN and WI datasets
###############################################################
### This code combines a portion (229/284 events) of Phelps et al. (2019) with Till et al. (2019)

# Merge datasets
Fish.Final <- merge(MN.Fish.Final, WI.Fish.Final, all.x = TRUE, all.y = TRUE)

# Create columns for fish families
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

Fish.Final$Sciaenidae     <- ifelse(Fish.Final$Drum == 1, 1,
                               ifelse(Fish.Final$Freshwater.Drum == 1, 1, 0))

## Order events by date and add sequence of events to remove duplicate events
Fish.Final$Investigation.Start.Date <- as.Date(Fish.Final$Investigation.Start.Date, format = "%d-%b-%y")
Fish.Final <- Fish.Final[order(as.Date(Fish.Final$Investigation.Start.Date, format="%d-%b-%y")),]
Fish.Final$Fishkill.Inv.Seq.No <- c(1:915)

# Remove unnecessary columns
Fish.Final[,c("Site.Seq.No", "Swims.Station.Id", "Stream.Miles.or.Lake.Acres.Affected",
              "Snail", "Crayfish", "Frogs", "Event")] <- NULL

# Make columns uppercase
Fish.Final$Station.Name <- toupper(Fish.Final$Station.Name)
Fish.Final$Cause.Detail <- toupper(Fish.Final$Cause.Detail)

# Export Fish.Final dataset
write.csv(Fish.Final, "data/raw/Fish_Final.csv", row.names = TRUE)

# Remove unnecessary dataframes
rm(MN.Fish.Final, WI.Fish.Final)

###############################################################
### Preliminary figures
###############################################################

# Subset data to make some quick maps
Fish.Map <- subset(Fish.Final, select = c(Lat, Long, Year, State))

# Remove events before 2000
Fish.Map$Year <- ifelse(Fish.Map$Year > 2000, Fish.Map$Year, NA)
Fish.Map <- na.omit(Fish.Map)

# Create new event column
Fish.Map$Event <- c(1:646)

#Fish.Map$Year <- as.numeric(Fish.Map$Year)
# Rename columns to match ggplot functions
Fish.Map$region <- Fish.Map$State
Fish.Map$State <- NULL
Fish.Map$long <- Fish.Map$Long
Fish.Map$lat <- Fish.Map$Lat
Fish.Map$Lat <- NULL
Fish.Map$Long <- NULL

# Remove event that is appears to be outside the study region
Fish.Map$Event <- ifelse(Fish.Map$Event == 586, NA, Fish.Map$Event)
Fish.Map <- na.omit(Fish.Map)

# Create state boundaries
states   <- map_data("state")
states   <- subset(states, region %in% c("minnesota", "wisconsin"))

# Create county boundaries
counties <- map_data("county")
counties <- subset(counties, region %in% c("minnesota", "wisconsin"))

# Quick map
ggplot(data = states, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(data = counties, color = "darkgray", fill = "gray", size = 0.5, aes(x = long, y = lat, alpha = 0.1, group = group)) +
  geom_polygon(data = states, color = "black", fill = NA, size = 1) +
  stat_density2d(data = Fish.Map, aes(x = long, y = lat, fill = ..level.., alpha = ..level.., group = region), bins = 30, geom = "polygon") +
  geom_point(data = Fish.Map, color = "black", fill = "darkolivegreen3", size = 2, shape = 21, aes(x = long, y = lat, group = region)) +
  theme_nothing()

# Remove map dataframes
rm(counties, states)

###############################################################
###############################################################
### Till et al. (2019) framework
###############################################################
###############################################################

###############################################################
### MME raw data
###############################################################

MME <- Fish.Final %>%
  rename_all(tolower) %>%
  mutate_all(tolower) %>%
  #dplyr::filter(min.kill.size!="excludable") %>% # Need to determine cutoff
  dplyr::select(site_id, # Changed from WBIC
                year,
                investigation.start.month,
                fishkill.inv.seq.no,
                cause.group) %>% # change from cause.category to cause.group
  rename(month = investigation.start.month) %>%
  mutate(dummy = 1,
         cause.categories = cause.group) %>% # change from cause.category to cause.group
  spread(cause.categories, dummy, fill = 0) %>%
  dplyr::select(-fishkill.inv.seq.no) %>%
  distinct(site_id, year, month, .keep_all = TRUE)

###############################################################
### Thermal raw data
###############################################################

thermal <- thermal %>%
  rename_all(tolower) #%>%
  mutate(year = as.numeric(year)) #%>%
  filter(year >= 2003) #%>%
  #mutate(year = as.character(year)) #%>%
  #dplyr::select(-contains("strat"),
                #-sthermo_depth_mean)

###############################################################

thermal_annual <- thermal %>%
  dplyr::select(-contains('jas'),
                -starts_with('mean_surf_'),
                -starts_with('mean_bot_'), 
                -starts_with('max_surf_'), 
                -starts_with('max_bot_')) %>%
  group_by(site_id, year) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>%
  ungroup() %>%
  rename(ice_duration = ice_duration_days,
         schmidt = schmidt_daily_annual_sum,
         variance_after_ice_30 = coef_var_0.30, 
         variance_after_ice_60 = coef_var_30.60, 
         cumulative_above_0 = gdd_wtr_0c,
         cumulative_above_5 = gdd_wtr_5c,
         cumulative_above_10 = gdd_wtr_10c) %>%
  mutate(log_schmidt = log(schmidt + .00001))

###############################################################

thermal_monthly <- thermal %>%
  dplyr::select(starts_with('mean_surf_'),            # tidy the temp data
                starts_with('mean_bot_'), 
                starts_with('max_surf_'), 
                starts_with('max_bot_'),
                -contains('jas'),
                year, site_id) %>%
  mutate(uniqueid = 1:n()) %>%
  gather(key = "type", value = "temperature", 
         starts_with('mean_surf_'),
         starts_with('mean_bot_'), 
         starts_with('max_surf_'), 
         starts_with('max_bot_')) %>%
  separate(type, into=c('metric', 'depth', 'month'), sep='_')  %>%
  unite(metric, metric, depth) %>%
  spread(metric, temperature) %>%
  dplyr::select(-uniqueid) %>%
  group_by(site_id, year, month) %>%                      # average over sites
  summarise_if(is.numeric, mean, na.rm = TRUE) %>%
  ungroup() %>%
  arrange(site_id, year, month) %>%
  mutate(date = ymd(paste(year, month, "15"))) %>%
  filter(date > "2003-01-01", date < "2014-05-01")

###############################################################

thermal_monthly <- thermal_monthly %>%
  group_by(site_id, month) %>%
  mutate(max_bot_z = scale(max_bot),                   # make z-score vars
         max_surf_z = scale(max_surf),
         mean_bot_z = scale(mean_bot),
         mean_surf_z = scale(mean_surf)) %>%
  ungroup() %>%
  mutate(layer_diff = mean_surf - mean_bot,            # create additional temp/time features
         quadratic_temp = mean_surf^2,
         season = fct_collapse(month,
                               "winter" = "dec",
                               "winter" = "jan",
                               "winter" = "feb",
                               "spring" = "mar",
                               "spring" = "apr",
                               "spring" = "may",
                               "summer" = "jun",
                               "summer" = "jul",
                               "summer" = "aug",
                               "fall"   = "sep",
                               "fall"   = "oct",
                               "fall"   = "nov"))

###############################################################

pr <- thermal_monthly %>%
  dplyr::select(max_surf, mean_surf, mean_bot) %>%
  prcomp(center = TRUE, scale = TRUE)

temp <- thermal_monthly %>%
  dplyr::select(max_surf, mean_surf, mean_bot) %>%
  as.matrix() %*% pr$rotation[,1]

thermal_monthly <- thermal_monthly %>%
  add_column(temp)

rm(pr, temp, thermal)

###############################################################
### Merging MME into thermal
###############################################################

# Change to numeric or characters, whichever works
thermal_annual$year  <- as.numeric(thermal_annual$year)
thermal_monthly$year <- as.numeric(thermal_monthly$year)
MME$year             <- as.numeric(MME$year)
### Site id also needs to be changes

df <- thermal_monthly %>%
  left_join(thermal_annual, by = c("year", "site_id")) %>%
  left_join(MME, by = c("year", "month", "site_id"))

df <- df %>%
  mutate(summerkill = ifelse(is.na(summerkill), 0, summerkill),
         winterkill = ifelse(is.na(winterkill), 0, winterkill),
         anthropogenic = ifelse(is.na(anthropogenic), 0, anthropogenic),
         infectious = ifelse(is.na(infectious), 0, infectious),
         unknown = ifelse(is.na(unknown), 0, unknown))

rm(thermal_monthly, thermal_annual)

###############################################################
### Snowfall data
###############################################################

tidy_snow <- function(path) {
  
  e <-extent(-92.9, -87, 42.4 , 46.9)
  a <- crop(raster(path),e)
  
  a1 <- as.data.frame(coordinates(a))
  a2<- as.data.frame(a)
  
  data <- na.omit(cbind(a1, a2)) 
  
  names(data) <- c('x', 'y', 'snow')
  
  data$long_round <- round(data$x, 1)
  data$lat_round <- round(data$y, 1)  
  
  data_output <- data %>%
    group_by(long_round, lat_round) %>%
    summarise(Snow = mean(snow))
  
  data_output$Year <- str_sub(path, 24, 27)
  data_output$Month <- str_sub(path, 28, 29)
  return(data_output)
}

###############################################################
###############################################################
###############################################################

setwd("data/raw/PRISM_precip")
file_names <- list.files() %>%
  str_subset("asc$")
snow_data <- map_df(file_names, tidy_snow)

write_csv(snow_data, "../../processed/snow_data.csv")

rm(snow_data)



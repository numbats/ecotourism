library(tidyverse)

# read data cuttlefish
data("giant_cuttlefish")

# read aus stations csv files locally
aus_stations <- read_csv("data-raw/aus_stations.csv")

# install.packages("geosphere")
library(geosphere)

# Function to find the nearest weather station
find_nearest_station <- function(spot, stations) {
  distances <- distm(
    matrix(c(spot$lon, spot$lat), ncol = 2),
    matrix(c(stations$lon, stations$lat), ncol = 2),
    fun = distHaversine
  )
  nearest_station_index <- which.min(distances)
  return(stations[nearest_station_index, ])
}


# Apply the function to each tourism spot
cuttlefish <- cuttlefish %>%
  rowwise() %>%
  mutate(
    stnid = find_nearest_station(cur_data(), aus_stations)$stnid,
    # stn_lon = find_nearest_station(cur_data(), aus_stations)$lon,
    # stn_lat = find_nearest_station(cur_data(), aus_stations)$lat
  ) %>%
  ungroup()

save(cuttlefish, file="data/cuttlefish.rda")

# independent nearest data sets
stations <- cuttlefish %>%
  rowwise() %>%
  transmute(
    stnid = find_nearest_station(cur_data(), aus_stations)$stnid,
    lon = find_nearest_station(cur_data(), aus_stations)$lon,
    lat = find_nearest_station(cur_data(), aus_stations)$lat
    
  ) %>%
  ungroup()

save(stations, file="data/stations.rda")

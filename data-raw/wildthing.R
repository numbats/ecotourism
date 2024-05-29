# This code is for processing the raw data into a nice size.
library(tidyverse)
library(ozmaps)
library(ggthemes)
library(rmapshaper)
library(plotly)
library(lubridate)
library(tsibble)
library(rnoaa)

# Original file, wrong name
load("data-raw/giant_cuttlefish.rda")
cuttlefish <- new_sepia_apama
save(cuttlefish, file="data-raw/giant_cuttlefish.rda")

# Clean data
cuttlefish <- cuttlefish |>
  rename(lon = decimalLongitude,
         lat = decimalLatitude,
         date = eventDate,
         name = scientificName,
         id = recordID,
         source = dataResourceName) |>
  mutate(year = year(date),
         month = month(date, label=TRUE),
         wday = wday(date, label=TRUE, week_start = 1)) |>
  select(id, name, lon, lat, date,
         year, month, wday, source)

# Check dates
cuttlefish |>
  group_by(year) |>
  summarise(count = n()) |>
  ggplot(aes(year, count)) +
    geom_point() +
  geom_smooth(se=FALSE, colour="grey60")

# Select only after 2000
cuttlefish <- cuttlefish |>
  filter(year > 1999)

# Check time of year
cuttlefish |>
  group_by(month) |>
  summarise(count = n()) |>
  ggplot(aes(month, count)) +
  geom_point() +
  geom_smooth(se=FALSE, colour="grey60")

# Check geography
oz <- ozmap_data("abs_lga")
oz_small <- ms_simplify(oz)

ggplot(oz) +
  geom_sf(colour="white", fill="grey90") +
  geom_point(data=cuttlefish, aes(x=lon, y=lat,
                                  label=date),
             colour="#EA6900", alpha=0.5) +
  xlim(c(113.09, 153.38)) +
  ylim(c(-43.38, -10.41)) +
  theme_map()
ggplotly()

# Note the curious line through NSW!

# Zoom to small regions
whyalla <- tibble(lon=137.5756, lat=-33.0346)
ggplot(oz) +
  geom_sf(colour="white", fill="grey90") +
  geom_point(data=cuttlefish, aes(x=lon, y=lat,
                                  label=date),
             colour="#EA6900", alpha=0.5) +
  xlim(c(136, 138.5)) +
  ylim(c(-35.95, -32.5)) +
  geom_point(data=whyalla, aes(x=lon, y=lat),
             colour="#3B99B1", shape=3, size=4) +
  theme_map()
ggplotly()

save(cuttlefish, file="data/giant_cuttlefish.rda")

# Weather
load("data-raw/weather.rda")
weather <- joined |>
  select(id, long, lat, elev, name, date, prcp, tmax, tmin) |>
  rename(stnid = id, lon=long)
save(weather, file="data/weather.rda")

# More stations
aus_stations <- ghcnd_stations() |>
  filter(str_starts(id, "ASN")) |>
  filter(last_year >= 2020) |>
  mutate(wmo_id = as.numeric(wmo_id),
         name = str_to_lower(name)) |>
  select(-state, -gsn_flag) |>
  filter(element %in% c("PRCP", "TMAX", "TMIN")) |>
  nest(element: last_year) |>
  rowwise() |>
  filter(nrow(data) == 3) |>
  select(-data)


# Tourism
# load("data-raw/tourism.rda") # Qtr isn't saved correctly
domestic_trips <- read_csv(
  "data-raw/domestic_trips_2023-10-08.csv",
  skip = 9,
  col_names = c("Quarter", "Region", "Holiday", "Visiting", "Business", "Other", "Total"),
  n_max = 248056
) %>% select(-X8)

# fill NA in "Quarter" using the last obs
fill_na <- domestic_trips %>%
  fill(Quarter, .direction = "down") %>%
  filter(Quarter != "Total")

# gather Stopover purpose of visit
long_data <- fill_na %>%
  pivot_longer(cols=Holiday:Total,
               names_to="Purpose",
               values_to="Trips")

# manipulate Quarter
qtr_data <- long_data %>%
  mutate(
    Quarter = paste(gsub(" quarter", "", Quarter), "01")
  )

tourism <- qtr_data
save(tourism, file="data/tourism.rda")

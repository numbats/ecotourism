#' cuttlefish
#'
#' Sightings of cuttlefish downloaded from https://www.ala.org.au
#'
#' \itemize{
#'   \item id, record id given by Atlas
#'   \item name, scientific name
#'   \item lon, lat spatial coordinates of the sighting
#'   \item date, year, month, wday, time of sighting
#'   \item source, original provider of the record
#' }
#'
#' @name Cuttlefish sightings
#' @docType data
#' @format A 750 x 9 numeric array
#' @keywords datasets
#' @examples
#'
#' head(cuttlefish)
"cuttlefish"

#' weather
#'
#' Daily records of precipitation, min and max temperature, covering locations and times of sightings, as available using the `rnoaa` package.
#'
#' \itemize{
#'   \item stnid, station id
#'   \item lon, lat, elev spatial coordinates of the station
#'   \item date, day of records
#'   \item prcp precipitation in mm
#'   \item tmax, tmin temperature in Celsius
#' }
#'
#' @name Weather records near sightings
#' @docType data
#' @format A 15274 x 9 numeric array
#' @keywords datasets
#' @examples
#'
#' head(weather)
"weather"

#' tourism
#'
#' Quarterly records of tourist counts in regions across the country
#'
#' \itemize{
#'   \item Quarter
#'   \item Region
#'   \item Purpose
#'   \item Trips
#' }
#'
#' @name Tourism counts
#' @docType data
#' @format A 1228000 x 4 numeric array
#' @keywords datasets
#' @examples
#'
#' library(tsibble)
#' data(tourism)
#' tourism <- tourism |>
#'   mutate(Quarter = yearquarter(myd(Quarter))) |>
#'   as_tsibble(key = c(Region, Purpose), index = Quarter))
#'
"tourism"

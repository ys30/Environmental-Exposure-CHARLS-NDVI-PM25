# City × Urban/NonUrban × Month NDVI exposure pipeline
# Cleaned from the working research script. Requires objects created from
# MOD13A3 NDVI, MCD12Q1 land cover and prefecture boundaries.

library(terra)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

urban_class <- 13
nonurban_classes <- c(1,2,3,4,5,6,7,8,9,10,11,12,14)

# Required objects:
# ndvi_clean : SpatRaster, monthly MOD13A3 NDVI after valid-range/QA processing
# dates      : dates for ndvi_clean layers
# lc_type1   : annual MCD12Q1 LC_Type1 raster stack
# lc_info    : data.frame with land-cover layer/year index
# china_city : prefecture-level polygons with city_id, province, city

ndvi_template <- ndvi_clean[[1]]
city_info <- as.data.frame(china_city) |> select(city_id, province, city)

prepare_landcover_year <- function(y) {
  idx <- which(lc_info$year == y)
  if (length(idx) != 1) stop("Cannot identify unique LC layer for ", y)
  lc_y <- lc_type1[[idx]]

  urban_500 <- ifel(lc_y == urban_class, 1, 0)
  nonurban_500 <- ifel(lc_y %in% nonurban_classes, 1, 0)

  # Average projection gives the fraction of each 1-km NDVI cell
  # covered by the source 500-m land-cover class.
  urban_fraction <- project(urban_500, ndvi_template, method = "average")
  nonurban_fraction <- project(nonurban_500, ndvi_template, method = "average")

  list(
    urban = ifel(urban_fraction >= 0.5, 1, NA),
    nonurban = ifel(nonurban_fraction >= 0.5, 1, NA)
  )
}

extract_context <- function(ndvi_y, mask_y, context_label) {
  z <- mask(ndvi_y, mask_y)
  means <- terra::extract(z, china_city, fun = mean, na.rm = TRUE)
  counts <- terra::extract(!is.na(z), china_city, fun = sum, na.rm = TRUE)

  m <- bind_cols(city_info, means[, -1]) |>
    pivot_longer(-c(city_id, province, city), names_to="layer", values_to="NDVI") |>
    mutate(
      year = as.integer(str_extract(layer, "\\d{4}")),
      month = as.integer(str_extract(layer, "\\d{2}$")),
      date = as.Date(paste(year, month, 1, sep="-")),
      urban_rural = context_label
    )

  n <- bind_cols(city_info, counts[, -1]) |>
    pivot_longer(-c(city_id, province, city), names_to="layer", values_to="valid_pixels") |>
    mutate(
      year = as.integer(str_extract(layer, "\\d{4}")),
      month = as.integer(str_extract(layer, "\\d{2}$"))
    ) |>
    select(city_id, province, city, year, month, valid_pixels)

  left_join(m, n, by=c("city_id","province","city","year","month"))
}

all_results <- list()
for (y in 2005:2020) {
  idx_y <- which(year(dates) == y)
  if (!length(idx_y)) next

  masks <- prepare_landcover_year(y)
  ndvi_y <- ndvi_clean[[idx_y]]

  all_results[[as.character(y)]] <- bind_rows(
    extract_context(ndvi_y, masks$urban, "Urban"),
    extract_context(ndvi_y, masks$nonurban, "NonUrban")
  )
}

city_monthly_ndvi <- bind_rows(all_results) |>
  select(city_id, province, city, urban_rural, year, month, date, NDVI, valid_pixels) |>
  arrange(city_id, urban_rural, date)

# Coverage diagnostics are retained with the exposure dataset.
city_completeness <- city_monthly_ndvi |>
  group_by(city_id, province, city, urban_rural) |>
  summarise(
    n_months=n(),
    n_valid_NDVI=sum(!is.na(NDVI)),
    valid_percent=mean(!is.na(NDVI))*100,
    .groups="drop"
  )

write.csv(city_monthly_ndvi, "China_city_urban_nonurban_monthly_NDVI_2005_2020.csv", row.names=FALSE)
write.csv(city_completeness, "China_city_urban_nonurban_NDVI_completeness.csv", row.names=FALSE)

# Modeling framework used in the CHARLS environmental-exposure analysis.
# This file documents the final structure without redistributing CHARLS microdata.

library(dplyr)
library(lme4)

# Expected analysis_data fields include:
# CESD10, NDVI_lag2, PM25_lag1, city_id, urban_nbs, interview_year,
# wave, ID, age, gender, education, hukou and selected contextual covariates.

analysis_data <- analysis_data |>
  mutate(
    NDVI_lag2_01 = NDVI_lag2 / 0.1,
    city_id = factor(city_id),
    urban_nbs = factor(urban_nbs),
    wave = factor(wave),
    ID = factor(ID),
    space_id = interaction(city_id, urban_nbs, drop=TRUE, sep="__")
  )

# PM2.5 between/within decomposition is constructed from unique city-year
# observations to separate persistent spatial differences from temporal change.
city_year_pm <- analysis_data |>
  filter(!is.na(city_id), !is.na(interview_year), !is.na(PM25_lag1)) |>
  distinct(city_id, interview_year, PM25_lag1)

city_pm_mean <- city_year_pm |>
  group_by(city_id) |>
  summarise(PM25_between=mean(PM25_lag1, na.rm=TRUE), .groups="drop")

city_year_pm <- city_year_pm |>
  left_join(city_pm_mean, by="city_id") |>
  mutate(PM25_within = PM25_lag1 - PM25_between)

analysis_data <- analysis_data |>
  left_join(city_year_pm, by=c("city_id","interview_year","PM25_lag1"))

# Representative spatial + wave adjusted mixed model.
# Extend the RHS with the selected contextual/personal covariate set used
# in the corresponding specification table.
m_primary <- lmer(
  CESD10 ~ NDVI_lag2_01 + PM25_between + PM25_within +
    age + gender + education + hukou +
    space_id + wave + (1 | ID),
  data = analysis_data,
  REML = FALSE
)

summary(m_primary)

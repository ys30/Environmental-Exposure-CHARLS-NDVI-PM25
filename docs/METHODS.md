# Methods notes

## Greenness exposure

Monthly MOD13A3.061 NDVI is processed at 1-km resolution. The workflow checks the valid NDVI range and retains Pixel Reliability as a QA/sensitivity dimension. Annual MCD12Q1.061 LC_Type1 is used to construct urban and non-urban vegetated/agricultural masks. Source 500-m land-cover classes are projected to the 1-km NDVI grid using average coverage, and a >=50% rule assigns the dominant context.

Monthly NDVI is then summarized within prefecture-level polygons separately for Urban and NonUrban contexts. Valid-pixel counts are saved alongside the exposure estimate for coverage auditing.

## QA

Good + Marginal Pixel Reliability is retained as a practical QA sensitivity. Good-only filtering is a strict sensitivity because it creates large spatial gaps in the working data. The epidemiologic exposure is based on spatially and temporally aggregated greenness rather than a single pixel-month.

## Health analysis

Harmonized CHARLS person-wave records are linked to city/context environmental exposure. CESD-10 is the mental-health outcome. The modeling sequence progressively adds spatial fixed effects, survey-wave or interview-year temporal controls, participant random intercepts, contextual covariates, and city-specific time trends. PM2.5 is decomposed into between-city and within-city components in stronger specifications.

## Interpretation

Current estimates are observational associations and remain subject to exposure misclassification, residual confounding, and specification sensitivity.

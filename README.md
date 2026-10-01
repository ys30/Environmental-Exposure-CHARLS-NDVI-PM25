# Environmental Exposure × CHARLS: NDVI, PM2.5 & Mental Health

Reproducible environmental-exposure workflow linking satellite-derived greenness, land-cover context, air pollution, and longitudinal CHARLS mental-health outcomes.

## Study workflow

```
MODIS MOD13A3 monthly NDVI (1 km)
        ↓ valid-range + Pixel Reliability QA
MCD12Q1 annual land cover (500 m)
        ↓ urban / non-urban masks
Prefecture × month greenness exposure
        ↓ lagged / long-term exposure windows
City-level PM2.5 + harmonized CHARLS person-wave data
        ↓
Longitudinal mixed / fixed-effects models
        ↓
CESD-10 depressive-symptom outcome
```

## Current analysis

- CHARLS waves: 2011/12–2020
- NDVI processing window: 2005–2020
- Greenness: MOD13A3.061 monthly NDVI, 1-km
- Land cover: MCD12Q1.061 LC_Type1, 500-m
- Urban class: IGBP class 13
- Non-urban vegetation/agriculture: IGBP classes 1–12 and 14
- Air pollution: city-level PM2.5
- Outcome: CESD-10 (lower scores indicate fewer depressive symptoms)

The current primary spatial-and-wave adjusted specification estimates **−0.477 CESD-10 points per +0.1 NDVI** (95% CI −0.831 to −0.122; p=0.0085; 63,004 observations). This is presented as an observational association, not a causal effect.

## NDVI QA strategy

Pixel Reliability is retained as a sensitivity dimension rather than using Good-only pixels as the sole exposure definition.

- **Primary exposure:** valid MOD13A3 NDVI aggregated to city/context and longer exposure windows.
- **QA sensitivity:** Good + Marginal observations.
- **Strict sensitivity:** Good-only observations.

Good-only screening produces substantial spatial gaps in these data, so it is useful as a strict sensitivity analysis rather than the only exposure surface.

## Repository structure

```
R/
  01_ndvi_landcover_city_exposure.R
  02_modeling_framework.R
docs/
  METHODS.md
results/
  current_estimates.csv
.gitignore
README.md
```

## Data availability

This repository intentionally does **not** redistribute restricted CHARLS microdata, raw respondent-level analysis files, private geographic crosswalks, Earthdata credentials, or large source rasters. Users should obtain source data under the relevant providers' terms and configure local paths/credentials outside version control.

## Reproducibility note

The scripts are cleaned from the working research code: machine-specific paths and credentials are removed, while the analytical definitions and modeling structure are retained.

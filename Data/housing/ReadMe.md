# Data provenance

These data have been sourced from the [Swedish statistical database](https://www.statistikdatabasen.scb.se/) (SCB) on 2021-09-28

Data were exported using the `Excel (xlsx) with code and text column` option, the resulting spreadsheet saved using the filename as downloaded. The following steps were then done to convert to CSV:

  1. Select a portion of the file that contains the data and copy it
  2. Paste into a new spreadsheet
  3. Add headings for columns
  4. Replace all commas with `-- `
  5. Save as `.xlsx`
  6. Export as UTF-8 `.csv`

## Data downloaded

### Households and demographics
  + [Number of persons by foreign or Swedish background, type of housing, age and sex. Year 2012 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0111/HushallT28/). Whole of Sweden. Saved as `sweden-demographics`
  + [Number and percentage of households by region, type of housing and useful floor space. Special housing not included. Year 2012 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0111/HushallT27/). Solna and Malmö. Saved as `household-floor-space`
  + [Number and percentage of households by region, type of housing and size of household. Year 2012 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0111/HushallT26/). Solna and Malmö. Saved as `household-size`.
  + [Number of households and average number of persons per household by region, tenure and type of dwelling (excluding one- or two-dwelling buildings). Year 2012 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0111/HushallT30/). Solna and Malmö. Saved as `household-tenancy`
  + [Number and percentage of households by region, type of housing and type of household. Year 2012 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0111/HushallT22/). Solna and Malmö. Saved as `household-type`.
  + [Average useful floor space per person by region, type of household and type of housing. Year 2012 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0111/HushallT23/). Solna and Malmö. Saved as `household-type-floor-space`.
  + 2022-05-11: [Income distribution for households (fractiles) by region. Year 2011 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0110__HE0110G/TabDispH1/). Solna and Malmö. Saved as `household-income-decile-upper-bounds` in expenses folder. Contains disposable income deciles for selected municipalities.
  + 2022-05-11: [Expenditures per household (0-79 years)(HBS) - disposable income and type of expenditure. (Survey) Year 2006 - 2009](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__HE__HE0201__HE0201A/HUTutgift5/). Saved as `household-expenditures-2006` in expenses folder. Contains household expenditure data by disposable income decile for years 2006-2009. HBS stands for Household Budget Survey.

### Dwellings and buildings
  + [Number of dwellings by region, type of building and period of construction. Year 2013 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__BO__BO0104__BO0104D/BO0104T02/). Solna and Malmö. Saved as `building-construction-year`
  + [Number of dwellings by region, type of building and useful floor space. Year 2013 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__BO__BO0104__BO0104D/BO0104T5/). Solna and Malmö. Saved as `building-floor-space`
  + [Number of dwellings by region, type of building and tenure (including special housing). Year 1990 - 2020](https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__BO__BO0104__BO0104D/BO0104T04/). Solna and Malmö. Saved as `building-tenancy`

## Columns in the data
  + `Age ID` (sweden demographics)
    + `0-9`
    + `010-19`
    + `020-29`
    + `030-39`
    + `040-49`
    + `050-59`
    + `060-64`
    + `065-69`
    + `070-79`
    + `080+`
  + `Background` (sweden-demographics)
    + `foreign background`
    + `swedish background`
  + `Building Type ID` (building-construction-year, building-floor-space, building-tenancy)
    + `SMÅHUS` (one- or two-dwelling buildings)
    + `FLERBOST` (multi-dwelling buildings)
    + `ÖVRHUS` (other buildings)
    + `SPEC` (special housing) -- not in building-construction-year or building-floor-space
  + `Construction Year ID` (building-construction-year)
    + `-1930`
    + `1931-1940`
    + `1941-1950`
    + `1951-1960`
    + `1961-1970`
    + `1971-1980`
    + `1981-1990`
    + `1991-2000`
    + `2001-2010`
    + `2011-` (2011-2020)
    + `UPPG. SAKNAS` (data missing)
  + `Dwelling Type ID` (sweden-demographics, household-floor-space, household-size, household-tenancy)
    + `SMAG` (one- or two-dwelling buildings, owner occupied) -- not in household-tenancy
    + `SMBO` (one- or two-dwelling buildings, tenant owned) -- not in household-tenancy
    + `SMHY0` (one- or two-dwelling buildings, rented) -- not in household-tenancy
    + `FBBO` (multi-dwelling buildings, tenant owned)
    + `FBHY0` (multi-dwelling buildings, rented)
    + `SPBO` (special housing)
    + `OB` (other housing)
    + `OVR` (data missing) -- not in sweden-demographics or household-tenancy
    + `TOT` (housing, total) -- not in sweden-demographics
  + `Dwelling Size ID` (household-tenancy)
    + `1R+` (dwellings without kitchen)
    + `1RKV+KS` (1 room and kitchenette)
    + `1RK` (1 room and kitchen)
    + `2RKV+KS` (2 or more rooms with kitchenette)
    + `2RK` (2 rooms and kitchen)
    + `3RK` (3 rooms and kitchen)
    + `4RK` (4 rooms and kitchen)
    + `5RK` (5 rooms and kitchen)
    + `6+RK` (6 or more rooms and kitchen)
    + `UPPGSAKNs` (data missing)
  + `Floor Space ID` (household-floor-space)
    + `45` (-50 sq.m.)
    + `55` (51-80 sq.m.)
    + `85` (81-110 sq.m.)
    + `115` (111-140 sq.m.)
    + `145` (141-170 sq.m.)
    + `175` (171- sq.m.)
    + `US` (data missing)
    + `samtl` (all)
  + `Floor Space ID` (building-floor-space)
    + `30mindre` (< 31 sq.m.)
    + `31` (31-40 sq.m.)
    + `41` (41-50 sq.m.)
    + `51` (51-60 sq.m.)
    + `61` (61-70 sq.m.)
    + `71` (71-80 sq.m.)
    + `81` (81-90 sq.m.)
    + `91` (91-100 sq.m.)
    + `101` (101-110 sq.m.)
    + `111` (111-120 sq.m.)
    + `121` (121-130 sq.m.)
    + `131` (131-140 sq.m.)
    + `141` (141-150 sq.m.)
    + `151` (151-160 sq.m.)
    + `161` (161-170 sq.m.)
    + `171` (171-180 sq.m.)
    + `181` (181-190 sq.m.)
    + `191` (191-200 sq.m.)
    + `200plus` (> 200 sq.m.)
    + `US` (data missing)
  + `Gender ID` (sweden-demographics)
    + `1` (men)
    + `2` (women)
    + `4` (men and women)
  + `Household Size ID` (household-size)
    + `1P` (1 person)
    + `2P` (2 persons)
    + `3P` (3 persons)
    + `4P` (4 persons)
    + `5P` (5 persons)
    + `6P` (6 persons)
    + `7+P` (7 persons or more)
    + `TOTAL` (all households)
  + `Region ID` (household-floor-space, household-size, household-tenancy, building-construction-year, building-floor-space, building-tenancy)
    + `0184` (Solna)
    + `1280` (Malmö)
  + `Tenancy ID` (building-tenancy)
    + `1` (rented dwellings)
    + `2` (tenant-owned dwellings)
    + `3` (owner-occupied dwellings)
    + `ÖVRIGT` (data missing)

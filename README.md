# Hot air or warm water: fishkills in northern temperate lakes

## Progress
I have combined the Minnesota (Phelps et al. 2019) and Wisconsin (Till et al. 2019) fishkill datasets (2003-2014), and added concurrent and future (2041-2059; 2081-2099) air and water temperature estimates. All of these steps are performed in `01_combine_datasets.Rmd`. After running this code, the concurrent and future datasets are named `df_historical` and `df_future`, respectively. This code is based on the Till workflow, except that it includes the Phelps et al. (2019) dataset and concurrent and future air temperature estimates.

We are currently on the fourth markdown file (04_assess_models.Rmd), which compares the various models.  All steps up to this point (#1 to #3) are complete. However, I am getting some errors when trying to combine all of the model outputs in the beginning of this markdown file. I left the code for each of my attempted remedies after the original code from Till et al. (2020). For now, all of the .rds files are in the latest patch release (1.3a, 1.3b, 1.3c). Specifically, the .rds files are in 1.3c, which has the files from "data/models/".

## Concurrent temperature estimates (df_historical)
Concurrent water temperature estimates (Winslow et al. 2017) include surface and bottom temperature estimates and are waterbody-specific throughout the study region. Concurrent air temperature estimates (~8 km resolution) were obtained from PRISM (http://prism.oregonstate.edu). I first tried using air temperature data from NOAA weather stations, but there were too many missing data. The code to acquire and examine the NOAA data are hashed out in `01_combine_datasets.Rmd` for a rainy day. I associated air temperature estimates with the nearest waterbody centroid. Lastly, I added 2010 census data for the area surrounding each waterbody.

## Future temperature estimates (df_future)
Future water temperature estimates (Winslow et al. 2017) are based on several climate models under RCP 8.5 projections. I obtained future air temperature estimates (~8 km resolution) for the entire study region (WI, MN, MI) from the NOAA GFGL CM3 model, one of the models used in Winslow et al. (2017). As above, I associated air temperature estimates with the nearest waterbody centroid. Lastly, I added 2010 census data for the area surrounding each waterbody.

## 01_combine_datasets.Rmd
This combines MN and WI fishkill datasets with thermal estimates. After running this script, the historical (2003-2014) and future (2041-2059; 2081-2099) dataframes are compiled as `df_historical.csv` and `df_future.csv`, respectively. The markdown file is organized into the following steps:

1.  Load packages and data.
2.  Add Minnesota fishkill data
3.  Add Wisconsin fishkill data
4.  Format final fishkill dataset
5.  Preliminary map of fishkills
6.  Add historical water temperature data
7a. Add historical air temperature data (NOAA)
7b. Add historical air temperature data (PRISM)
8.  Add geographic and census data
9.  Add future water temperature data
13. Add future air temperature data
14. Add snowfall data

## 02_prepare_models.Rmd
This code is from the Till et al. (2019) workflow, and creates training and testing sets for modelling. The markdown file is organized into the following steps:

1. Partition data into training and testing sets
2. Scale data in training sets
3. Exports training and testing sets
	a. `models/training.csv`: Training set
	a. `models/testing.csv`: Testing set
	
## 03_fit_models.Rmd
Compares preliminary models from four model families:

1. Logistic regression
2. Ridge regression
3. Lasso regression
4. Logistic regression with random effects

## 04_assess_models.Rmd

Compares preliminary models.

## 05_fit_full_models.Rmd

Runs the best fit models based on assessments.

## 06_statistics.Rmd

Contains statistical tests used in Till et al., (2019). I am holding off on this until we agree on the models used in the above steps.

## Data
All data files are in the following folders:raw, processed, or models. These data are available for download via GitHub or R.
For GitHub, click "Release" in the top menu and then download the latest releases (1.3a, 1.3b, 1.3c).
These are in separate files because there is a 2 GB limit for this method.
It will likely have to be spread out into 3+ compressed files soon.
For R, run the following chunk of code.

```{R: Download data files}
# install.packages("piggyback")
# require(piggyback)
# pb_download(repo = "simontye/2020_MME_Temp",
#             tag  = "1.3a",
#             dest = "data")
# pb_download(repo = "simontye/2020_MME_Temp",
#             tag  = "1.3b",
#             dest = "data")
# pb_download(repo = "simontye/2020_MME_Temp",
#             tag  = "1.3c",
#             dest = "data")
```
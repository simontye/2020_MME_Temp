# Hot air or warm water: fishkills in north temperate lakes

## Progress
I have combined the Minnesota (Phelps et al. 2019) and Wisconsin (Till et al. 2019) fishkill datasets, and added concurrent (2003-2014) and future (2041-2059; 2081-2099) air and water temperature estimates.

Concurrent water temperature estimates (Winslow et al. 2017) include surface and benthic temperature estimates and are waterbody-specific throughout the study region. Concurrent air temperature estimates (~4 km resolution) were obtained from PRISM (http://prism.oregonstate.edu). I first tried using air temperature data from NOAA weather stations, but there were too many missing data. NOAA has minimum, mean, and maximum air tempearture data, whereas PRISM just has mean air temperature data.

Future water temperature estimates are from Winslow et al. (2017), and based on several climate models under RCP 8.5 projections. I obtained future air temperature estimates (~8 km resolution) for the entire study region from the ACCESS 1.3 model, one of the models used in Winslow et al. (2017). After giving each waterbody a specific coordinate, I matched each waterbody with the nearest air tempearture estimate location. Lastly, I added snowfall data from PRISM and 2010 US census data for the area surrounding each waterbody.

All of these steps are performed in `01_combine_datasets.Rmd`. After running this code, the concurrent and future datasets are named `df_historical` and `df_future`, respectively. I need to add cold-, cool-, and warm-water classification for the affected taxa and tidy this code, otherwise it should be ready for modelling.

## Files
1. `01_combine_datasets.Rmd`: Combines MN and WI fishkill datasets with air (~4 km resolution) and water (waterbody-specific) temperature estimates.
2. `02_prepare_models.Rmd`: Partitions and scales the combined dataset.
3. `03_fit_models.Rmd`: In progress

## 01_combine_datasets.Rmd
This code combines MN fishkill, WI fishkill, water temperature, and air temperature data. After running this script, the historical (2003-2014) and future (2041-2059; 2081-2099) dataframes are compiled as df.historical and df.future, respectively.

1. Load packages and data.
2. Organize MN fishkill data from Phelps et al. (2019).
3. Organize WI fishkill data from Till et al. (2019).
4. Merge fishkill datasets.
5. Group fish taxa by family.
6. Create a preliminary map to visual verify fishkill localities.
7. Simplify combined fishkill dataset.
8. Add historical water temperature data from Winslow et al. (2017).
9. Add historical air temperature data from PRISM.
10. Merge fiskill and thermal datasets.
11. Add spatial and census data.
12. Add future water temperature data from Winslow et al. (2017).
13. Add future air temperature data from ACCESS 1.3 model, then save processed files.
	a. `processed/model_historical.csv`
	b. `processed/model_future.csv`
14. Add snowfall data.

## 02_prepare_models.Rmd
This code is from the Till et al. (2019) workflow, and creates training and testing sets for modelling.

1. Partition data into training and testing sets.
2. Scale data in training sets.
3. Exports training and testing sets.
	a. `models/training.csv`: Training set
	a. `models/testing.csv`: Testing set
	
## 03_fit_models.Rmd
In progress

## Data
All data files are categorized as either raw, processed, or model. These data are available for download via GitHub or R.
For GitHub, click "Release" in the top menu and then download "data_1.0.zip".
For R, run the following chunk of code.

```{R: Download data files}
# install.packages("piggyback")
# require(piggyback)
# pb_download(repo = "simontye/2020_MME_Temp" 
#             tag  = "1.0",
#             dest = "data")
```
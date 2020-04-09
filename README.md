# Hot air or warm water: fishkills in north temperate lakes

### Authors
Mass mortality crew

### Workflow
The code to replicate this study are located in the following R Markdown files.

1. `01_combine_datasets.Rmd`: Combines MN and WI fishkill datasets with air and water temperature data.
2. `02_prepare_models.Rmd`: Partitions and scales the combined dataset.
3. `03_fit_models.Rmd`: In progress

### Data
All data files are categorized as either raw, processed, or model. These data are available for download via GitHub or R.
To download from GitHub, do this. To download in R, do that.

```{R: Download data files}
# install.packages("piggyback")
# require(piggyback)
# pb_download(repo = "simontye/2020_MME_Temp" 
#            tag  = "v0.0.1",
#            dest = "data")
```
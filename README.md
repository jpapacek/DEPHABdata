# DEP HAB data READ ME
This repository automatically imports Harmful Algal Bloom sample results from the Florida Department of Environmental Protection [Algal Bloom Site Visits](https://geodata.dep.state.fl.us/datasets/FDEP::florida-algal-bloom-site-visits-1/about) data table into csv file on a daily basis.

Main components:
- R script to import, organize, and export data [link](/R/DEP_HAB_script_git.R)
- workflow to automate R script [link](.github/workflows/automate_cript_using_renv.yml)
- output csv files [link](/data/)

Thanks to Paul Julian [@SwampThingPaul](https://github.com/SwampThingPaul) for assistance with writing the geojson query.

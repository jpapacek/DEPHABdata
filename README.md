# DEP HAB data READ ME
This repository automatically imports Harmful Algal Bloom sample results from the Florida Department of Environmental Protection [Algal Bloom Site Visits](https://geodata.dep.state.fl.us/datasets/FDEP::florida-algal-bloom-site-visits-1/about) data table into csv file on a daily basis. Note that the query is only for samples from certain Florida counties (Alachua, Baker, Brevard, Clay, Duval, Flager, Indian River, Lake, Marion, Nassau, Orange, Osceola, Putnam, Seminole, St. Johns, Volusia).

Main components:
- R script to import, organize, and export data [link](/R/DEP_HAB_script_git.R)
- workflow to automate R script [link](.github/workflows/automate_script_using_renv.yml)
- output csv file(s) [link](/data/) updated daily

A csv file for DEP HAB data for the same counties sampled from 2019-2021 is also available.

Thanks to Paul Julian [@SwampThingPaul](https://github.com/SwampThingPaul) for assistance with writing the geojson query.

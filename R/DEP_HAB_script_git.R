library(reshape)
library(plyr)
library(dplyr)
library(tidyr)
library(zoo)
library(lubridate)
library(jsonlite)
#library(geojsonsf)
library(httr)
library(stringr)
#library(renv)
system(sudo apt-get install libcurl4-openssl-dev)

### Grab HAB Sampling Results from FDEP Dashboard
####OLDER DATA####
#Set path and request JSON
# DEP_path <- 'https://services1.arcgis.com/nRHtyn3uE1kyzoYc/arcgis/rest/services/VIEW_FL_Algal_Bloom_Site_Visits_1/FeatureServer/0/query?'
# DEP_request <- GET(
#   url = DEP_path,
#   query= list(       
#     where = "County='Brevard' OR County='Clay' OR County='Duval' OR County='Flagler' 
#     OR County='IndianRiver'",
#     outFields = '*',
#     f = 'pjson'
#   )
# )
# 
# #Reformat to table
# DEP_response <- content(DEP_request, 
#                         as = "text", 
#                         encoding = "UTF-8")
# DEP_results <- jsonlite::fromJSON(DEP_response,flatten=T)
# # nrow(results$features)
# DEP_bgdat=DEP_results$features
# 
# #Second request to get additional counties within District (query is limited to 1000 instances)
# request <- GET(
#   url = DEP_path,
#   query= list(       
#     where = "County='StJohns' OR County='Volusia' OR County='Nassau' OR County='Putnam' OR County='Seminole'",
#     outFields = '*',
#     f = 'pjson'
#   )
# )
# response <- content(request, as = "text", encoding = "UTF-8")
# results <- jsonlite::fromJSON(response,flatten=T)
# # nrow(results$features)
# 
# #Bind results together
# DEP_bgdat=rbind(DEP_bgdat, results$features)
# 
# 
# #Third request to get additional counties within District (query is limited to 1000 instances)
# request <- GET(
#   url = DEP_path,
#   query= list(       
#     where = "County='Lake' OR County='Marion' OR County='Orange' OR County='Osceola' OR County='Alachua'",
#     outFields = '*',
#     f = 'pjson'
#   )
# )
# response <- content(request, as = "text", encoding = "UTF-8")
# results <- jsonlite::fromJSON(response,flatten=T)
# # nrow(results$features)
# 
# #Bind results together
# DEP_bgdat=rbind(DEP_bgdat, results$features)
# 
# #Rename Columns
# vars=c("attributes.objectid", "attributes.globalid", "attributes.SiteVisitDate", 
#        "attributes.Location", "attributes.County", "attributes.Visitor", 
#        "attributes.AlgaeObserved", "attributes.SampleTaken", "attributes.DepthDesc", 
#        "attributes.SampleDepth", "attributes.AnalyzedBy", "attributes.Otherlab", 
#        "attributes.Comments", "attributes.Latitude", "attributes.Longitude", 
#        "attributes.AlgalID", "attributes.Microcystin", "attributes.OtherToxin", 
#        "attributes.EditDate", "attributes.PicURL", "attributes.ToxinPresent", 
#        "attributes.CyanobacteriaDominant", "geometry.x", "geometry.y"
# )
# vars=strsplit(vars,"\\.")
# vars=sapply(vars,"[",2)
# DEP_bgdat=as.data.frame(DEP_bgdat)
# colnames(DEP_bgdat)<-tolower(vars)

####NEWER DATA####
###IMPORTANT: The path for 2022 samples changed sometime in June; needs to be called again, bound to previous samples and cleaned up!
path <- 'https://services1.arcgis.com/nRHtyn3uE1kyzoYc/arcgis/rest/services/AlgalBloom_Final_View/FeatureServer/0/query?'

request <- GET(
  url = path,
  query= list(       
    where = "County='Brevard' OR County='Clay' OR County='Duval' OR County='Flagler' 
    OR County='IndianRiver'",
    outFields = '*',
    f = 'pjson'
  )
)
response <- content(request, as = "text", encoding = "UTF-8")
results <- jsonlite::fromJSON(response,flatten=T)

#Column names are different, so needs to be updated
DEP_bgdat_new=results$features

#2022 data second query
path <- 'https://services1.arcgis.com/nRHtyn3uE1kyzoYc/arcgis/rest/services/AlgalBloom_Final_View/FeatureServer/0/query?'

request <- GET(
  url = path,
  query= list(       
    where = "County='StJohns' OR County='Volusia' OR County='Nassau' OR County='Putnam' OR County='Seminole'",
    outFields = '*',
    f = 'pjson'
  )
)
response <- content(request, as = "text", encoding = "UTF-8")
results <- jsonlite::fromJSON(response,flatten=T)

#Bind new 
DEP_bgdat_new=rbind(DEP_bgdat_new, results$features)

#2022 data third
path <- 'https://services1.arcgis.com/nRHtyn3uE1kyzoYc/arcgis/rest/services/AlgalBloom_Final_View/FeatureServer/0/query?'

request <- GET(
  url = path,
  query= list(       
    where = "County='Lake' OR County='Marion' OR County='Orange' OR County='Osceola' OR County='Alachua'",
    outFields = '*',
    f = 'pjson'
  )
)
response <- content(request, as = "text", encoding = "UTF-8")
results <- jsonlite::fromJSON(response,flatten=T)

#Bind new 
DEP_bgdat_new=rbind(DEP_bgdat_new, results$features)


#Rename Columns
vars_new=c("attributes.objectid", "attributes.globalid", "attributes.SampleDateTime", "attributes.MonitoringGroupPublicFacing",
           "attributes.County", "attributes.esrignss_latitude", "attributes.esrignss_longitude","attributes.BloomObserved", "attributes.Comments",
           "attributes.MeterReadingsOnly", "attributes.SampleDepthDesc", "attributes.AnalyzedBy","attributes.Otherlab", "attributes.SampleDepth",
           "attributes.AlgalIDResult","attributes.ToxinPresent","attributes.Microcystin","attributes.OtherToxin",
           "attributes.locationString",  "attributes.EditDate","attributes.PicURL",   "attributes.CyanobacteriaDominant", "geometry.x", "geometry.y"
)
vars_new=strsplit(vars_new,"\\.")
vars_new=sapply(vars_new,"[",2)
DEP_bgdat_new=as.data.frame(DEP_bgdat_new)
colnames(DEP_bgdat_new)<-tolower(vars_new)

#Rename columns to match "older" dataset
DEP_bgdat_new=DEP_bgdat_new%>%
  dplyr::rename(sitevisitdate=sampledatetime,
                visitor=monitoringgrouppublicfacing,
                latitude=esrignss_latitude,
                longitude=esrignss_longitude,
                algaeobserved=bloomobserved,
                sampletaken=meterreadingsonly,
                depthdesc=sampledepthdesc,
                algalid=algalidresult,
                location=locationstring)

#Join datasets
#Need to replace Pending values with NAs to help with merge
#DEP_bgdat=DEP_bgdat[!(DEP_bgdat$algalid=="Pending"),]

#DEP_bgdat=rbind(DEP_bgdat,DEP_bgdat_new)

#For some reason some "Toxin present" columns show pending when they are ND
DEP_bgdat=DEP_bgdat_new%>% #THIS IS A WORK AROUND TO ONLY USE 2022-present DATA AS DEP DF FOR 2020-2021 IS INACCESSIBLE
  mutate(toxinpresent=case_when(toxinpresent=="Pending"&microcystin=="not detected"&
                                  othertoxin=="Anatoxin-a: not detected; Cylindrospermopsin: not detected; Nodularin-R: not detected; Saxitoxins: not detected"~"No",
                                TRUE~toxinpresent))

#Add fixed date columns
#Manually divide by 1000 instead of removing '000'; for some reason doesn't work on all rows
DEP_bgdat$sitevisitdate1=DEP_bgdat$sitevisitdate
DEP_bgdat$sitevisitdate1=as.numeric(gsub('000$', '',format(DEP_bgdat$sitevisitdate1,scientific=F)))
DEP_bgdat$sitevisitdate2=as.numeric(DEP_bgdat$sitevisitdate/1000)
DEP_bgdat$sitevisitdate_diff=as.numeric(DEP_bgdat$sitevisitdate1/DEP_bgdat$sitevisitdate2)
DEP_bgdat$datetime=as.POSIXct(DEP_bgdat$sitevisitdate2,origin = c('1970-01-01'), tz = 'UTC')
# DEP_bgdat$datetime=date.fun(DEP_bgdat$datetime,form="%F %R")
# DEP_bgdat$date=date.fun(DEP_bgdat$datetime)
DEP_bgdat$date <- as.Date(round_date(ymd_hms(DEP_bgdat$datetime),'day')-1) #For some reason this is adding a day
DEP_bgdat$dateC <- as.character(as.Date(round_date(ymd_hms(DEP_bgdat$datetime),'day'))-1)

####CLEAN UP####
#Filter to only samples taken at time of visit (otherwise there's no point in showing the taxa/toxin data)
DEP_bgdat=DEP_bgdat%>%
  filter(sampletaken=="Yes")#%>% Lori wants to see all samples, not just SJRWMD
# filter(visitor=="SJRWMD")


#Add routine vs response
#All response before May 2020 (this dataset only goes to 2019 anyways)
#Routine sites: MP72, DTL, 20030157, CRESLM, LEO, LMAC, OW-CTR, LWC, STKM, BCL
#OW-2 was routine site on Jesup until sometime in 2021
DEP_bgdat=DEP_bgdat%>%
  mutate(visittype=case_when(date>="2020-05-01"&grepl('(MP72)|(DTL)|(20030157)|(CRESLM)|(LEO)|(LMAC)|(OW-CTR)|(OW-2)|(LWC)|(STKM)|(BCL)|(SNKLCA)',location)~"Routine",
                             TRUE~"Response"))

#Filter routine vs. response
#DEP_routine=DEP_bgdat%>%
#filter(visittype=="Routine")
#DEP_response=DEP_bgdat%>%
#filter(visittype=="Response")

# #Add station ID to match with WQ data
# #DEP_routine=DEP_routine%>%
#  # mutate(station=case_when(grepl('(MP72)',location)~"MP72",
#                            grepl('(DTL)',location)~"DTL",
#                            grepl('(20030157)',location)~"20030157",
#                            grepl('(CRESLM)',location)~"CRESLM",
#                            grepl('(LEO)',location)~"LEO",
#                            grepl('(LMAC)',location)~"LMAC",
#                            grepl('(OW-CTR)',location)~"OW-CTR",
#                            grepl('(OW-2)',location)~"OW-2",
#                            grepl('(LWC)',location)~"LWC",
#                            grepl('(STKM)',location)~"STKM",
#                            grepl('(BCL)',location)~"BCL"))

#####Isolate toxin data alone in columns####
#####Microcystin####
#Need to account for Pending & Nondetects
#This creates logical column for detected or not
DEP_bgdat$mcdetect=case_when(DEP_bgdat$microcystin=="not detected"~0,
                             DEP_bgdat$microcystin=="Pending"|DEP_bgdat$microcystin=="not collected"~NA_real_,
                             TRUE~1)
#A sample from Georges Lake has a comma in the MC column (i.e. '9,000') which is currently a character; need to replace
DEP_bgdat$microcystin1=gsub(",","",DEP_bgdat$microcystin)


#This replaces space with | to ease separation
DEP_bgdat=DEP_bgdat%>%
  mutate(microcystin1 = str_replace(microcystin1, "\\s", "|")) %>%
  separate(microcystin1,into = c("mcvalue","mcqualifier"),sep ="\\|")
#Replace ND/NC strings with NAs
DEP_bgdat$mcvalue=case_when(DEP_bgdat$mcvalue=="not"|DEP_bgdat$mcvalue=="Pending"~NA_character_,
                            TRUE~DEP_bgdat$mcvalue)
DEP_bgdat$mcqualifier=case_when(DEP_bgdat$mcqualifier=="detected"|DEP_bgdat$mcqualifier=="collected"~NA_character_,
                                TRUE~DEP_bgdat$mcqualifier)

#####Attempt with othertoxins column (use test dataframe first)####
DEP_bgdat_test=DEP_bgdat%>%
  separate(othertoxin,sep="\\:",into = c("tox1","tox2","tox3","tox4","tox5"))%>%
  separate(tox2,sep="\\;",into = c("ana","tox2"))
####Anatoxin####
#All anatoxin-a are NDs, just going to convert that to NAs for now 
#(IMPORTANT: need to redo if any anatoxins are detected in the future! Some values may come w/ qualifiers)
DEP_bgdat_test=DEP_bgdat_test%>%
  mutate(ana=trimws(DEP_bgdat_test$ana,which="left"))%>% #trims leading space
  mutate(ana = str_replace(ana, "\\s", "|"))%>%
  separate(ana,into = c("anavalue","anaqualifier"),sep ="\\|")

#If not detected, qualifier column shows that
DEP_bgdat_test$anadetect=case_when(DEP_bgdat_test$anaqualifier=="detected"~0,
                                   DEP_bgdat_test$anavalue!="not"~1,
                                   TRUE~NA_real_)

#Change Ana values and qualifiers to NAs like Mcy
DEP_bgdat_test$anavalue=case_when(DEP_bgdat_test$anavalue=="not"|DEP_bgdat_test$anavalue=="Pending"~NA_character_,
                                  TRUE~DEP_bgdat_test$anavalue)
DEP_bgdat_test$anaqualifier=case_when(DEP_bgdat_test$anaqualifier=="detected"|DEP_bgdat_test$anaqualifier=="collected"~NA_character_,
                                      TRUE~DEP_bgdat_test$anaqualifier)
####Cylindrospermopsin####
#Separate cyl data
DEP_bgdat_test=DEP_bgdat_test%>%
  separate(tox3,sep="\\;",into = c("cyl","tox3"))
DEP_bgdat_test$cyl=trimws(DEP_bgdat_test$cyl,which="left") #trims leading space
#Cyl now has value with qualifiers; need to separate again
DEP_bgdat_test=DEP_bgdat_test%>%
  mutate(cyl = str_replace(cyl, "\\s", "|"))%>%
  separate(cyl,into = c("cylvalue","cylqualifier"),sep ="\\|")
#If not detected, qualifier column shows that
DEP_bgdat_test$cyldetect=case_when(DEP_bgdat_test$cylqualifier=="detected"~0,
                                   DEP_bgdat_test$cylvalue!="not"~1,
                                   TRUE~NA_real_)

#Change Cyl values and qualifiers to NAs like Mcy
DEP_bgdat_test$cylvalue=case_when(DEP_bgdat_test$cylvalue=="not"|DEP_bgdat_test$cylvalue=="Pending"~NA_character_,
                                  TRUE~DEP_bgdat_test$cylvalue)
DEP_bgdat_test$cylqualifier=case_when(DEP_bgdat_test$cylqualifier=="detected"|DEP_bgdat_test$cylqualifier=="collected"~NA_character_,
                                      TRUE~DEP_bgdat_test$cylqualifier)

####Saxitoxin & Nodularin####
#Saxitoxins & Nodularins are annoyingly sometimes in the same columns depending on how many analyses were done on the sample
DEP_bgdat_test=DEP_bgdat_test%>%
  separate(tox4,sep="\\;",into = c("tox3value","tox4"))
DEP_bgdat_test$tox3value=trimws(DEP_bgdat_test$tox3value,which="left")
DEP_bgdat_test$tox3=trimws(DEP_bgdat_test$tox3,which="left")#trims leading space
#Create new combined Sax column
DEP_bgdat_test$sax=case_when(DEP_bgdat_test$tox3=="Saxitoxin"|DEP_bgdat_test$tox3=="Saxitoxins"~DEP_bgdat_test$tox3value,
                             TRUE~DEP_bgdat_test$tox5) #basically telling it to grab the values in tox3value column *if* that row uses tox3 for saxitoxins, if not then grab values from tox5 column
#sax now has value with qualifiers; need to separate again
DEP_bgdat_test$sax=trimws(DEP_bgdat_test$sax,which="left")#trims leading space
DEP_bgdat_test=DEP_bgdat_test%>%
  mutate(sax = str_replace(sax, "\\s", "|"))%>%
  separate(sax,into = c("saxvalue","saxqualifier"),sep ="\\|")
#If not detected, qualifier column shows that
DEP_bgdat_test$saxdetect=case_when(DEP_bgdat_test$saxqualifier=="detected"~0,
                                   DEP_bgdat_test$saxvalue!="not"~1,
                                   TRUE~NA_real_)

#Change sax values and qualifiers to NAs like Mcy & Cyl
DEP_bgdat_test$saxvalue=case_when(DEP_bgdat_test$saxvalue=="not"|DEP_bgdat_test$saxvalue=="Pending"~NA_character_,
                                  TRUE~DEP_bgdat_test$saxvalue)
DEP_bgdat_test$saxqualifier=case_when(DEP_bgdat_test$saxqualifier=="detected"|DEP_bgdat_test$saxqualifier=="collected"~NA_character_,
                                      TRUE~DEP_bgdat_test$saxqualifier)

#Create new Nod column without sax data
DEP_bgdat_test$nod=case_when(DEP_bgdat_test$tox3=="Nodularin"|DEP_bgdat_test$tox3=="Nodularin-R"~DEP_bgdat_test$tox3value,
                             TRUE~NA_character_) #basically telling it to grab the values in tox3value column *if* that row uses tox3 for Nodularin, if not then it is NA as it wasn't analyzed
#Nod now has value with qualifiers; need to separate again (note they are all NDs)
DEP_bgdat_test$nod=trimws(DEP_bgdat_test$nod,which="left")#trims leading space
DEP_bgdat_test=DEP_bgdat_test%>%
  mutate(nod = str_replace(nod, "\\s", "|"))%>%
  separate(nod,into = c("nodvalue","nodqualifier"),sep ="\\|")
DEP_bgdat_test$noddetect=case_when(DEP_bgdat_test$nodqualifier=="detected"~0,
                                   DEP_bgdat_test$nodvalue!="not"~1,
                                   TRUE~NA_real_)
#Change nod values and qualifiers to NAs like Mc & Cyl &sax
DEP_bgdat_test$nodvalue=case_when(DEP_bgdat_test$nodvalue=="not"|DEP_bgdat_test$nodvalue=="Pending"~NA_character_,
                                  TRUE~DEP_bgdat_test$nodvalue)
DEP_bgdat_test$nodqualifier=case_when(DEP_bgdat_test$nodqualifier=="detected"|DEP_bgdat_test$nodqualifier=="collected"~NA_character_,
                                      TRUE~DEP_bgdat_test$nodqualifier)
#Add other toxin data back in
DEP_bgdat_test$othertoxins=DEP_bgdat$othertoxin

#Cleanup data
DEP_bgdat_clean=DEP_bgdat_test%>%
  select(location,county,date,visitor,algaeobserved,algalid,cyanobacteriadominant,toxinpresent,
         mcvalue,mcqualifier,cylvalue,cylqualifier,anavalue,anaqualifier,saxvalue,saxqualifier,nodvalue,nodqualifier,othertoxins,comments,
         datetime,latitude,longitude,sampledepth,picurl)%>%
  mutate(mcvalue=as.numeric(mcvalue),
         cylvalue=as.numeric(cylvalue),
         anavalue=as.numeric(anavalue),
         saxvalue=as.numeric(saxvalue),
         nodvalue=as.numeric(nodvalue))%>%
  arrange(desc(datetime))

#NOTE: Filter duplicates (some 2022 have two entries with slightly different URLs)

DEP_bgdat_unique=DEP_bgdat_clean%>%
  distinct(location,visitor,datetime,.keep_all = TRUE)


write.csv(DEP_bgdat_unique,file = paste0("data/daily/DEP_HAB_data_", make.names(Sys.time()), ".csv"),na="",row.names = FALSE)
write.csv(DEP_bgdat_unique,file = "data/DEP_HAB_data_2022_present.csv",na="",row.names = FALSE)


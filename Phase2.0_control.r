## Phase2.0 - Prediction of phenological phases in Germany
#
#
#   Copyright (C) <2013>  <Markus Möller> <markus.moeller@geo.uni-halle.de>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>
#
##########################################################################################################################
## Setup and parameter definition 
##########################################################################################################################


##Include Packages
library(gdata)         # various R programming tools for data manipulation, in particular for xls-file import (works also in 64-bit environment)
library(shapefiles)    # functions to read and write ESRI shapefiles.
library(randomForest)  # classification and regression based on a Breiman and Cutler's random  forest of trees using random input
library(rgdal)         # provides bindings to Frank Warmerdam's Geospatial Data Abstraction Library (GDAL) (>= 1.3.1) and access to projection/transformation operations from the PROJ.4 library. 
library(maptools)      # set of tools for manipulating and reading geographic data, in particular ESRI shapefiles
library(RColorBrewer)  # palettes for drawing nice maps shaded according to a variable
library(classInt)      # a package for choosing univariate class intervals for mapping or other graphics purposes

##Initial working directory
initial.dir <- "c:/Users/markus.moeller/Dropbox/_phase2.0/Phase_2.0_download_version/_model"             # Insert path here

##Setting of directories and file locations
#Input
set1 <- "_input/_temperature"                     # working directory for daily temperatures' folder
set2 <- "_input/_shape/station_t25832.dbf"        # file name for temperatures' station data set
set3 <- "_input/doy2010.csv"                      # look-up table for 'doy-date' transformation
set4 <- "_input/_shape/srtm25832.dbf"             # filename for object data set (dbf)
set6 <- "_input/_phenology"                       # working directory for phenological observations' folder
set7 <- "_input/_shape/station_p25832"            # file name for phenological station data set
set9 <- "_input/_shape/srtm25832.shp"             # filename for object data set (shp)

#Output
set5 <- "_output/_rf"                             # working directory for predictions' explaining variances
set8 <- "_output/_doy"                            # file name for phenological station data set


##Start calculations
#Setting of PLANT-ID and PHASE-ID
system.time(source(file.path(initial.dir,"Phase2.0_model1.r")))

PLANT <- 202 #PLANT-ID (here: Winter wheat)
PHASE  <-  15 # PHASE-ID; (here: Beginning of Shooting)
system.time(source(file.path(initial.dir,"Phase2.0_model2.r")))
system.time(source(file.path(initial.dir,"Phase2.0_model3.r")))
system.time(source(file.path(initial.dir,"Phase2.0_accuracy.r")))
system.time(source(file.path(initial.dir,"Phase2.0_mapping.r")))
        

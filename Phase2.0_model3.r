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
##MODEL 3: Final Prediction
##########################################################################################################################

##Prediction of phase-specific heat units
set.seed(100)
rf.sum <- randomForest(pHU ~ .,data=var.p.pHU, proximity = TRUE,importance=TRUE,ntree=500)

## writing final phase-specific heat units to RandomForest result text file
sink(file.path(initial.dir,set5,paste('rf2sum',PLANT,'-',PHASE,c(".txt"),sep="")))
print(rf.sum)
sink()

## Actual prediction of heat sums
rf.sum.pred <- predict(rf.sum, var.dem)
var.dem$pHU <-  rf.sum.pred
set.seed(100)


## Prediction of phase-specific doy 
rf.jultag <- randomForest(JULTAG ~ pHU,   data=var.p, proximity = TRUE)

## Writing results to output file
sink(file.path(initial.dir,set5,paste('rf2jultag',PLANT,'-',PHASE,c(".txt"),sep="")))
print(rf.jultag)
sink()

## Actual prediction of Julian Date
rf.jultag.pred <- predict(rf.jultag, var.dem)
var.dem$pDOY <-  rf.jultag.pred
names(var.dem)


##Read SRTM opject shapefile to data frame
phase <- readShapePoly(file.path(initial.dir,set9), proj4string=CRS("+init=epsg:25832"), force_ring=T)

## Write output DOY shapefile
writePolyShape(phase,file.path(initial.dir,set8,paste('doy',PLANT,'-',PHASE,c(".shp"),sep="")))


##Export of DOY prediction result as DBF (attached to shapefile)
dbf.dem$dbf <- var.dem[c(match(paste('ID_DEM',sep=""),names(var.dem)),length(var.dem))]
write.dbf(dbf.dem, file.path(initial.dir,set8,paste('doy',PLANT,'-',PHASE,c(".dbf"),sep="")), T)

##########################################################################################################################
##End Model 3
##########################################################################################################################

##Phase2.0 - Prediction of phenological phases in Germany
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
##

##########################################################################################################################
##MODEL 1
##########################################################################################################################
##Import of segmented SRTM object data set (var.dem)
dbf.dem <- read.dbf(file.path(initial.dir,set4))
var.dem <- dbf.dem$dbf

##Import and merging of daily temperatures (var.t)
setwd(file.path(initial.dir,set1))      # directory of temperature data sets
list.t1 <- list.files(pattern=".dat$")  # Initialization of temperature list
var.t <- data.frame(list.t1=NULL,V1=NULL, V2=NULL , V3=NULL, V4=NULL, V5=NULL) 

for(i in seq(along=list.t1)) {#Loop for temperature value assignment
                x <- read.fwf(list.t1[i], width=c(1,4,4,4,6))
                x <- data.frame(file=rep(list.t1[i], length(x[,1])), x)
                var.t <- rbind(var.t,x)
                               }
var.t$V1 <- NULL
colnames(var.t) <- c("file","STATION","Y","D","T")

##Deleting of missing values (here: t=-999)
var.t <- var.t[which(var.t$T > -999),]

##Import of weather stations' shape file (shp.ts) and  joining with imported temperatures (var.t) and a look-up table 'doy-date' (lut.doy)
dbf.t <- read.dbf(file.path(initial.dir,set2))
shp.ts <- dbf.t$dbf
var.t <- merge(var.t,shp.ts, by="STATION")
lut.doy <- read.table(file.path(initial.dir,set3), header=TRUE, sep=";", na.strings="NA", dec=",", strip.white=TRUE)

##Joining of temperature stations' data set dates with 'lut.doy'
var.t <- merge(var.t,lut.doy, by="D")
var.t <- var.t[which(var.t$ID_DEM != "NA"),]
var.t <- merge(var.t,var.dem, by="ID_DEM")

##Splitting of var.t according to DOY
list.t2 <- split(var.t,var.t$DOY)

##Prediction of daily temperatures and appending on SRTM object data set
setwd(file.path(initial.dir,set5))
set.seed(100)
v.t <- data.frame(pHU=NULL)

for(i in seq(along=list.t2)){   #Loop for temperature prediction using Random Forest algorithm (Breiman 2001)
                rf.t <- randomForest(T ~ DEM,   data=list.t2[[i]], proximity = TRUE)
                var.dem[[paste('T',i,sep="")]] <-   predict(rf.t, var.dem)
                rsq.t <- rf.t$rsq
                rsq.t <- rsq.t[length(rsq.t)]
                v.t <- rbind(v.t,rsq.t)
                 }
colnames(v.t) <- c("rsq.t")

## Writing output table for temperature prediction results
sink(file.path(initial.dir,set5,paste('rf_t',c(".txt"),sep="")))
print(v.t)
sink()                
var.temp <- var.dem

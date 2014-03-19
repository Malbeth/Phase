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
##MODEL 2: Optimal starting doy determination and prediction of heat sums
##########################################################################################################################


## Combining SRTM objects and temperature records
var.dem <- var.temp
names(var.dem) 

## Import and merging of phenological observations (var.p)
setwd(file.path(initial.dir,set6))
list.p1 <- list.files(pattern=".xls$")
var.p <-  data.frame(V1=NULL,V2=NULL,V3=NULL,V4=NULL,V5=NULL,V6=NULL)

for(i in seq(along=list.p1)){                                   # loop for import of MS EXCEL file format
  
  #read xls-files
  x <- read.xls(list.p1[i],perl="c:/strawberry/perl/bin/perl")  # Path to Perl distribution if already installed, otherwise download from http://strawberryperl.com
  x <- x[c(1,2,4,5,7,11)] 
  var.p <- rbind(var.p,x) 
  }

## Exclude non-valid observations
var.p <- var.p[which(var.p$STATIONS_ID != "NA"),]

## Select observations of PLANT
var.p <- var.p[which(var.p$PH_OBJEKT_ID == PLANT),]


## Boxplot of observed PLANT-specific phases
pdf(file.path(initial.dir,set8,paste('boxplot',PLANT,c(".pdf"),sep="")))  #Plotting box plots
boxplot(JULTAG ~ PHASE_ID, data=var.p,main=paste(PLANT, 'boxplot'),ylim=c(range((var.p$JULTAG))),xlab="PHASE",ylab="DOY")
dev.off()
var.p <- var.p[which(var.p$PHASE_ID == PHASE),]
nrow(var.p)


## Import of phenological stations (shp.p) and coupling of  var.p and shp.p
shp.p <- readShapePoints(file.path(initial.dir,set7),proj4string=CRS("+init=epsg:25832")) # Set spatial reference code
shp.p$STATIONS_ID <- shp.p$STATION_ID
var.p <- merge(shp.p,var.p, by="STATIONS_ID")
var.p <- var.p[which(var.p$STATIONSKENNUNG != "NA"),]


## Selection of phase-specific observed minimal and maximal DOY
min.ph <- min(var.p$JULTAG)
max.ph <- max(var.p$JULTAG)
var.dem <- var.dem[c(match(paste('DEM',sep=""),names(var.dem)),match(paste('ID_DEM',sep=""),names(var.dem)),(match(paste('T',1,sep=""),names(var.dem)):match(paste('T',max.ph,sep=""),names(var.dem))))]
var.dem[var.dem<5] <- 0
head(var.dem)


## Calculation of unspecific heat sums
for(i in seq(from=1, to=(max.ph), by=1)){#Loop
var.dem[[paste('uHU',i,sep="")]] <- rowSums(var.dem[match(paste('T',1,sep=""),names(var.dem)):match(paste('T',i,sep=""),names(var.dem))])
}


##Coupling of phase-specific stations with segmented SRTM object data set (var.p)
var.p <- merge(var.p,var.dem, by="ID_DEM")


##Generating unique ID (Id1) and splitting of data set according to Id1 (list.p2)
var.p$ID1 <- seq(along=var.p$STATIONS_ID, from=1, by=1)
list.p2 <- split(var.p,var.p$ID1)


##########################################################################################################################
##Begin optimization 
##########################################################################################################################


##Conditional summation of heat sums with dynamic determination of the optimal starting DOY
v.s <- data.frame(pHU=NULL)
v.j <- data.frame(pHU=NULL)

for(i in seq(from=1, to=(max.ph), by=1)){#Loop1: data frame of phase-specific heat units per StartDOY/MaxDOY combination
    pHU <- data.frame(pHU=NULL)
	
  for(j in seq(along=list.p2)){#Loop2: Summation of all possible StartDOY/MaxDOY combinations
      
    x1 <- list.p2[[j]]
      if(i<=x1$JULTAG){
        x2 <-  rowSums(x1[match(paste('T',i,sep=""),names(x1)):match(paste('T',x1$JULTAG,sep=""),names(x1))])
      }
      else{
        x2 <- x1[[match(paste('T',x1$JULTAG,sep=""),names(x1))]]
      }
      pHU <- rbind(pHU,x2)
    }#End loop2
  
    colnames(pHU) <- c("pHU")
    
    # Interim prediction of phase-specific heat units and JULTAG to determine highest explaining variance
    var.p$pHU <- pHU$pHU
    var.p.pHU <- var.p[c(match(paste('pHU',sep=""),names(var.p)),(match(paste('uHU',i,sep=""),names(var.p)):match(paste('uHU',max.ph,sep=""),names(var.p))))]#Data set with phase-specific heat sums
    
    set.seed(100)
    rf.sum <- randomForest(pHU ~ .,data=var.p.pHU, proximity = TRUE,importance=TRUE,ntree=500) #Random forest model for heat sum prediction
    var.dem$pHU <- predict(rf.sum, var.dem)
    
    set.seed(100)
    rf.jultag <- randomForest(JULTAG ~ pHU,   data=var.p, proximity = TRUE)
    var.dem$pDOY <- predict(rf.jultag, var.dem)
    
    
    ##Calculation of internal accuracy metrics of interim predictions
    
    #Explaining variance (Heat sum prediction)
    rsq.s <- rf.sum$rsq
    rsq.s <- rsq.s[length(rsq.s)]
    v.s <- rbind(v.s,rsq.s)
    
    #Explaining variance (JULTAG prediction)
    rsq.j <- rf.jultag$rsq
    rsq.j <- rsq.j[length(rsq.j)]
    v.j <- rbind(v.j,rsq.j)
    }#End loop1

#Writing explaining variances of all StartDOY/MaxDOY Combinations
colnames(v.s) <- c("rsq.s")
sink(file.path(initial.dir,set5,paste('rf1sum',PLANT,'-',PHASE,c(".txt"),sep="")))
print(v.s)
sink()

colnames(v.j) <- c("rsq.j")
sink(file.path(initial.dir,set5,paste('rf1jultag',PLANT,'-',PHASE,c(".txt"),sep="")))
print(v.j)
sink()

##Determination of starting DOY by selecting DOY with highest variance explained
v <- v.s
v$rsq.j <- v.j$rsq.j
v[v<0] <- 0
v$rsq <- v$rsq.j * v$rsq.s
start.ph <- match(max(v$rsq), v$rsq)

## Writing optimization result to PDF file
pdf(file.path(initial.dir,set8,paste('optimization',PLANT,'-',PHASE,c(".pdf"),sep="")), height=6,width=6)

#Plotting, add legend and titles
plot(v.j$rsq.j,v.s$rsq.s, main="Optimal starting DOY",xlab="V(pDOY)",ylab="V(pHU)",col="gray",)
points(v.j[match(max(v$rsq), v$rsq),],v.s[match(max(v$rsq), v$rsq),], pch=7,col="red",cex=2)
legend("topleft",legend=c(paste("Starting DOY =",start.ph),
                          paste("V(pHU,opt) =",round(v.s[match(max(v$rsq), v$rsq),],2)),
                          paste("V(pDOY,opt) =",round(v.j[match(max(v$rsq), v$rsq),],2))))
dev.off()

##########################################################################################################################
##End optimization 
##########################################################################################################################

#Final conditional summation of phase-specific heat units with optimal starting DOY
pHU <- data.frame(pHU=NULL)
for(j in seq(along=list.p2)){#Loop1: Summation
        x1 <- list.p2[[j]]
        x2 <-  rowSums(x1[match(paste('T',start.ph,sep=""),names(x1)):match(paste('T',x1$JULTAG,sep=""),names(x1))])
        pHU <- rbind(pHU,x2)
    }

## Writing phase-specific heat units to var.p
colnames(pHU) <- c("pHU")
var.p$pHU <- pHU$pHU
var.p.pHU <-  var.p[c(match(paste('pHU',sep=""),names(var.p)),(match(paste('uHU',start.ph,sep=""),names(var.p)):match(paste('uHU',max.ph,sep=""),names(var.p))))]
names(var.p.pHU)

##########################################################################################################################
##End Model 2
##########################################################################################################################





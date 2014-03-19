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
#Mapping
##########################################################################################################################

## Read produced shapefile to data frame
phase <- readShapePoly(file.path(initial.dir,set8,paste('doy',PLANT,'-',PHASE,c(".shp"),sep="")),IDvar="ID_DEM", proj4string=CRS("+init=epsg:25832"))

## Set map layout
plotvar <- round(phase$pDOY, 1)
nclr <- 8
plotclr <- brewer.pal(nclr,"Spectral")
class <- classIntervals(plotvar, nclr, style="quantile")
colcode <- findColours(class, plotclr)

## Write map to PDF
pdf(file.path(initial.dir,set8,paste('Map',PLANT,'-',PHASE,c(".pdf"),sep="")), height=9,width=7)#Plotting
plot(phase, col=colcode,border=NA,axes=TRUE)
points(var.p$coords.x1,var.p$coords.x2, col="red", pch=10, cex=1)

## Add legend and titles
title(main=paste('Phenological phase',PLANT,'-',PHASE),sub="EPSG projection 25832 (http://spatialreference.org)")
legend("bottomright", title="Predicted DOY", legend=names(attr(colcode, "table")),fill=attr(colcode, "palette"), cex=1, bty="n")
legend("bottomleft", legend=c("Used phenological stations"),pch=c(10), col=c("red"))
dev.off()

##########################################################################################################################
##End Mapping
##########################################################################################################################

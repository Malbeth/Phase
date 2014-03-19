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
##Quality assessment
##########################################################################################################################

## Coupling of DEM and interpolated data
names(var.p)
var.p <- merge(var.p,var.dem[c(match(paste('ID_DEM',sep=""),names(var.dem)),match(paste('pDOY',sep=""),names(var.dem)))], by="ID_DEM")
names(var.p)


## Calculation of internal and external accuracy metrics
cor.tr <- cor.test(var.p$JULTAG,var.p$pDOY, method="spearman") # Spearman's rank  correlation coefficient
rsq.s <- rf.sum$rsq
rsq.j <- rf.jultag$rsq


## Drawing scatter plots and plot legend
pdf(file.path(initial.dir,set8,paste('quality',PLANT,'-',PHASE,c(".pdf"),sep="")), height=5,width=7)
plot(var.p$JULTAG,var.p$pDOY,xlab="pDOY (observed)", ylab="pDOY (predicted)", main="Scatter diagram",xlim=c(range((var.dem$pDOY),(var.p$JULTAG))),ylim=c(range((var.dem$pDOY),(var.p$JULTAG))),col="black")
abline(lsfit(var.p$JULTAG,var.p$pDOY),col= "red", lwd=1)

legend("bottomright",legend=c("regression function"),lty=c(1), lwd=c(2), col=c("red"))
legend("topleft",legend=c(paste("Internal accuracy metrics: V(T) =",round(sum(v.t[min.ph:max.ph,])/(max.ph-min.ph),2)," | V(pHU) =",round(rsq.s[length(rsq.s)],2)," | V(pDOY) =",round(rsq.j[length(rsq.j)],2)),

paste("External accuracy metrics: rho =",round(cor.tr$estimate,2),", p =",round(cor.tr$p.value,3), "| RMSE = ",round(sqrt(mean((var.p$JULTAG-var.p$pDOY)^2)),2)),
paste('training data set -> N =',length(var.p$ID_DEM),' | total data set -> N =',length(var.dem$ID_DEM))),bty="n")
dev.off()

##########################################################################################################################
##End Accuracy Assessment
##########################################################################################################################

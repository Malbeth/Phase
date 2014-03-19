Phase - Prediction of Phenological Phases in Germany
====================================================

VERSION:
	2.0


AUTHOR:	
	Dr. Markus Möller <markus.moeller@geo.uni-halle.de>


LICENCE: 
	GNU General Public Licence (Version 3)


CONTENTS:
	subdir '_model':
		Phase2.0_control.r (Controlling Module)
		Phase2.0_model1.r (Prediction of temperature sums)
		Phase2.0_model2.r (calculation of unspecific heat units)
		Phase2.0_model3.r (DOY-prediction of beginning of phenological phase)
		Phase2.0_accuracy.r (calculation of metrics for quality assessment)
		Phase2.0_mapping.r (writing shapefiles, maps and accuracy reports)

		Phase2.0_model2a2.r (Modification of Phase2.0_model2.r, see 'troubleshooting')

	subsubdir '_input'
		doy2010.xls (Look-Up-Table for DOY/Date conversation)
		_phenology (Folder that contains phenological observation data sets in .xls-file format)
		_shape (Folder that contains ESRI point shapefiles .shp with segmented SRTM objects and phenological/meteorological observation networks)
		_temperature (Folder that contains daily mean temperature data in .DAT-format)

	subsubdir '_output' (initially empty)
		'_doy':	Map, Accuracy metrics, optimization, quality assesment (.PDF), predicted DOY (.shp)
		'_rf':	Random forest results for temperature sums, DOY prediction (.txt)
		
	

DEPENDS:
	R Environment for statistical computing and graphics (www.r-Project.org), Version 2.5.0 or higher
	Strawberry Perl distribution for running on Windows Platforms (www.strawberryperl.com)


CONFIGURATION NOTES:
	
 	Note: Folder structure should not be modified!

	Linked R packages:	gdata (Various R programming tools for data manipulation)
				              shapefiles (Read and write ESRI shapefiles)
				              randomForest (Breiman and Cutler's random forests for classification and regression
				              rgdal (Bindings for the Geospatial Data Abstraction Library), Version 1.3.1 or higher
				              maptools (Tools for Reading and handling spatial objects)
				              RColorBrewer (ColorBrewer palettes)
				              ClassInt (Choose univariate class intervalls)

	in 'Phase2.0_control.r':Copy working directory path in 'initial.dir' assignment
	in 'Phase2.0_model2.r':	Set path to Strawberry Perl directory

				
OPERATING INSTRUCTIONS:
	1) Open Phase2.0_control.r script
	2) Set (multiple) Plant-IDs (URL: http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/KU/KU2/KU21/phaenologie/beobachtungsprogramm/sofortmelderphasen__download,templateId=raw,property=publicationFile.xls/sofortmelderphasen_download.xls)
	3) Set ID for phenological Phase
	4) Run Script


TROUBLESHOOTING:
	


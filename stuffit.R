# /usr/bin/r
#
# Created: 2017.07.01
# Copyright: Steven E. Pav, 2017
# Author: Steven E. Pav <steven@gilgamath.com>
# Comments: Steven E. Pav

# 751M if stored as all chars...

suppressMessages(library(docopt))       # we need docopt (>= 0.3) as on CRAN

doc <- "Usage: stuffit.R [-v] [-D <UPSTREAM_D>] [-O <OUTPUT_SQLITE>]

-D UPSTREAM_D --upstream=UPSTREAM_D   Give the upstream BLS directory [default: download.bls.gov/pub/time.series/oe]
-O OUTPUT --output=OUTPUT             Give the output sqlite file [default: bls.sqlite]
-v --verbose                     Be more verbose
-h --help                        show this help text"

opt <- docopt(doc)

suppressMessages({
	library(dplyr)
	library(readr)
})

area <- readr::read_tsv(file.path(opt$upstream,'oe.area'),
												col_types=cols(area_code=col_integer(),
																			 state_code=col_integer()))
areatype <- readr::read_tsv(file.path(opt$upstream,'oe.areatype'))
datatype <- readr::read_tsv(file.path(opt$upstream,'oe.datatype'),
														col_types=cols(datatype_code=col_integer()))
footnote <- readr::read_tsv(file.path(opt$upstream,'oe.footnote'))
industry <- readr::read_tsv(file.path(opt$upstream,'oe.industry'))
occupation <- readr::read_tsv(file.path(opt$upstream,'oe.occupation'),
														col_types=cols(occupation_code=col_integer()))
release <- readr::read_tsv(file.path(opt$upstream,'oe.release'))
seasonal <- readr::read_tsv(file.path(opt$upstream,'oe.seasonal'))
sector <- readr::read_tsv(file.path(opt$upstream,'oe.sector'))

outp <- src_sqlite(opt$output,create=TRUE)

copy_to(outp,area,temporary=FALSE,name='area',
				unique_indexes=list(c('area_code')),
				indexes=list(c('state_code'),c('areatype_code')))
copy_to(outp,areatype,temporary=FALSE,name='areatype',
				unique_indexes=list(c('areatype_code')))
copy_to(outp,datatype,temporary=FALSE,name='datatype',
				unique_indexes=list(c('datatype_code')))
copy_to(outp,footnote,temporary=FALSE,name='footnote',
				unique_indexes=list(c('footnote_code')))
copy_to(outp,sector,temporary=FALSE,name='sector',
				unique_indexes=list(c('sector_code')))
copy_to(outp,industry,temporary=FALSE,name='industry',
				unique_indexes=list(c('industry_code')),
				indexes=list(c('display_level'),c('sort_sequence')))
copy_to(outp,occupation,temporary=FALSE,name='occupation',
				unique_indexes=list(c('occupation_code')),
				indexes=list(c('display_level'),c('sort_sequence')))
copy_to(outp,release,temporary=FALSE,name='release')
copy_to(outp,seasonal,temporary=FALSE,name='seasonal')


data_0_Current <- readr::read_tsv(file.path(opt$upstream,'oe.data.0.Current'),
																	col_types=cols(year=col_integer(),
																								 value=col_double())) %>%
	mutate(seasonal=substr(series_id,3,3),
				 areatype_code=substr(series_id,4,4),
				 area_code=as.integer(substr(series_id,5,11)),
				 industry_code=substr(series_id,12,17),
				 occupation_code=as.integer(substr(series_id,18,23)),
				 datatype_code=as.integer(substr(series_id,24,25))) %>%
	dplyr::select(-series_id) %>%
	mutate(value=as.numeric(value)) 

copy_to(outp,data_0_Current,temporary=FALSE,name='data',
				indexes=list('areatype_code','area_code','industry_code','occupation_code','datatype_code'))

#for vim modeline: (do not edit)
# vim:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:syn=r:ft=r

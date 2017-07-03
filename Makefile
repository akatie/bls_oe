# BLS data...
# this really ought to be in a sqlite file...

UPSTREAM_D 			= download.bls.gov/pub/time.series/oe
SQLITE_F 				= bls.sqlite

BLS_NAMES 			 = oe.area oe.areatype oe.contacts oe.data.0.Current oe.datatype oe.footnote oe.industry
BLS_NAMES 			+= oe.occupation oe.release oe.seasonal oe.sector 

BLS_FILES 			 = $(foreach name,$(BLS_NAMES),$(UPSTREAM_D)/$(name))

.PHONY : bls_files

$(UPSTREAM_D) : 
	mkdir -p $@

bls_files : $(BLS_FILES)   ## download all the BLS files

$(UPSTREAM_D)/index.html : 
	wget -r -l 1 https://$(UPSTREAM_D)/

$(UPSTREAM_D)/% : | $(UPSTREAM_D)
	wget -O $@ https://download.bls.gov/pub/time.series/oe/$*

$(SQLITE_F) : stuffit.R $(BLS_FILES) 
	r $(filter %.R,$^) -D $(UPSTREAM_D) -O $@

.PHONY : sqlite

sqlite : $(SQLITE_F)  ## stuff into a sqlite file

.PHONY : readme

readme : README.md  ## make the README.md file

README.md : %.md : %.Rmd $(SQLITE_F)
	r -l knitr -e 'setwd(".");if (require(knitr)) { knit("$(<F)") }'

############## DEFAULT ##############

.DEFAULT_GOAL 	:= help

.PHONY   : help 

# this will have to change b/c of inclusion file names...
help:  ## generate this help message
	@grep -h -P '^(([^\s]+\s+)*([^\s]+))\s*:.*?##\s*.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



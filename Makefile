#
# Makefile - for the PPR document set, usage:
#
# make - should just build ppr.pdf for now, eventually it should maybe archive it somewhere
#
# 


############# User configuration 

SITE=	Megalona
DEFAULTS = Defaults

# each section consists of a list of documents
#INTRO =      Introduction.docx
INTRO =
SYSTEM =     System-Pv-Diesel-Ess.docx 
SITEINFO =   Site.docx Location.docx SLD.docx GA.docx Logistics.docx Geotech-Report.docx
COMPONENTS = Component-Pv.docx Component-Diesel.docx Component-Ess.docx Component-Controllers.docx

# Meter, Pcc, Fuel, ....
# use Pv-Root-Harelec-MkII for a specific design

EVERYTHING = $(INTRO) $(SYSTEM) $(SITEINFO) $(COMPONENTS)

############
# variables from GS for now
PvMaxPPa = 500
EssMaxPPa = 400
EssMaxEPa = 1600

#
# Actiu\
.PHONEY: show pdf clean wbs

all:	show pdf wbs

# specifics
VPATH=$(SITE):$(DEFAULTS)

PANDOCFLAGS = -t latex --latex-engine=xelatex --template=templates/format.tex -Vtoc 
PANDOCVARS = -Vsitename=Megalona -VPvMaxPPa=$(PVMAXPPA)

show:	$(EVERYTHING)
	@echo "using files:"
	@for f in $^ ; do echo $$f ; done

pdf:  $(EVERYTHING)
	pandoc $(PANDOCFLAGS) $(PANDOCVARS) $^ wbs.docx -o ppr.pdf

ppr.tex:  $(EVERYTHING)
	pandoc $(PANDOCFLAGS) $(PANDOCVARS) $^ -o ppr.tex

wbs: 	$(EVERYTHING)
	pandoc $^ -t mediawiki -o - | ./wbs.py >wbs.csv
	awk -F, '{ print $$2, "\t", $$3 }' wbs.csv

wbs.docx: wbs.csv
	awk -F, 'BEGIN { print '* WBS Schedule' } { print $$2, "\t", $$3 }' wbs.csv | \
         pandoc -f org -t docx -o wbs.docx 


wbs-test: $(EVERYTHING)
	pandoc $^ -t mediawiki -o - | grep '='

others:
	echo '\\section{Annex N: Names}' >Names.tex
	echo 'PvMaxPPa = 500kW' >> Names.tex
	pandoc $(PANDOCFLAGS) -t docx $(PANDOCVARS) Names.tex -o Names.docx

# rules for generating templates for Components

Component-%.md: Component-Generic.org
	# test ! -e $@ ; # if the file exists don't clobber it
	NAME=$@ ./transmogrify.py $< | pandoc -f org -o $@
	cat $@

# rules for generating .docx from markdown, etc.
%.docx:	%.md
	pandoc $< -o $@

%.docx: %.tex
	pandoc $< -o $@

%.docx: %.org
	pandoc -f org $< -o $@





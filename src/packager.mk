# Copyright 2021 Richard Lincoln. All rights reserved.

PYODIDE_ROOT = $(abspath ../pyodide)
include $(PYODIDE_ROOT)/Makefile.envs

FILEPACKAGER = $(PYODIDE_ROOT)/tools/file_packager.py
XLSX2JSON = xlsx2json.py

CASESDIR = /usr/local/lib/python3.8/site-packages/andes/cases

CASEFILES = \
$(CASESDIR)/5bus/pjm5bus.xlsx \
$(CASESDIR)/ieee14/ieee14_fault.xlsx \
$(CASESDIR)/kundur/kundur_full.xlsx

JSONDIR = ./json

JSONFILES = \
$(JSONDIR)/pjm5bus.json \
$(JSONDIR)/ieee14_fault.json \
$(JSONDIR)/kundur_full.json

DOTANDES = $(HOME)/.andes


all: $(JSONFILES) cases.asm.data.js andes.asm.data.js

.PHONY: jsonfiles
jsonfiles: $(JSONFILES)

$(JSONDIR)/pjm5bus.json: $(CASESDIR)/5bus/pjm5bus.xlsx $(XLSX2JSON) $(JSONDIR)
	$(HOSTPYTHON) $(XLSX2JSON) $< $@

$(JSONDIR)/ieee14_fault.json: $(CASESDIR)/ieee14/ieee14_fault.xlsx $(XLSX2JSON) $(JSONDIR)
	$(HOSTPYTHON) $(XLSX2JSON) $< $@

$(JSONDIR)/kundur_full.json: $(CASESDIR)/kundur/kundur_full.xlsx $(XLSX2JSON) $(JSONDIR)
	$(HOSTPYTHON) $(XLSX2JSON) $< $@

$(JSONDIR):
	mkdir -p $@


cases.asm.data.js:
	$(FILEPACKAGER) $(basename $@) --abi=$(PYODIDE_PACKAGE_ABI) --preload $(JSONDIR)@/cases --js-output=$@

andes.asm.data.js:
	$(FILEPACKAGER) $(basename $@) --abi=$(PYODIDE_PACKAGE_ABI) --preload $(DOTANDES)@/home/web_user/.andes --js-output=$@

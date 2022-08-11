SUITESPARSE_VERSION = 5.4.0

ROOT=$(abspath .)

SRC = $(ROOT)/SuiteSparse-WA


all: $(SRC)/Makefile

suitesparse.tgz:
	wget -q -O $@ https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v$(SUITESPARSE_VERSION).tar.gz

$(SRC)/Makefile: suitesparse.tgz
	tar xzf $<
	rm -rf $(SRC)
	mv SuiteSparse-$(SUITESPARSE_VERSION) $(SRC)

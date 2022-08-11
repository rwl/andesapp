PYODIDE_ROOT = $(abspath ../..)
include $(PYODIDE_ROOT)/Makefile.envs

F2CLAPACK_VERSION = 3.2.1

ROOT=$(abspath .)

SRC=$(ROOT)/F2CLAPACK_WA

all: $(SRC)/libf2c.a $(SRC)/blas.a $(SRC)/lapack.a


$(SRC)/blas.a: $(SRC)/.patched
	emmake make -C $(SRC) -j $${PYODIDE_JOBS:-3} blaslib

$(SRC)/lapack.a: $(SRC)/.patched
	emmake make -C $(SRC) -j $${PYODIDE_JOBS:-3} lapacklib

$(SRC)/F2CLIBS/libf2c.a: $(SRC)/.patched
	emmake make -C $(SRC) -j $${PYODIDE_JOBS:-3} f2clib

$(SRC)/libf2c.a: $(SRC)/F2CLIBS/libf2c.a
	mv $< $@


clapack.tgz:
	wget -q -O clapack.tgz http://www.netlib.org/clapack/clapack.tgz

$(SRC)/Makefile: clapack.tgz
	tar xzf clapack.tgz
	rm -rf $(SRC)
	mv CLAPACK-$(F2CLAPACK_VERSION) $(SRC)

$(SRC)/.patched: $(SRC)/Makefile
	cd $(SRC); cat ../f2clapack.patch | patch -p1
	cp make.inc $(SRC)

	# Modify subroutines to return void instead of int
	# as expected by KVXOPT and SuiteSparse.
	sed -i 's|^/\* Subroutine \*/ int |/\* Subroutine \*/ void |' $(SRC)/BLAS/SRC/*.c
	sed -i 's|^/\* Subroutine \*/ int |/\* Subroutine \*/ void |' $(SRC)/SRC/*.c
	sed -i 's|^    extern /\* Subroutine \*/ int |    extern /\* Subroutine \*/ void |' $(SRC)/BLAS/SRC/*.c
	sed -i 's|^    extern /\* Subroutine \*/ int |    extern /\* Subroutine \*/ void |' $(SRC)/SRC/*.c
	sed -i 's|return 0;|return;|' $(SRC)/BLAS/SRC/*.c
	sed -i 's|return 0;|return;|' $(SRC)/SRC/*.c

	touch $@

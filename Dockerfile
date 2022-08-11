FROM iodide/pyodide-env:9 as builder

# Install native Andes for converting .xslx cases to .json format.
RUN python3 -m pip install 'andes==1.3.5'


ENV PYODIDE_DIR /usr/src/pyodide

COPY third_party/pyodide-0.16.1 $PYODIDE_DIR
WORKDIR $PYODIDE_DIR
COPY src/pyodide.patch pyodide.patch
RUN cat pyodide.patch | patch -p1

RUN make emsdk/emsdk/.complete
RUN make build/pyodide.asm.js build/pyodide.asm.data

#COPY src/buildall.py $PYODIDE_DIR/pyodide_build/buildall.py
RUN PYODIDE_PACKAGES="micropip,numpy,sympy" make

COPY packages/F2CLAPACK $PYODIDE_DIR/packages/F2CLAPACK
COPY packages/SuiteSparse $PYODIDE_DIR/packages/SuiteSparse
COPY packages/kvxopt $PYODIDE_DIR/packages/kvxopt
COPY packages/dill $PYODIDE_DIR/packages/dill
COPY packages/tqdm $PYODIDE_DIR/packages/tqdm

RUN PYODIDE_PACKAGES="kvxopt,dill,tqdm" make -C packages

COPY packages/andes $PYODIDE_DIR/packages/andes
RUN PYODIDE_PACKAGES="andes" make -C packages


ENV ANDESAPPDIR /usr/src/andesapp

COPY src/xlsx2json.py $ANDESAPPDIR/xlsx2json.py
COPY src/packager.mk $ANDESAPPDIR/Makefile
COPY web/calls.pkl $ANDESAPPDIR/.andes/calls.pkl
COPY web/pycode $ANDESAPPDIR/.andes/pycode
WORKDIR $ANDESAPPDIR

RUN make PYODIDE_ROOT=$PYODIDE_DIR DOTANDES=$ANDESAPPDIR/.andes


FROM ubuntu:bionic as server

RUN apt-get update && apt-get install -yq --no-install-recommends \
	python3 ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

ENV PROJECTDIR /work

COPY --from=builder /usr/src/pyodide/build $PROJECTDIR/pyodide
COPY --from=builder /usr/src/pyodide/packages/.artifacts $PROJECTDIR/packages/.artifacts

COPY --from=builder /usr/src/andesapi/cases.asm.data $PROJECTDIR/pyodide/cases.asm.data
COPY --from=builder /usr/src/andesapi/cases.asm.data.js $PROJECTDIR/pyodide/cases.asm.data.js
COPY --from=builder /usr/src/andesapi/andes.asm.data $PROJECTDIR/pyodide/andes.asm.data
COPY --from=builder /usr/src/andesapi/andes.asm.data.js $PROJECTDIR/pyodide/andes.asm.data.js

COPY src/pyodide_server.py $PROJECTDIR/pyodide_server.py
COPY src/index.html $PROJECTDIR/index.html
COPY src/calls.html $PROJECTDIR/calls.html
WORKDIR $PROJECTDIR

EXPOSE 8000
CMD ["python3", "pyodide_server.py"]

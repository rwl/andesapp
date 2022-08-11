
WASM_TAG = andesapp/wasm

.PHONY: wasmbuild
wasmbuild:
	docker build --target $(TARGET) -t $(WASM_TAG) .

.PHONY: wasmrun
wasmrun:
	docker run -it --rm -p 8000:8000 -v `pwd`/src/index.html:/work/index.html $(WASM_TAG) $(CMD)


DESTDIR = ../andesapp.github.com

.PHONY: wasmcp
wasmcp:
	docker run -it --rm -d $(WASM_TAG)
	CONTAINER_ID=$$(docker ps -alq) && \
	docker cp $$CONTAINER_ID:/work/index.html $(DESTDIR) && \
	docker cp $$CONTAINER_ID:/work/packages $(DESTDIR) && \
	docker cp $$CONTAINER_ID:/work/pyodide $(DESTDIR) && \
	docker stop $$CONTAINER_ID

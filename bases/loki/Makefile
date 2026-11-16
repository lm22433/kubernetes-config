OUTPUT_DIR = generated-manifests
KUSTOMIZATION_FILE = ${OUTPUT_DIR}/kustomization.yaml

.PHONY: docker-build
docker-build:
	docker build -t loki-builder .
	docker run \
		--rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(shell pwd):/src \
		-w /src \
		loki-builder \
		make generate-manifests

vendor:	jsonnetfile.lock.json
	jb install

.PHONY: generate-manifests
generate-manifests: vendor
	rm -rf ./${OUTPUT_DIR}
	mkdir ./${OUTPUT_DIR}

	tk export ./${OUTPUT_DIR} .

	rm ${OUTPUT_DIR}/manifest.json

	echo "apiVersion: kustomize.config.k8s.io/v1beta1" > ${KUSTOMIZATION_FILE}
	echo "kind: Kustomization" >> ${KUSTOMIZATION_FILE}
	echo "" >> ${KUSTOMIZATION_FILE}
	echo "resources:" >> ${KUSTOMIZATION_FILE}

	for f in ${OUTPUT_DIR}/*.yaml; do \
		if [ $$f != ${KUSTOMIZATION_FILE} ]; then \
			echo "- $$(basename $$f)" >> ${KUSTOMIZATION_FILE}; \
		fi \
	done

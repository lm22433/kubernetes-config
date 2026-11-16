out_dir = generated-manifests
components = $(shell find . -name '*.jsonnet' -not -path "./vendor/*")

.PHONY: docker-build
docker-build:
	docker build -t kube-prometheus-builder .
	docker run \
		--rm \
		--user $(shell id -u):$(shell id -g) \
		-v $(shell pwd):/src \
		-w /src \
		kube-prometheus-builder \
		make generate-manifests

vendor:	jsonnetfile.lock.json
	jb install

.PHONY: generate-manifests
generate-manifests: vendor
	for component in $(components); do \
		echo $$component; \
		parent=$$(dirname $$component); \
		out=$$parent/$(out_dir); \
		rm -rf ./$$out; \
		mkdir -p ./$$out; \
		files=$$(jsonnet -J vendor -m $$out $$component) || exit 1; \
		printf '%s\n' "$$files" | xargs -I{} sh -c 'echo "# Generated from Makefile" > {}.yaml && cat {} | gojsontoyaml >> {}.yaml' -- {} || exit 1; \
		find $$out -type f ! -name '*.yaml' -delete; \
		rm -f $$parent/kustomization; \
	done

	# Strip descriptions from custom resrouce definitions
	for f in setup/$(out_dir)/*CustomResourceDefinition.yaml; do \
		tmpf=$$f.tmp; \
	  	cp $$f $$tmpf; \
		gojsontoyaml -yamltojson < $$tmpf | jq 'walk(if type == "object" then with_entries(select(.key != "description" or (.value | type) != "string")) else . end)' | gojsontoyaml > $$f; \
		rm $$tmpf; \
	done


.PHONY: clean
clean:
	rm -rf */$(out_dir)

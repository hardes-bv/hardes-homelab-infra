## Validate by running `kustomize build` myself for each kustomization.
## This will already check if there are no errors in paths or patches.

CLUSTERS := \
	desk8s \
	rack8s

clean:
	rm -rf build/

build-folder-%: CLUSTER    = $(word 1,$(subst @, ,$*))
build-folder-%:
	mkdir -p build/$(CLUSTER)/infrastructure

# Root level validation for each cluster
test-root-%: CLUSTER    = $(word 1,$(subst @, ,$*))
test-root-%:
	@echo target: $*
	kustomize build kubernetes/infrastructure/$(CLUSTER) \
	    -o build/$(CLUSTER)/infrastructure
$(foreach c,$(CLUSTERS),$(eval test-root-$(c): build-folder-$(c)))

# Every combination of cluster + deployment
# Split "<cluster>@<deployment>"
test-%: CLUSTER    = $(word 1,$(subst @, ,$*))
test-%: DEPLOYMENT_TARGET = $(word 2,$(subst @, ,$*))
test-%: DEPLOYMENT = $(subst _,/,$(DEPLOYMENT_TARGET))
test-%:
	@echo target: $*
	mkdir -p build/$(CLUSTER)/infrastructure/$(DEPLOYMENT)
	kustomize build kubernetes/infrastructure/$(CLUSTER)/$(DEPLOYMENT)/ \
	    -o build/$(CLUSTER)/infrastructure/$(DEPLOYMENT)
$(foreach c,$(CLUSTERS),$(eval test-$(c): build-folder-$(c)))

flate-build-%: CLUSTER    = $(word 1,$(subst @, ,$*))
flate-build-%:
	@echo target: $*
	flate build -p ./kubernetes/clusters/$(CLUSTER) --supply ./test/$(CLUSTER)/flux-runtime-info.yaml > build/$(CLUSTER)/flate-build.yaml
$(foreach c,$(CLUSTERS),$(eval flate-build-$(c): build-folder-$(c)))

flate-build: $(addprefix flate-build-,$(CLUSTERS))

flate-test-%: CLUSTER    = $(word 1,$(subst @, ,$*))
flate-test-%:
	flate test -p ./kubernetes/clusters/$(CLUSTER) --supply ./test/$(CLUSTER)/flux-runtime-info.yaml
$(foreach c,$(CLUSTERS),$(eval flate-test-$(c): build-folder-$(c)))

flate-test: $(addprefix flate-test-,$(CLUSTERS))

flate-diff-%: CLUSTER    = $(word 1,$(subst @, ,$*))
flate-diff-%:
	@echo diff target: $*
	flate diff all -p ./kubernetes/clusters/$(CLUSTER) --base main --supply ./test/$(CLUSTER)/flux-runtime-info.yaml --output diff > build/$(CLUSTER)/flate.diff
$(foreach c,$(CLUSTERS),$(eval flate-diff-$(c): build-folder-$(c)))


flate-diff: $(addprefix flate-diff-,$(CLUSTERS))

test: $(addprefix test-root-,$(CLUSTERS)) flate-test flate-build flate-diff

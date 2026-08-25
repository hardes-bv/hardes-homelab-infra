## Validate by running `kustomize build` myself for each kustomization.
## This will already check if there are no errors in paths or patches.

CLUSTERS := \
	desk8s \
	rack8s

clean:
	rm -rf build/

# Root level validation for each cluster
test-root-%: CLUSTER    = $(word 1,$(subst @, ,$*))
test-root-%:
	@echo target: $*
	mkdir -p build/$(CLUSTER)/infrastructure
	kustomize build kubernetes/infrastructure/$(CLUSTER) \
	    -o build/$(CLUSTER)/infrastructure
	mkdir -p build/$(CLUSTER)/apps
	kustomize build kubernetes/apps/$(CLUSTER) \
	    -o build/$(CLUSTER)/apps

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

test: $(addprefix test-root-,$(CLUSTERS))

## Validate by running `kustomize build` myself for each kustomization.
## This will already check if there are no errors in paths or patches.

CLUSTERS := \
	desk8s \
	rack8s

DEPLOYMENTS := \
	external-secrets/external-secrets/app \
	external-secrets/onepassword-sdk-hardes/app \
	kube-system/cilium/app \
	kube-system/cilium/networking \
	kube-system/spegel/app \
	system-upgrade/tuppr/app \
	system-upgrade/tuppr/upgrades

clean:
	rm -rf build/

# Root level validation for each cluster
test-root-%: CLUSTER    = $(word 1,$(subst @, ,$*))
test-root-%:
	@echo target: $*
	mkdir -p build/$(CLUSTER)
	kustomize build kubernetes/infrastructure/$(CLUSTER) \
	    -o build/$(CLUSTER)

# Every combination of cluster + deployment
# Split "<cluster>@<deployment>"
test-%: CLUSTER    = $(word 1,$(subst @, ,$*))
test-%: DEPLOYMENT_TARGET = $(word 2,$(subst @, ,$*))
test-%: DEPLOYMENT = $(subst _,/,$(DEPLOYMENT_TARGET))
test-%:
	@echo target: $*
	mkdir -p build/$(CLUSTER)/$(DEPLOYMENT)
	kustomize build kubernetes/infrastructure/$(CLUSTER)/$(DEPLOYMENT)/ \
	    -o build/$(CLUSTER)/$(DEPLOYMENT)

DEPLOY_MATRIX := $(foreach c,$(CLUSTERS),$(foreach d,$(DEPLOYMENTS),$(c)@$(subst /,_,$(d))))
test: $(addprefix test-root-,$(CLUSTERS)) $(addprefix test-,$(DEPLOY_MATRIX))

# Bootstrap Cilium

Command to install the Helm chart, after which Flux will take over.

```shell
helm install \
    cilium \
    oci://quay.io/cilium/charts/cilium \
    --version 1.20.1 \
    --namespace kube-system \
    --values values.yaml
```

Use `kustomize` to deploy the custom resources for Cilium on `desk8s`:

```shell
$ kustomize build kubernetes/infrastructure/desk8s/kube-system/cilium/networking/ -o build
$ kubectl apply -f build/cilium.io_v2alpha1_ciliuml2announcementpolicy_announce-all.yaml
$ kubectl apply -f build/cilium.io_v2_ciliumloadbalancerippool_lb-ip-pool.yaml
```

Use `kustomize` to deploy the custom resources for Cilium on `rack8s`:

```shell
$ kustomize build kubernetes/infrastructure/rack8s/kube-system/cilium/networking/ -o build
$ kubectl apply -f build/cilium.io_v2alpha1_ciliuml2announcementpolicy_announce-all.yaml
$ kubectl apply -f build/cilium.io_v2_ciliumloadbalancerippool_lb-ip-pool.yaml
```

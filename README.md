# Hardes Homelab clusters managed by Flux CD

## Bootstrap

### Flux

Flux CD is bootstrapped using the [Flux Operator](https://fluxoperator.dev) Helm chart, via a manual
`helm install` command. After that, the Flux Instance CRD is used to let the cluster bootstrap a Flux CD instance.
The initial Flux Instance is configured to bootstrap the Flux CD instance in the `flux-system` namespace.

The Flux Operator can use [Github App authentication](https://fluxcd.io/blog/2025/04/flux-operator-github-app-bootstrap/)
to authenticate with Github to read the repository containing the Flux CD configuration. A Github App is created
in `hardes-bv` organization and installed only on this repository. The app information is stored in a secret in
`flux-system` namespace. The Flux Instance config has a `sync` section pointing to this secret and repository.

See `clusters/<cluster>/flux-system/flux-instance.yaml`.

After that, we enabled the Flux Operator to automate upgrades of itself using 
[the documented `ResourceSet`](https://fluxoperator.dev/docs/guides/migration/#automating-flux-operator-upgrades).

The folder structure of this repository follows the monorepo pattern described in the
[Flux CD documentation](https://fluxcd.io/flux/guides/repository-structure/).

### External Secrets Operator (ESO)

The External secrets operator is configured to read secrets from 1Password vaults. The setup needs
one manually created secret containing the token for the 1Password service account used to connect
to the vaults.

For Kubernetes contexts `admin@desk8s` and `admin@rack8s`, use the following command line to create
this secret:

```sh
kustomize build bootstrap/external-secrets/ | op inject | kubectl apply -f -
```

The `op` command is the CLI to fetch the service token from the vault itself and replace the
`op://...` placeholder with the actual value. The External Secrets Operator can now fetch
any secrets from the respective vault via `ExternalSecret` custom resources.

# Bootstrap & Upgrade of Talos Kubernetes Clusters

## Content

The folders `desk8s` and `rack8s` contain the Talos configuration and patch files which can be applied
using `talosctl`.

The files in the root directory make up a Pulumi IaC program with 2 stacks (`desk8s` and `rack8s`).
The Pulumi program installs the [Tuppr](https://github.com/home-operations/tuppr) operator using
the official Helm chart. Once the operator is installed, two custom resources are installed
to manage upgrades of:

* Talos using the `TalosUpgrade` custom resource.
* Kubernetes using the `KubernetesUpgrade` custom resource.

## Prerequisites

- [Talosctl](https://www.talos.dev/docs/latest/reference/talosctl/)

## Detecting new versions

New versions of Talos and Kubernetes are detected using [UpdateCLI](https://updatecli.io/). They are first
applied to the `desk8s` stack, and then to the `rack8s` stack. You will see this reflected in the UpdateCLI
manifests. The first manifest will check upstream for new versions and apply these new versions only to `desk8s`,
this in all file locations where versions need to be kept in sync.

After merging the PR for `desk8s`, the versions for `desk8s` and `rack8s` are out of sync which will result
in the second UpdateCLI manifest detecting this and applying the newer `desk8s` versions to `rack8s`.

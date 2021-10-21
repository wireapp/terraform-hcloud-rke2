# terraform-hcloud-rke2

This spins up a RKE2 cluster on hcloud.

The files in the root module intended to show how the individual modules can be
tied together.

In your own projects, most likely you'd like to instantiate the submodules from
your projects directly.

## Demo (from the root module)
In the hcloud web console, create a new project, and a read/write token for it.

Configure the hcloud token (both to invoke terraform, as well as hand it over to the CCM):
 - `export HCLOUD_TOKEN=<your-token>`
 - `export TF_VAR_hcloud_token=<your-token>`

Invoke terraform:
 - `terraform init`
 - `terraform apply`

This will generate an SSH key at `id_root`, which can be used to SSH to
individual machines.

Look up one of the controlplane node ips in the hcloud web console.
SSH into the box to check the cluster status:

```shell
$ ssh -i id_root root@<controlplane-0>
$ kubectl get nodes
```

Please see `variables.tf` in the root directory, and in the individual
subfolders for a full list of configuration options.

If enabled (`hetzner_ccm_enabled`), it will install
[hcloud-cloud-controller-manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager),
and configure their internal nginx ingress controller to deploy services of
type `LoadBalancer`.

`hcloud-cloud-controller-manager` requires an API token to be configured. As
the hcloud terraform provider does not allow to create API tokens on demand,
this needs to be configured manually.

The controller manager is deployed [with networks support](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/master/docs/deploy_with_networks.md),
so it uses the (more reliable) Hetzner private network.

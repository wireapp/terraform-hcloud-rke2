# terraform-hcloud-rke2

This spins up a RKE2 cluster on hcloud.

If enabled `ssh_key_create`, will generate a ssh key randomly which will be stored in the terraform state.

```bash
terraform show -json | jq  '.values.root_module | select(.address=="tls_private_key.root[0]")'
```

This is needed to ssh into the cluster for ops, as well as retrieving the initial kubeconfig.

If enabled (`hetzner_ccm_enabled`), it will install
[hcloud-cloud-controller-manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager),
and configure their internal nginx ingress controller to deploy services of
type `LoadBalancer` - so instead of configuring the load balancer by yourself,
it'll create one for you.

`hcloud-cloud-controller-manager` requires an API token to be configured. As
the hcloud terraform provider does not allow to create API tokens on demand, this needs to be configured manually.

The controller manager is deployed [with networks support](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/master/docs/deploy_with_networks.md) to use the underlying Hetzner private network avoiding the overhead of

ssh into one of the controlplane nodes and run the following:
```
kubectl -n kube-system create secret generic hcloud --from-literal=token=<hcloud API token>
```

Please see `variables.tf` for a full list of configuration options.

It exposes the following outputs:

 - `controlplane_ipv{4,6}s`
   The IPv4/IPv6 addresses of all controlplane nodes.
 - `worker_ipv{4,6}s`
   The IPv4/IPv6 addresses of all pure worker nodes.
 - `controlplane_lb_ipv{4,6}`
	 The IPv4/IPv6 address of the load balancer in front of all control planes,
	 exposing the kube-api-server port and RKE2 management port.
 - `ingress_lb_ipv{4,6}`
	 The IPv4/IPv6 address of the load balancer in front of all nodes running
	 workloads (can also be controlplane nodes), exposing port 80 and 443 from
	 nodes running pods from the `rke2-ingress-nginx` deployment.
	 This only applies if `hetzner_ccm_enabled` is disabled, otherwise the CCM will
	 take care of adding a load balancer.

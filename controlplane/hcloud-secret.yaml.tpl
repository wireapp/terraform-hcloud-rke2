apiVersion: v1
kind: Secret
metadata:
  name: hcloud
  namespace: kube-system
type: Opaque
data:
  token: ${base64encode(hcloud_token)}
  network: ${base64encode(network_id)}
  network_zone: ${base64encode(network_zone)}

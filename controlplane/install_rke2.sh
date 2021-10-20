#!/bin/bash
internal_ip=$(curl -sfL http://169.254.169.254/hetzner/v1/metadata/private-networks | grep "ip:" | head -n 1| cut -d ":" -f2 | xargs)
# internal_mac=$(curl -sfL http://169.254.169.254/hetzner/v1/metadata/private-networks | grep "mac_address:" | head -n 1 | awk '{print $2}')
# echo -e "[Match]\nMACAddress=$internal_mac\n[Link]\nName=priv" > /etc/systemd/network/80-internal.link

# Add the internal ip as node-ip to rancher config
jq --arg nodeip $internal_ip '. + {"node-ip": $nodeip}' < /etc/rancher/rke2/config.yaml > /etc/rancher/rke2/config.yaml.new
mv /etc/rancher/rke2/config.yaml.new /etc/rancher/rke2/config.yaml

# Check if server is set in config (so we're not the bootstrap controlplane node).
if jq -re .server /etc/rancher/rke2/config.yaml; then
	echo "We're not the seed controlplane node, wait for it to be up"
  while ! curl -sk -m 5 $(jq -re .server /etc/rancher/rke2/config.yaml); do sleep 1; done
fi

export INSTALL_RKE2_TYPE=server
curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server
systemctl start rke2-server

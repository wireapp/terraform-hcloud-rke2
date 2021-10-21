#!/bin/bash
internal_ip=$(curl -sfL http://169.254.169.254/hetzner/v1/metadata/private-networks | grep "ip:" | head -n 1| cut -d ":" -f2 | xargs)
internal_mac=$(curl -sfL http://169.254.169.254/hetzner/v1/metadata/private-networks | grep "mac_address:" | head -n 1 | awk '{print $2}')

# Add a .link file renaming the private interface to "priv"
echo -e "[Match]\nMACAddress=$internal_mac\n[Link]\nName=priv" > /etc/systemd/network/80-private.link

# Do the same change manually, so it doesn't need a reboot to apply
internal_if=$(ip -br link | awk "\$3 ~ /$internal_mac/ {print \$1}")
ip l set down dev $internal_if
ip l set $internal_if name priv
ip l set up dev priv

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

# Configure /root/.profile to add rke2 binaries to $PATH and set $KUBECONFIG
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/var/lib/rancher/rke2/bin' >> /root/.profile

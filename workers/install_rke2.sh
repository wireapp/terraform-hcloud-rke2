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

# Wait for master to be up
while ! curl -sk -m 5 $(jq -re .server /etc/rancher/rke2/config.yaml); do sleep 1; done

export INSTALL_RKE2_TYPE=agent
curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-agent
systemctl start rke2-agent

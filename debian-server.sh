#! /bin/bash

sudo apt install -y wireguard-tools
if [[ $? -ne 0 ]]; then
    echo "Failed to install WireGuard"
    exit 1
fi

# Generate
wg genkey | tee privatekey | wg pubkey > publickey
if [[ $? -ne 0 ]]; then
    echo "Failed to generate keys"
    exit 1
fi

# Create config
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $(cat privatekey)
Address = 10.24.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $(cat publickey)
AllowedIPs = 10.24.0.1
EOF

# Enable and start
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
if [[ $? -ne 0 ]]; then
    echo "Failed to start WireGuard"
    exit 1
fi

# Enable forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
if [[ $? -ne 0 ]]; then
    echo "Failed to enable forwarding"
    exit 1
fi

echo "WireGuard installed and configured"

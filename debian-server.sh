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
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
PrivateKey = $(cat privatekey)
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -A INPUT -p udp --dport 51820 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -D INPUT -p udp --dport 51820 -j ACCEPT

[Peer]
PublicKey = $(cat publickey)
AllowedIPs = 10.0.0.2/32
EOF
if [[ $? -ne 0 ]]; then
    echo "Failed to start WireGuard"
    exit 1
fi

# Enable forwarding
tee -a  /etc/sysctl.conf > /dev/null <<EOF 
"net.ipv4.ip_forward = 1"
EOF
if [[ $? -ne 0 ]]; then
    echo "Failed to enable forwarding"
    exit 1
fi

sysctl -p
if [[ $? -ne 0 ]]; then
    echo "Failed to enable forwarding"
    exit 1
fi

echo "WireGuard installed and configured"

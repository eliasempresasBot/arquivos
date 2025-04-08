#!/bin/bash

# 1. Instalar WireGuard
apt update
apt install -y wireguard

# 2. Gerar chaves do servidor
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
PUBLIC_KEY=$(cat /etc/wireguard/publickey)

# 3. Configurar interface do servidor
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.77.0.1/24
ListenPort = 51820
SaveConfig = true
EOF

# 4. Ativar IP forwarding e regras de NAT
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
iptables -t nat -A POSTROUTING -s 10.77.0.0/24 -o eth0 -j MASQUERADE
apt install -y iptables-persistent
netfilter-persistent save

# 5. Ativar e iniciar WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# 6. Gerar cliente
mkdir -p /etc/wireguard/cliente
cd /etc/wireguard/cliente
wg genkey | tee cliente.key | wg pubkey > cliente.pub
CLIENTE_PRIV=$(cat cliente.key)
CLIENTE_PUB=$(cat cliente.pub)

# 7. Atualizar wg0.conf com peer do cliente
cat <<EOF >> /etc/wireguard/wg0.conf

[Peer]
PublicKey = $CLIENTE_PUB
AllowedIPs = 10.77.0.2/32
EOF

# 8. Gerar configuração do cliente
cat <<EOF > cliente.conf
[Interface]
PrivateKey = $CLIENTE_PRIV
Address = 10.77.0.2/32
DNS = 8.8.8.8

[Peer]
PublicKey = $PUBLIC_KEY
Endpoint = 192.168.1.55:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

chmod 600 /etc/wireguard/wg0.conf /etc/wireguard/cliente/cliente.conf

echo "VPN configurada com sucesso. Config do cliente em /etc/wireguard/cliente/cliente.conf"

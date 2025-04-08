#!/bin/bash

echo "Instalando dependências..."
apt update
apt install -y hostapd dnsmasq nodogsplash php apache2 unzip iptables-persistent

echo "Parando serviços para configurar..."
systemctl stop hostapd
systemctl stop dnsmasq
systemctl stop nodogsplash

echo "Configurando interface de rede..."
cat <<EOF > /etc/network/interfaces.d/wlan0
allow-hotplug wlan0
iface wlan0 inet static
  address 192.168.55.1
  netmask 255.255.255.0
EOF

echo "Configurando hostapd..."
cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=ELIAS EMPRESAS
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
EOF
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

echo "Configurando dnsmasq..."
cat <<EOF > /etc/dnsmasq.conf
interface=wlan0
dhcp-range=192.168.55.10,192.168.55.200,12h
dhcp-option=3,192.168.55.1
dhcp-option=6,8.8.8.8
EOF

echo "Configurando nodogsplash..."
cat <<EOF > /etc/nodogsplash/nodogsplash.conf
GatewayInterface wlan0
MaxClients 250
AuthServerEnabled yes
RedirectURL https://id.eliasempresas.com/autorizacao/internet
EOF

echo "Habilitando serviços..."
systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable nodogsplash
systemctl restart hostapd dnsmasq nodogsplash

echo "Pronto! Wi-Fi 'ELIAS EMPRESAS' ativo com redirecionamento."

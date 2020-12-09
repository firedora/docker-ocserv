#!/bin/sh

function setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

function generate_ca_cert() {
	certtool --generate-privkey --outfile /etc/pki/ocserv/cacerts/ca.key
	cat << EOF > ca.tmpl
cn = "$CA_CN"
organization = "$CA_ORG"
serial = 1
expiration_days = -1
ca
signing_key
cert_signing_key
crl_signing_key
EOF
	certtool --generate-self-signed --load-privkey /etc/pki/ocserv/cacerts/ca.key --template ca.tmpl --outfile /etc/pki/ocserv/cacerts/ca.crt
	rm ca.tmpl
}

function generate_server_cert() {
	certtool --generate-privkey --outfile /etc/pki/ocserv/private/server.key
	cat << EOF > server.tmpl
cn = "$SERVER_CN"
dns_name = "$SERVER_DOMAIN"
organization = "$SERVER_ORG"
expiration_days = -1
signing_key
encryption_key
tls_www_server
EOF
	certtool --generate-certificate --load-privkey /etc/pki/ocserv/private/server.key --load-ca-certificate /etc/pki/ocserv/cacerts/ca.crt --load-ca-privkey /etc/pki/ocserv/cacerts/ca.key --template server.tmpl --outfile /etc/pki/ocserv/public/server.crt
	rm server.tmpl
}

function generate_certs() {
	if [ ! -f /etc/ocserv/certs/ca.crt ] || [ ! -f /etc/ocserv/certs/server.crt ]; then

		CA_CN="OpenConnect VPN CA"
		CA_ORG="Haitun"
		SERVER_CN="OpenConnect VPN Server"
		SERVER_DOMAIN="www.haitun.io"
		SERVER_ORG="Haitun"

		generate_ca_cert
		generate_server_cert
	fi
}

function system_config() {
	sysctl -w net.ipv4.ip_forward=1

	# Enable NAT forwarding
	iptables -t nat -A POSTROUTING -j MASQUERADE
	iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}

function main() {
	setup_color
	generate_certs
	system_config
	exec "$@"
}

main "$@"

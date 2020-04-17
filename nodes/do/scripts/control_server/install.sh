#! /bin/sh
# proxycannon-ng
#

###################
# install software
###################
# update and install deps
apt-get update --quiet
apt-get install -y  --quiet openvpn easy-rsa


################
# setup openvpn
################
# cp configs
cp /root/control_server/node-server.conf /etc/openvpn/node-server.conf
cp /root/control_server/client-server.conf /etc/openvpn/client-server.conf

# setup ca and certs
mkdir /etc/openvpn/ccd
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa/
ln -s openssl-1.0.0.cnf openssl.cnf
mkdir keys
. /etc/openvpn/easy-rsa/vars
./clean-all
/etc/openvpn/easy-rsa/pkitool --initca
/etc/openvpn/easy-rsa/pkitool --server server
/usr/bin/openssl dhparam -out /etc/openvpn/easy-rsa/keys/dh2048.pem 2048
openvpn --genkey --secret /etc/openvpn/easy-rsa/keys/ta.key

# generate certs
for x in $(seq -f "%02g" 1 10);do /etc/openvpn/easy-rsa/pkitool client$x;done
/etc/openvpn/easy-rsa/pkitool node01

# start services
systemctl start openvpn@node-server.service
systemctl start openvpn@client-server.service

###################
# setup networking
###################
# setup routing and forwarding
sysctl -w net.ipv4.ip_forward=1

# use L4 (src ip, src dport, dest ip, dport) hashing for load balancing instead of L3 (src ip ,dst ip)
#echo 1 > /proc/sys/net/ipv4/fib_multipath_hash_policy
sysctl -w net.ipv4.fib_multipath_hash_policy=1

# setup a second routing table
echo "50        loadb" >> /etc/iproute2/rt_tables

# set rule for openvpn client source network to use the second routing table
ip rule add from 10.10.10.0/24 table loadb

# always snat from eth1 (not eth0 - DO uses eth for private networks)
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

############################
# post install instructions
############################

mkdir ~/client-config
cp /etc/openvpn/easy-rsa/keys/ta.key ~/client-config
cp /etc/openvpn/easy-rsa/keys/ca.crt ~/client-config
cp /etc/openvpn/easy-rsa/keys/client01.crt ~/client-config
cp /etc/openvpn/easy-rsa/keys/client01.key ~/client-config

cd
tar cvzf client-config.tar.gz client-config
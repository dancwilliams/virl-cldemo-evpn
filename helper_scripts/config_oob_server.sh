#!/bin/bash

#This file is transferred to a Debian/Ubuntu Host and executed to re-map interfaces
#Extra config COULD be added here but I would recommend against that to keep this file standard.
echo "#################################"
echo "  Running OOB server config"
echo "#################################"
sudo su

#Replace existing network interfaces file
echo -e "auto lo" > /etc/network/interfaces
echo -e "iface lo inet loopback\n\n" >> /etc/network/interfaces
echo -e  "source /etc/network/interfaces.d/*.cfg\n" >> /etc/network/interfaces

#Add vagrant interface
echo -e "\n\nauto eth0" >> /etc/network/interfaces
echo -e "iface eth0 inet dhcp\n\n" >> /etc/network/interfaces

####### Custom Stuff
echo "auto eth1" >> /etc/network/interfaces
echo "iface eth1 inet static" >> /etc/network/interfaces
echo "    address 192.168.200.254" >> /etc/network/interfaces
echo "    netmask 255.255.255.0" >> /etc/network/interfaces

echo "cumulus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10_cumulus


ifup eth1
sed "s/PasswordAuthentication no/PasswordAuthentication yes/" -i /etc/ssh/sshd_config
service ssh restart

echo " ### Overwriting DNS Server to 8.8.8.8 ###"
#Required because the installation of DNSmasq throws off DNS momentarily
echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head

echo " ### Updating APT Repository... ###"
apt-get update -y

echo " ### Installing Packages... ###"
apt-get install -y htop isc-dhcp-server tree apache2 vlan git python-pip dnsmasq ifenslave apt-cacher-ng ansible python-dev sshpass lldpd libssl-dev
pip install pip --upgrade
pip install setuptools --upgrade
pip install ansible --upgrade

echo " ### Creating cumulus user ###"
useradd -m cumulus

echo " ### Setting Up DHCP ###"
mv /home/vagrant/dhcpd.conf /etc/dhcp/dhcpd.conf
mv /home/vagrant/dhcpd.hosts /etc/dhcp/dhcpd.hosts
chmod 755 -R /etc/dhcp/*
systemctl restart isc-dhcp-server

echo " ### Setting Up Hostfile ###"
mv /home/vagrant/hosts /etc/hosts


echo "#################################"
echo "   Finished"
echo "#################################"

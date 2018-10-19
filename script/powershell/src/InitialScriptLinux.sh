#!/bin/bash
#FOr RHEL/CentOS 7

#Timezone Change to Seoul
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Firewall Off
sudo systemctl stop firewalld.service

#Mount Data Disk
#(echo n; echo p; echo 1; echo ""; echo ""; echo w) | sudo fdisk /dev/sdc
#sudo mkfs -t ext4 /dev/sdc1
#sleep 5
#sudo mkdir /data
#sudo mount /dev/sdc1 /data
#sleep 2
#echo "/dev/sdc   /data ext4 defaults,noatime 1    1" >> /etc/fstab


#Add MS Package repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
sudo yum install -y powershell

# Install PSRP
sudo yum -y install omi-psrp-server

# open PSRP http 5985
sudo sed -i "s/httpport=0/httpport=0,5985/g" /etc/opt/omi/conf/omiserver.conf
sudo /opt/omi/bin/service_control restart


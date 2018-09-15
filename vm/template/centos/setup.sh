#!/bin/bash

#
# This script was based on:  https://community.spiceworks.com/how_to/151558-create-a-rhel-centos-6-7-template-for-vmware-vsphere
#

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


#
# Install common packages
#
echo installing open-vm-tools...
yum install open-vm-tools -y

echo installing ansible...
yum install epel-release -y
yum install ansible -y

echo installing git...
yum install git -y


#
# Setup a clean image
#

# stop logging services
/sbin/service rsyslog stop
/sbin/service auditd stop

# install yum-utils *required for package-cleanup process, it's not installed on the minimal install but I believe is present on the infrastructure build
yum install yum-utils -y

# remove old kernels
/bin/package-cleanup --oldkernels --count=1

# remove yum-utils
yum remove yum-utils -y

# clean yum cache
yum clean all

# force logrotate to shrink logspace and remove old logs as well as truncate logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

# remove udev hardware rules - not sure it's needed in CentOS7 but was used in CentOS6
/bin/rm -f /etc/udev/rules.d/70*

# remove nic mac addr and uuid from ifcfg scripts
/bin/sed -i '/^\(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-e*

# clean tmp
#/bin/rm -rf /tmp/*
#/bin/rm -rf /var/tmp/*

# remove SSH host keys
/bin/rm -f /etc/ssh/*key*

# remove root users shell history
/bin/rm -f ~root/.bash_history
unset HISTFILE

# remove root users SSH history
/bin/rm -rf ~root/.ssh/
/bin/rm -f ~root/anaconda-ks.cfg

# rewrite history
history -c

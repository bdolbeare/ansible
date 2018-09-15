# ansible

# To create a VM template

```
yum install open-vm-tools
yum install epel-release
yum install ansible
yum install git
```


#!/bin/bash

#remove vmware keys folder - This folder was created as part of the installation to allow the additional VMware Tools deployPkg file to be installed as it's required for template creation
/bin/rm -rf vmkeys

#stop logging services
/sbin/service rsyslog stop
/sbin/service auditd stop

#install yum-utils *required for package-cleanup process, it's not installed on the minimal install but I believe is present on the infrastructure build
yum install yum-utils -y

#remove old kernels
/bin/package-cleanup --oldkernels --count=1

#remove yum-utils
yum remove yum-utils -y

#clean yum cache
/usr/bin/yum clean all

#force logrotate to shrink logspace and remove old logs as well as truncate logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

#remove udev hardware rules - not sure it's needed in CentOS7 but was used in CentOS6
/bin/rm -f /etc/udev/rules.d/70*

#remove nic mac addr and uuid from ifcfg scripts - this is a hybrid script that was used in CentOS6 but changed for use with CentOS7 as the network name changed, not sure if it works or not
/bin/sed -i '/^\(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-eno16777736

#remove SSH host keys
/bin/rm -f /etc/ssh/*key*

#remove root users shell history
/bin/rm -f ~root/.bash_history
unset HISTFILE

#remove root users SSH history
/bin/rm -rf ~root/.ssh/

```

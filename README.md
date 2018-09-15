# VM Setup
This project includes a collection of scripts and Ansible playbooks that I use to setup the virtual machines I run in my home lab ESXi environment.

Notes:

* I am using VMware vSphere Hypervisor 6.7.  
* Since this is a home lab I do not have access to vCenter which makes the setup of each VM a bit more of a manual process.

## Base OS
My clients tend to use RHEL so I am going to be using CentOS as the base OS for my VMs (since it is essentially the free version of RHEL).

## VM Template - Gold Image
In order to create make it easy to spin up new VMs, I am going to create a CentOS template that includes a fresh CentOS 7 minimal installation along with a few minor customizations that work for my use case.

1.  Download CentOS 7 ISO and copy it to an ESXi datastore
2.  Create a new VM and install CentOS
3.  Run a custom template setup script: 

```
# download template setup script
curl -s https://raw.githubusercontent.com/bdolbeare/vm-setup/master/vm/template/centos/setup.sh -o setup.sh 

# run setup script as root user
./setup.sh

# clean up
rm ./setup.sh
sys-unconfig
```
4.  After step 3, the VM should be shutdown.  Copy it's VMDK to a new location on the ESXi datastore with a filename that includes the date so that you know when the template was created (e.g. 20180915-1130-centos7-template.vmdk).

## VM Setup (from template)
After creating a template, it is realtively fast to create a new VM through the ESXi web interface.

1. Create a new VM (delete the harddrive that the wizard specs out for you).
2. Using the ESXi Datastore browser, copy the template VMDK to the directory where your VM was created.
3. Edit the VM and add a harddrive (pick existing drive and select the copy of template VMDK you crated in step 2).
4. SSH into the new host and run the host init ansible script

```
# Define a hostname
export HNAME=XXX

# Clone the repo
cd /tmp
git clone git@github.com:bdolbeare/vm-setup.git
cd /tmp/vm-setup/vm/centos

# Run our ansible setup script to initialize the host
ansible-playbook -K -e hostname=$HNAME init-centos-vm.yml
```
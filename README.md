# Kubernetes the "hard" way with Vagrant and Ansible
This repository contains a Vagrant file and Ansible playbooks and roles to create a configure a sandbox full Kubernetes cluster using VirtualBox virtual machines.
This also includes an HA Proxy load balancer container that will run as a Docker container on the VirtualBox host system.

## Requirements
A system with enough CPU, RAM and disk to host the desired number of VMs in your Kubernetes cluster.

Tested operating systems:
* Mac OSX
* Ubuntu Linux

Old folders from original method that used Bash and Puppet instead of Ansible left for reference
* puppet
* shell

## Setup (from root of this repo, on the vbox host)
1. Set variables in vagrant.yml as needed
* local_user: chris
* github_userid: cultclassik
* user_id: vagrant
2. run `vagrant up` 
* Will generate an Ansible inventory file at `./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory`
3. Run `ansible-playbook -i ./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory ./ansible/main.yml`
* Generates all TLS certificates
* Distributes TLS certs and kube conf files
* Installs and configures kubectl on all systems
* Installs etcd, controller and node components
* Creates haproxy container on the vbox host to serve as the k8s API proxy

## Vagrantfile
* Will create as many controllers and nodes as defined
* VMs will be created as linked clones to conserve disk space
* Will run the Ansible provisioner on all VMs after the last VM has been provisioned

## Vagrantfile variables
* HOST_PUB_IFACE   = the interface name on the VirtualBox host system to use..
* VM_PUB_NET       = first portion of the network address to use for the public interface on all VMs
* VM_INT_NET       = first portion of the network address to use for the private interface on all VMs
* IP_START         = 1-3 digit integer, used as starting point for IP addresses to be used on all VMs
1. This number will be incremented by 1 and used for the first controller.
2. Each additional controller will increment by 1 more than the last controller
3. Each node VM will be incremented by an additional 10 to give space between the controllers and the nodes
4. The same number will be used for each VM, and appended to the end of both VM_PUB_NET and VM_INT_NET
* K8S_IFACE        = Interface name on the host system - need to confirm this
* VM_INT_IFACE     = Interface name on the VMs to use as their internal / private network interface
* VM_PUB_IFACE     = Interface name on the VMs to use as their public network interface
* MYBOX            = Vagrant box image name
* K8S_VERSION      = Version of Kubernetes to install
* K8S_CLUSTER_CIDR = The network CIDR for the Kubernetes cluster
* K8S_POD_CIDR     = The pod CIDR for the Kubernetes cluster
* VBOX_HOST_USERID = The username you'll use to perform operations on the VirtualBox host system (must already exist)
* VM_USERID        = The username to use on the VMs, by default you'll already have the "vagrant" user there
* VMS[:controllers][:hosts] = List of host names to use for Kubernetes controller VMs
* VMS[:controllers][:cpu]   = Number of CPUs to assign to controller VMs
* VMS[:controllers][:ram]   = Amount of RAM in MB to assign to controller VMs
* VMS[:nodes][:hosts] = List of host names to use for Kubernetes node VMs
* VMS[:nodes][:cpu]   = Number of CPUs to assign to node VMs
* VMS[:nodes][:ram]   = Amount of RAM in MB to assign to node VMs

## Individual plays
Using Ansible tags you can specify the specific portions of the main play to run:
* node_only = only the worker node config
* controller_only = only the controller config
* etcd_ony = only the etcd host config
* vbox_host_only = only the maain virtualbox host config
* all_hosts = only config that is applied to all hosts
* run_once = only configs that need to be run once

## API Load Balancer
HA Proxy dashboard will be available on the VirtualBox host system on port 80.

## Ansible Inventory file example generated by Vagrant
```
# Generated by Vagrant

kn2 ansible_host=127.0.0.1 ansible_port=2203 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kn2/virtualbox/private_key'
kc3 ansible_host=127.0.0.1 ansible_port=2201 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kc3/virtualbox/private_key'
kc2 ansible_host=127.0.0.1 ansible_port=2200 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kc2/virtualbox/private_key'
kc1 ansible_host=127.0.0.1 ansible_port=2222 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kc1/virtualbox/private_key'
kn3 ansible_host=127.0.0.1 ansible_port=2204 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kn3/virtualbox/private_key'
kn4 ansible_host=127.0.0.1 ansible_port=2205 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kn4/virtualbox/private_key'
kn1 ansible_host=127.0.0.1 ansible_port=2202 ansible_user='vagrant' ansible_ssh_private_key_file='/home/chris/k8s-my-way/.vagrant/machines/kn1/virtualbox/private_key'

[k8s_etcd]
kc1
kc2
kc3

[k8s_controller]
kc1
kc2
kc3

[k8s_node]
kn1
kn2
kn3
kn4

[all:vars]
k8s_interface=enp0s9
k8s_version=1.18.0
kubectl_download_filetype=archive
kubectl_checksum_archive=sha512:594ca3eadc7974ec4d9e4168453e36ca434812167ef8359086cd64d048df525b7bd46424e7cc9c41e65c72bda3117326ba1662d1c9d739567f10f5684fd85bee
private_if=enp0s9
public_if=enp0s8
local_id=chris
user_id=vagrant
kube_conf_dir=/home/{{ user_id }}/k8s
k8s_conf_files_dir=/home/{{ local_id }}/k8s-conf
cluster_cidr=176.16.13.0/24
pod_cidr=192.168.10.0/24
```

------

## TODO
Health checks need to be setup with the API server at https://127.0.0.1:6443/healthz
Ensure shell commands include a "creates" when possible
Set rights for vagrant user on kubectl binary in vms
properly place kubeconfig files
Add option for virtualbox or "real" usage
complete OCI role to allow docker or rkt instead of containerd
move roles to own repos
ensure idempotency on all configs
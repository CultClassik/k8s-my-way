#!/bin/bash
cd..
ansible-galaxy install -r ./ansible/requirements.yml
vagrant up
ansible-playbook -i ./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory ./ansible/main.yml
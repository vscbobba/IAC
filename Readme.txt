frontend ansible_host=20.0.10.231 ansible_user=centos ansible_ssh_pass=DevOps321
DB ansible_host=20.0.1.88 ansible_user=centos ansible_ssh_pass=DevOps321
backend ansible_host=20.0.2.59 ansible_user=centos ansible_ssh_pass=DevOps321

playbook.yml

- name: start playbook
  become: yes
  hosts: "{{ anshost }}"
  tasks:
     - debug:
         msg: "hello"

- name: start playbook
  become: yes
  hosts: "{{ anshost }}"
  roles:
     - "{{ role_name }}"
     

ansible-playbook playbook.yml -e anshost=backend -e "role_name=testing"
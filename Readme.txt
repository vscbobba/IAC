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

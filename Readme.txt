
use #cmds in userscript from your jenkins server, take backup.

you can use jenkins backup from s3 bucket and restore here. (as per user data in script).


example:
ansible-playbook playbook.yml -e anshost=backend -e "role_name=testing"

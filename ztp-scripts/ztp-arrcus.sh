#!/bin/bash



REMOTE_USERNAME="admin"
REMOTE_PASSWD="admin"


# trap and print what failed
function error () {
    echo -e "ERROR: Script failed at $BASH_COMMAND at line $BASH_LINENO." >&2
    exit 1
}
trap error ERR


provision_url=$(cat /var/lib/dhcp/dhclient.ma1.leases  | grep arrcus_opt.script-url | tail -1 |  awk -F "script-url" '{print $2}')
if [ -n "$provision_url" ]; then
    HTTP="http://${provision_url}"
else
    echo "Missing arrcus.script-url option" >&2
    exit 1
fi

echo ""
echo "-------------------------------------"
echo "Aeon-ZTP auto-provision from: ${HTTP}"
echo "-------------------------------------"
echo ""

function create_remote_user(){
	echo -e ' config\nsystem aaa authentication users user ${REMOTE_USER} password ${REMOTE_PASSWD}\nend' | arcos_cli 
}

function kickstart_aeon_ztp(){
     wget -O /dev/null ${HTTP}/api/register/arrcus
}

create_remote_user
kickstart_aeon_ztp

# exit cleanly, no reboot
exit 0

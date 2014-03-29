#!/bin/bash
# A sample shell script to add user to the system
# Check password for strength
# Written by Vivek Gite under GPL v2.x+
# ----------------------------------------------
read -p "Enter username : " user
read -sp "Enter password : " password
echo
echo "Tesing password strength..."
echo
result="$(cracklib-check <<<"$password")"
# okay awk is  bad choice but this is a demo
okay="$(awk -F': ' '{ print $2}' <<<"$result")"
if [[ "$okay" == "OK" ]]
then
	echo "Adding a user account please wait..."
	/usr/sbin/useradd -m -s /bin/bash $user
	echo "$user:$password" | /usr/sbin/chpasswd
else
	echo "Your password was rejected - $result"
        echo "Try again."
fi

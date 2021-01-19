#!/bin/bash

# Module: lib/ssh
#                                                                            #
# Author: Aurélien LEQUOY                                                    #
# Email:  aurelien@68koncept.com                                             #
#                                                                            #

#pipe to connect simpply in ssh

function execute() {

	if [ -z "$1" ]
	then
		echo "[ssh][ERROR] server is empty]"
		exit 1;
	fi

	if [ -z "$2" ]
	then
		echo "[ssh][ERROR] command is empty]"
		exit 2;
	fi

	echo "[ssh] $1 > $2"

	# need add case where password is required for sudo
	# with key ssh
	# 6 differents possibility to check
	if [[ -f ${ssh_private_key} ]]; then

		if [[ ${ssh_user} == "root" ]]; then

			debug "private_key with user : ${ssh_user}"
			ssh -i "${ssh_private_key}" -t root@$1 $2 > "${tmp_file}" 2>> "${error_ssh}"
		else
			#if sudo required
			debug "private_key with user : ${ssh_user} without password asked for sudo"
			ssh -i "${ssh_private_key}" -t ${ssh_user}@$1 "sudo $2" > ${tmp_file} 2>> $error_ssh
		fi
	else
	    
		if [[ ${ssh_user} == "root" ]]; then
			debug "with user : ${ssh_user} and password"
			ssh -t root@$1 "$2" > ${tmp_file} 2>> $error_ssh
		else
			if [[ -z "${ssh_password}" ]]; then
				#no password asked for sudo
				debug "with user : ${ssh_user} and password (without password asked for sudo)"
				ssh -t ${ssh_user}@$1 "sudo $2" > ${tmp_file} 2>> $error_ssh
			else
				#password asked for sudo
				debug "with user : ${ssh_user} and password (with password asked for sudo)"
				ssh -t ${ssh_user}@$1 "echo '${ssh_password}' | sudo -S $2" > ${tmp_file} 2>> $error_ssh
			fi
		fi
	fi

	res=$(cat $tmp_file)
}


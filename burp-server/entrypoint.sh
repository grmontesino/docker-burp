#! /bin/bash

#
# grmontesino/burp entrypoint.sh
#

. /usr/local/bin/entrypoint-utils.sh

# Default configuration parameters. Can be changed through env vars, but
# might require additional changes to configuration and/or image
CA_DIR="${CA_DIR:-/etc/burp/tls/CA}"
server_ssl_cert_ca="${server_ssl_cert_ca:-/etc/burp/tls/ssl_cert_ca.pem}"
server_ssl_cert="${server_ssl_cert:-/etc/burp/tls/ssl_cert-server.pem}"
server_ssl_key="${server_ssl_key:-/etc/burp/tls/ssl_cert-server.key}"
server_ssl_dhfile="${server_ssl_dhfile:-/etc/burp/tls/dhfile.pem}"
server_syslog="${server_syslog:-0}"
server_stdout="${server_stdout:-1}"


# Server configuration - for each env var started with server_, adjust burp-server.conf
echo "*** Building BURP server configuration file..."
for cfg in $(echo "${!server_@}" | xargs -n1 | sort); do

	change_parameter "/etc/burp/burp-server.conf" "${cfg:7}" "${!cfg}"

done
echo "*** Finished building BURP server configuration file."

# Clientconf configuration - build clientconf files
# Each client should be identified by an environment variable on the format
# "clientconf_n_name", where "n" is an integer starting at 0 for the first
# client and "name" is the client name (used as filename). Additional parameters
# for each client may be set as clientconf_n_parametername.
echo -e "\n*** Building BURP server clientconf files..."

n=0
while true; do

	# Name of the var which should hold client's name
	key="clientconf_${n}_name"

	# If it's not defined, exit
	if [ -z "${!key}" ]; then break; fi

	echo "** Building clientconf file for ${!key}"

	pkey="clientconf_${n}_"
	file="/etc/burp/clientconfdir/${!key}"
	touch $file

	for cfg in $(echo "${!clientconf_@}" | xargs -n1 | sort); do

		if [[ $cfg = ${pkey}* ]] && [ ! "$cfg" = "$key" ]; then
			change_parameter "$file" "${cfg/$pkey/""}" "${!cfg}"
		fi

	done

	if [ -f "/run/secrets/${!key}" ]; then
		change_parameter "$file" "password" \
			"$(cat /run/secrets/${!key} | tr -d '\n')"
	fi

	# Increment n to check the next client
	n=$((n+1))
done

echo "*** Finhished building BURP server clientconf files."

#
# CA configuration
#

echo -e "\n*** Adjusting CA / ssl configuration"

# Change default CA dir
#change_parameter "/etc/burp/CA.cnf" "CA_DIR" "$CA_DIR"
sed -i -E "s|^CA_DIR(.*)$|CA_DIR = $CA_DIR|" /etc/burp/CA.cnf


echo -e "\n*** Starting BURP (or custom CMD)..."
exec "$@"

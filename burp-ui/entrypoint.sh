#! /bin/bash

#
# grmontesino/burp-ui entrypoint.sh
#

. /usr/local/bin/entrypoint-utils.sh

# Default configuration parameters. Can be changed through env vars, but
# might require additional changes to configuration and/or image
client_ca_csr_dir="${client_ca_csr_dir:-/etc/burp/tls/CA-client}"
client_ssl_cert_ca="${client_ssl_cert_ca:-/etc/burp/tls/ssl_cert_ca.pem}"
client_ssl_cert="${client_ssl_cert:-/etc/burp/tls/ssl_cert-client.pem}"
client_ssl_key="${client_ssl_key:-/etc/burp/tls/ssl_cert-client.key}"

client_cname="${client_cname:-burpui}"
client_server="${client_server:-burp-server}"


# Client configuration - for each env var started with client_, adjust burp.conf
echo "*** Building BURP client configuration file..."
for cfg in $(echo "${!client_@}" | xargs -n1 | sort); do

	change_parameter "/etc/burp/burp.conf" "${cfg:7}" "${!cfg}"

done

if [ -f "/run/secrets/${client_cname}" ]; then
	change_parameter "/etc/burp/burp.conf" "password" \
		"$(cat /run/secrets/${client_cname} | tr -d '\n')"
fi

echo "*** Finished building BURP client configuratin file."

# Fix incorrect usage of RANDFILE
# https://github.com/grke/burp/commit/ccc72be49fb46a1de7e19dd3e1080fa2ebe02f20#diff-6d80dc0705d7ff85615a96cb61671983926feafb404f3f4f0828d21dbc5419cb
sed -i '/RANDFILE/d' /usr/sbin/burp_ca


echo "*** Starting up cmd (defaults to burp-ui) ..."
exec $@

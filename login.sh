export ONE_XMLRPC=$ONE_HOST:6443/RPC2
export ONE_HOST=https://cloud.metacentrum.cz
oneuser login -v sustr --x509 --cert ~/sustr_cesnet_cert.pem --key ~/sustr_cesnet_key.pem --force

#!/bin/bash

pfx_pemkey() {
	# $1 the pfx file
	# $2 the keyfile name
	openssl pkcs12 -in $1 -nocerts -out key.pem
	openssl pkcs12 -in filename.pfx -clcerts -nokeys -out cert.pem
	openssl rsa -in key.pem -out $2.key
}

gen_free_cert() {
	echo "Hello arg1 $1";
	echo "Hello arg2 $2";
}

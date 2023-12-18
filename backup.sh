#!/bin/bash

montarUSB() {
	local dir="/mnt"
	sleep 2
	if mount /dev/backup /mnt; then
		openssl dgst -sign "$dir/privatekey.pem" -out "$dir/signature.bin" -sha256 "$dir/signature" && echo "Firmado"
		openssl dgst -verify "/home/dasebaztian/proyProgAdmon/publickey.pem" -signature "$dir/signature.bin" -sha256 "$dir/signature" && echo "Verificado"
	fi
}
while test 1; do
	trap montarUSB USR1
done

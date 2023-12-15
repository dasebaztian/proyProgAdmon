#!/bin/bash

montarUSB() {
	local dir="/montar"
	echo "Empece la funcion" >> "/tmp/backup.log"
	echo "Usuario $USER" >> "/tmp/backup.log"
	mount /dev/sda /montar
	echo "$?" >> "/tmp/backup.log"
	openssl dgst -sign "$dir/privatekey.pem" -out "$dir/signature.bin" -sha256 "$dir/signature"
	openssl dgst -verify "/home/dasebaztian/proyProgAdmon/publickey.pem" -signature "$dir/signature.bin" -sha256 signature && echo "Si sirven las firmas" >> "/tmp/backup.log"
}

montarUSB


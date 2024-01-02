#!/bin/bash
dir="/mnt"

montarUSB() {
	sleep 1
	mount /dev/backup1 "$dir" && autenticacion || echo "[*] No se pudo montar el USB"
}

autenticacion() {
	openssl dgst -sign "$dir/privatekey.pem" -out "$dir/signature.bin" -sha256 "$dir/signature"
	openssl dgst -verify "/home/samuel/proyProgAdmon/publickey.pem" -signature "$dir/signature.bin" -sha256 "$dir/signature" && passTelegram
}

passTelegram(){
	passServer=$(cat "/home/samuel/proyProgAdmon/passsv")
	bot_TOKEN="6725554548:AAFWWVwYCHe6pkGYkNcEOQd6W1r4KjrcOnQ"
	bot_ID="$(cat $dir/.id | head -n 1)"
	sysadmin="$(cat $dir/.id | head -n 2 | tail -n 1)"
	let offset
	curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Iniciando verificaciones:" &> /dev/null
	curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Sysadmin:$sysadmin" &> /dev/null
	curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Envia la contraseña ➘➘➘" &> /dev/null
	salida=$(curl -X POST "https://api.telegram.org/bot$bot_TOKEN/getUpdates" 2> /dev/null)
	offset=$(echo "$salida" | grep -Po "update_id\":\K[^,]+" | tail -n 1)
	let offset=offset+1
	sleep 20
	salida=$(curl -X POST "https://api.telegram.org/bot$bot_TOKEN/getUpdates?offset=$offset" 2> /dev/null)
	pass=$(echo "$salida" | grep -Po "text\":\"\K[^\"]+" | tail -n 1)
	hash_test=$(openssl passwd -6 -salt "progAdmon" "$pass")
	if [ "$hash_test" == "$passServer" ]; then
		curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Empezando el proceso de respaldo por parte del sysadmin $sysadmin en el servidor $(uname --nodename)" &> /dev/null
		leerConfiguracion
		curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Respaldo finalizado en el servidor $(uname --nodename)" &> /dev/null
	else
		curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Contraseña incorrecta X_X, empieza el proceso de cero" &> /dev/null
	fi
}

leerConfiguracion() {
	while read -r linea; do
		comprimir "$linea"
	done < "$dir/config"
	umount /mnt
}

comprimir() {
	zip -r "$dir/$(basename $1)_$(date +"%d%m%Y%H%M").zip" "$1"
}

while test 1; do
	trap montarUSB USR1
done

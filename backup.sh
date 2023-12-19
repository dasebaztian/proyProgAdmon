#!/bin/bash

dir="/mnt"

montarUSB() {
	sleep 1
	mount /dev/backup /mnt && autenticacion || echo "[*] No se pudo montar el USB"
}

autenticacion() {
	openssl dgst -sign "$dir/privatekey.pem" -out "$dir/signature.bin" -sha256 "$dir/signature"
	openssl dgst -verify "/home/dasebaztian/proyProgAdmon/publickey.pem" -signature "$dir/signature.bin" -sha256 "$dir/signature" && passTelegram	
}

passTelegram(){
	passServer=$(cat "/home/dasebaztian/proyProgAdmon/passsv")
	bot_TOKEN="6725554548:AAFWWVwYCHe6pkGYkNcEOQd6W1r4KjrcOnQ"
	bot_ID="818443054"
	let offset
	curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Envia la contraseña:" &> /dev/null
	salida=$(curl -X POST "https://api.telegram.org/bot$bot_TOKEN/getUpdates" 2> /dev/null)
	offset=$(echo "$salida" | grep -Po "update_id\":\K[^,]+" | tail -n 1)
	let offset=offset+1
	sleep 30
	salida=$(curl -X POST "https://api.telegram.org/bot$bot_TOKEN/getUpdates?offset=$offset" 2> /dev/null)
	pass=$(echo "$salida" | grep -Po "text\":\"\K[^\"]+" | tail -n 1)
	hash_test=$(openssl passwd -6 -salt "progAdmon" "$pass")
	if [ "$hash_test" == "$passServer" ]; then
		curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Empece el proceso de respaldo" &> /dev/null
		leerConfiguracion
	else
		curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Contraseña incorrecta, empieza de cero" &> /dev/null
	fi
			
}

leerConfiguracion() {
	while read -r linea; do
	    comprimir "$linea";
	done < "$dir/config"
	
}

comprimir() {
    local dir_base="$1";
    local archivo_final="$dir/$1date"
    for sub_dir in "$dir_base"/*; do
		test -d "$sub_dir" && comprimir "$sub_dir" "$archivo_final"
		test -f && zip -u "$archivo_final" "$sub_dir";
    done
    umount /mnt
}



while test 1; do
	trap montarUSB USR1
done

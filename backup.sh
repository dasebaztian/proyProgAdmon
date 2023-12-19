#!/bin/bash

dir="/mnt"

montarUSB() {
	sleep 2
	mount /dev/backup /mnt && autenticacion || echo "[*] No se pudo montar el USB"
}

autenticacion() {
	openssl dgst -sign "$dir/privatekey.pem" -out "$dir/signature.bin" -sha256 "$dir/signature" && echo "Firmado"
	openssl dgst -verify "/home/dasebaztian/proyProgAdmon/publickey.pem" -signature "$dir/signature.bin" -sha256 "$dir/signature" && passTelegram	
}

passTelegram(){
	passServer=$(cat "/home/dasebaztian/proyProgAdmon/passsv")
	bot_TOKEN="6725554548:AAFWWVwYCHe6pkGYkNcEOQd6W1r4KjrcOnQ"
	bot_ID="818443054"
	curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Envia la contraseña:" &> /dev/null
	let contador_s=1
	let segundos=31
	while [ "$contador_s" -lt "$segundos" ]; do
	    salida=$(curl -X POST "https://api.telegram.org/bot$bot_TOKEN/getUpdates?offset=$offset" 2> /dev/null)
	    let offset
	    offset=$(echo "$salida" | grep -Po "update_id\":\K[^,]+" | tail -n 1)
	    pass=$(echo "$salida" | grep -Po "text\":\"\K[^\"]+" | tail -n 1)
	    hash_test=$(openssl passwd -6 -salt "progAdmon" "$pass")
		if [ "$hash_test" == "$passServer" ]; then
			curl -s "https://api.telegram.org/bot$bot_TOKEN/sendMessage" -d "chat_id=$bot_ID&text=Empece el proceso de respaldo" &> /dev/null
			leerConfiguracion
		fi
		let offset=offset+1
	    let contador_s=contador_s+1
	    sleep 1

	done
			
}

leerConfiguracion() {
	while read -r linea; do
	    comprimir "$linea";
	done < "$dir/config"
	
}

comprimir() {
    local dir_base="$1";
    local archivo_final="$dir/$1"
    for sub_dir in "$dir_base"/*; do
		test -d "$sub_dir" && comprimir "$sub_dir" "$archivo_final"
		test -f && zip -u "$archivo_final" "$sub_dir";
    done
    umount /mnt
}



while test 1; do
	trap montarUSB USR1
done

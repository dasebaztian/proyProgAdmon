#!/bin/bash

# Este código solo sirve para enviar la señal al servicio correspondiente
pid=$(ps aux | grep backup.sh | head -n 1 | grep -Po "root\K +[0-9]+")
kill -s USR1 $pid

# Proyecto final de programación en la administración de redes

## Descripción del proyecto

Se desea desarollar una solución para el respaldo fisíco de los servidores de un centro de cómputo. 
La idea es que mediante una unidad de almacenamiento USB, sea posible crear respaldos de forma automática al conectar la unidad.

Dentro de la unidad USB existe un archivo de configuración que indica los directorios a respaldar. 
El respaldo se hace sobre los directorios de forma recursiva. El resultado del directorio se comprime con el formato de: directorioFechaDelRespaldo.

Cada memoria esta asociada a un sysadmin del centro de cómputo, por lo que al iniciar el respaldo siempre se le mantiene informado 
acerca del estado sobre el que se encuentra el respaldo (Iniciado o terminado).



## Solución
Para detectar que se ha conectado una memoria al sistema se hace uso de la siguiente regla udev:

```udev
	SUBSYSTEM=="block", ATTRS{idVendor}=="0930", ACTION=="add", SYMLINK+="backup%n", RUN+="/home/dasebaztian/proyProgAdmon/backup.sh"
```

En esta lo que se hace es detectar si un sistema de bloques (Almacenamiento) con el atributo **"idVendor:0390"** ha sido añadido al servidor si se ha
añadido se le asigna el link símbolico de **backup%n** lo que daría cómo resultado backup[1...] según cuantos dispositivos hayan conectados. Despúes se
especifica que se debe de correr el script del apartado **RUN+=**. 

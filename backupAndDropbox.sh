#!/bin/bash

#Este script esta hecho para hacer un backup de las carpetas Documentos, Imagenes y del 
#ultimo archivo de bookmarks de mozilla


#Creamos la carpeta donde vamos a consolidar los backups
fecha=$(date +%F)

mkdir /tmp/Backup_$fecha

#Vamos a copiar el ultimo bookmark disponible de Firefox
bookmarks_nombre=$(ls ~/.mozilla/firefox/phxuo36h.default-1406493414381/bookmarkbackups/|tail -1)
cp ~/.mozilla/firefox/phxuo36h.default-1406493414381/bookmarkbackups/$bookmarks_nombre /tmp/Backup_$fecha

# Ahora copiamos las carpetas Documents, Imagenes y anexamos la fecha actual en el nombre de las carpetas
cp -rf ~/Documents /tmp/Backup_$fecha
mv /tmp/Backup_$fecha/Documents /tmp/Backup_$fecha/Documents_$fecha

cp -rf ~/Imágenes /tmp/Backup_$fecha
mv /tmp/Backup_$fecha/Imágenes /tmp/Backup_$fecha/Imágenes_$fecha

aux=$(ls ~/Dropbox/BackupActual|wc -l)

if [ "$aux" -gt 0 ]
then
	#Enviamos la carpeta de Backups a  la carpeta BackupActual en Dropbox
	mv /tmp/Backup_$fecha ~/Dropbox/BackupActual

	#Comprimimos la carpeta que teniamos antes para enviar a la carpeta donde almacenamos las versiones
	#antiguas de backups
	backup_comprimir=$(ls ~/Dropbox/BackupActual/|head -1)

	cd ~/Dropbox/BackupActual

	tar -zcf $backup_comprimir.tar.gz $backup_comprimir
	rm -rf $backup_comprimir

	#Como solo dispongo de 2GB en dropbox, vamos a guardar hasta 10 versiones de backups
	#Una vez lleguemos a esa cantidad de backups, vamos a eliminar la mas antigua para hacerle espacio 
	#a la mas reciente

	cantidad=$(ls ~/Dropbox/Ultimos10Backups |wc -l)

	if [ "$cantidad" -lt 10 ]
	then

	mv ~/Dropbox/BackupActual/$backup_comprimir.tar.gz  ~/Dropbox/Ultimos10Backups

	else

	backup_a_borrar=$(ls ~/Dropbox/Ultimos10Backups |head -1)

	rm ~/Dropbox/Ultimos10Backups/$backup_a_borrar
	mv ~/Dropbox/BackupActual/$backup_comprimir.tar.gz  ~/Dropbox/Ultimos10Backups

	fi
else

#Si todavia no teniamos backups en la carpeta actual de backups, simplemente movemos la carpeta a 
#su nueva ubicacion

mv /tmp/Backup_$fecha ~/Dropbox/BackupActual

fi

#Ahora que ya tenemos todo listo, iniciamos dropbox para que empiece a sincronizar

dropbox start

#Finalmente esperamos a que Dropbox sincronize el servidor y cuando este actualizado lo cierre

Estado="Sincronizando"

while [ "$Estado" != "Actualizado" ]
do
Estado=$(dropbox status)
sleep 20s
done

dropbox stop
dropbox autostart n

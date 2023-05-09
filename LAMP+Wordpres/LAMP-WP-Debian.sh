#!/usr/bin/bash

#--------------------Instalación LAMP-----------------------------------
#INSTALL_YUM='/usr/bin/yum'
#---------Actualización de paquetes
/usr/bin/apt -y update      
/usr/bin/apt -y upgrade

#--------- Instalación de wget
/usr/bin/apt -y install wget
    
#--------- Instalación de Apache
/usr/bin/apt -y install apache2

#--------- Instalación de MariaDB
/usr/bin/apt -y install mariadb-server

#--------- Instalación de PHP
/usr/bin/apt -y install php

#--------- Instalación de plugins PHP
/usr/bin/apt -y install php7.4-pdo php7.4-mysql php7.4-mbstring php7.4-json php7.4-xml php7.4-gd

#--------- Inicialización de servicios
/usr/bin/systemctl start apache2
/usr/bin/systemctl start mariadb
/usr/bin/systemctl enable apache2
/usr/bin/systemctl enable mariadb
/usr/bin/mysql_secure_installation


#--------------------Configuración vhost-----------------------------------
#--------- Petición de datos para el vhost
echo "Digite el nombre de su equipo:"
read EQUIPO

echo "Digite un coreo electronico:"
read EMAIL

echo "Digite el dominio de wordpress:"
read DOMAIN

/usr/bin/systemctl reload apache2

#------- Asignación de LOGS
LOGS='\/var\/log\/apache2'

#------- Creación del template para vhost
cp vhost2.txt "${EQUIPO}".conf

#------- Cargar valores de vhost
sed -i "s/CORREO/${EMAIL}/g" "${EQUIPO}".conf
sed -i "s/DOMINIO/${DOMAIN}/g" "${EQUIPO}".conf
sed -i "s/ALIAS/\*.${DOMAIN}/g" "${EQUIPO}".conf
sed -i "s/RUTA/\/var\/www\/html\/${EQUIPO}/g" "${EQUIPO}".conf
sed -i "s/LOGS/${LOGS}/g" "${EQUIPO}".conf
cp "${EQUIPO}".conf /etc/apache2/sites-available/"${EQUIPO}".conf
a2ensite "${EQUIPO}".conf

#------- Se refresca el servicio de apache
/usr/bin/systemctl reload apache2


#------------------Instalación wordpress-------------------------------
#------------ Obtener la ruta de los scripts
PROJECT_DIR=$(pwd)

#------------ Obtener los datos para la BD
echo "Digite el usuario nuevo para la base de datos:"
read USER

echo "Digite una contraseña para el nuevo usuario:"
read PASS


#------------ Descarga de Wordpress
cd /tmp

wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

#------------ Creación de la carpeta del proyecto web
mkdir /var/www/html/"${EQUIPO}"

#------------ Copia de los archivos de Worpress a la carpeta del proyecto
cp -fr wordpress/* /var/www/html/"${EQUIPO}"

#------------ Creación del archivo de configuración
cp -fr /var/www/html/"${EQUIPO}"/wp-config-sample.php /var/www/html/"${EQUIPO}"/wp-config.php



#--------------Configuración usuario BD------------------------------------------------------------

echo "Digite la contraseña del usuario root para la base de datos:"
read PASSROOT

echo "CREATE DATABASE ${EQUIPO};" | mysql -u root -p"'${PASSROOT}'"

echo "CREATE USER '${USER}'@'%' IDENTIFIED BY '${PASS}';" | mysql -u root -p"'${PASSROOT}'"

echo "GRANT ALL PRIVILEGES ON ${EQUIPO}.* to '${USER}'@'%';" | mysql -u root -p"'${PASSROOT}'"

echo "FLUSH PRIVILEGES;" | mysql -u root -p"'${PASSROOT}'"

#------------ Validación de la BD para configurar Wordpress
if [ "$?" -eq 0 ]; then
	sed -i "s/database_name_here/${EQUIPO}/g" /var/www/html/"${EQUIPO}"/wp-config.php
	sed -i "s/username_here/${USER}/g" /var/www/html/"${EQUIPO}"/wp-config.php
	sed -i "s/password_here/${PASS}/g" /var/www/html/"${EQUIPO}"/wp-config.php
cd
rm vhost2.txt
rm "${EQUIPO}".conf
echo "La instalación de WordPress en el servidor LAMP ha finalizado con éxito."
else
	echo "Algo salio mal al crear la Base de datos."
fi

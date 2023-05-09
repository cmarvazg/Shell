#!/usr/bin/bash

#------------------INSTALACIÓN LAMP--------------------------

#---------Instalación de repositorios para PHP 7.4
/usr/bin/yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
/usr/bin/yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
/usr/bin/yum -y install yum-utils
/usr/bin/yum-config-manager --enable remi-php74
/usr/bin/yum -y update
/usr/bin/yum -y install php php-cli

#--------- Instalacion de wget
/usr/bin/yum -y install wget

#--------- Instalacion de Apache
/usr/bin/yum -y install httpd

#--------- Instalacion de MariaDB
/usr/bin/yum -y install mariadb-server

#--------- Instalacion de PHP
/usr/bin/yum -y install php

#--------- Instalacion de plugins PHP
/usr/bin/yum -y install php-pdo php-mysqlnd php-mbstring php-json php-xml php-gd

#--------- Iniciar servicios en RHEL
/usr/bin/systemctl start httpd
/usr/bin/systemctl start mariadb
/usr/bin/systemctl enable httpd
/usr/bin/systemctl enable mariadb
/usr/bin/mysql_secure_installation


#--------------------Configuración vhost-----------------------------------
echo "Digite el nombre de su equipo:"
read EQUIPO

echo "Digite un coreo electronico:"
read MAIL

echo "Digite el dominio de wordpress:"
read DOMAIN

LOGS=logs

#------- Crear template para vhost
cp vhost2.txt "${EQUIPO}".conf

#------- Cargar valores de vhost
sed -i "s/CORREO/${MAIL}/g" "${EQUIPO}".conf
sed -i "s/DOMINIO/${DOMAIN}/g" "${EQUIPO}".conf
sed -i "s/ALIAS/\*.${DOMAIN}/g" "${EQUIPO}".conf
sed -i "s/RUTA/\/var\/www\/html\/${EQUIPO}/g" "${EQUIPO}".conf
sed -i "s/LOGS/${LOGS}/g" "${EQUIPO}".conf

cp "${EQUIPO}".conf /etc/httpd/conf.d/"${EQUIPO}".conf
/usr/bin/systemctl reload httpd

#------------------INSTALACIÓN DE wORDPRESS-------------------------------

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

#------------ Creacion de la carpeta del proyecto web
mkdir /var/www/html/"${EQUIPO}"

#------------ Copia de los archivos de Worpress a la carpeta del proyecto
cp -fr wordpress/* /var/www/html/"${EQUIPO}"

#------------ Creacion del archivo de configuracion
cp -fr /var/www/html/"${EQUIPO}"/wp-config-sample.php /var/www/html/"${EQUIPO}"/wp-config.php

#--------------Configuración usuario BD------------------------------------------------------------
echo "Digite la contraseña del usuario root para la base de datos:"
read PASSROOT

echo "CREATE DATABASE ${EQUIPO};" | mysql -u root -p"'${PASSROOT}'"

echo "CREATE USER '${USER}'@'%' IDENTIFIED BY '${PASS}';" | mysql -u root -p"'${PASSROOT}'"

echo "GRANT ALL PRIVILEGES ON ${EQUIPO}.* to '${USER}'@'%';" | mysql -u root -p"'${PASSROOT}'"

echo "FLUSH PRIVILEGES;" | mysql -u root -p"'${PASSROOT}'"

#------------ Valida si se creo la BD para configurar Wordpress
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

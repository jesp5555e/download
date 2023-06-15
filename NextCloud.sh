#!/bin/bash

# Installer og konfigurer Apache-webserveren
apt update
apt install apache2 -y

# Installer og konfigurer PHP
apt install php libapache2-mod-php -y

# Hent og installer NextCloud
apt install wget unzip -y
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip -d /var/www/html/
chown -R www-data:www-data /var/www/html/nextcloud/
chmod -R 755 /var/www/html/nextcloud/

# Konfigurer Apache for at betjene NextCloud
echo "Alias /nextcloud "/var/www/html/nextcloud/"

<Directory /var/www/html/nextcloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/html/nextcloud
 SetEnv HTTP_HOME /var/www/html/nextcloud

</Directory>" >> /etc/apache2/sites-available/nextcloud.conf

a2ensite nextcloud.conf
a2enmod rewrite
systemctl restart apache2

# Konfigurer firewall-regler for web-serveren
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Konfigurer NextCloud til at bruge den specificerede databaseserver
sed -i "s/'dbhost' => 'localhost',/'dbhost' => '192.168.224.2',/g" /var/www/html/nextcloud/config/config.php
sed -i "s/'dbname' => 'nextcloud',/'dbname' => 'nextcloud',/g" /var/www/html/nextcloud/config/config.php
sed -i "s/'dbuser' => 'nextcloud',/'dbuser' => 'nextcloud',/g" /var/www/html/nextcloud/config/config.php
sed -i "s/'dbpassword' => 'password',/'dbpassword' => 'DATABASE_PASSWORD',/g" /var/www/html/nextcloud/config/config.php

# Genstart Apache for at anvende ændringer
systemctl restart apache2
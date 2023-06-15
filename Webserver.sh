#!/bin/bash

# Installer nødvendige pakker
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
yum install firewalld -y

# Start og aktiver firewalld-tjenesten
systemctl start firewalld 
systemctl enable firewalld

# Konfigurer firewall-regler for webmail-serveren
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Installer nødvendige pakker for webmail
yum install httpd php php-mysqlnd mod_ssl mysql yum-utils -y

# Installer og konfigurer Remi-repository
yum install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
yum-config-manager --set-enable remi

# Opdater systemet
yum update -y
yum upgrade -y

# Installer Roundcube fra Remi-repository
yum install roundcubemail -y

# Konfigurer Roundcube
cp -pRv /etc/roundcubemail/config.inc.php.sample /etc/roundcubemail/config.inc.php
sed -i "s/\$config\['db_dsnw'\] = 'mysql://roundcube:pass@localhost/roundcubemail';/\$config\['db_dsnw'\] = 'mysql://roundcube:Kode1234!@192.168.224.2/roundcubemail';/" /etc/roundcubemail/config.inc.php
sed -i "s/\$config\['default_host'\] = 'localhost';/\$config\['default_host'\] = 'localhost';/" /etc/roundcubemail/config.inc.php
sed -i "s/\$config\['smtp_server'\] = 'localhost';/\$config\['smtp_server'\] = '';/" /etc/roundcubemail/config.inc.php
sed -i "s/\$config\['smtp_user'\] = '%u';/\$config\['smtp_user'\] = '%u';/" /etc/roundcubemail/config.inc.php
sed -i "s/\$config\['smtp_pass'\] = '%p';/\$config\['smtp_pass'\] = '%p';/" /etc/roundcubemail/config.inc.php

# Company details selvsigneret SSL-certifikat
country=DK
state=Sjaelland
locality=Legoland
organization=TogT
organizationalunit=IT
email=mail@togt.local

# Generer selvsigneret SSL-certifikat
mkdir /etc/httpd/ssl
openssl req -new -x509 -nodes -days 365 -out /etc/httpd/ssl/server.crt -keyout /etc/httpd/ssl/server.key -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

# Konfigurer Apache til at bruge SSL
echo "<VirtualHost *:443>" >> /etc/httpd/conf/httpd.conf
echo "SSLEngine on" >> /etc/httpd/conf/httpd.conf
echo "SSLCertificateFile /etc/httpd/ssl/server.crt" >> /etc/httpd/conf/httpd.conf
echo "SSLCertificateKeyFile /etc/httpd/ssl/server.key" >> /etc/httpd/conf/httpd.conf
echo "</VirtualHost>" >> /etc/httpd/conf/httpd.conf

# Start Apache-tjenesten
systemctl enable httpd
systemctl start httpd

echo "Mail server and webmail setup completed."
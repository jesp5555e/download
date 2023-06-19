#!/bin/bash

# update
yum update -y

# Installer nødvendige pakker
yum install httpd php php-mysqlnd mod_ssl yum-utils -y

# Tilføger et repo
touch /etc/yum.repos.d/webmin.repo
echo [Webmin] >> /etc/yum.repos.d/webmin.repo
echo name=Webmin Distribution Neutral >> /etc/yum.repos.d/webmin.repo
echo baseurl=https://download.webmin.com/download/yum >> /etc/yum.repos.d/webmin.repo
echo enabled=1 >> /etc/yum.repos.d/webmin.repo
echo gpgcheck=1 >> /etc/yum.repos.d/webmin.repo
echo gpgkey=https://download.webmin.com/jcameron-key.asc >> /etc/yum.repos.d/webmin.repo

# Importer det nyge repo
rpm --import https://download.webmin.com/jcameron-key.asc

# Installer webmin
yum install webmin -y

# Start webmin-tjenesten
systemctl start webmin
systemctl enable webmin

# Company details selvsigneret SSL-certifikat
country=DK
state=Sjaelland
locality=Keldby
organization=Keldby Technology
organizationalunit=IT
email=mail@kbytech.dom

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


# Konfigurer firewall-regler for webmail-serveren
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=21/tcp
firewall-cmd --permanent --add-service=ftp
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
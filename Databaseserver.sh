#!/bin/bash

# Installer nødvendige pakker
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
yum install firewalld -y

# Start og aktiver firewalld-tjenesten
systemctl start firewalld
systemctl enable firewalld

# Konfigurer firewall-regler for database-serveren
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

# Installer MariaDB-server
yum install mariadb-server -y

# Start MariaDB-tjenesten
systemctl start mariadb
systemctl enable mariadb

# Konfigurer MariaDB
mysql -u root -e "CREATE DATABASE roundcubemail;"
mysql -u root -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'192.168.244.7' IDENTIFIED BY 'Kode1234!';"
mysql -u root -e "CREATE DATABASE TT_Kunde;"
mysql -u root -e "GRANT ALL PRIVILEGES ON .* TO 'admin'@'%' IDENTIFIED BY 'Kode1234!';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Aktivér fjernadgang til MariaDB-serveren
sed -i 's/bind-address.*/bind-address = 192.168.224.2/' /etc/mysql/mariadb.conf.d/50-server.cnf 
# Genstart MariaDB-tjenesten
systemctl restart mariadb
echo "Database server setup completed."
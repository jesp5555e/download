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
service mariadb start

# Konfigurer MariaDB
mysql -u root -e "CREATE DATABASE roundcubemail;"
mysql -u root -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'192.168.244.7' IDENTIFIED BY 'Kode1234!';"
mysql -u root -e "CREATE DATABASE nextcloud;"
mysql -u root -e "GRANT ALL ON nextcloud.* TO 'nextcloud'@'192.168.224.5' IDENTIFIED BY 'password';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Aktivér fjernadgang til MariaDB-serveren
sed -i 's/bind-address.*/bind-address = 192.168.224.2/' /etc/mysql/mariadb.conf.d/50-server.cnf 
# Genstart MariaDB-tjenesten
service mariadb restart

echo "Database server setup completed."
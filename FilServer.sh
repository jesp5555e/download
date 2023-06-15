#!/bin/bash

# Installer og konfigurer Samba-serveren
yum update
yum install samba -y

# Installer og konfigurer vsftpd FTP-serveren
yum install vsftpd -y

# Opret en delt mappe og konfigurer Samba
mkdir /var/shared_folder
chown nobody:nogroup /var/shared_folder
chmod 770 /var/shared_folder

echo "[shared_folder]" >> /etc/samba/smb.conf
echo "path = /var/shared_folder" >> /etc/samba/smb.conf
echo "valid users = @togt.local" >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf
echo "guest ok = no" >> /etc/samba/smb.conf

# Konfigurer vsftpd
echo "local_enable=YES" >> /etc/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd.conf
echo "local_umask=022" >> /etc/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf

# Genstart Samba-tjenesten for at anvende konfigurationsændringer
systemctl restart smbd

# Genstart vsftpd-tjenesten for at anvende konfigurationsændringer
systemctl restart vsftpd
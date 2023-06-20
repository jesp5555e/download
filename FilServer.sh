#!/bin/bash

# Installer og konfigurer Samba-serveren
dnf install samba samba-common samba-client 

# Installer og konfigurer vsftpd FTP-serveren
yum install vsftpd -y

# Opret en delt mappe og konfigurer Samba
sudo mkdir -p /srv/share/data
chmod -R 755 /srv/share/data
chown -R  nobody:nobody /srv/share/data
chcon -t samba_share_t /srv/share/data

sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
touch /etc/samba/smb.conf

echo "[global]" > /etc/samba/smb.conf
echo "workgroup = WORKGROUP" >> /etc/samba/smb.conf
echo "server string = Samba Server %v" >> /etc/samba/smb.conf
echo "netbios name = rocky-8" >> /etc/samba/smb.conf
echo "security = user" >> /etc/samba/smb.conf
echo "map to guest = bad user" >> /etc/samba/smb.conf
echo "dns proxy = no" >> /etc/samba/smb.conf
echo "ntlm auth = true" >> /etc/samba/smb.conf

echo "[Public]" >> /etc/samba/smb.conf
echo "path =  /srv/share/data" >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf
echo "guest ok = yes" >> /etc/samba/smb.conf
echo "browsable =yes" >> /etc/samba/smb.conf
echo "writable = yes" >> /etc/samba/smb.conf

# Konfigurer vsftpd
echo "local_enable=YES" >> /etc/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd.conf
echo "local_umask=022" >> /etc/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf

# Genstart Samba-tjenesten for at anvende konfigurationsændringer
systemctl start smb
systemctl enable smb
systemctl start nmb
systemctl enable nmb

# Genstart vsftpd-tjenesten for at anvende konfigurationsændringer
systemctl restart vsftpd

firewall-cmd --permanent --add-service=samba
firewall-cmd --permanent --add-service=ftp
firewall-cmd --reload
# Opdater systemet
yum update -y
yum upgrade -y

# Installer Postfix og Dovecot
yum install postfix dovecot -y

# Konfigurer Postfix
echo "myhostname = mail-server.togt.local" >> /etc/postfix/main.cf
echo "mydomain = togt.local" >> /etc/postfix/main.cf
echo "myorigin = \$mydomain" >> /etc/postfix/main.cf
echo "inet_interfaces = all" >> /etc/postfix/main.cf
echo "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain" >> /etc/postfix/main.cf
echo "mynetworks = 127.0.0.0/8" >> /etc/postfix/main.cf
echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf
echo "smtpd_sasl_type = dovecot" >> /etc/postfix/main.cf
echo "smtpd_sasl_path = private/auth" >> /etc/postfix/main.cf
echo "smtpd_sasl_auth_enable = yes" >> /etc/postfix/main.cf
echo "smtpd_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
echo "smtpd_sasl_local_domain =" >> /etc/postfix/main.cf
echo "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination" >> /etc/postfix/main.cf

# Genstart Postfix-tjenesten
systemctl restart postfix

# Konfigurer Dovecot
echo "mail_location = maildir:~/Maildir" >> /etc/dovecot/conf.d/10-mail.conf
echo "auth_mechanisms = plain login" >> /etc/dovecot/conf.d/10-auth.conf
echo "ssl = no" >> /etc/dovecot/conf.d/10-ssl.conf

# Aktivér og start Dovecot-tjenesten
systemctl enable dovecot
systemctl start dovecot

# Start og aktiver firewalld-tjenesten
firewall-cmd --permanent --add-service=smtp
firewall-cmd --reload

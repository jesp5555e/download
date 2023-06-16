#!/bin/bash

#Installer Nginx-pakken
yum update -y
yum install -y nginx

#Opret en ny Nginx-serverblok til Nextcloud
tee /etc/nginx/sites-available/nextcloud > /dev/null <<EOT
server {
    listen 80;
    server_name 192.168.224.4;

    # Tilføj eventuelle SSL-konfigurationer her

    root /var/www/html/nextcloud;

    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }

    location ~ ^/(?:.htaccess|data|config|dbstructure.xml|README) {
        deny all;
    }

    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
        deny all;
    }

    location ~ ^/(?:.|autotest|occ|issue|indie|db|console) {
        deny all;
    }

    location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+).php(?:$|/) {
        fastcgi_split_path_info ^(.+?.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true;
        fastcgi_param front_controller_active true;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ ^/(?:updater|ocs-provider)(?:$|/) {
        try_files $uri/ =404;
        index index.php;
    }

    location ~ .(?:css|js|woff2?|svg|gif|map)$ {
        try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463";
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        access_log off;
    }

    location ~ .(?:png|html|ttf|ico|jpg|jpeg)$ {
        try_files $uri /index.php$request_uri;
        access_log off;
    }
}
EOT

#Aktivér Nextcloud-serverblokken
ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/

#Fjern standardserverblokken
rm /etc/nginx/sites-enabled/default

#Genstart Nginx-tjenesten
systemctl restart nginx
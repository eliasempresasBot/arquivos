#!/bin/bash

echo "Atualizando pacotes e instalando Nginx..."
sudo apt update && sudo apt upgrade -y
sudo apt install nginx -y

echo "Criando diretório raiz do site..."
sudo mkdir -p /var/www/eliasempresas.com

echo "Criando configuração do Nginx..."
cat <<EOF | sudo tee /etc/nginx/sites-available/eliasempresas.com > /dev/null
server {
    listen 80;
    server_name eliasempresas.com www.eliasempresas.com
                id.eliasempresas.com painel.eliasempresas.com
                media.eliasempresas.com servidor.eliasempresas.com
                dns.eliasempresas.com smtp.eliasempresas.com
                feed.eliasempresas.com social.eliasempresas.com
                virus.eliasempresas.com stf.eliasempresas.com
                arquivos.eliasempresas.com;

    root /var/www/eliasempresas.com;
    index index.html index.htm;

    access_log /var/log/nginx/eliasempresas_access.log;
    error_log /var/log/nginx/eliasempresas_error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\. {
        deny all;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|svg)\$ {
        expires 7d;
    }

    # location /painel {
    #     return 301 https://painel.eliasempresas.com;
    # }
}
EOF

echo "Ativando site no Nginx..."
sudo ln -s /etc/nginx/sites-available/eliasempresas.com /etc/nginx/sites-enabled/

echo "Reiniciando Nginx..."
sudo systemctl restart nginx

echo "Pronto! Nginx configurado com o domínio eliasempresas.com"

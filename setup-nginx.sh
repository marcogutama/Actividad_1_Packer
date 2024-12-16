#!/bin/bash

# Actualizar paquetes y herramientas
sudo apt-get update
sudo apt-get install -y nodejs npm nginx

# Instalar y configurar PM2
timeout 5 node hello.js
sudo npm install pm2@latest -g
pm2 start /home/ubuntu/hello.js
pm2 kill
pm2 startup systemd
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save
sudo systemctl start pm2-ubuntu

# Configurar Nginx
sudo rm -f /etc/nginx/sites-available/default
sudo mv /home/ubuntu/default /etc/nginx/sites-available/default

# Reiniciar Nginx
sudo systemctl restart nginx

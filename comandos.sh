sudo apt install -y nodejs npm nginx
nano hello.js
node hello.js
sudo npm install pm2@latest -g
pm2 start hello.js
pm2 startup systemd
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save
#sudo systemctl start pm2-sammy #error
#sudo nano /etc/nginx/sites-available/default
sudo sed -i '/location \/ {/,/}/c\
location / {\
    proxy_pass http://localhost:3000;\
    proxy_http_version 1.1;\
    proxy_set_header Upgrade $http_upgrade;\
    proxy_set_header Connection "upgrade";\
    proxy_set_header Host $host;\
    proxy_cache_bypass $http_upgrade;\
}' /etc/nginx/sites-available/default
sudo systemctl restart nginx
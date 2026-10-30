#!/bin/bash
apt-get update -y
apt-get install -y nginx
HOSTNAME=$(hostname)
echo "<h1>NovaSphere DEV - ${HOSTNAME}</h1>" > /var/www/html/index.html
systemctl enable nginx
systemctl restart nginx

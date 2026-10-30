#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx awscli

mkdir -p /etc/novasphere

DB_PASSWORD=$(aws ssm get-parameter \
  --name "/novasphere/dev/db_password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

printf 'DB_PASSWORD=%s\n' "$DB_PASSWORD" > /etc/novasphere/app.conf
chmod 0640 /etc/novasphere/app.conf

HOSTNAME=$(hostname)

echo "<h1>NovaSphere DEV - ${HOSTNAME}</h1>" > /var/www/html/index.html

systemctl enable nginx
systemctl restart nginx

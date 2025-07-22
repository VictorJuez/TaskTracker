#!/bin/bash

# TaskTracker Deployment Script for Digital Ocean Droplet
# Run this script on your droplet as root

set -e

echo "🚀 Starting TaskTracker deployment..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "🔧 Installing required packages..."
apt install -y nginx curl wget git unzip software-properties-common

# Install .NET 9
echo "🔧 Installing .NET 9..."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update
apt install -y dotnet-sdk-9.0

# Install Node.js 18
echo "🔧 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /var/www/tasktracker
chown www-data:www-data /var/www/tasktracker

# Clone repository (replace with your repo URL)
echo "📥 Cloning repository..."
cd /var/www/tasktracker
git clone https://github.com/VictorJuez/TaskTracker.git .
chown -R www-data:www-data /var/www/tasktracker

# Build and deploy backend
echo "🔨 Building backend..."
cd /var/www/tasktracker/backend
dotnet restore
dotnet publish -c Release -o /var/www/tasktracker/backend/publish
chown -R www-data:www-data /var/www/tasktracker/backend/publish

# Create database and run migrations
echo "🗄️ Setting up database..."
cd /var/www/tasktracker/backend/publish
dotnet ef database update

# Build frontend
echo "🔨 Building frontend..."
cd /var/www/tasktracker/frontend
npm ci --production
npm run build
chown -R www-data:www-data /var/www/tasktracker/frontend/build

# Setup systemd service
echo "⚙️ Setting up backend service..."
cp /var/www/tasktracker/backend/TaskTracker.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable TaskTracker
systemctl start TaskTracker

# Setup Nginx
echo "🌐 Setting up Nginx..."
cp /var/www/tasktracker/nginx.conf /etc/nginx/sites-available/tasktracker
ln -sf /etc/nginx/sites-available/tasktracker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Setup firewall
echo "🔥 Setting up firewall..."
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

# Setup SSL with Let's Encrypt (optional)
echo "🔒 SSL Setup (optional)..."
echo "To enable SSL, run:"
echo "apt install certbot python3-certbot-nginx"
echo "certbot --nginx -d your-domain.com"

echo "✅ Deployment completed!"
echo "🌐 Your application should be available at: http://$(curl -s ifconfig.me)"
echo "📊 Check service status: systemctl status TaskTracker"
echo "📋 View logs: journalctl -u TaskTracker -f" 
#!/bin/bash

# TaskTracker Bootstrap Script
# This script handles initial droplet setup and can be run remotely
# Usage: This script is designed to be run via GitHub Actions for initial setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "🚀 Starting TaskTracker bootstrap setup..."

# Update system
print_status "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
print_status "🔧 Installing required packages..."
apt install -y nginx curl wget git unzip software-properties-common

# Setup swap space for memory optimization
print_status "💾 Setting up swap space..."
if [ ! -f /swapfile ]; then
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    print_success "1GB swap space created and activated"
else
    print_warning "Swap file already exists, skipping creation"
fi

# Install .NET 8
print_status "🔧 Installing .NET 8..."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update
apt install -y dotnet-sdk-8.0

# Verify .NET installation
print_status "🔍 Verifying .NET installation..."
if dotnet --version > /dev/null 2>&1; then
    print_success "NET $(dotnet --version) installed successfully"
else
    print_error "NET installation verification failed"
    exit 1
fi

# Install Entity Framework tools
print_status "🔧 Installing Entity Framework tools..."
dotnet tool install --global dotnet-ef

# Install Node.js 18
print_status "🔧 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Create application directory
print_status "📁 Creating application directory..."
mkdir -p /var/www/tasktracker
mkdir -p /var/www/.dotnet
chown -R www-data:www-data /var/www

# Clone repository
print_status "📥 Cloning repository..."
cd /var/www/tasktracker
git clone https://github.com/VictorJuez/TaskTracker.git .
chown -R www-data:www-data /var/www/tasktracker

# Setup systemd service
print_status "⚙️ Setting up backend service..."
cp /var/www/tasktracker/backend/TaskTracker.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable TaskTracker

# Setup Nginx
print_status "🌐 Setting up Nginx..."
cp /var/www/tasktracker/nginx.conf /etc/nginx/sites-available/tasktracker
ln -sf /etc/nginx/sites-available/tasktracker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Setup firewall
print_status "🔥 Setting up firewall..."
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

print_success "✅ Bootstrap setup completed!"
print_status "🎯 Ready for automated deployment via GitHub Actions"
print_status "🌐 Your application will be available at: http://$(curl -s ifconfig.me)"
print_status "💾 Swap space: $(free -h | grep Swap | awk '{print $2}') available" 
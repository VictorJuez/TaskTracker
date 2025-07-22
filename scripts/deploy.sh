#!/bin/bash

# TaskTracker Deployment Script
# This script handles both initial setup and updates

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

# Check if this is initial setup or update
INITIAL_SETUP=false
if [ ! -d "/var/www/tasktracker" ]; then
    INITIAL_SETUP=true
    print_status "Performing initial setup..."
else
    print_status "Performing update deployment..."
fi

# Initial setup steps
if [ "$INITIAL_SETUP" = true ]; then
    print_status "Updating system packages..."
    apt update && apt upgrade -y

    print_status "Installing required packages..."
    apt install -y nginx curl wget git unzip software-properties-common

    print_status "Installing .NET 9..."
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    apt update
    apt install -y dotnet-sdk-9.0

    print_status "Installing Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs

    print_status "Creating application directory..."
    mkdir -p /var/www/tasktracker
    chown www-data:www-data /var/www/tasktracker

    print_status "Cloning repository..."
    cd /var/www/tasktracker
    git clone https://github.com/VictorJuez/TaskTracker.git .
    chown -R www-data:www-data /var/www/tasktracker

    print_status "Setting up systemd service..."
    cp /var/www/tasktracker/backend/TaskTracker.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable TaskTracker

    print_status "Setting up Nginx..."
    cp /var/www/tasktracker/nginx.conf /etc/nginx/sites-available/tasktracker
    ln -sf /etc/nginx/sites-available/tasktracker /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    systemctl restart nginx

    print_status "Setting up firewall..."
    ufw allow 'Nginx Full'
    ufw allow OpenSSH
    ufw --force enable

    print_success "Initial setup completed!"
fi

# Common deployment steps (both initial and update)
print_status "Navigating to application directory..."
cd /var/www/tasktracker

if [ "$INITIAL_SETUP" = false ]; then
    print_status "Pulling latest changes..."
    git pull origin main
    chown -R www-data:www-data /var/www/tasktracker
fi

print_status "Building backend..."
cd backend
dotnet restore
dotnet publish -c Release -o /var/www/tasktracker/backend/publish
chown -R www-data:www-data /var/www/tasktracker/backend/publish

print_status "Setting up database..."
cd /var/www/tasktracker/backend/publish
dotnet ef database update

print_status "Starting backend service..."
systemctl start TaskTracker
systemctl restart TaskTracker

print_status "Building frontend..."
cd /var/www/tasktracker/frontend
npm ci --production
npm run build
chown -R www-data:www-data /var/www/tasktracker/frontend/build

print_status "Reloading Nginx..."
nginx -s reload

# Verify deployment
print_status "Verifying deployment..."
if systemctl is-active --quiet TaskTracker; then
    print_success "Backend service is running"
else
    print_error "Backend service failed to start"
    systemctl status TaskTracker --no-pager
    exit 1
fi

if systemctl is-active --quiet nginx; then
    print_success "Nginx is running"
else
    print_error "Nginx failed to start"
    systemctl status nginx --no-pager
    exit 1
fi

# Test API endpoint
print_status "Testing API endpoint..."
if curl -f http://localhost:5000/api/tasks > /dev/null 2>&1; then
    print_success "API endpoint is responding"
else
    print_warning "API endpoint test failed (this might be normal if no tasks exist)"
fi

print_success "Deployment completed successfully!"
print_status "Application should be available at: http://$(curl -s ifconfig.me)"

# Show service status
echo ""
print_status "Service Status:"
systemctl status TaskTracker --no-pager -l
echo ""
systemctl status nginx --no-pager -l 
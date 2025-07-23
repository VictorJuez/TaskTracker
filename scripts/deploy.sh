#!/bin/bash

# TaskTracker Deployment Script
# This script handles application updates and deployment
# For initial setup, use bootstrap.sh instead

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

# Check if application directory exists
if [ ! -d "/var/www/tasktracker" ]; then
    print_error "Application directory not found. Please run bootstrap.sh first for initial setup."
    exit 1
fi

print_status "🔄 Starting application deployment..."

# Set .NET environment variables (in case they're not set)
export DOTNET_ROOT=/usr/lib/dotnet
export PATH=$PATH:$DOTNET_ROOT

# Navigate to application directory
print_status "📁 Navigating to application directory..."
cd /var/www/tasktracker

# Pull latest changes
print_status "📥 Pulling latest changes..."
git pull origin main
chown -R www-data:www-data /var/www/tasktracker

# Build backend
print_status "🔨 Building backend..."
cd backend
dotnet restore
dotnet publish -c Release -o /var/www/tasktracker/backend/publish
chown -R www-data:www-data /var/www/tasktracker/backend/publish

# Run database migrations
print_status "🗄️ Running database migrations..."
cd /var/www/tasktracker/backend/publish
dotnet ef database update

# Restart backend service
print_status "⚙️ Restarting backend service..."
systemctl restart TaskTracker

# Build frontend
print_status "🔨 Building frontend..."
cd /var/www/tasktracker/frontend
npm ci --production
npm run build
chown -R www-data:www-data /var/www/tasktracker/frontend/build

# Reload Nginx
print_status "🌐 Reloading Nginx..."
nginx -s reload

# Verify deployment
print_status "🔍 Verifying deployment..."
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
print_status "🧪 Testing API endpoint..."
if curl -f http://localhost:5000/api/tasks > /dev/null 2>&1; then
    print_success "API endpoint is responding"
else
    print_warning "API endpoint test failed (this might be normal if no tasks exist)"
fi

print_success "✅ Deployment completed successfully!"
print_status "🌐 Application is available at: http://$(curl -s ifconfig.me)"

# Show service status
echo ""
print_status "📊 Service Status:"
systemctl status TaskTracker --no-pager -l
echo ""
systemctl status nginx --no-pager -l 
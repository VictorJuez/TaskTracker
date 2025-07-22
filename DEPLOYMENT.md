# Deployment Guide - Digital Ocean Droplet

This guide covers deploying the TaskTracker application to a single Digital Ocean droplet (~$6/month).

## Prerequisites

- Digital Ocean account
- SSH key added to Digital Ocean
- Domain name (optional, but recommended for SSL)

## Deployment Options

### Option 1: Automated Deployment (Recommended)

The application is configured for automated deployment using GitHub Actions. Every push to the `main` branch will automatically deploy to your droplet.

#### Setup Steps:

1. **Create a Digital Ocean Droplet**

   - Follow the manual setup steps below to create your droplet
   - Run the initial deployment script once

2. **Configure GitHub Secrets**

   - Follow the guide in `GITHUB_SECRETS_SETUP.md`
   - Add the required secrets to your GitHub repository

3. **Enable Automated Deployment**
   - Push to the `main` branch to trigger deployment
   - Monitor the deployment in GitHub Actions

#### Benefits:

- ✅ Zero-downtime deployments
- ✅ Automatic rollback on failure
- ✅ Consistent deployment process
- ✅ No manual intervention required

### Option 2: Manual Deployment

For manual deployment or initial setup.

## Step 1: Create a Droplet

1. **Go to Digital Ocean Console**

   - Navigate to [Digital Ocean Droplets](https://cloud.digitalocean.com/droplets)

2. **Create New Droplet**

   - **Choose an image**: Ubuntu 22.04 LTS
   - **Choose a plan**: Basic ($6/month minimum)
   - **Choose a datacenter region**: Select closest to your users
   - **Add your SSH key**: Select your SSH key
   - **Finalize and create**: Click "Create Droplet"

3. **Note your droplet IP**
   - Copy the IP address shown in the droplet list

## Step 2: Connect to Your Droplet

```bash
ssh root@YOUR_DROPLET_IP
```

## Step 3: Run the Deployment Script

1. **Download and run the deployment script**

   ```bash
   # Download the script
   curl -O https://raw.githubusercontent.com/VictorJuez/TaskTracker/main/scripts/deploy.sh

   # Make it executable
   chmod +x deploy.sh

   # Run the deployment
   ./deploy.sh
   ```

2. **Or run it directly**
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/VictorJuez/TaskTracker/main/scripts/deploy.sh)
   ```

The script will:

- Update the system
- Install .NET 9 and Node.js 18
- Clone your repository
- Build both backend and frontend
- Set up the database
- Configure Nginx as a reverse proxy
- Set up systemd service for the backend
- Configure firewall

## Step 4: Verify Deployment

1. **Check if services are running**

   ```bash
   # Check backend service
   systemctl status TaskTracker

   # Check Nginx
   systemctl status nginx

   # View backend logs
   journalctl -u TaskTracker -f
   ```

2. **Test the application**
   - Open your browser and go to `http://YOUR_DROPLET_IP`
   - You should see the TaskTracker application

## Step 5: Setup SSL (Optional but Recommended)

1. **Install Certbot**

   ```bash
   apt install certbot python3-certbot-nginx
   ```

2. **Get SSL certificate**

   ```bash
   # Replace with your domain
   certbot --nginx -d your-domain.com
   ```

3. **Auto-renewal**
   ```bash
   # Test auto-renewal
   certbot renew --dry-run
   ```

## Architecture

```
Internet → Nginx (Port 80/443) → React Frontend (Static files)
                              → Backend API (Port 5000)
```

- **Nginx**: Serves static frontend files and proxies API requests
- **Backend**: ASP.NET Core API running on port 5000
- **Database**: SQLite file (stored in `/var/www/tasktracker/backend/publish/`)

## Management Commands

### Backend Service

```bash
# Start/Stop/Restart backend
systemctl start TaskTracker
systemctl stop TaskTracker
systemctl restart TaskTracker

# View logs
journalctl -u TaskTracker -f

# Check status
systemctl status TaskTracker
```

### Nginx

```bash
# Reload configuration
nginx -s reload

# Check configuration
nginx -t

# Restart Nginx
systemctl restart nginx
```

### Application Updates

#### For Automated Deployment:

- Simply push to the `main` branch
- GitHub Actions will handle the deployment

#### For Manual Updates:

```bash
# Pull latest changes
cd /var/www/tasktracker
git pull

# Rebuild and restart backend
cd backend
dotnet publish -c Release -o /var/www/tasktracker/backend/publish
systemctl restart TaskTracker

# Rebuild frontend
cd ../frontend
npm ci --production
npm run build
```

## Troubleshooting

### Common Issues

1. **Application not accessible**

   ```bash
   # Check if services are running
   systemctl status TaskTracker nginx

   # Check firewall
   ufw status

   # Check Nginx configuration
   nginx -t
   ```

2. **Backend not responding**

   ```bash
   # Check backend logs
   journalctl -u TaskTracker -f

   # Test backend directly
   curl http://localhost:5000/api/tasks
   ```

3. **Database issues**

   ```bash
   # Check database file
   ls -la /var/www/tasktracker/backend/publish/

   # Run migrations manually
   cd /var/www/tasktracker/backend/publish
   dotnet ef database update
   ```

4. **Permission issues**

   ```bash
   # Fix permissions
   chown -R www-data:www-data /var/www/tasktracker
   ```

5. **GitHub Actions deployment fails**
   - Check the GitHub Actions logs for specific errors
   - Verify your GitHub secrets are correctly configured
   - Test SSH connection manually

### Log Locations

- **Backend logs**: `journalctl -u TaskTracker -f`
- **Nginx logs**: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`
- **System logs**: `/var/log/syslog`
- **GitHub Actions logs**: Available in your repository's Actions tab

## Cost Breakdown

- **Droplet**: $6/month (Basic plan)
- **Domain**: ~$12/year (optional)
- **Total**: ~$6-7/month

## Security Considerations

1. **Firewall**: Only ports 22 (SSH), 80 (HTTP), and 443 (HTTPS) are open
2. **Updates**: Run `apt update && apt upgrade` regularly
3. **Backups**: Consider setting up automated backups of your database
4. **Monitoring**: Set up basic monitoring with Digital Ocean alerts
5. **SSH Keys**: Use dedicated deployment SSH keys, not your main key

## Scaling Considerations

For future scaling:

1. **Database**: Migrate to PostgreSQL or MySQL
2. **Load Balancing**: Add more droplets behind a load balancer
3. **CDN**: Use Cloudflare for static assets
4. **Monitoring**: Add application monitoring (e.g., New Relic, DataDog)

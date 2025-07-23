# Automated Setup Guide

This guide explains how to use the new automated setup system for TaskTracker deployment.

## 🚀 Overview

The new system provides **two deployment methods**:

1. **Bootstrap + Deploy**: Fully automated initial setup and deployment
2. **Manual Debugging**: Manual execution for troubleshooting

## 📋 Prerequisites

- Digital Ocean account
- SSH key added to Digital Ocean
- GitHub repository with secrets configured

## 🔧 Method 1: Fully Automated Setup (Recommended)

### Step 1: Create a New Droplet

1. **Go to [Digital Ocean Droplets](https://cloud.digitalocean.com/droplets)**
2. **Create New Droplet:**

   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic ($6/month)
   - **Region**: Choose closest to your users
   - **SSH Key**: Select your SSH key
   - **Create Droplet**

3. **Note the droplet IP address**

### Step 2: Update GitHub Secrets

1. **Go to your GitHub repository**: https://github.com/VictorJuez/TaskTracker
2. **Settings → Secrets and variables → Actions**
3. **Update the secrets:**
   - `DROPLET_HOST`: Your new droplet IP
   - `DROPLET_USER`: `root`
   - `DROPLET_SSH_KEY`: Your SSH private key

### Step 3: Trigger Automated Setup

**Option A: Push to main branch**

```bash
git add .
git commit -m "feat: trigger automated deployment"
git push origin main
```

**Option B: Manual trigger**

1. Go to GitHub repository → Actions tab
2. Click "Deploy to Digital Ocean Droplet"
3. Click "Run workflow"

### Step 4: Monitor Deployment

1. **Watch GitHub Actions**: Go to Actions tab to see progress
2. **Check your application**: Visit `http://YOUR_DROPLET_IP`
3. **Future updates**: Just push to main branch

## 🔧 Method 2: Manual Bootstrap (For Debugging)

### Step 1: Bootstrap New Droplet

**Via GitHub Actions:**

1. Go to Actions tab
2. Click "Bootstrap New Droplet"
3. Enter droplet IP and username
4. Click "Run workflow"

**Via SSH (for debugging):**

```bash
# SSH into your droplet
ssh root@YOUR_DROPLET_IP

# Download and run bootstrap
curl -O https://raw.githubusercontent.com/VictorJuez/TaskTracker/main/scripts/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

### Step 2: Deploy Application

**Via GitHub Actions (automatic):**

- Push to main branch

**Via SSH (for debugging):**

```bash
# SSH into your droplet
ssh root@YOUR_DROPLET_IP

# Download and run deployment
curl -O https://raw.githubusercontent.com/VictorJuez/TaskTracker/main/scripts/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

## 📁 Scripts Overview

### `scripts/bootstrap.sh`

- **Purpose**: Initial droplet setup
- **What it does**:
  - Installs .NET 9, Node.js 18, Nginx
  - Configures environment variables
  - Sets up firewall and services
  - Clones repository
  - Prepares for deployment

### `scripts/deploy.sh`

- **Purpose**: Application deployment and updates
- **What it does**:
  - Pulls latest code
  - Builds backend and frontend
  - Runs database migrations
  - Restarts services
  - Verifies deployment

### `.github/workflows/bootstrap.yml`

- **Purpose**: Manual bootstrap trigger
- **When to use**: Setting up new droplets manually

### `.github/workflows/deploy.yml`

- **Purpose**: Automated deployment
- **Triggers**: Push to main branch
- **Smart detection**: Auto-runs bootstrap if needed

## 🔄 Workflow Scenarios

### Scenario 1: New Droplet Setup

1. Create droplet
2. Update GitHub secrets
3. Push to main branch
4. GitHub Actions automatically:
   - Detects new droplet
   - Runs bootstrap
   - Deploys application

### Scenario 2: Application Update

1. Make code changes
2. Push to main branch
3. GitHub Actions automatically:
   - Detects existing setup
   - Skips bootstrap
   - Deploys updates

### Scenario 3: Debugging Issues

1. SSH into droplet
2. Run scripts manually:

   ```bash
   # For initial setup issues
   ./scripts/bootstrap.sh

   # For deployment issues
   ./scripts/deploy.sh
   ```

## 🎯 Benefits

### ✅ Fully Automated

- No manual SSH required for new droplets
- Just update secrets and push to deploy
- Automatic detection of setup vs update

### ✅ Debugging Friendly

- Manual execution still available
- Clear error messages and logging
- Step-by-step progress indicators

### ✅ Reliable

- Environment variable fixes included
- Proper error handling
- Service verification

### ✅ Scalable

- Easy to set up multiple droplets
- Consistent deployment process
- Version-controlled configuration

## 🚨 Troubleshooting

### Common Issues

1. **SSH Connection Failed**

   - Verify droplet IP in secrets
   - Check SSH key format
   - Ensure key is added to Digital Ocean

2. **Bootstrap Fails**

   - Check GitHub Actions logs
   - Verify droplet has internet access
   - Check system resources

3. **Deployment Fails**
   - Check if bootstrap completed
   - Verify .NET environment variables
   - Check service logs

### Debugging Commands

```bash
# Check service status
systemctl status TaskTracker nginx

# View logs
journalctl -u TaskTracker -f

# Test .NET
dotnet --version

# Test API
curl http://localhost:5000/api/tasks

# Check environment
echo $DOTNET_ROOT
```

## 🔄 Migration from Old Setup

If you have an existing droplet:

1. **Option A: Fresh Start**

   - Create new droplet
   - Use automated setup

2. **Option B: Update Existing**
   - Update GitHub secrets
   - Push to main branch
   - GitHub Actions will detect and update

## 📊 Monitoring

- **GitHub Actions**: Monitor deployment progress
- **Application**: Check `http://YOUR_DROPLET_IP`
- **Logs**: SSH and check service logs
- **Health**: API endpoint testing included

## 🎉 Next Steps

1. **Test the automated setup** with a new droplet
2. **Set up monitoring** for production use
3. **Configure SSL** with Let's Encrypt
4. **Set up backups** for your database

The new system provides the best of both worlds: **fully automated deployment** with **manual debugging capabilities** when needed!

# GitHub Secrets Setup for Automated Deployment

This guide explains how to set up the required GitHub secrets for automated deployment to your Digital Ocean droplet.

## Required Secrets

You need to add the following secrets to your GitHub repository:

### 1. DROPLET_HOST

- **Description**: The IP address of your Digital Ocean droplet
- **Example**: `123.456.789.012`
- **How to get it**: From your Digital Ocean dashboard

### 2. DROPLET_USER

- **Description**: SSH username for your droplet
- **Value**: `root` (for most Digital Ocean droplets)
- **Note**: This is typically `root` for Digital Ocean droplets

### 3. DROPLET_SSH_KEY

- **Description**: Private SSH key for connecting to your droplet
- **Format**: The entire private key content (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`)
- **How to get it**: Your local SSH private key file

## Step-by-Step Setup

### Step 1: Get Your Droplet IP

1. Go to [Digital Ocean Droplets](https://cloud.digitalocean.com/droplets)
2. Find your droplet and copy its IP address
3. This will be your `DROPLET_HOST` value

### Step 2: Get Your SSH Private Key

1. On your local machine, find your SSH private key:

   ```bash
   # Usually located at:
   cat ~/.ssh/id_rsa
   # or
   cat ~/.ssh/id_ed25519
   ```

2. Copy the entire content of the private key file (including the header and footer lines)

### Step 3: Add Secrets to GitHub

1. **Go to your GitHub repository**

   - Navigate to your TaskTracker repository on GitHub

2. **Access repository settings**

   - Click on "Settings" tab
   - In the left sidebar, click "Secrets and variables" → "Actions"

3. **Add each secret**
   - Click "New repository secret"
   - Add each secret with the exact names:
     - `DROPLET_HOST`
     - `DROPLET_USER`
     - `DROPLET_SSH_KEY`

### Step 4: Test the Connection

1. **Test SSH connection locally first**:

   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Verify the droplet is accessible**:
   - You should be able to SSH into your droplet
   - If not, check your SSH key setup in Digital Ocean

## Security Best Practices

### 1. Use a Dedicated SSH Key

- Create a new SSH key pair specifically for deployment
- Don't use your main SSH key

### 2. Restrict SSH Access

- Consider using a non-root user for deployment
- Set up SSH key-only authentication
- Disable password authentication

### 3. Regular Key Rotation

- Rotate your deployment SSH keys periodically
- Update the GitHub secret when you rotate keys

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**

   - Verify the droplet IP is correct
   - Check that the SSH key is properly added to Digital Ocean
   - Ensure the private key content is copied correctly

2. **Permission Denied**

   - Verify the SSH key format is correct
   - Check that the key is not password-protected
   - Ensure the key is added to the correct user on the droplet

3. **Deployment Fails**
   - Check the GitHub Actions logs for specific error messages
   - Verify the droplet has internet access
   - Ensure all required packages can be installed

### Testing the Setup

1. **Manual SSH Test**:

   ```bash
   ssh -i ~/.ssh/your_deployment_key root@YOUR_DROPLET_IP
   ```

2. **Test the Deployment Script**:
   ```bash
   # On your droplet
   curl -O https://raw.githubusercontent.com/VictorJuez/TaskTracker/main/scripts/deploy.sh
   chmod +x deploy.sh
   ./deploy.sh
   ```

## Alternative: Using SSH Config

If you prefer, you can also set up SSH config for easier management:

1. **Create SSH config** (`~/.ssh/config`):

   ```
   Host tasktracker-droplet
       HostName YOUR_DROPLET_IP
       User root
       IdentityFile ~/.ssh/your_deployment_key
   ```

2. **Update GitHub Actions** to use the host alias:
   ```yaml
   host: tasktracker-droplet
   ```

## Next Steps

Once you've set up the secrets:

1. **Push to main branch** to trigger the first deployment
2. **Monitor the GitHub Actions** to ensure deployment succeeds
3. **Test your application** at `http://YOUR_DROPLET_IP`

The deployment will automatically:

- Install all required dependencies
- Build and deploy your application
- Set up the database
- Configure Nginx and systemd services

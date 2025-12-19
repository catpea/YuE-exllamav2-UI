# YuE-exllamav2-UI Setup Guide

Complete setup guide for running YuE-exllamav2-UI with Docker, optimized for RTX 5080 16GB VRAM.

## Quick Start

```bash
# 1. Run the installation script
./install.sh

# 2. Build and start the container
docker-compose up -d

# 3. Monitor the first-time setup (models will download)
docker-compose logs -f

# 4. Access the UI (after models finish downloading)
# Open http://localhost:7860 in your browser
```

## Installation Steps

### 1. Run the Installer

The `install.sh` script handles all setup automatically:

```bash
./install.sh
```

This script will:
- Create workspace directories (`~/AI/YuE-exllamav2-UI/workspace` by default)
- Configure SELinux permissions (Fedora/RHEL)
- Set proper directory permissions (777 for Docker access)
- Create `.env` configuration file
- Update `docker-compose.yml` with correct paths

**Custom Workspace Location:**
```bash
# Set custom workspace directory
WORKSPACE_DIR=/your/custom/path ./install.sh
```

### 2. Review Configuration

The installer creates a `.env` file with default settings:

```bash
# View configuration
cat .env
```

Default configuration:
```bash
WORKSPACE_DIR=/home/meow/AI/YuE-exllamav2-UI/workspace
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-4.0bpw,YuE-s2-1B-general-exl2-6.0bpw,YuE-upsampler
HF_TOKEN=
NVIDIA_VISIBLE_DEVICES=all
```

**Customize Model Selection:**

Edit `.env` and change `DOWNLOAD_MODELS`:

```bash
# For maximum quality (uses ~10GB VRAM)
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-5.0bpw,YuE-s2-1B-general-exl2-8.0bpw,YuE-upsampler

# For maximum speed (uses ~3GB VRAM)
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-3.0bpw,YuE-s2-1B-general-exl2-4.0bpw,YuE-upsampler

# Download all EXL2 models
DOWNLOAD_MODELS=all_exl2

# Download all models (not recommended - very large!)
DOWNLOAD_MODELS=all

# Skip downloads (manual model setup)
DOWNLOAD_MODELS=false
```

### 3. Build and Start

```bash
# Build the Docker image (first time only, ~10 minutes)
docker-compose build

# Start the container
docker-compose up -d

# Monitor the initialization
docker-compose logs -f
```

**First Run Timeline:**
- Dependency installation: ~5 minutes
- Model downloads: ~30-40 minutes (depends on internet speed)
- UI startup: ~1 minute
- **Total: ~40-50 minutes**

### 4. Verify Installation

```bash
# Check container status
docker-compose ps
# Should show: yue-exllamav2-interface   Up

# Check GPU usage
nvidia-smi
# Should show Python process using VRAM

# Test UI
curl -I http://localhost:7860
# Should return: HTTP/1.1 200 OK
```

## Accessing the Services

### Gradio UI (Main Interface)
```
http://localhost:7860
```

### JupyterLab (Optional Development Environment)
```
http://localhost:8888
```

### Outputs and Models (via Nginx)
```
http://localhost:8080/outputs
http://localhost:8080/models
```

## Common Operations

### Stop the Container
```bash
docker-compose down
```

### Restart the Container
```bash
docker-compose restart

# Or stop and start
docker-compose down
docker-compose up -d
```

### View Logs
```bash
# Follow logs in real-time
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100

# View only errors
docker-compose logs | grep -i error
```

### Reset to First Run

```bash
# Stop and remove container
docker-compose down
docker-compose rm -f

# Optional: Remove downloaded models
rm -rf ~/AI/YuE-exllamav2-UI/workspace/models/*

# Start fresh
docker-compose up -d
```

### Rebuild After Code Changes

```bash
# Rebuild the image
docker-compose build --no-cache

# Restart with new image
docker-compose down
docker-compose up -d
```

### Update the Project

```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

### Permission Errors

If you see permission errors:

```bash
# Re-run the installer to fix permissions
./install.sh

# Or manually fix
sudo chcon -Rt svirt_sandbox_file_t ~/AI/YuE-exllamav2-UI/workspace
chmod -R 777 ~/AI/YuE-exllamav2-UI/workspace
```

### Model Download Failures

```bash
# Check logs for specific error
docker-compose logs | grep -i "downloading model"

# Try downloading manually
docker-compose exec yue-exllamav2-interface bash
cd /workspace/models
hf download Alissonerdx/YuE-s1-7B-anneal-en-cot-exl2-4.0bpw --local-dir YuE-s1-7B-anneal-en-cot-exl2-4.0bpw
```

### Out of Memory

```bash
# Switch to lighter models
# Edit .env:
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-3.0bpw,YuE-s2-1B-general-exl2-4.0bpw,YuE-upsampler

# Restart
docker-compose down
docker-compose up -d
```

### UI Not Accessible

```bash
# Check if port is in use
sudo netstat -tlnp | grep 7860

# Check container logs
docker-compose logs | grep -i "gradio"

# Try accessing from inside container
docker-compose exec yue-exllamav2-interface curl http://localhost:7860
```

### SELinux Issues (Fedora/RHEL)

```bash
# Check SELinux status
getenforce

# View denials
sudo ausearch -m avc -ts recent

# Fix context
sudo chcon -Rt svirt_sandbox_file_t ~/AI/YuE-exllamav2-UI/workspace

# Or temporarily set to permissive (NOT recommended for production)
sudo setenforce 0
```

### Container Exits Immediately

```bash
# View exit reason
docker-compose logs

# Start in interactive mode for debugging
docker-compose run --rm yue-exllamav2-interface /bin/bash
```

## Advanced Configuration

### Using a Different Workspace Directory

```bash
# Edit .env
WORKSPACE_DIR=/mnt/nvme/models

# Restart
docker-compose down
docker-compose up -d
```

### Multiple GPU Setup

```bash
# Edit .env to use specific GPUs
NVIDIA_VISIBLE_DEVICES=0,1

# Or use just one GPU
NVIDIA_VISIBLE_DEVICES=0
```

### Custom Model Repository

To use your own models:

```bash
# Set DOWNLOAD_MODELS=false in .env
DOWNLOAD_MODELS=false

# Place models manually in workspace
cp -r /path/to/your/model ~/AI/YuE-exllamav2-UI/workspace/models/

# Restart container
docker-compose restart
```

## File Structure

```
YuE-exllamav2-UI/
├── install.sh                  # Installation script
├── docker-compose.yml          # Docker compose configuration
├── Dockerfile                  # Docker image definition
├── .env                        # Environment variables (created by install.sh)
├── docker/
│   ├── entrypoint.sh          # Model download & initialization
│   ├── initialize.sh          # Container startup script
│   └── default                # Nginx configuration
└── ~/AI/YuE-exllamav2-UI/workspace/  # Persistent data (default)
    ├── models/                # Downloaded models
    └── outputs/               # Generated outputs
```

## Performance Tips

1. **SSD/NVMe Storage**: Store models on fast storage for better loading times
2. **Model Selection**: Start with 4.0bpw, adjust based on quality needs
3. **VRAM Monitoring**: Use `nvidia-smi` to ensure you're not exceeding limits
4. **Batch Sizes**: Adjust in the UI based on available VRAM

## Support

For issues specific to this setup:
1. Check logs: `docker-compose logs`
2. Review this guide's troubleshooting section
3. Check `RTX_5080_SETUP.md` for model-specific information

For YuE-exllamav2-UI issues:
- GitHub: https://github.com/alisson-anjos/YuE-exllamav2-UI

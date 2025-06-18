# 🚀 Quick Start - Automated Jellyfin Media Stack

## One Command Installation

```bash
git clone https://github.com/yourusername/automated-jellyfin.git
cd automated-jellyfin
./setup.sh
```

## 🔐 What the Script Does

The setup script will automatically:

### 🛠️ Install Dependencies
- **Docker** and **Docker Compose** (if not installed)
- **curl**, **wget**, **git**, **Python3** (system dependencies)
- **xmlstarlet** (for configuration parsing)
- **Python requests** library (for API interactions)

### ⚙️ Configure Your System
- Detect your Linux distribution
- Start Docker daemon
- Add your user to the docker group
- Set up proper file permissions

### 🎯 Deploy Services
- Create Docker Compose configuration with your settings
- Pull all required Docker images
- Start all services with proper networking
- Wait for services to initialize
- Run automatic inter-service configuration

## 🔑 What You'll Be Asked

1. **Mullvad VPN account number** (required for secure torrenting)
2. **Timezone** (default: UTC)
3. **User/Group IDs** (default: your current user)

## 🖥️ Supported Operating Systems

- ✅ **Ubuntu** (18.04+)
- ✅ **Debian** (10+)
- ✅ **Linux Mint** (19+)
- ✅ **CentOS** (7+)
- ✅ **RHEL** (7+)
- ✅ **Fedora** (30+)
- ✅ **Arch Linux**

## ⚠️ Requirements

- **sudo access** (for installing system packages)
- **Internet connection** (for downloading Docker images)
- **~2GB free disk space** (for Docker images)
- **Open ports**: 8096, 8989, 7878, 9696, 8085, 6767, 5055

## 🎬 What You'll Get

After 5-10 minutes, you'll have:

- **Jellyfin** streaming server at http://localhost:8096
- **Jellyseerr** request interface at http://localhost:5055
- **Prowlarr** indexer manager at http://localhost:9696
- **Sonarr** TV show automation at http://localhost:8989
- **Radarr** movie automation at http://localhost:7878
- **qBittorrent** torrent client at http://localhost:8085
- **Bazarr** subtitle manager at http://localhost:6767

All services are:
- 🔒 **Secured** via Mullvad VPN for torrenting
- 🔧 **Pre-configured** to work together
- 🚀 **Ready to use** immediately

## 🆘 Troubleshooting

If you encounter issues:

```bash
# Check what's running
docker-compose ps

# View logs
docker-compose logs -f

# Restart everything
docker-compose restart

# Check requirements first
./check-requirements.sh
```

## 🎉 Next Steps

1. **Add indexers** in Prowlarr (1337x, RARBG, etc.)
2. **Connect Jellyseerr** to your services
3. **Set up Jellyfin** media libraries
4. **Request content** and watch it appear!

---

**Need help?** Check the detailed guides:
- `INSTALL.md` - Detailed installation and configuration
- `README.md` - Complete documentation and troubleshooting

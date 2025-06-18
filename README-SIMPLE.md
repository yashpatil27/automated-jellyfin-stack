# 🎬 Automated Jellyfin Media Stack

**One-command setup for a complete automated media server!**

## 🚀 Quick Start

```bash
git clone https://github.com/yourusername/automated-jellyfin.git
cd automated-jellyfin
./setup.sh
```

That's it! The script will:
- ✅ Check prerequisites (Docker, Docker Compose)
- 🔐 Ask for your Mullvad VPN account
- ⚙️ Configure all services automatically
- 🚀 Start everything and wait for initialization
- 🎉 Give you all the URLs to access your services

## 📋 What You Need

- **Linux system** (Ubuntu, Debian, CentOS, Fedora, Arch, etc.)
- **Mullvad VPN account** (get one at [mullvad.net](https://mullvad.net))
- **5 minutes** of your time

**That's it!** Docker and all dependencies are installed automatically.

## 📺 What You Get

- **Jellyfin**: Stream your media from anywhere
- **Jellyseerr**: Beautiful interface to request movies/shows
- **Sonarr**: Automatic TV show downloading
- **Radarr**: Automatic movie downloading
- **Prowlarr**: Manages torrent indexers
- **qBittorrent**: Secure torrent client (VPN protected)
- **Bazarr**: Automatic subtitle downloading

## 🔒 Security

- All torrent traffic goes through Mullvad VPN
- VPN kill-switch prevents leaks
- Services run in isolated Docker networks
- No sensitive data in the repository

## 🎯 Access Your Services

After setup completes, visit:
- **Jellyfin**: http://localhost:8096 (your media center)
- **Jellyseerr**: http://localhost:5055 (request movies/shows here)
- **Prowlarr**: http://localhost:9696 (add torrent sites)

## 📚 Next Steps

1. **Add indexers** in Prowlarr (1337x, RARBG, etc.)
2. **Configure Jellyseerr** to connect to your services
3. **Set up Jellyfin libraries** pointing to your media folders
4. **Request content** through Jellyseerr and watch it appear!

## 🛠️ Management

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop everything
docker-compose down

# Update services
docker-compose pull && docker-compose up -d
```

## 🆘 Need Help?

See `INSTALL.md` for detailed setup instructions and troubleshooting.

---

**⚠️ Important**: This is for educational purposes. Ensure you comply with your local laws regarding content downloading and VPN usage.

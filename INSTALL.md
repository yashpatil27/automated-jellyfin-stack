# Automated Jellyfin Media Stack - Quick Install Guide

This repository provides a fully automated setup for a complete media server stack with minimal manual configuration required.

## What You Get

- **Jellyfin**: Media streaming server
- **Sonarr**: TV show management and downloading
- **Radarr**: Movie management and downloading  
- **Prowlarr**: Indexer management (torrent sites)
- **qBittorrent**: Torrent client (secured via VPN)
- **Bazarr**: Subtitle management
- **Jellyseerr**: User-friendly request interface
- **Mullvad VPN**: Secure VPN for all torrent traffic

## Prerequisites

- Docker and Docker Compose installed
- A Mullvad VPN account (get one at https://mullvad.net)
- Python 3 (for advanced configuration script)

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url> automated-jellyfin
cd automated-jellyfin
```

### 2. Run Setup Script

```bash
./setup.sh
```

This script will:
- Prompt for your Mullvad VPN account number
- Create necessary directories
- Start all Docker containers
- Wait for services to initialize

### 3. (Optional) Run Advanced Configuration

For automatic inter-service connections:

```bash
python3 configure.py
```

This will automatically:
- Configure Prowlarr to connect to Sonarr and Radarr
- Set up qBittorrent as download client in both Sonarr and Radarr
- Configure basic settings for optimal operation

## Access Your Services

After setup completes (2-3 minutes), access your services:

- **Jellyfin**: http://localhost:8096 (media streaming)
- **Jellyseerr**: http://localhost:5055 (request movies/shows)
- **Prowlarr**: http://localhost:9696 (add torrent indexers)
- **Sonarr**: http://localhost:8989 (TV show management)
- **Radarr**: http://localhost:7878 (movie management)
- **qBittorrent**: http://localhost:8085 (torrent client)
- **Bazarr**: http://localhost:6767 (subtitles)

## Manual Steps Required

### 1. Add Indexers in Prowlarr
- Visit http://localhost:9696
- Go to Indexers → Add Indexer
- Add your preferred torrent sites (1337x, RARBG, etc.)

### 2. Configure Jellyseerr
- Visit http://localhost:5055
- Connect to Jellyfin server: http://jellyfin:8096
- Connect to Sonarr: http://sonarr:8989
- Connect to Radarr: http://radarr:7878

### 3. Set up Jellyfin Libraries
- Visit http://localhost:8096
- Add libraries pointing to:
  - Movies: `/media/movies`
  - TV Shows: `/media/tv`

## File Structure

```
automated-jellyfin/
├── docker-compose.yml       # Main container configuration
├── setup.sh                # Basic setup script
├── configure.py            # Advanced configuration script
├── INSTALL.md              # This file
├── configs/                # Configuration templates
├── media/
│   ├── movies/            # Downloaded movies appear here
│   └── tv/                # Downloaded TV shows appear here
├── downloads/             # Temporary download location
└── [service-folders]/     # Config data for each service
```

## How It Works

1. **Request**: Use Jellyseerr to request movies/TV shows
2. **Search**: Prowlarr searches configured indexers
3. **Download**: Sonarr/Radarr send torrents to qBittorrent
4. **Transfer**: Files are moved to media folders when complete
5. **Stream**: Jellyfin makes content available for streaming

## Security Features

- All torrent traffic goes through Mullvad VPN
- qBittorrent has VPN kill-switch (no downloads without VPN)
- Services are isolated in separate Docker networks
- No personal data exposed to torrent swarms

## Troubleshooting

### Services won't start
```bash
docker-compose logs [service-name]
docker-compose down && docker-compose up -d
```

### VPN not working
- Check your Mullvad account status
- Verify account number in docker-compose.yml
- Check VPN logs: `docker-compose logs mullvad-vpn`

### Can't connect services
- Run the Python configuration script: `python3 configure.py`
- Check network connectivity: `docker network ls`

### No downloads happening
1. Add indexers in Prowlarr
2. Verify Prowlarr is connected to Sonarr/Radarr
3. Check qBittorrent is working via VPN
4. Test by requesting content in Jellyseerr

## Updating

To update services:
```bash
docker-compose pull
docker-compose up -d
```

## Backup

Backup your configuration:
```bash
tar -czf backup-$(date +%Y%m%d).tar.gz */config docker-compose.yml
```

---

**Note**: This setup is for educational purposes. Ensure you comply with your local laws regarding content downloading and VPN usage.

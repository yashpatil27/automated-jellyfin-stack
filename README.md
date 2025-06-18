# Automated Jellyfin Media Stack

This Docker Compose setup provides a complete media server stack with Jellyfin, Sonarr, Radarr, Prowlarr, qBittorrent, Bazarr, and Jellyseerr, all secured through a Mullvad VPN connection.

## Services Overview

- **Jellyfin**: Media server for streaming movies and TV shows
- **Sonarr**: TV show management and automated downloading
- **Radarr**: Movie management and automated downloading
- **Prowlarr**: Indexer manager for torrent sites
- **qBittorrent**: Torrent client
- **Bazarr**: Subtitle management
- **Jellyseerr**: Request management for movies and TV shows
- **Mullvad VPN**: VPN service for secure torrenting

## Network Architecture

This setup uses two Docker networks to ensure proper communication while maintaining VPN security:

### Media Network (`media-network`)
- Contains: Jellyfin, Sonarr, Radarr, Bazarr, Jellyseerr, and Prowlarr
- Purpose: Internal communication between media services
- No VPN routing - direct internet access for API calls and metadata

### VPN Network (`vpn-network`)
- Contains: Mullvad VPN, Prowlarr, and qBittorrent (via network_mode)
- Purpose: Secure torrenting through VPN
- All traffic routed through Mullvad VPN

### Why This Design?
- **Prowlarr** needs access to both networks:
  - `media-network`: To communicate with Sonarr/Radarr using hostnames
  - `vpn-network`: To search torrent indexers through VPN
- **qBittorrent** uses `network_mode: "service:mullvad-vpn"` for complete VPN isolation
- Other services on `media-network` can access external APIs without VPN

## Setup Instructions

### Prerequisites
1. Docker and Docker Compose installed
2. Mullvad VPN account with valid credentials

### Initial Setup

1. **Clone/Download this configuration**:
   ```bash
   cd /home/oem/automated_jellyfin
   ```

2. **Update Mullvad credentials** in `docker-compose.yml`:
   ```yaml
   environment:
     - OPENVPN_USER=YOUR_MULLVAD_ACCOUNT_NUMBER
     - OPENVPN_PASSWORD=m
   ```

3. **Start the services**:
   ```bash
   docker-compose up -d
   ```

4. **Wait for services to initialize** (2-3 minutes):
   ```bash
   docker-compose logs -f
   ```

### Service Configuration

#### Access URLs
- Jellyfin: http://localhost:8096
- Sonarr: http://localhost:8989
- Radarr: http://localhost:7878
- Prowlarr: http://localhost:9696
- qBittorrent: http://localhost:8085
- Bazarr: http://localhost:6767
- Jellyseerr: http://localhost:5055

#### Configuring Prowlarr with Sonarr/Radarr

**IMPORTANT**: With the new network configuration, you can now use hostnames in Prowlarr:

1. **Access Prowlarr**: http://localhost:9696

2. **Add Radarr Application**:
   - Go to Settings → Apps → Add Application
   - Select "Radarr"
   - Server: `http://radarr:7878` (hostname works now!)
   - API Key: Get from Radarr Settings → General → API Key

3. **Add Sonarr Application**:
   - Go to Settings → Apps → Add Application
   - Select "Sonarr"
   - Server: `http://sonarr:8989` (hostname works now!)
   - API Key: Get from Sonarr Settings → General → API Key

#### Configuring Download Client in Sonarr/Radarr

1. **In Sonarr** (Settings → Download Clients):
   - Add qBittorrent
   - Host: `mullvad-vpn` (since qBittorrent shares VPN network)
   - Port: `8085`
   - Username/Password: From qBittorrent web UI

2. **In Radarr** (Settings → Download Clients):
   - Same configuration as Sonarr above

## Troubleshooting

### Network Connectivity Issues

1. **Check container networks**:
   ```bash
   docker network ls
   docker network inspect automated_jellyfin_media-network
   docker network inspect automated_jellyfin_vpn-network
   ```

2. **Test hostname resolution from Prowlarr**:
   ```bash
   docker exec prowlarr nslookup radarr
   docker exec prowlarr nslookup sonarr
   ```

3. **Check VPN connection**:
   ```bash
   docker exec mullvad-vpn curl -s https://ipinfo.io/json
   ```

### Service Communication Test

1. **Test Prowlarr → Radarr connection**:
   ```bash
   docker exec prowlarr curl -I http://radarr:7878
   ```

2. **Test Prowlarr → Sonarr connection**:
   ```bash
   docker exec prowlarr curl -I http://sonarr:8989
   ```

### Common Issues

#### "Name doesn't resolve" Error
This error should be resolved with the new network configuration. If it persists:
1. Restart the stack: `docker-compose down && docker-compose up -d`
2. Check that both services are on the same network
3. Verify DNS resolution as shown above

#### VPN Not Working
1. Check Mullvad account status
2. Verify credentials in docker-compose.yml
3. Check logs: `docker-compose logs mullvad-vpn`

#### Permission Issues
1. Ensure PUID/PGID (29999) has access to mounted directories
2. Check directory ownership: `ls -la ./media ./downloads`

## File Structure

```
/home/oem/automated_jellyfin/
├── docker-compose.yml
├── README.md
├── jellyfin/
│   └── config/
├── sonarr/
├── radarr/
├── prowlarr/
├── qbittorrent/
├── bazarr/
├── jellyseerr/
├── media/
│   ├── movies/
│   └── tv/
└── downloads/
```

## Maintenance

### Updating Services
```bash
docker-compose pull
docker-compose up -d
```

### Backup Configuration
```bash
tar -czf jellyfin-backup-$(date +%Y%m%d).tar.gz ./*/config ./docker-compose.yml
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f prowlarr
```

## Security Notes

1. **VPN Kill Switch**: qBittorrent traffic is routed through VPN only
2. **Network Isolation**: Torrenting traffic is isolated from other services
3. **API Security**: Consider setting up reverse proxy with SSL for external access
4. **Credentials**: Keep Mullvad credentials secure and rotate regularly

## Port Reference

| Service | Internal Port | External Port | Network |
|---------|---------------|---------------|---------|
| Jellyfin | 8096 | 8096 | media-network |
| Sonarr | 8989 | 8989 | media-network |
| Radarr | 7878 | 7878 | media-network |
| Prowlarr | 9696 | 9696 | both networks |
| qBittorrent | 8085 | 8085 | vpn-network (via mullvad) |
| Bazarr | 6767 | 6767 | media-network |
| Jellyseerr | 5055 | 5055 | media-network |

---

**Note**: This configuration ensures Prowlarr can communicate with both Sonarr/Radarr (via media-network) and torrent indexers (via VPN network), solving the "name doesn't resolve" issue while maintaining security.

## Quick Deploy Instructions

Now that the configuration is updated, restart your services:

```bash
cd /home/oem/automated_jellyfin
docker-compose down
docker-compose up -d
```

After services start (2-3 minutes), you can now configure Prowlarr using hostnames:
- **Radarr**: `http://radarr:7878`  
- **Sonarr**: `http://sonarr:8989`

The "name doesn't resolve" error should now be fixed! 🎉


#!/bin/bash

echo "🚀 Optimizing qBittorrent for Better Speeds"
echo "==========================================="

# Backup current config
docker exec qbittorrent cp /config/qBittorrent/qBittorrent.conf /config/qBittorrent/qBittorrent.conf.backup

# Create optimized configuration
cat > /tmp/qbittorrent-optimized.conf << 'QBIT_EOF'
[Application]
FileLogger\Age=1
FileLogger\AgeType=1
FileLogger\Backup=true
FileLogger\DeleteOld=true
FileLogger\Enabled=true
FileLogger\MaxSizeBytes=66560
FileLogger\Path=/config/qBittorrent/logs

[AutoRun]
enabled=false
program=

[BitTorrent]
Session\AddTorrentStopped=false
Session\DefaultSavePath=/downloads/
Session\ExcludedFileNames=
Session\Interface=tun0
Session\InterfaceName=tun0
Session\MaxActiveDownloads=10
Session\MaxActiveTorrents=20
Session\MaxActiveUploads=10
Session\Port=6881
Session\QueueingSystemEnabled=true
Session\SSL\Port=17996
Session\ShareLimitAction=Stop
Session\TempPath=/downloads/incomplete/
Session\GlobalMaxSeedingMinutes=10080
Session\MaxRatio=2
Session\MaxUploads=10
Session\MaxConnections=500
Session\MaxConnectionsPerTorrent=100
Session\MaxUploadsPerTorrent=4
Session\IgnoreLimitsOnLAN=true
Session\IncludeOverheadInLimits=false
Session\AnnounceToAllTrackers=true
Session\AnnounceToAllTiers=true

[Core]
AutoDeleteAddedTorrentFile=Never

[LegalNotice]
Accepted=true

[Meta]
MigrationVersion=4

[Network]
Cookies=@Invalid()
PortForwardingEnabled=true

[Preferences]
Advanced\RecheckOnCompletion=false
Advanced\trackerPort=9000
Bittorrent\MaxConnecs=500
Bittorrent\MaxConnecsPerTorrent=100
Bittorrent\MaxRatioAction=0
Bittorrent\MaxUploads=10
Bittorrent\MaxUploadsPerTorrent=4
Connection\GlobalDLLimit=0
Connection\GlobalUPLimit=0
Connection\PortRangeMin=6881
Connection\PortRangeMax=6881
Downloads\NewAdditionDialog=false
Downloads\NewAdditionDialogFront=true
General\Locale=
General\UseRandomPort=false
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelistEnabled=true
WebUI\AuthSubnetWhitelist=172.0.0.0/8, 192.168.0.0/16
WebUI\BanDuration=3600
WebUI\CSRFProtection=true
WebUI\ClickjackingProtection=true
WebUI\LocalHostAuth=false
WebUI\MaxAuthenticationFailCount=5
WebUI\Port=8085
WebUI\SecureCookie=true
WebUI\UseUPnP=false
WebUI\Username=admin
QBIT_EOF

# Copy optimized config to container
docker cp /tmp/qbittorrent-optimized.conf qbittorrent:/config/qBittorrent/qBittorrent.conf

# Restart qBittorrent to apply changes
echo "Restarting qBittorrent with optimized settings..."
docker-compose restart qbittorrent

# Wait for restart
sleep 10

echo "✅ qBittorrent optimized!"
echo ""
echo "🎯 Changes Applied:"
echo "   • Max Downloads: 3 → 10"
echo "   • Max Torrents: 8 → 20" 
echo "   • Max Connections: Default → 500"
echo "   • Connections per torrent: Default → 100"
echo "   • Upload optimization enabled"
echo "   • Port forwarding enabled"
echo ""
echo "🚀 Try downloading a popular torrent to test speeds!"

# Cleanup
rm /tmp/qbittorrent-optimized.conf

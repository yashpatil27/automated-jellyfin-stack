# Function to apply qBittorrent speed optimizations
optimize_qbittorrent_config() {
    print_step "Applying qBittorrent speed optimizations..."
    
    # Wait for qBittorrent to be fully ready
    sleep 30
    
    # Create optimized qBittorrent configuration
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

    # Wait for qBittorrent container to be ready
    if docker ps | grep -q qbittorrent; then
        # Copy optimized config to container
        docker cp /tmp/qbittorrent-optimized.conf qbittorrent:/config/qBittorrent/qBittorrent.conf
        
        # Restart qBittorrent to apply changes
        print_status "Restarting qBittorrent with optimized settings..."
        docker-compose restart qbittorrent
        
        # Wait for restart
        sleep 10
        wait_for_service "$QBITTORRENT_URL" "qBittorrent"
        
        print_success "qBittorrent optimized for maximum speed!"
        print_status "Speed improvements: 10 downloads, 500 connections, port forwarding enabled"
    else
        print_warning "qBittorrent container not found - optimization skipped"
    fi
    
    # Cleanup
    rm -f /tmp/qbittorrent-optimized.conf
}

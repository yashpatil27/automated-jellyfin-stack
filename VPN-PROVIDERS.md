# 🔒 Supported VPN Providers

The automated Jellyfin setup supports multiple VPN providers for secure torrenting. All torrent traffic is routed through your chosen VPN to protect your privacy.

## 🌟 Supported Providers

### 1. 🥇 Mullvad (Recommended)
- **Privacy**: Excellent (no logs, anonymous accounts)
- **Speed**: Very fast
- **Torrenting**: Optimized for P2P
- **Setup**: Account number only (no password needed)
- **Cost**: €5/month
- **Why recommended**: Best privacy, P2P friendly, simple setup

### 2. 🌐 NordVPN
- **Privacy**: Good (no logs policy)
- **Speed**: Fast
- **Torrenting**: P2P servers available
- **Setup**: Username + password
- **Cost**: Varies with subscription
- **Features**: Large server network, specialty servers

### 3. ⚡ ExpressVPN
- **Privacy**: Good (no logs policy)
- **Speed**: Very fast
- **Torrenting**: Allowed on all servers
- **Setup**: Username + password
- **Cost**: Premium pricing
- **Features**: Fast speeds, reliable connections

### 4. 🦈 Surfshark
- **Privacy**: Good (no logs policy)
- **Speed**: Good
- **Torrenting**: P2P supported
- **Setup**: Username + password
- **Cost**: Budget friendly
- **Features**: Unlimited devices, good value

### 5. 🛡️ ProtonVPN
- **Privacy**: Excellent (Swiss privacy laws)
- **Speed**: Good
- **Torrenting**: Plus tier and above
- **Setup**: Username + password
- **Cost**: Free tier available
- **Features**: Open source, security focused

## 🚀 Quick Setup Guide

### During Installation:
1. **Choose your provider** from the list (1-5)
2. **Enter credentials**:
   - **Mullvad**: Just your account number
   - **Others**: Username and password
3. **Select country** for server location
4. **Setup continues automatically**

### Example Credentials:

#### Mullvad
```
Username: 1234567890123456  (Your account number)
Password: (not needed - auto-filled)
```

#### NordVPN/ExpressVPN/Surfshark/ProtonVPN
```
Username: your-vpn-username
Password: your-vpn-password
```

## 🌍 Country Selection

Popular server locations:
- **Netherlands**: Good privacy laws, fast connections
- **Switzerland**: Strong privacy protections
- **Sweden**: Privacy-friendly jurisdiction
- **Germany**: Fast speeds, good connectivity
- **United States**: If you need US content access

## 🔧 Technical Details

### How It Works:
1. **VPN Container**: Runs your chosen VPN client
2. **qBittorrent Routing**: All torrent traffic through VPN
3. **Kill Switch**: If VPN disconnects, torrenting stops
4. **DNS Protection**: All DNS queries through VPN
5. **Other Services**: Media servers use direct connection for speed

### Network Architecture:
- **VPN Network**: qBittorrent, Prowlarr
- **Media Network**: Jellyfin, Sonarr, Radarr, Bazarr
- **Isolation**: Torrent traffic completely separated

## 🛠️ Troubleshooting

### VPN Not Connecting?
1. **Check credentials** in your VPN provider account
2. **Verify subscription** is active
3. **Try different country** if connection fails
4. **Check logs**: `docker-compose logs vpn-service`

### Slow Downloads?
1. **Try different server country** closer to you
2. **Check VPN provider's P2P servers**
3. **Verify your internet speed** without VPN

### Changing VPN Provider?
1. **Stop services**: `docker-compose down`
2. **Run setup again**: `./setup.sh`
3. **Choose different provider**
4. **Reconfigure with new credentials**

## 📊 Provider Comparison

| Provider | Privacy | Speed | P2P | Setup | Cost |
|----------|---------|-------|-----|-------|------|
| Mullvad | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | €5/mo |
| NordVPN | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | $3-12/mo |
| ExpressVPN | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | $6-15/mo |
| Surfshark | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | $2-12/mo |
| ProtonVPN | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Free-$10/mo |

## 🎯 Recommendations

### For Privacy: 
**Mullvad** - Anonymous accounts, no personal info required

### For Speed: 
**ExpressVPN** or **Mullvad** - Consistently fast connections

### For Budget: 
**Surfshark** - Good features at low cost

### For Security: 
**ProtonVPN** or **Mullvad** - Open source, audited

### For Beginners: 
**Mullvad** - Simplest setup, just account number needed

---

**Remember**: Always verify your VPN is working before downloading. The setup includes automatic VPN testing to ensure your traffic is protected.

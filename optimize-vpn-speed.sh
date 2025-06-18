#!/bin/bash

echo "🔒 VPN Speed Optimization"
echo "========================"

echo "Current VPN server: Netherlands (Amsterdam)"
echo ""
echo "Speed optimization options:"
echo ""
echo "1. 🇳🇱 Stay in Netherlands (current)"
echo "2. 🇬🇧 Switch to United Kingdom (closer to EU)"
echo "3. 🇩🇪 Switch to Germany (fast servers)" 
echo "4. 🇸🇪 Switch to Sweden (Mullvad's home)"
echo "5. 🇺🇸 Switch to United States (if you're in US)"
echo "6. 🌐 Let me choose different country"
echo ""
echo -n "Select option (1-6): "
read choice

case $choice in
    2)
        NEW_COUNTRY="United Kingdom"
        ;;
    3)
        NEW_COUNTRY="Germany"
        ;;
    4)
        NEW_COUNTRY="Sweden"
        ;;
    5)
        NEW_COUNTRY="United States"
        ;;
    6)
        echo -n "Enter country name: "
        read NEW_COUNTRY
        ;;
    *)
        echo "Keeping current Netherlands server"
        exit 0
        ;;
esac

echo ""
echo "🔄 Switching VPN server to: $NEW_COUNTRY"

# Update docker-compose.yml
sed -i "s/SERVER_COUNTRIES=.*/SERVER_COUNTRIES=$NEW_COUNTRY/" docker-compose.yml

# Restart VPN to apply new server
echo "Restarting VPN service..."
docker-compose restart mullvad-vpn

# Wait for VPN to reconnect
echo "Waiting for VPN reconnection..."
sleep 30

# Check new IP
echo "🌐 New VPN location:"
docker exec qbittorrent curl -s https://ipinfo.io/json | grep -E '"(ip|city|country)"'

echo ""
echo "✅ VPN server changed to $NEW_COUNTRY"
echo "🚀 Try downloading again to test improved speeds!"

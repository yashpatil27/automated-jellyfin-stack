#!/bin/bash

# Function to create docker-compose.yml with VPN configuration
create_docker_compose_with_vpn() {
    local vpn_provider=$1
    local vpn_username=$2
    local vpn_password=$3
    local vpn_country=$4
    local timezone=$5
    local user_id=$6
    local group_id=$7
    
    # Read VPN template
    local vpn_config=$(cat "$SCRIPT_DIR/configs/vpn-templates/$vpn_provider.yml")
    
    # Replace VPN placeholders
    vpn_config=${vpn_config//VPN_USERNAME_PLACEHOLDER/$vpn_username}
    vpn_config=${vpn_config//VPN_PASSWORD_PLACEHOLDER/$vpn_password}
    vpn_config=${vpn_config//VPN_COUNTRY_PLACEHOLDER/$vpn_country}
    
    # Create temporary file with VPN config
    echo "$vpn_config" > /tmp/vpn_service.yml
    
    # Replace main template placeholders and insert VPN config
    sed "s/TZ=UTC/TZ=$timezone/g; 
         s/PUID=1000/PUID=$user_id/g; 
         s/PGID=1000/PGID=$group_id/g" \
         "$SCRIPT_DIR/docker-compose.template.yml" > /tmp/docker-compose-temp.yml
    
    # Replace VPN placeholder with actual config
    awk '
    /VPN_SERVICE_PLACEHOLDER/ {
        while ((getline line < "/tmp/vpn_service.yml") > 0)
            print line
        close("/tmp/vpn_service.yml")
        next
    }
    {print}
    ' /tmp/docker-compose-temp.yml > "$SCRIPT_DIR/docker-compose.yml"
    
    # Cleanup
    rm -f /tmp/vpn_service.yml /tmp/docker-compose-temp.yml
}

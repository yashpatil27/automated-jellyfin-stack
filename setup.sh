#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"

# Service URLs
SONARR_URL="http://localhost:8989"
RADARR_URL="http://localhost:7878"
PROWLARR_URL="http://localhost:9696"
QBITTORRENT_URL="http://localhost:8085"
BAZARR_URL="http://localhost:6767"
JELLYSEERR_URL="http://localhost:5055"
JELLYFIN_URL="http://localhost:8096"

# Global variables for user input
MULLVAD_ACCOUNT=""
TIMEZONE=""
USER_ID=""
GROUP_ID=""

# Function to print colored output
print_banner() {
    echo -e "${PURPLE}======================================"
    echo -e "🎬 Automated Jellyfin Media Stack 🎬"
    echo -e "======================================"
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$NAME
            OS_VERSION=$VERSION_ID
        elif [ -f /etc/redhat-release ]; then
            OS="Red Hat"
        elif [ -f /etc/debian_version ]; then
            OS="Debian"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
    else
        OS="Unknown"
    fi
    
    print_status "Detected OS: $OS"
}

# Function to install Docker on different systems
install_docker() {
    print_step "Installing Docker..."
    
    case "$OS" in
        *"Ubuntu"*|*"Debian"*|*"Linux Mint"*)
            print_status "Installing Docker for Ubuntu/Debian-based system..."
            
            # Update package index
            sudo apt-get update
            
            # Install prerequisites
            sudo apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
            
            # Add Docker's official GPG key
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            
            # Set up the stable repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Install Docker Engine
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            
            # Add user to docker group
            sudo usermod -aG docker $USER
            
            print_success "Docker installed successfully!"
            ;;
            
        *"CentOS"*|*"Red Hat"*|*"Fedora"*)
            print_status "Installing Docker for Red Hat-based system..."
            
            # Install using dnf/yum
            if command -v dnf > /dev/null 2>&1; then
                sudo dnf install -y docker docker-compose
                sudo systemctl enable --now docker
                sudo usermod -aG docker $USER
            elif command -v yum > /dev/null 2>&1; then
                sudo yum install -y docker docker-compose
                sudo systemctl enable --now docker
                sudo usermod -aG docker $USER
            fi
            
            print_success "Docker installed successfully!"
            ;;
            
        *"Arch"*)
            print_status "Installing Docker for Arch Linux..."
            sudo pacman -S --noconfirm docker docker-compose
            sudo systemctl enable --now docker
            sudo usermod -aG docker $USER
            print_success "Docker installed successfully!"
            ;;
            
        "macOS")
            print_error "macOS detected. Please install Docker Desktop manually from:"
            print_error "https://docs.docker.com/desktop/mac/install/"
            exit 1
            ;;
            
        *)
            print_error "Unsupported operating system: $OS"
            print_error "Please install Docker manually from: https://docs.docker.com/get-docker/"
            exit 1
            ;;
    esac
}

# Function to install Docker Compose
install_docker_compose() {
    print_step "Installing Docker Compose..."
    
    # Get latest version
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    
    # Download and install
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Make executable
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink if needed
    if [ ! -f /usr/bin/docker-compose ]; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
    
    print_success "Docker Compose installed successfully!"
}

# Function to start Docker daemon
start_docker() {
    print_step "Starting Docker daemon..."
    
    if ! docker info > /dev/null 2>&1; then
        case "$OS" in
            *"Ubuntu"*|*"Debian"*|*"Linux Mint"*|*"CentOS"*|*"Red Hat"*|*"Fedora"*|*"Arch"*)
                sudo systemctl start docker
                sudo systemctl enable docker
                ;;
        esac
        
        # Wait for Docker to start
        sleep 5
        
        if ! docker info > /dev/null 2>&1; then
            print_error "Failed to start Docker daemon"
            print_error "You may need to log out and log back in for group changes to take effect"
            print_error "Or try running: newgrp docker"
            exit 1
        fi
    fi
    
    print_success "Docker daemon is running!"
}

# Function to install system dependencies
install_dependencies() {
    print_step "Installing system dependencies..."
    
    case "$OS" in
        *"Ubuntu"*|*"Debian"*|*"Linux Mint"*)
            sudo apt-get update
            sudo apt-get install -y curl wget git python3 python3-pip xmlstarlet
            ;;
        *"CentOS"*|*"Red Hat"*|*"Fedora"*)
            if command -v dnf > /dev/null 2>&1; then
                sudo dnf install -y curl wget git python3 python3-pip xmlstarlet
            else
                sudo yum install -y curl wget git python3 python3-pip xmlstarlet
            fi
            ;;
        *"Arch"*)
            sudo pacman -S --noconfirm curl wget git python python-pip xmlstarlet
            ;;
    esac
    
    # Install Python requests library for configuration script
    if command -v pip3 > /dev/null 2>&1; then
        pip3 install --user requests
    fi
    
    print_success "System dependencies installed!"
}

# Function to check and install prerequisites
check_and_install_prerequisites() {
    print_step "Checking and installing prerequisites..."
    
    # Detect OS first
    detect_os
    
    # Install system dependencies
    install_dependencies
    
    # Check if running as root (not recommended)
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root is not recommended!"
        print_warning "Consider running as a regular user for better security."
        echo -n "Continue anyway? (y/N): "
        read continue_as_root
        if [[ ! "$continue_as_root" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check if Docker is installed
    if ! command -v docker > /dev/null 2>&1; then
        print_warning "Docker not found. Installing Docker..."
        install_docker
        
        # After installing Docker, we need to start it
        start_docker
        
        print_warning "Docker has been installed. You may need to log out and log back in."
        print_warning "If you encounter permission issues, try: newgrp docker"
    else
        print_success "Docker is already installed"
        
        # Make sure Docker daemon is running
        if ! docker info > /dev/null 2>&1; then
            start_docker
        else
            print_success "Docker daemon is running"
        fi
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose > /dev/null 2>&1; then
        print_warning "Docker Compose not found. Installing Docker Compose..."
        install_docker_compose
    else
        print_success "Docker Compose is already installed"
    fi
    
    # Verify installations
    print_step "Verifying installations..."
    
    if docker --version > /dev/null 2>&1; then
        print_success "Docker version: $(docker --version)"
    else
        print_error "Docker installation verification failed"
        exit 1
    fi
    
    if docker-compose --version > /dev/null 2>&1; then
        print_success "Docker Compose version: $(docker-compose --version)"
    else
        print_error "Docker Compose installation verification failed"
        exit 1
    fi
    
    print_success "All prerequisites are installed and working!"
}

# Function to gather user inputs
gather_user_inputs() {
    print_step "Gathering configuration..."
    echo ""
    
    # Mullvad VPN account
    echo -e "${WHITE}🔐 VPN Configuration${NC}"
    echo "Choose your VPN provider for secure torrenting:"
    echo ""
    echo "1) Mullvad (Recommended - Privacy focused)"
    echo "2) NordVPN (Popular choice)"
    echo "3) ExpressVPN (Fast speeds)"
    echo "4) Surfshark (Good value)"
    echo "5) ProtonVPN (Security focused)"
    echo ""
    echo -n "Select VPN provider (1-5, default: 1): "
    read VPN_CHOICE
    
    case $VPN_CHOICE in
        2)
            VPN_PROVIDER="nordvpn"
            VPN_PROVIDER_NAME="NordVPN"
            ;;
        3)
            VPN_PROVIDER="expressvpn"
            VPN_PROVIDER_NAME="ExpressVPN"
            ;;
        4)
            VPN_PROVIDER="surfshark"
            VPN_PROVIDER_NAME="Surfshark"
            ;;
        5)
            VPN_PROVIDER="protonvpn"
            VPN_PROVIDER_NAME="ProtonVPN"
            ;;
        *)
            VPN_PROVIDER="mullvad"
            VPN_PROVIDER_NAME="Mullvad"
            ;;
    esac
    
    echo "Selected: $VPN_PROVIDER_NAME"
    echo ""
    
    echo -n "Enter your $VPN_PROVIDER_NAME username/account: "
    read VPN_USERNAME
    if [ -z "$VPN_USERNAME" ]; then
        print_error "$VPN_PROVIDER_NAME credentials are required"
        exit 1
    fi
    
    if [ "$VPN_PROVIDER" != "mullvad" ]; then
        echo -n "Enter your $VPN_PROVIDER_NAME password: "
        read -s VPN_PASSWORD
        echo ""
        if [ -z "$VPN_PASSWORD" ]; then
            print_error "$VPN_PROVIDER_NAME password is required"
            exit 1
        fi
    else
        VPN_PASSWORD="m"  # Mullvad uses "m" as password
    fi
    
    echo -n "Enter preferred country (default: Netherlands): "
    read VPN_COUNTRY
    if [ -z "$VPN_COUNTRY" ]; then
        VPN_COUNTRY="Netherlands"
    fi
    
    print_success "$VPN_PROVIDER_NAME configuration collected!"

    # Suggest optimal VPN server
    suggest_vpn_server
    echo "Get one at: ${CYAN}https://mullvad.net${NC}"
    echo ""
    while [ -z "$MULLVAD_ACCOUNT" ]; do
        echo -n "Enter your Mullvad account number: "
        read MULLVAD_ACCOUNT
        if [ -z "$MULLVAD_ACCOUNT" ]; then
            print_error "Mullvad account number is required!"
        fi
    done
    
    echo ""
    echo -e "${WHITE}🌍 System Configuration${NC}"
    
    # Timezone
    echo -n "Enter your timezone (default: UTC): "
    read TIMEZONE
    if [ -z "$TIMEZONE" ]; then
        TIMEZONE="UTC"
    fi
    
    # User and Group IDs
    current_uid=$(id -u)
    current_gid=$(id -g)
    
    echo -n "Enter your user ID for file permissions (default: $current_uid): "
    read USER_ID
    if [ -z "$USER_ID" ]; then
        USER_ID=$current_uid
    fi
    
    echo -n "Enter your group ID for file permissions (default: $current_gid): "

    # Theme preference
    echo ""
    echo -e "${WHITE}🎨 Jellyfin Theme Configuration${NC}"
    echo "Apply the beautiful Zesty Cyan theme to Jellyfin?"
    echo "This gives Jellyfin a modern cyan color scheme with custom backgrounds."
    echo -n "Apply Zesty Cyan theme? (Y/n): "
    read APPLY_THEME
    if [[ "$APPLY_THEME" =~ ^[Nn]$ ]]; then
        APPLY_THEME="false"
        echo "Skipping theme - Jellyfin will use default appearance"
    else
        APPLY_THEME="true"
        echo "Zesty Cyan theme will be applied!"
    fi
    read GROUP_ID
    if [ -z "$GROUP_ID" ]; then
        GROUP_ID=$current_gid
    fi
    
    echo ""
    print_success "Configuration collected!"
}

# Function to create docker-compose.yml from template
create_docker_compose() {
    print_step "Creating Docker Compose configuration..."
    
    if [ ! -f "$SCRIPT_DIR/docker-compose.template.yml" ]; then
        print_error "docker-compose.template.yml not found!"
        exit 1
    fi
    
    # Source the docker-compose creation function
    source "$SCRIPT_DIR/create-docker-compose.sh"
    
    # Create docker-compose.yml with VPN configuration
    create_docker_compose_with_vpn "$VPN_PROVIDER" "$VPN_USERNAME" "$VPN_PASSWORD" "$VPN_COUNTRY" "$TIMEZONE" "$USER_ID" "$GROUP_ID"
    
    print_success "Docker Compose configuration created with $VPN_PROVIDER_NAME!"
}

# Function to set up directory structure
setup_directories() {
    print_step "Setting up directory structure..."
    
    # Create necessary directories
    mkdir -p "$SCRIPT_DIR/media/movies"
    mkdir -p "$SCRIPT_DIR/media/tv"
    mkdir -p "$SCRIPT_DIR/downloads"
    mkdir -p "$SCRIPT_DIR/configs"
    
    # Set proper permissions
    sudo chown -R $USER_ID:$GROUP_ID "$SCRIPT_DIR/media" 2>/dev/null || chown -R $USER_ID:$GROUP_ID "$SCRIPT_DIR/media"
    sudo chown -R $USER_ID:$GROUP_ID "$SCRIPT_DIR/downloads" 2>/dev/null || chown -R $USER_ID:$GROUP_ID "$SCRIPT_DIR/downloads"
    chmod -R 755 "$SCRIPT_DIR/media"
    chmod -R 755 "$SCRIPT_DIR/downloads"
    
    # Create .gitkeep files to preserve empty directories in git
    touch "$SCRIPT_DIR/media/movies/.gitkeep"
    touch "$SCRIPT_DIR/media/tv/.gitkeep"
    touch "$SCRIPT_DIR/downloads/.gitkeep"
    
    print_success "Directory structure created!"
}

# Function to wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=60
    local attempt=1

    print_status "Waiting for $service_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            print_success "$service_name is ready!"
            return 0
        fi
        
        if [ $((attempt % 10)) -eq 0 ]; then
            echo "   Still waiting for $service_name... (${attempt}s)"
        else
            echo -n "."
        fi
        
        sleep 5
        ((attempt++))
    done
    
    print_error "$service_name failed to start within expected time"
    return 1
}

# Function to start Docker services
start_services() {
    print_step "Starting Docker services..."
    
    cd "$SCRIPT_DIR"
    
    # Stop existing containers if any
    docker-compose down 2>/dev/null || true
    
    # Pull latest images
    print_status "Pulling latest Docker images..."
    docker-compose pull
    
    # Start services
    print_status "Starting all services..."
    docker-compose up -d
    
    print_success "Docker services started!"
}

# Function to wait for all services
wait_for_all_services() {
    print_step "Waiting for services to initialize..."
    echo "This may take 2-3 minutes for first-time setup..."
    echo ""
    
    # Give services initial time to start
    sleep 30
    
    # Wait for each service
    wait_for_service "$JELLYFIN_URL" "Jellyfin"
    wait_for_service "$PROWLARR_URL" "Prowlarr"
    wait_for_service "$SONARR_URL" "Sonarr"
    wait_for_service "$RADARR_URL" "Radarr"
    wait_for_service "$QBITTORRENT_URL" "qBittorrent"
    wait_for_service "$BAZARR_URL" "Bazarr"
    wait_for_service "$JELLYSEERR_URL" "Jellyseerr"
    
    print_success "All services are running!"
}

# Function to run post-setup configuration
    configure_metadata_sources
run_post_setup() {
    apply_jellyfin_theme
    optimize_qbittorrent_config
    print_step "Running post-setup configuration..."
    
    # Check if Python configuration script exists
    if [ -f "$SCRIPT_DIR/configure.py" ]; then
        print_status "Running automatic service configuration..."
        
        # Wait a bit more for services to fully initialize
        sleep 30
        
        if command -v python3 > /dev/null 2>&1; then
            python3 "$SCRIPT_DIR/configure.py" || print_warning "Automatic configuration partially failed - manual setup may be required"
        else
            print_warning "Python3 not found - skipping automatic configuration"
        fi
    fi
}

# Function to display final information
display_final_info() {
    echo ""
    echo -e "${GREEN}======================================"
    echo -e "🎉      Setup Complete!      🎉"
    echo -e "======================================${NC}"
    echo ""
    echo -e "${WHITE}📺 Your Media Stack Services:${NC}"
    echo ""
    echo -e "   🎬 ${CYAN}Jellyfin (streaming):${NC}     $JELLYFIN_URL"
    echo -e "   📝 ${CYAN}Jellyseerr (requests):${NC}    $JELLYSEERR_URL"
    echo -e "   🔍 ${CYAN}Prowlarr (indexers):${NC}      $PROWLARR_URL"
    echo -e "   📺 ${CYAN}Sonarr (TV shows):${NC}        $SONARR_URL"
    echo -e "   🔒 ${CYAN}VPN ($VPN_PROVIDER_NAME):${NC}         Securing torrent traffic"
    echo -e "   🎥 ${CYAN}Radarr (movies):${NC}          $RADARR_URL"
    echo -e "   📦 ${CYAN}qBittorrent (torrents):${NC}   $QBITTORRENT_URL"
    echo -e "   💬 ${CYAN}Bazarr (subtitles):${NC}       $BAZARR_URL"
    echo ""
    echo -e "${WHITE}🔧 Next Steps:${NC}"
    echo -e "   1️⃣  Add indexers in ${CYAN}Prowlarr${NC} ($PROWLARR_URL)"
    echo -e "   2️⃣  Configure ${CYAN}Jellyseerr${NC} ($JELLYSEERR_URL)"
    echo -e "   3️⃣  Set up ${CYAN}Jellyfin${NC} libraries ($JELLYFIN_URL)"
    echo -e "   4️⃣  Test by requesting content through ${CYAN}Jellyseerr${NC}"
    echo -e "   5️⃣  Enjoy ${CYAN}optimized torrent speeds${NC} (10 downloads, 500 connections)"

    if [ "$APPLY_THEME" = "true" ]; then
        echo -e "   5️⃣  Enjoy the ${CYAN}Zesty Cyan theme${NC} in Jellyfin!"
    fi
    echo ""
    echo -e "${WHITE}📖 Documentation:${NC}"
    echo -e "   • See ${CYAN}INSTALL.md${NC} for detailed setup instructions"
    echo -e "   • See ${CYAN}README.md${NC} for troubleshooting and advanced configuration"
    echo ""
    echo -e "${WHITE}🛠️  Management Commands:${NC}"
    echo -e "   • View logs: ${CYAN}docker-compose logs -f${NC}"
    echo -e "   • Restart services: ${CYAN}docker-compose restart${NC}"
    echo -e "   • Stop services: ${CYAN}docker-compose down${NC}"
    echo -e "   • Update services: ${CYAN}docker-compose pull && docker-compose up -d${NC}"
    echo ""
    echo -e "${GREEN}🎊 Happy streaming!${NC}"
    echo ""
    
    if [[ "$NEW_DOCKER_INSTALL" == "true" ]]; then
        echo -e "${YELLOW}⚠️  Note: If you encounter Docker permission issues, try:${NC}"
        echo -e "   ${CYAN}newgrp docker${NC} or log out and log back in"
        echo ""
    fi
}

# Main function
main() {
    # Clear screen and show banner
    clear
    print_banner
    
    NEW_DOCKER_INSTALL="false"
    
    # Check if Docker was already installed
    if ! command -v docker > /dev/null 2>&1; then
        NEW_DOCKER_INSTALL="true"
    fi
    
    # Run setup steps
    check_and_install_prerequisites
    gather_user_inputs
    create_docker_compose
    setup_directories
    start_services
    wait_for_all_services
    configure_metadata_sources
    run_post_setup
    apply_jellyfin_theme
    optimize_qbittorrent_config
    display_final_info
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Function to configure metadata sources
configure_metadata_sources() {
    print_step "Configuring metadata sources..."
    
    if [ -n "$TMDB_API_KEY" ]; then
        print_status "Using TMDB as primary metadata source"
        # Configure TMDB as primary
        if [ -f "$SCRIPT_DIR/configs/jellyseerr-config.json" ]; then
            sed -i "s/TMDB_API_KEY_PLACEHOLDER/$TMDB_API_KEY/" "$SCRIPT_DIR/configs/jellyseerr-config.json"
        fi
    else
        print_status "Using OMDB as fallback metadata source (no API key required)"
        # Use OMDB as fallback
        if [ -f "$SCRIPT_DIR/configs/jellyseerr-config.json" ]; then
            sed -i 's/"apiKey": "TMDB_API_KEY_PLACEHOLDER"/"apiKey": ""/' "$SCRIPT_DIR/configs/jellyseerr-config.json"
        fi
    fi
    
    print_success "Metadata sources configured!"
}

# Function to apply Jellyfin theme
apply_jellyfin_theme() {
    optimize_qbittorrent_config
    if [ "$APPLY_THEME" = "true" ]; then
        print_step "Applying Zesty Cyan theme to Jellyfin..."
        
        # Wait for Jellyfin to be fully ready
        sleep 30
        
        # Copy theme to Jellyfin container
        if docker ps | grep -q jellyfin; then
            docker cp "$SCRIPT_DIR/themes/jellyfin/zesty-cyan-theme.css" jellyfin:/config/custom.css
            
            # Restart Jellyfin to apply theme
            print_status "Restarting Jellyfin to apply theme..."
            docker-compose restart jellyfin
            
            # Wait for restart
            sleep 15
            wait_for_service "$JELLYFIN_URL" "Jellyfin"
            
            print_success "Zesty Cyan theme applied to Jellyfin!"
        else
            print_warning "Jellyfin container not found - theme not applied"
        fi
    else
        print_status "Skipping theme application - using default Jellyfin appearance"
    fi
}
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

# Function to suggest optimal VPN server based on location
suggest_vpn_server() {
    print_step "Detecting optimal VPN server location..."
    
    # Detect user's country
    USER_COUNTRY=$(curl -s https://ipinfo.io/json | grep '"country"' | cut -d'"' -f4 2>/dev/null || echo "")
    
    # Suggest optimal server based on location
    case "$USER_COUNTRY" in
        "IN"|"BD"|"LK"|"PK"|"NP")  # South Asia
            SUGGESTED_COUNTRY="Singapore"
            REGION="Asia"
            ;;
        "CN"|"JP"|"KR"|"TH"|"VN"|"MY"|"ID"|"PH")  # East/Southeast Asia
            SUGGESTED_COUNTRY="Singapore"
            REGION="Asia"
            ;;
        "AU"|"NZ")  # Oceania
            SUGGESTED_COUNTRY="Australia"
            REGION="Oceania"
            ;;
        "US"|"CA"|"MX")  # North America
            SUGGESTED_COUNTRY="United States"
            REGION="North America"
            ;;
        "BR"|"AR"|"CL"|"CO"|"PE")  # South America
            SUGGESTED_COUNTRY="United States"
            REGION="Americas"
            ;;
        "GB"|"IE")  # UK/Ireland
            SUGGESTED_COUNTRY="United Kingdom"
            REGION="Europe"
            ;;
        "DE"|"AT"|"CH"|"NL"|"BE"|"LU")  # Central Europe
            SUGGESTED_COUNTRY="Germany"
            REGION="Europe"
            ;;
        "SE"|"NO"|"DK"|"FI")  # Nordic
            SUGGESTED_COUNTRY="Sweden"
            REGION="Europe"
            ;;
        "FR"|"ES"|"IT"|"PT")  # Southern Europe
            SUGGESTED_COUNTRY="France"
            REGION="Europe"
            ;;
        "PL"|"CZ"|"SK"|"HU"|"RO"|"BG")  # Eastern Europe
            SUGGESTED_COUNTRY="Germany"
            REGION="Europe"
            ;;
        "RU"|"UA"|"BY")  # Eastern Europe/Russia
            SUGGESTED_COUNTRY="Sweden"
            REGION="Europe"
            ;;
        *)  # Default
            SUGGESTED_COUNTRY="Netherlands"
            REGION="Europe (Default)"
            ;;
    esac
    
    if [ -n "$USER_COUNTRY" ]; then
        print_success "Detected location: $USER_COUNTRY"
        print_success "Optimal VPN server: $SUGGESTED_COUNTRY ($REGION)"
    else
        print_warning "Could not detect location - using default: $SUGGESTED_COUNTRY"
    fi
    
    # Update VPN_COUNTRY with suggestion if not already set
    if [ -z "$VPN_COUNTRY" ] || [ "$VPN_COUNTRY" = "Netherlands" ]; then
        VPN_COUNTRY="$SUGGESTED_COUNTRY"
        print_status "Using optimized server: $VPN_COUNTRY"
    fi
}

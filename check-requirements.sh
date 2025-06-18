#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🔍 Checking system compatibility for Automated Jellyfin Media Stack..."
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    fi
    echo -e "✅ Operating System: ${GREEN}$OS (Supported)${NC}"
else
    echo -e "❌ Operating System: ${RED}$OSTYPE (Not supported)${NC}"
    echo "   This script supports Linux distributions only"
    exit 1
fi

echo ""
echo -e "${BLUE}📦 Dependencies that will be installed automatically:${NC}"

# Check Docker
if command -v docker > /dev/null 2>&1; then
    echo -e "✅ Docker: ${GREEN}Already installed${NC}"
    if docker info > /dev/null 2>&1; then
        echo -e "✅ Docker Daemon: ${GREEN}Running${NC}"
    else
        echo -e "⚠️  Docker Daemon: ${YELLOW}Not running (will be started)${NC}"
    fi
else
    echo -e "📦 Docker: ${YELLOW}Will be installed automatically${NC}"
fi

# Check Docker Compose
if command -v docker-compose > /dev/null 2>&1; then
    echo -e "✅ Docker Compose: ${GREEN}Already installed${NC}"
else
    echo -e "📦 Docker Compose: ${YELLOW}Will be installed automatically${NC}"
fi

# Check curl
if command -v curl > /dev/null 2>&1; then
    echo -e "✅ curl: ${GREEN}Already installed${NC}"
else
    echo -e "📦 curl: ${YELLOW}Will be installed automatically${NC}"
fi

# Check git
if command -v git > /dev/null 2>&1; then
    echo -e "✅ git: ${GREEN}Already installed${NC}"
else
    echo -e "📦 git: ${YELLOW}Will be installed automatically${NC}"
fi

# Check Python (optional)
if command -v python3 > /dev/null 2>&1; then
    echo -e "✅ Python3: ${GREEN}Already installed${NC}"
else
    echo -e "📦 Python3: ${YELLOW}Will be installed automatically${NC}"
fi

echo ""
echo -e "${BLUE}🔐 What you need to provide:${NC}"
echo -e "   • Mullvad VPN account (get one at ${BLUE}https://mullvad.net${NC})"
echo -e "   • Your timezone preference"
echo -e "   • File permission preferences (or use defaults)"

echo ""
echo -e "${GREEN}✨ Ready to install!${NC}"
echo ""
echo -e "🚀 Run: ${BLUE}./setup.sh${NC}"
echo ""
echo -e "${YELLOW}Note: The script will ask for sudo password to install system dependencies${NC}"

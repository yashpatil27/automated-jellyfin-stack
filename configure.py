#!/usr/bin/env python3

import requests
import json
import time
import sys
import os
import xml.etree.ElementTree as ET
from pathlib import Path

class MediaStackConfigurator:
    def __init__(self):
        self.base_dir = Path(__file__).parent
        self.services = {
            'sonarr': {'url': 'http://localhost:8989', 'api_version': 'v3'},
            'radarr': {'url': 'http://localhost:7878', 'api_version': 'v3'},
            'prowlarr': {'url': 'http://localhost:9696', 'api_version': 'v1'},
            'bazarr': {'url': 'http://localhost:6767', 'api_version': 'v1'},
            'jellyseerr': {'url': 'http://localhost:5055', 'api_version': 'v1'}
        }
        self.api_keys = {}
        
    def print_status(self, message):
        print(f"[INFO] {message}")
        
    def print_success(self, message):
        print(f"[SUCCESS] {message}")
        
    def print_error(self, message):
        print(f"[ERROR] {message}")
        
    def wait_for_service(self, service_name, max_attempts=60):
        """Wait for a service to be ready"""
        url = self.services[service_name]['url']
        self.print_status(f"Waiting for {service_name} to be ready...")
        
        for attempt in range(max_attempts):
            try:
                response = requests.get(url, timeout=5)
                if response.status_code == 200:
                    self.print_success(f"{service_name} is ready!")
                    return True
            except requests.exceptions.RequestException:
                pass
            
            print(".", end="", flush=True)
            time.sleep(5)
            
        self.print_error(f"{service_name} failed to start")
        return False
        
    def get_api_key(self, service_name):
        """Extract API key from service config file"""
        config_paths = {
            'sonarr': self.base_dir / 'sonarr' / 'config.xml',
            'radarr': self.base_dir / 'radarr' / 'config.xml',
            'prowlarr': self.base_dir / 'prowlarr' / 'config.xml',
            'bazarr': self.base_dir / 'bazarr' / 'config' / 'config.yaml'
        }
        
        config_path = config_paths.get(service_name)
        if not config_path or not config_path.exists():
            self.print_error(f"Config file not found for {service_name}")
            return None
            
        try:
            if service_name == 'bazarr':
                # Bazarr uses YAML config
                with open(config_path, 'r') as f:
                    content = f.read()
                    # Simple extraction for API key
                    for line in content.split('\n'):
                        if 'apikey:' in line:
                            return line.split(':')[1].strip()
            else:
                # XML config for Sonarr/Radarr/Prowlarr
                tree = ET.parse(config_path)
                root = tree.getroot()
                api_key_elem = root.find('.//ApiKey')
                if api_key_elem is not None:
                    return api_key_elem.text
                    
        except Exception as e:
            self.print_error(f"Error reading config for {service_name}: {e}")
            
        return None
        
    def make_api_request(self, service_name, endpoint, method='GET', data=None):
        """Make API request to service"""
        if service_name not in self.api_keys:
            return None
            
        base_url = self.services[service_name]['url']
        api_version = self.services[service_name]['api_version']
        url = f"{base_url}/api/{api_version}/{endpoint}"
        
        headers = {
            'X-Api-Key': self.api_keys[service_name],
            'Content-Type': 'application/json'
        }
        
        try:
            if method == 'GET':
                response = requests.get(url, headers=headers)
            elif method == 'POST':
                response = requests.post(url, headers=headers, json=data)
            elif method == 'PUT':
                response = requests.put(url, headers=headers, json=data)
                
            return response
        except Exception as e:
            self.print_error(f"API request failed for {service_name}: {e}")
            return None
            
    def configure_prowlarr(self):
        """Configure Prowlarr with indexers and applications"""
        self.print_status("Configuring Prowlarr...")
        
        # Add Sonarr application
        if 'sonarr' in self.api_keys:
            sonarr_app = {
                "name": "Sonarr",
                "implementation": "Sonarr",
                "configContract": "SonarrSettings",
                "fields": [
                    {"name": "baseUrl", "value": "http://sonarr:8989"},
                    {"name": "apiKey", "value": self.api_keys['sonarr']},
                    {"name": "syncLevel", "value": "fullSync"}
                ],
                "tags": []
            }
            
            response = self.make_api_request('prowlarr', 'applications', 'POST', sonarr_app)
            if response and response.status_code in [200, 201]:
                self.print_success("Added Sonarr to Prowlarr")
            else:
                self.print_error("Failed to add Sonarr to Prowlarr")
                
        # Add Radarr application
        if 'radarr' in self.api_keys:
            radarr_app = {
                "name": "Radarr",
                "implementation": "Radarr",
                "configContract": "RadarrSettings",
                "fields": [
                    {"name": "baseUrl", "value": "http://radarr:7878"},
                    {"name": "apiKey", "value": self.api_keys['radarr']},
                    {"name": "syncLevel", "value": "fullSync"}
                ],
                "tags": []
            }
            
            response = self.make_api_request('prowlarr', 'applications', 'POST', radarr_app)
            if response and response.status_code in [200, 201]:
                self.print_success("Added Radarr to Prowlarr")
            else:
                self.print_error("Failed to add Radarr to Prowlarr")
                
    def configure_download_clients(self):
        """Configure qBittorrent as download client"""
        self.print_status("Configuring download clients...")
        
        qbittorrent_config = {
            "enable": True,
            "name": "qBittorrent",
            "implementation": "QBittorrent",
            "configContract": "QBittorrentSettings",
            "fields": [
                {"name": "host", "value": "mullvad-vpn"},
                {"name": "port", "value": 8085},
                {"name": "username", "value": "admin"},
                {"name": "password", "value": "adminpass"}
            ],
            "tags": []
        }
        
        # Add to Sonarr
        if 'sonarr' in self.api_keys:
            sonarr_config = qbittorrent_config.copy()
            sonarr_config["fields"].append({"name": "category", "value": "sonarr"})
            
            response = self.make_api_request('sonarr', 'downloadclient', 'POST', sonarr_config)
            if response and response.status_code in [200, 201]:
                self.print_success("Added qBittorrent to Sonarr")
            else:
                self.print_error("Failed to add qBittorrent to Sonarr")
                
        # Add to Radarr
        if 'radarr' in self.api_keys:
            radarr_config = qbittorrent_config.copy()
            radarr_config["fields"].append({"name": "category", "value": "radarr"})
            
            response = self.make_api_request('radarr', 'downloadclient', 'POST', radarr_config)
            if response and response.status_code in [200, 201]:
                self.print_success("Added qBittorrent to Radarr")
            else:
                self.print_error("Failed to add qBittorrent to Radarr")
                
    def run(self):
        """Main configuration process"""
        print("="*50)
        print("  Automated Media Stack Configuration")
        print("="*50)
        
        # Wait for services to be ready
        services_to_wait = ['sonarr', 'radarr', 'prowlarr']
        for service in services_to_wait:
            if not self.wait_for_service(service):
                sys.exit(1)
                
        # Give services time to fully initialize
        self.print_status("Allowing services to fully initialize...")
        time.sleep(60)
        
        # Get API keys
        for service in ['sonarr', 'radarr', 'prowlarr']:
            api_key = self.get_api_key(service)
            if api_key:
                self.api_keys[service] = api_key
                self.print_success(f"Retrieved API key for {service}")
            else:
                self.print_error(f"Failed to get API key for {service}")
                
        # Configure services
        if self.api_keys:
            self.configure_prowlarr()
            self.configure_download_clients()
        self.configure_metadata_sources()
            
        print("\n" + "="*50)
        print("  Configuration Complete!")
        print("="*50)
        print("\nNext steps:")
        print("1. Visit Prowlarr to add indexers manually")
        print("2. Configure Jellyseerr at http://localhost:5055")
        print("3. Set up Jellyfin libraries at http://localhost:8096")

if __name__ == "__main__":
    configurator = MediaStackConfigurator()
    configurator.run()

    def configure_metadata_sources(self):
        """Configure metadata sources with TMDB/OMDB fallback"""
        print_step("Configuring metadata sources...")
        
        # Check if TMDB API key is available
        tmdb_key = os.environ.get('TMDB_API_KEY', '')
        
        if tmdb_key:
            self.print_status("Using TMDB as primary metadata source")
            # Configure TMDB
            metadata_config = {
                "tmdb": {"apiKey": tmdb_key},
                "omdb": {"apiKey": ""},  # OMDB as fallback
                "priority": "tmdb"
            }
        else:
            self.print_status("Using OMDB as primary metadata source (no TMDB key provided)")
            # Use OMDB as primary
            metadata_config = {
                "tmdb": {"apiKey": ""},
                "omdb": {"apiKey": ""},  # OMDB doesn't require key
                "priority": "omdb"
            }
        
        # Save configuration
        config_path = self.base_dir / "configs" / "metadata-config.json"
        with open(config_path, 'w') as f:
            json.dump(metadata_config, f, indent=2)
            
        self.print_success("Metadata sources configured!")

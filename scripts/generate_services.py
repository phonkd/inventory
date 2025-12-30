#!/usr/bin/env python3
import os
import re
import glob

# Configuration
MODULES_DIR = "modules"
MACHINES_DIR = "machines"
TRAEFIK_FILE = os.path.join(MACHINES_DIR, "201-mono/traefik.nix")
OUTPUT_FILE = os.path.join(MODULES_DIR, "services-list.nix")

# Metadata mapping for enrichment (icons, titles, categories)
# Note: "category" logic will also use heuristics (e.g., URL pattern)
METADATA = {
    # Teleport apps
    "paperless": {"icon": "si:paperlessngx", "title": "Paperless", "category": "Private"},
    "spawner-argo": {"icon": "si:argo", "title": "ArgoCD", "category": "Private"},
    "grafana": {"icon": "si:grafana", "title": "Grafana", "category": "Private"},
    "syncthing": {"icon": "si:syncthing", "title": "Syncthing", "category": "Private"},
    "kuma": {"icon": "si:kuma", "title": "Kuma", "category": "Private"},
    "proxmox": {"icon": "si:proxmox", "title": "Proxmox", "category": "Private"},
    "openwrt": {"icon": "si:openwrt", "title": "OpenWrt", "category": "Private"},
    
    # Traefik routers (keys usually match router name or derived name)
    "pve": {"icon": "si:proxmox", "title": "Proxmox", "category": "Private"},
    "pve-router": {"icon": "si:proxmox", "title": "Proxmox", "category": "Private"},
    "oldblac-pve": {"category": "Private"},
    "vaultwarden": {"icon": "si:vaultwarden", "title": "Bitwarden", "category": "Public"},
    "immich": {"icon": "si:immich", "title": "Photos", "category": "Public"},
    "auth": {"category": "Private"}, # Keycloak
    "filestash": {"category": "Public"},
    "collabora": {"category": "Public"},
    "s3": {"category": "Public"}, # Public s3 bucket usually
}

# External services (hardcoded as they aren't in nix config usually)
EXTERNAL_SERVICES = [
    { "name": "Cloudflare", "url": "https://dash.cloudflare.com/", "icon": "si:cloudflare", "category": "Public" },
    { "name": "hetzner", "url": "https://accounts.hetzner.com/login/", "icon": "si:hetzner", "category": "Public" },
    { "name": "Clips", "url": "https://share.w.phonkd.net/", "icon": "si:airplayvideo", "category": "Public" },
    { "name": "OpenWrt", "url": "http://192.168.1.3", "icon": "si:openwrt", "category": "Private" },
]

def parse_teleport_apps(modules_dir):
    apps = []
    # Regex to find: apps = [ { name = "..."; uri = "..."; ... } ];
    # This is a simple regex and might fail on complex nested structures or comments
    # We look for the 'apps = [' block and then iterate items.
    
    files = glob.glob(os.path.join(modules_dir, "**/*.nix"), recursive=True)
    files += glob.glob(os.path.join(MACHINES_DIR, "**/*.nix"), recursive=True)

    for fpath in files:
        if not os.path.isfile(fpath): continue
        with open(fpath, 'r') as f:
            content = f.read()
        
        # Naive extraction of "apps" blocks inside services.teleport.settings
        # We look for `apps = [` and then grab the content until `];`
        # This is very brittle but might work for this specific codebase style
        
        # Pattern: find `apps = [` then capture content until `];`
        app_blocks = re.findall(r'apps\s*=\s*\[(.*?)\];', content, re.DOTALL)
        
        for block in app_blocks:
            # Inside the block, we look for `{ ... }` items
            # We assume items are enclosed in { }
            items = re.findall(r'\{(.*?)\}', block, re.DOTALL)
            for item in items:
                # Extract fields
                name_match = re.search(r'name\s*=\s*"(.*?)";', item)
                uri_match = re.search(r'uri\s*=\s*"(.*?)";', item)
                
                if name_match:
                    app = {}
                    app['name'] = name_match.group(1)
                    if uri_match:
                        app['uri'] = uri_match.group(1)
                    else:
                        app['uri'] = "http://unknown" # Placeholder
                    
                    # Try to find publicHost from rewrite headers if present
                    # rewrite = { headers = [ "Host: foo.bar" ]; };
                    host_match = re.search(r'Host:\s*([a-zA-Z0-9.-]+)', item)
                    if host_match:
                        app['publicHost'] = host_match.group(1)
                        
                    apps.append(app)
    return apps

def parse_traefik_routers(traefik_file):
    routers_list = []
    if not os.path.exists(traefik_file):
        print(f"Warning: {traefik_file} not found.")
        return []

    with open(traefik_file, 'r') as f:
        content = f.read()

    # We need to extract the `routers = { ... }` block first, or just regex for router definitions directly
    # A router usually looks like: name = { rule = "..."; ... };
    
    # Let's find the `routers = {` block
    routers_block_match = re.search(r'routers\s*=\s*\{(.*?)\};', content, re.DOTALL)
    if not routers_block_match:
        # Maybe it's nested differently or multiple blocks?
        # In the file provided: dynamicConfigOptions.http.routers = { ... };
        # Let's try to match the keys inside `routers = { ... }`
        pass
    
    # We will iterate over the file content specifically inside the routers block if we can find it
    # Or just regex for `rule = "Host...` and backtrack to find the name?
    # Backtracking is hard with regex.
    
    # Let's try to parse the dict structure manually-ish
    # We assume standard formatting:
    # routerName = {
    #   rule = "...";
    #   ... 
    # };
    
    # Find all assignments to a set that contains a rule
    # pattern:  name = { ... rule = "..." ... };
    
    # We will loop through the lines to find `key = {`
    lines = content.split('\n')
    current_router = None
    buffer = ""
    
    # Also need to parse `services` to get URLs
    # structure: services = { serviceName = { loadBalancer = { servers = [ { url = "..."; } ]; }; }; };
    services_map = {}
    
    # First pass: Extract services URLs
    svc_block_match = re.search(r'services\s*=\s*\{(.*?)\};', content, re.DOTALL) # This matches only the first closing brace, problematic if nested
    # The file has indentation, we can rely on that or write a proper parser.
    # Given the constraint, let's use a simpler regex for services
    
    # Find all: serviceName = { ... url = "..." ... }
    # We'll regex for `url = "..."` and associate it with the nearest preceding `name = {` ? No.
    
    # Let's tokenize simply.
    # 1. Extract all service->url mappings
    # 2. Extract all router->host mappings and service references
    
    # Service Extraction
    # Look for:  some-service = { ... url = "..." ... }
    # We can find `name = {` and then look ahead for `url = 
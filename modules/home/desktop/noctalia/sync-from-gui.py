#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""
Noctalia GUI Settings Sync Script
Copies settings from ~/.config/noctalia/settings.json to ./settings.json
so they can be committed to git.
"""

import shutil
import sys
from pathlib import Path
from datetime import datetime

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

def print_header():
    print(f"{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
    print(f"{Colors.BLUE}   Noctalia Settings Sync (Backup Local → Git){Colors.NC}")
    print(f"{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}\n")

def main():
    print_header()

    script_dir = Path(__file__).parent
    
    # Destination is the settings.json next to this script
    dest_file = script_dir / "settings.json"
    
    # Source is the live config file
    source_file = Path.home() / ".config" / "noctalia" / "settings.json"

    if not source_file.exists():
        print(f"{Colors.RED}Error: Source settings file not found at {source_file}{Colors.NC}")
        print("Make sure you have configured Noctalia through the GUI first.")
        return 1

    if source_file.is_symlink():
         # If it's a symlink, it might already be pointing to our nix store or a managed file.
         # But we want to copy the *content* to our git repo file.
         # So we resolve it or just read it.
         print(f"{Colors.YELLOW}Note: Source is a symlink.{Colors.NC}")

    # timestamp for backup of the destination file (in case we overwrite something important in git)
    if dest_file.exists():
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = script_dir / f"settings.json.bak.{timestamp}"
        shutil.copy2(dest_file, backup_path)
        print(f"Created backup of current git-stored settings at: {backup_path}")

    try:
        shutil.copy2(source_file, dest_file)
        print(f"{Colors.GREEN}✓{Colors.NC} Successfully synced settings!")
        print(f"  From: {source_file}")
        print(f"  To:   {dest_file}\n")
        
        print(f"{Colors.YELLOW}Next steps:{Colors.NC}")
        print("  1. Review changes: git diff settings.json")
        print("  2. Rebuild system: nh os switch (or nixos-rebuild switch)")
        print("  3. Commit changes to git")

    except Exception as e:
        print(f"{Colors.RED}Error copying file: {e}{Colors.NC}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())

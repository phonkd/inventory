#!/usr/bin/env bash
# !!!!!!! VIBECODE WARNING, this has been created by claude but tested and worked for me, if you dont want to trust it just rebuild your vm using "nixos-rebuild switch --flake .#200-root --target-host=VMIP --build-host=VMIP --ask-sudo-password" ; )
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if fzf is installed
check_fzf() {
    if ! command -v fzf &> /dev/null; then
        print_warning "fzf is not installed. File selection will use basic input."
        return 1
    fi
    return 0
}

# Function to select file with fzf
select_file_with_fzf() {
    local prompt="$1"
    local start_dir="${2:-$HOME}"

    if check_fzf; then
        print_info "Use fzf to select the file (Ctrl+C to cancel, type to search)" >&2
        local selected_file=$(find "$start_dir" -type f 2>/dev/null | fzf --prompt="$prompt > " --height=40% --reverse --preview='head -n 10 {}' --preview-window=right:50%:wrap)

        if [ -n "$selected_file" ]; then
            echo "$selected_file"
            return 0
        else
            print_error "No file selected" >&2
            return 1
        fi
    else
        # Fallback to basic input
        read -p "$prompt: " -e selected_file >&2

        # Expand tilde
        selected_file="${selected_file/#\~/$HOME}"

        if [ -f "$selected_file" ]; then
            echo "$selected_file"
            return 0
        else
            print_error "File does not exist: $selected_file" >&2
            return 1
        fi
    fi
}

# Function to select directory with fzf
select_directory_with_fzf() {
    local prompt="$1"
    local start_dir="${2:-$HOME}"

    if check_fzf; then
        print_info "Use fzf to select the flake directory (Ctrl+C to cancel, type to search)" >&2
        local selected_dir=$(find "$start_dir" -type d 2>/dev/null | fzf --prompt="$prompt > " --height=40% --reverse --preview='ls -la {}' --preview-window=right:50%:wrap)

        if [ -n "$selected_dir" ]; then
            echo "$selected_dir"
            return 0
        else
            print_error "No directory selected" >&2
            return 1
        fi
    else
        # Fallback to basic input
        read -p "$prompt: " -e selected_dir >&2

        # Expand tilde
        selected_dir="${selected_dir/#\~/$HOME}"

        if [ -d "$selected_dir" ]; then
            echo "$selected_dir"
            return 0
        else
            print_error "Directory does not exist: $selected_dir" >&2
            return 1
        fi
    fi
}

# Main script
main() {
    print_info "SOPS Age Keys Setup for VM"
    echo ""

    # Ask for VM IP address
    read -p "Enter VM IP address: " vm_ip

    if [ -z "$vm_ip" ]; then
        print_error "IP address cannot be empty"
        exit 1
    fi

    print_info "VM IP: $vm_ip"
    echo ""

    # Test SSH connectivity
    print_info "Testing SSH connection to $vm_ip..."
    if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$vm_ip" "echo 'SSH connection successful'" 2>/dev/null; then
        print_warning "SSH connection test failed. Make sure you have SSH access to the VM."
        read -p "Do you want to continue anyway? (y/N): " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            print_error "Aborting."
            exit 1
        fi
    else
        print_info "SSH connection successful!"
    fi
    echo ""

    # Create directory on VM
    print_info "Creating directory ~/.config/sops/age on VM..."
    if ssh "$vm_ip" "mkdir -p ~/.config/sops/age"; then
        print_info "Directory created successfully"
    else
        print_error "Failed to create directory on VM"
        exit 1
    fi
    echo ""

    # Ask for keys.txt location with fzf
    print_info "Select the keys.txt file location"
    keys_file=""

    while [ -z "$keys_file" ]; do
        if ! keys_file=$(select_file_with_fzf "Select keys.txt" "$HOME"); then
            read -p "Try again? (y/N): " try_again
            if [[ ! "$try_again" =~ ^[Yy]$ ]]; then
                print_error "Aborting."
                exit 1
            fi
        fi
    done

    print_info "Selected file: $keys_file"
    echo ""

    # Verify file exists and is readable
    if [ ! -r "$keys_file" ]; then
        print_error "Cannot read file: $keys_file"
        exit 1
    fi

    # Copy keys.txt to VM
    print_info "Copying $keys_file to $vm_ip:~/.config/sops/age/keys.txt..."
    if scp "$keys_file" "$vm_ip:~/.config/sops/age/keys.txt"; then
        print_info "File copied successfully!"
    else
        print_error "Failed to copy file to VM"
        exit 1
    fi
    echo ""

    # Set appropriate permissions on the VM
    print_info "Setting secure permissions (600) on keys.txt..."
    if ssh "$vm_ip" "chmod 600 ~/.config/sops/age/keys.txt"; then
        print_info "Permissions set successfully"
    else
        print_warning "Failed to set permissions. You may need to do this manually."
    fi
    echo ""

    print_info "Setup completed successfully!"
    print_info "SOPS Age keys have been configured on $vm_ip"
    echo ""

    # Ask for flake path with fzf
    print_info "Select the flake directory"
    flake_path=""

    while [ -z "$flake_path" ]; do
        if ! flake_path=$(select_directory_with_fzf "Select flake directory" "$HOME"); then
            read -p "Try again? (y/N): " try_again >&2
            if [[ ! "$try_again" =~ ^[Yy]$ ]]; then
                print_error "Aborting."
                exit 1
            fi
        fi
    done

    print_info "Selected flake path: $flake_path"
    echo ""

    # Verify flake.nix exists in the selected directory
    if [ ! -f "$flake_path/flake.nix" ]; then
        print_warning "No flake.nix found in $flake_path"
        read -p "Continue anyway? (y/N): " continue_anyway >&2
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            print_error "Aborting."
            exit 1
        fi
    fi

    # Ask for flake target name
    read -p "Enter flake target name (e.g., 200-root): " flake_name

    if [ -z "$flake_name" ]; then
        print_error "Flake target name cannot be empty"
        exit 1
    fi

    print_info "Flake target name: $flake_name"
    echo ""

    # Run nixos-rebuild
    print_info "Running nixos-rebuild switch..."
    print_info "Command: nixos-rebuild switch --flake $flake_path#$flake_name --target-host=$vm_ip --build-host=$vm_ip --ask-sudo-password"
    echo ""

    # Run nixos-rebuild
    if nixos-rebuild switch --flake "$flake_path#$flake_name" --target-host="$vm_ip" --build-host="$vm_ip" --ask-sudo-password; then
        print_info "NixOS rebuild completed successfully!"
    else
        print_error "NixOS rebuild failed with exit code: $?"
        exit 1
    fi

    echo ""
    print_info "Script completed. The VM should be rebuilding with the new configuration."
}

# Run main function
main

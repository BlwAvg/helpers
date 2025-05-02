#!/bin/bash

# This works, I made it.
# modified from https://raw.githubusercontent.com/community-scripts/ProxmoxVE/refs/heads/main/ct/omada.sh
# The script was found at https://tteck.github.io/Proxmox/#omada-controller-lxc

# Define a function to display error messages
msg_error() {
    echo "Error: $1" >&2
}

# Define a function to display header information (if needed)
header_info() {
    echo "Starting the Omada Controller update script..."
}

update_script() {
    header_info

    # Check if the directory exists
    if [[ ! -d /opt/tplink ]]; then
        msg_error "No ${APP} Installation Found!"
        exit 1
    fi

    # Fetch the latest URL and version
    latest_url=$(curl -s "https://support.omadanetworks.com/en/product/omada-software-controller/?resourceType=download" | grep -o 'https://static\.tp-link\.com/upload/software/[^"]*linux_x64[^"]*\.deb' | head -n 1)
# OLD URL
#    latest_url=$(curl -fsSL "https://www.tp-link.com/en/support/download/omada-software-controller/" | grep -o 'https://.*x64.deb' | head -n1)
#
    latest_version=$(basename "${latest_url}")

    # Check if the URL was found
    if [ -z "${latest_version}" ]; then
        msg_error "It seems that the server (tp-link.com) might be down. Please try again at a later time."
        exit 1
    fi

    echo "Updating Omada Controller..."

    # Download the latest version
    if ! wget -qL "${latest_url}"; then
        msg_error "Failed to download ${latest_version}. Please check your network connection and try again."
        exit 1
    fi

    # Install the downloaded package
    if ! dpkg -i "${latest_version}"; then
        msg_error "Failed to install ${latest_version}. Please check the package and try again."
        rm -f "${latest_version}"
        exit 1
    fi

    # Clean up the downloaded package
    rm -f "${latest_version}"

    echo "Updated Omada Controller successfully."
}

# Call the update_script function
update_script

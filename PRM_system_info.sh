#!/bin/bash

# Create the output directory if it doesn't exist
output_dir="/var/www/html/cri/screens"
mkdir -p "$output_dir"

# Output file path
output_file="$output_dir/system_info.txt"

# Get the actual user running the script
actual_user=$(logname)
home_dir=$(eval echo "~$actual_user")

# Gather system information
echo "Collecting system information..."

# OS name and version
# lsb_release provides distribution-specific information
# If lsb_release is not available, use /etc/os-release
os_name=$(lsb_release -ds 2>/dev/null || grep -m 1 'PRETTY_NAME' /etc/os-release | cut -d '=' -f2- | tr -d '"')
echo -e "\n# OS Name and Version\nOS Name and Version: $os_name" > "$output_file"

# Processor information
# lscpu provides detailed CPU information, here we extract the model name
cpu_info=$(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs)
echo -e "\n# Processor Information\nProcessor: $cpu_info" >> "$output_file"

# Architecture
# uname -m provides the machine hardware name, indicating architecture (e.g., x86_64)
architecture=$(uname -m)
echo -e "\n# System Architecture\nArchitecture: $architecture" >> "$output_file"

# RAM information
# /proc/meminfo contains memory information; we extract the total RAM and convert it to MB
total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2/1024 " MB"}')
echo -e "\n# Total System RAM\nTotal RAM: $total_ram" >> "$output_file"

# Node.js and npm versions
# node -v and npm -v provide the versions of Node.js and npm if installed
node_version=$(node -v 2>/dev/null || echo "Node.js is not installed")
npm_version=$(npm -v 2>/dev/null || echo "npm is not installed")
echo -e "\n# Node.js and npm Versions\nNode.js Version: $node_version\nnpm Version: $npm_version" >> "$output_file"

# Package manager
# Check for common package managers (apt, yum, pacman)
if command -v apt &> /dev/null; then
    package_manager="apt"
elif command -v yum &> /dev/null; then
    package_manager="yum"
elif command -v pacman &> /dev/null; then
    package_manager="pacman"
else
    package_manager="unknown"
fi
echo -e "\n# Package Manager\nPackage Manager: $package_manager" >> "$output_file"

# Home directory path
# $HOME provides the path to the current user's home directory
echo -e "\n# Home Directory Path\nHome Directory Path: $home_dir" >> "$output_file"

# User information
# logname provides the actual logged-in user's username
echo -e "\n# User Information\nUser: $actual_user\nUser Home: $home_dir" >> "$output_file"

# Internet access
# Check internet connectivity by pinging google.com
internet_access=$(ping -c 1 google.com &> /dev/null && echo "Yes" || echo "No")
echo -e "\n# Internet Access\nInternet Access: $internet_access" >> "$output_file"

# Sudo access
# Check if the user can run commands with sudo without a password prompt
sudo_access=$(sudo -n true 2>/dev/null && echo "Yes" || echo "No")
echo -e "\n# Sudo Access\nSudo Access: $sudo_access" >> "$output_file"

# Preferred text editor
# $EDITOR environment variable provides the user's preferred text editor, defaulting to nano if not set
preferred_editor=$(echo "${EDITOR:-nano}")
echo -e "\n# Preferred Text Editor\nPreferred Text Editor: $preferred_editor" >> "$output_file"

# Firewall/Antivirus information
# Check the status of UFW (Uncomplicated Firewall)
firewall_status=$(sudo ufw status 2>/dev/null || echo "UFW not installed or no sudo access")
echo -e "\n# Firewall Status\nFirewall Status: $firewall_status" >> "$output_file"

# Browser preferences (assuming Chrome)
# Check the version of Chrome or Chromium if installed
chrome_version=$(google-chrome --version 2>/dev/null || chromium-browser --version 2>/dev/null || echo "Chrome/Chromium is not installed")
echo -e "\n# Chrome/Chromium Version\nChrome Version: $chrome_version" >> "$output_file"

# Output the location of the saved file
echo "System information has been saved to $output_file"

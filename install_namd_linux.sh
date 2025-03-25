#!/bin/bash

VMD_URL="https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.4/files/alpha/vmd-1.9.4a57.bin.LINUXAMD64-CUDA102-OptiX650-OSPRay185.opengl.tar.gz"
NAMD_URL="https://www.ks.uiuc.edu/Research/namd/3.0.1/download/453167/NAMD_3.0.1_Linux-x86_64-multicore-CUDA.tar.gz"
NAMD_DIR="NAMD_3.0.1_Linux-x86_64-multicore-CUDA"

# Create a directory for downloads
mkdir -p ~/namd_setup
cd ~/namd_setup

# Download NAMD and tutorial files
echo "Downloading NAMD..."
curl -L -O "$NAMD_URL"

echo "Downloading tutorial files..."
curl -L -O "https://github.com/BlueSky2311/namd_tutorial/raw/main/tutorial_files.zip"

# Download and handle VMD
echo "Downloading VMD..."
curl -L -O "$VMD_URL"
echo "Extracting VMD..."
tar -xzf $(basename "$VMD_URL") -C ~/

# Extract NAMD and tutorial archives
echo "Extracting NAMD..."
tar -xzf $(basename "$NAMD_URL") -C ~/
echo "Extracting tutorial files..."
# Check if unzip is installed
if ! command -v unzip &> /dev/null; then
    echo "unzip command not found. Installing..."
    sudo apt-get install -y unzip
fi
unzip tutorial_files.zip -d ~/namd-tutorial

# Determine shell config file
SHELL_CONFIG="$HOME/.bashrc"

echo "Using shell config file: $SHELL_CONFIG"

if ! grep -q "$NAMD_DIR" "$SHELL_CONFIG"; then
    echo "Adding NAMD to PATH in $SHELL_CONFIG..."
    echo "export PATH=\"\$HOME/$NAMD_DIR:\$PATH\"" >> "$SHELL_CONFIG"
    echo "Note: If PATH setting doesn't work, manually add the following line to your shell config:"
    echo "export PATH=\"\$HOME/$NAMD_DIR:\$PATH\""
fi

# Install required packages
echo "Installing required packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y build-essential nedit

# Install Python packages
echo "Installing Python packages..."
# Check if pip is installed
if ! command -v pip &> /dev/null; then
    echo "pip not found."
    sudo apt-get install -y python3-pip
fi

if command -v pip &> /dev/null; then
    pip install MDAnalysis matplotlib pandas numpy
fi

echo "Installation complete!"
echo "Please restart your terminal or run 'source $SHELL_CONFIG' to update your PATH."
echo ""
echo "If you encounter any issues:"
echo "1. If PATH settings don't work, manually add NAMD to your path"
echo "2. For package installation failures, try installing them manually" 
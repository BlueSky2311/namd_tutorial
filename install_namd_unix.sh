#!/bin/bash

# Detect operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="MacOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

echo "Detected operating system: $OS"

# Create a directory for downloads
mkdir -p ~/namd_setup
cd ~/namd_setup

# Download VMD, NAMD and tutorial files
echo "Downloading VMD..."
curl -L -O https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.4/files/alpha/vmd-1.9.4a57.bin.LINUXAMD64-CUDA102-OptiX650-OSPRay185.opengl.tar.gz

echo "Downloading NAMD..."
curl -L -O https://www.ks.uiuc.edu/Research/namd/3.0.1/download/453167/NAMD_3.0.1_Linux-x86_64-multicore.tar.gz

echo "Downloading tutorial files..."
curl -L -O https://www.ks.uiuc.edu/Training/Tutorials/namd/namd-tutorial-files.tar.gz

# Extract archives
echo "Extracting NAMD..."
tar -xzf NAMD_3.0.1_Linux-x86_64-multicore.tar.gz -C ~/
echo "Extracting tutorial files..."
tar -xzf namd-tutorial-files.tar.gz -C ~/
echo "Extracting VMD..."
tar -xzf vmd-1.9.4a57.bin.LINUXAMD64-CUDA102-OptiX650-OSPRay185.opengl.tar.gz -C ~/

# Add NAMD to PATH in appropriate file based on OS
if [[ "$OS" == "MacOS" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
    # Check if using bash instead of zsh (older macOS)
    if [[ "$SHELL" == */bash ]]; then
        SHELL_CONFIG="$HOME/.bash_profile"
        if [ ! -f "$SHELL_CONFIG" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        fi
    fi
else
    SHELL_CONFIG="$HOME/.bashrc"
fi

echo "Using shell config file: $SHELL_CONFIG"

if ! grep -q "NAMD_3.0.1_Linux-x86_64-multicore" "$SHELL_CONFIG"; then
    echo "Adding NAMD to PATH in $SHELL_CONFIG..."
    echo 'export PATH="$HOME/NAMD_3.0.1_Linux-x86_64-multicore:$PATH"' >> "$SHELL_CONFIG"
fi

# Install required packages based on OS
if [[ "$OS" == "Linux" ]]; then
    echo "Updating and installing required packages for Linux..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y build-essential nedit
elif [[ "$OS" == "MacOS" ]]; then
    echo "Installing required packages for macOS..."
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install packages
    brew install gcc
    brew install --cask xquartz  # For GUI applications like VMD
fi

# Install Python packages
echo "Installing Python packages..."
# Check if pip is installed
if ! command -v pip &> /dev/null; then
    if [[ "$OS" == "MacOS" ]]; then
        brew install python
    else
        sudo apt-get install -y python3-pip
    fi
fi

pip install MDAnalysis matplotlib pandas numpy notebook

echo "Installation complete!"
echo "Please restart your terminal or run 'source $SHELL_CONFIG' to update your PATH." 
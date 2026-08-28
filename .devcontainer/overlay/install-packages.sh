#!/usr/bin/env -S bash -e

export ACCEPT_EULA=Y
export DEBIAN_FRONTEND=noninteractive
export OS_DISTRIBUTION=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)
export SCRIPT_DIR=$(realpath $(dirname $0))
source "${SCRIPT_DIR}/common.sh"

curl -sSL -O "https://packages.microsoft.com/config/ubuntu/${OS_DISTRIBUTION}/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb >/dev/null
rm -f packages-microsoft-prod.deb

apt-get update
apt-get install -y \
    apt-transport-https \
    blobfuse2 \
    ca-certificates \
    cmake \
    cpio \
    cron \
    curl \
    file \
    fuse3 \
    gnupg \
    jq \
    libc6 \
    libfuse3-dev \
    lsb-release \
    msodbcsql18 \
    openssl \
    p7zip-full \
    pkg-config \
    rpm2cpio \
    software-properties-common \
    unixodbc \
    unixodbc-dev \
    unzip \
    vim \
    wget \
    xdg-utils

# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# curl -fsSL https://aka.ms/install-azd.sh | bash
# sudo apt install gh -y

source "${SCRIPT_DIR}/copilot-cli-install.sh"

# Install tfenv to manage Terraform versions per project.
if ! command -v tfenv >/dev/null 2>&1; then
    git clone --depth=1 https://github.com/tfutils/tfenv.git /usr/local/share/tfenv
    ln -sf /usr/local/share/tfenv/bin/tfenv /usr/local/bin/tfenv
    printf '%s\n' 'export PATH="/usr/local/share/tfenv/bin:$PATH"' > /etc/profile.d/tfenv.sh
    printf '%s\n' 'export PATH="/usr/local/share/tfenv/bin:$PATH"' >> /etc/bash.bashrc
    chmod +x /etc/profile.d/tfenv.sh
fi

pip install python-dotenv

sudo apt-get autoremove -y &&
    sudo apt-get clean -y &&
    sudo rm -rf /var/lib/apt/lists/* &&
    sudo rm -rf /tmp/downloads
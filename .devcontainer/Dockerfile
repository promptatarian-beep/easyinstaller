FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python dev tools, build essentials, and installer dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev \
    build-essential git curl wget ca-certificates \
    openssh-client sudo \
 && rm -rf /var/lib/apt/lists/*

# Create vscode user (used by Codespaces/devcontainer)
RUN useradd -m -s /bin/bash vscode && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode
USER vscode
WORKDIR /workspace

# Upgrade pip
RUN python3 -m pip install --user --upgrade pip

# Install Python dependencies
RUN python3 -m pip install --user ruamel.yaml

# Default entrypoint is a shell so Codespaces can start with the container
CMD ["/bin/bash"]

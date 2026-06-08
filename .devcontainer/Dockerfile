FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic build tools and QEMU
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl wget ca-certificates python3 python3-pip python3-venv \
    qemu-system-arm qemu-system-aarch64 qemu-utils \
    gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    openssh-client sudo net-tools iproute2 \
    python3-websocket python3-websockify \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
 && git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify

# Create vscode user (used by Codespaces/devcontainer)
RUN useradd -m -s /bin/bash vscode && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode
USER vscode
WORKDIR /workspace

# Set PATH for cross toolchain and novnc
ENV PATH="/opt/noVNC/utils:${PATH}"

# Small helper to ensure websockify is runnable
RUN python3 -m pip install --user --upgrade pip

# Expose typical noVNC port (container runtime/exposed by Codespaces)
EXPOSE 6080

# Default entrypoint is a shell so Codespaces can start with the container
CMD ["/bin/bash"]

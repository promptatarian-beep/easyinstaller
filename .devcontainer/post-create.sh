#!/usr/bin/env bash
# Post-create setup for devcontainer
python3 -m pip install --user --upgrade pip
python3 -m pip install --user ruamel.yaml

echo "Devcontainer post-create complete. Dependencies installed."

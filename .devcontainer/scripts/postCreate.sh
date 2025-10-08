apt-get update && apt-get upgrade -y
apt-get install -y zsh inotify-tools

git config --global --add safe.directory /workspace

# Run environment setup script if it exists
if [ -f "/workspace/.devcontainer/scripts/setup_env.sh" ]; then
    echo "Setting up environment variables..."
    /workspace/.devcontainer/scripts/setup_env.sh
else
    echo "Environment setup script not found at: /workspace/.devcontainer/scripts/setup_env.sh"
fi
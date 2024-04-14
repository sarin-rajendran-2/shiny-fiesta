apt-get update && apt-get upgrade -y
apt-get install -y zsh inotify-tools
mix archive.install hex phx_new
# mix deps.get
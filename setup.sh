#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_dir=$HOME/.config/kanata-remapper
config_file=$config_dir/kanata.kbd

say() { printf 'kanata setup: %s\n' "$*" >&2; }
die() { printf 'kanata setup: error: %s\n' "$*" >&2; exit 1; }
needs_new_login=0

find_kanata() {
  command -v kanata 2>/dev/null || true
}

install_kanata() {
  local os=$1
  local found
  found=$(find_kanata)
  [ -n "$found" ] && { printf '%s\n' "$found"; return; }

  if [ "$os" = Darwin ]; then
    command -v brew >/dev/null 2>&1 || die "Kanata is not installed. Install Homebrew, then run: brew install kanata"
    say "Kanata not found; installing it with Homebrew"
    brew install kanata
  else
    if command -v cargo >/dev/null 2>&1; then
      say "Kanata not found; installing it with Cargo"
      cargo install kanata
    else
      die "Kanata is not installed. Install it with your distro package manager or install Rust/Cargo, then run this script again."
    fi
  fi

  found=$(find_kanata)
  [ -n "$found" ] || die "Kanata was installed but is not on PATH"
  printf '%s\n' "$found"
}

configure_linux_permissions() {
  if id -nG | tr ' ' '\n' | grep -qx input && [ -r /dev/uinput ] && [ -w /dev/uinput ]; then
    return
  fi

  command -v sudo >/dev/null 2>&1 || die "sudo is required once to configure Kanata device access"

  say "Administrator permission is required once to configure keyboard-device access"
  sudo -v || die "administrator authorization is required to configure Kanata device access"
  sudo groupadd --force input
  printf '%s\n' \
    '# Allow members of input to use Kanata virtual and physical keyboards.' \
    'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' \
    'SUBSYSTEM=="input", KERNEL=="event[0-9]*", MODE="0660", GROUP="input"' \
    | sudo tee /etc/udev/rules.d/99-kanata.rules >/dev/null
  sudo udevadm control --reload-rules
  sudo modprobe uinput
  sudo udevadm trigger --subsystem-match=input

  if ! id -nG | tr ' ' '\n' | grep -qx input; then
    sudo usermod --append --groups input "$(id -un)"
    needs_new_login=1
  fi
}

os=$(uname -s)
kanata_bin=$(install_kanata "$os")

[ -f "$script_dir/kanata.kbd" ] || die "kanata.kbd is missing from $script_dir"
mkdir -p "$config_dir"
cp "$script_dir/kanata.kbd" "$config_file"
say "Installed config at $config_file"

case "$os" in
  Linux)
    command -v systemctl >/dev/null 2>&1 || die "systemd is required for automatic startup on Linux"
    configure_linux_permissions
    service_dir=$HOME/.config/systemd/user
    service_file=$service_dir/kanata-remapper.service
    mkdir -p "$service_dir"
    {
      printf '%s\n' '[Unit]' 'Description=Personal Kanata keyboard remapping' \
        'Documentation=https://github.com/jtroo/kanata' \
        'After=graphical-session-pre.target' 'PartOf=graphical-session.target' ''
      printf '%s\n' '[Service]' 'Type=simple'
      printf 'ExecStart=%s --no-wait --nodelay --cfg %%h/.config/kanata-remapper/kanata.kbd\n' "$kanata_bin"
      printf '%s\n' 'Restart=on-failure' 'RestartSec=2' '' '[Install]' 'WantedBy=graphical-session.target'
    } > "$service_file"
    systemctl --user daemon-reload
    systemctl --user enable --now kanata-remapper.service
    say "Kanata is enabled and running as a user service"
    say "If it cannot access the keyboard, check /dev/uinput and your input-device permissions"
    ;;
  Darwin)
    launch_dir=$HOME/Library/LaunchAgents
    plist=$launch_dir/com.poonnaratn.kanata-remapper.plist
    mkdir -p "$launch_dir"
    escaped_bin=${kanata_bin//&/&amp;}; escaped_bin=${escaped_bin//</&lt;}; escaped_bin=${escaped_bin//>/&gt;}
    escaped_cfg=${config_file//&/&amp;}; escaped_cfg=${escaped_cfg//</&lt;}; escaped_cfg=${escaped_cfg//>/&gt;}
    escaped_home=${HOME//&/&amp;}; escaped_home=${escaped_home//</&lt;}; escaped_home=${escaped_home//>/&gt;}
    {
      printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' '<plist version="1.0"><dict>'
      printf '%s\n' '<key>Label</key><string>com.poonnaratn.kanata-remapper</string>' '<key>ProgramArguments</key><array>'
      printf '<string>%s</string>\n' "$escaped_bin" '<string>--no-wait</string>' '<string>--nodelay</string>' '<string>--cfg</string>' "$escaped_cfg"
      printf '%s\n' '</array>' '<key>RunAtLoad</key><true/>' '<key>KeepAlive</key><true/>' '<key>StandardOutPath</key>' "<string>$escaped_home/Library/Logs/kanata-remapper.log</string>" '<key>StandardErrorPath</key>' "<string>$escaped_home/Library/Logs/kanata-remapper.error.log</string>" '</dict></plist>'
    } > "$plist"
    launchctl bootout "gui/$(id -u)/com.poonnaratn.kanata-remapper" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$plist"
    say "Kanata is enabled as a macOS LaunchAgent"
    say "Grant Kanata Input Monitoring and Accessibility permissions in System Settings if prompted"
    ;;
  *) die "unsupported operating system: $os" ;;
esac

say "Running post-install verification"
if [ "$needs_new_login" -eq 1 ]; then
  say "Your user was added to the input group. Log out and back in (or reboot); Kanata will then start automatically."
  say "After logging back in, run ./verify.sh"
else
  "$script_dir/verify.sh"
fi

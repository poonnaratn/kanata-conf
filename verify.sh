#!/usr/bin/env bash
set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_file=$HOME/.config/kanata-remapper/kanata.kbd
failures=0

pass() { printf '[PASS] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*"; failures=$((failures + 1)); }

printf 'Kanata verification on %s\n\n' "$(uname -s)"

if [ -f "$script_dir/kanata.kbd" ]; then
  pass "Repository config exists: $script_dir/kanata.kbd"
else
  fail "Repository config is missing: $script_dir/kanata.kbd"
fi

if [ -f "$config_file" ]; then
  pass "Installed config exists: $config_file"
else
  fail "Installed config is missing: $config_file (run ./setup.sh)"
fi

if kanata_bin=$(command -v kanata 2>/dev/null); then
  pass "Kanata found: $kanata_bin"
  printf '       version: '
  kanata --version 2>&1 || true
  if [ -f "$config_file" ]; then
    if "$kanata_bin" --check --cfg "$config_file"; then
      pass "Kanata accepted the configuration"
    else
      fail "Kanata rejected the configuration"
    fi
  fi
else
  fail "Kanata is not on PATH"
fi

case "$(uname -s)" in
  Linux)
    if [ -e /dev/uinput ]; then
      pass "/dev/uinput exists"
      if [ -r /dev/uinput ] && [ -w /dev/uinput ]; then
        pass "/dev/uinput is readable and writable"
      else
        fail "/dev/uinput exists but is not readable/writable by this user"
      fi
    else
      fail "/dev/uinput is missing (Kanata cannot create its virtual keyboard)"
    fi
    if command -v systemctl >/dev/null 2>&1; then
      if systemctl --user is-enabled --quiet kanata-remapper.service; then
        pass "systemd service is enabled"
      else
        fail "systemd service is not enabled"
      fi
      if systemctl --user is-active --quiet kanata-remapper.service; then
        pass "systemd service is active"
      else
        fail "systemd service is not active"
        printf '\nRecent service log:\n'
        systemctl --user status kanata-remapper.service --no-pager -n 30 2>&1 || true
      fi
    else
      fail "systemctl is not installed"
    fi
    ;;
  Darwin)
    plist=$HOME/Library/LaunchAgents/com.poonnaratn.kanata-remapper.plist
    if [ -f "$plist" ]; then
      if command -v plutil >/dev/null 2>&1 && plutil -lint "$plist" >/dev/null; then
        pass "LaunchAgent plist is valid"
      else
        fail "LaunchAgent plist is missing or invalid: $plist"
      fi
    else
      fail "LaunchAgent plist is missing: $plist (run ./setup.sh)"
    fi
    if launchctl print "gui/$(id -u)/com.poonnaratn.kanata-remapper" >/dev/null 2>&1; then
      pass "LaunchAgent is loaded"
    else
      fail "LaunchAgent is not loaded"
    fi
    ;;
  *) fail "Unsupported operating system" ;;
esac

printf '\n'
if [ "$failures" -eq 0 ]; then
  printf 'All checks passed. Test the key mappings manually.\n'
else
  printf '%s check(s) failed. Review the messages above.\n' "$failures"
  exit 1
fi

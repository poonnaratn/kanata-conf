# Kanata remapper

This is the isolated home for the personal keyboard remapping. Nothing is
installed at the root of `~/.config`.

## Behaviour

- Tap Caps Lock: `Esc`.
- Hold Caps Lock: left `Ctrl`.
- The Copilot key acts as Left Super.
- Tap Enter: `Enter`.
- Hold Enter: `W`, `A`, `S`, and `D` become Up, Left, Down, and Right Arrow;
  `Q` becomes Page Up and `E` becomes Page Down.

The Copilot key is handled as the chord it actually emits on this keyboard:
Left Meta + Left Shift + F23.

## Enable Kanata

For a new Linux or macOS machine, clone this repository and run:

```sh
./setup.sh
```

The script installs Kanata when possible, copies `kanata.kbd` to the standard
user config directory, and registers it to start at login. On Linux it creates
a systemd user service; on macOS it creates a LaunchAgent. Re-run the script
after changing the configuration.

On macOS, approve Kanata under System Settings → Privacy & Security → Input
Monitoring and Accessibility. On Linux, Kanata needs access to the keyboard
event devices and `/dev/uinput`; your distribution may require an additional
udev rule or group membership.

### Manual Linux setup

Kanata 1.12.0 is installed at `/usr/bin/kanata`. Register and start the
included per-user service:

```sh
systemctl --user link ~/.config/kanata-remapper/kanata-remapper.service
systemctl --user enable --now kanata-remapper.service
```

Check its status with:

```sh
systemctl --user status kanata-remapper.service
```

After changing the configuration, restart the service:

```sh
systemctl --user restart kanata-remapper.service
```

Kanata also needs permission to read the keyboard event device and create its
virtual keyboard. Before enabling the service, check that `/dev/uinput` exists
on the logged-in system. It is normally created automatically by the `uinput`
kernel module.
# kanata-conf
# kanata-conf
# kanata-conf
# kanata-conf

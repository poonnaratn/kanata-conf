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
user config directory, and registers it to start at login. On Linux it asks for
your password once to install a udev rule and add your user to the `input`
group, then creates a systemd user service; on macOS it creates a LaunchAgent.
After a first Linux installation, log out and back in (or reboot) so the new
group membership takes effect. Re-run the script after changing the
configuration. Setup automatically runs `verify.sh` and returns a failure
status if a required check does not pass.

On macOS, approve Kanata under System Settings → Privacy & Security → Input
Monitoring and Accessibility. On Linux, Kanata needs access to the keyboard
event devices and `/dev/uinput`; your distribution may require an additional
udev rule or group membership.

Verify an installation without changing anything:

```sh
./verify.sh
```

The verifier checks the config syntax, Kanata version, Linux virtual-keyboard
access, and whether the Linux service or macOS LaunchAgent is enabled and
running. It exits with status 1 if a required check fails.

### Manual Linux setup

After logging back in following the first setup, manage the per-user service:

```sh
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

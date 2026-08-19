# Kanata remapper

This is the isolated home for the personal keyboard remapping. Nothing is
installed at the root of `~/.config`.

## Behaviour

- Tap Caps Lock: `Esc`.
- Hold Caps Lock: left `Ctrl`.
- Hold the Copilot key: `W`, `A`, `S`, and `D` become Up, Left, Down, and
  Right Arrow respectively.

The Copilot key is handled as the chord it actually emits on this keyboard:
Left Meta + Left Shift + F23.

## Enable after Kanata is installed

The `kanata` executable was not installed when this configuration was made.
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

Kanata also needs permission to read the keyboard event device and create its
virtual keyboard. Before enabling the service, check that `/dev/uinput` exists
on the logged-in system. It is normally created automatically by the `uinput`
kernel module.
# kanata-conf
# kanata-conf
# kanata-conf
# kanata-conf

# AEL//Screenshot

## Requirements

```bash
sudo pacman -S grim gimp
```

`grim` is required. GIMP is only required for the **Open in GIMP** button.

## Install

Copy the bundle contents into:

```text
~/.config/quickshell/ael-bar/
```

The included `shell.qml` and `qmldir` already contain the required integration.
The screenshot icon belongs at `icons/screenshot.svg`.

## Controls

- Left-click the camera: capture the monitor containing that bar.
- Right-click the camera: choose no delay, 3, 5, or 10 seconds.
- During a delay, the camera becomes a countdown.
- Save writes a timestamped PNG under `~/Pictures/Screenshots`.
- Open in GIMP opens the temporary full-resolution capture.
- Discard closes the preview and removes the temporary image.

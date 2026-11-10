# omarchy-dtp-tray-the-stocks

Moves the stock status buttons (agents, Bluetooth, Wi-Fi, sound, display) off the bar and into the system tray's drawer, on the right of the tray icons. They show when the tray opens, not all the time. Power and the clock stay on the bar.

Works best with `omarchy-dtp-tray-auto-hide`, which also hides the chevron until the pointer is over the right side of the bar.

## Install

`omarchy-dtp-install` runs this after `omarchy-dtp-tray-auto-hide`. From GitHub:

```bash
git clone https://github.com/dtpietrzak/omarchy-dtp-tray-the-stocks.git
cd omarchy-dtp-tray-the-stocks
./install.sh
omarchy restart shell
```

The script edits `bar.layout` in `~/.config/omarchy/shell.json`: it moves those buttons from `right` to `tray`, keeping each one's settings. A backup of the file is saved beside it first. Running it again changes nothing. The bar shows the change after the shell restarts.

## Put them back

```bash
./install.sh --undo
omarchy restart shell
```

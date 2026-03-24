# Auto Layout Switch

A World of Warcraft addon that automatically switches your Edit Mode layout based on your current screen resolution.

## How It Works

When you log in, the addon detects your screen resolution and searches your Edit Mode layouts for one that matches. It looks for the resolution in layout names using this priority:

1. Full resolution (e.g. `3440x1440`)
2. Width only (e.g. `3440`)
3. Height only (e.g. `1080`)

Numbers are matched as standalone tokens, so a layout named "Laptop 1080" matches a height of 1080 but not 10800.

If a matching layout is found and isn't already active, the addon switches to it automatically.

## Setup

Name your Edit Mode layouts to include the resolution they're meant for. For example:

- `PC 3440x1440`
- `Laptop 1080`
- `Ultrawide 3440`

No other configuration is needed.

## Slash Commands

| Command | Description |
|---|---|
| `/alt` | Show available commands |
| `/alt list` | List all Edit Mode layouts |
| `/alt status` | Show current resolution and matched layout |
| `/alt switch` | Manually trigger a layout switch |

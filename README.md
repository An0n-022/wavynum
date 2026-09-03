# wavynum

`wavynum` is a lightweight Bash animation that fills your terminal with flowing waves made from numbers. It is designed as a visual extra for Linux ricing setups, screenshots, terminal dashboards, or simply adding some motion to a desktop.

## Features

- Animated number waves that adapt to the terminal size
- Seven color modes, including a 256-color rainbow mode
- Adjustable animation speed and wave count
- Custom drawing characters
- Clean exit that restores the cursor and original terminal screen
- No heavy dependencies

## Requirements

- Linux or another Unix-like system
- Bash 4 or newer
- An interactive terminal with `tput` and 256-color support recommended
- `awk`, which is included with most Linux distributions

## Install and run

```bash
git clone https://github.com/An0n-022/wavynum.git
cd wavynum
chmod +x wavynum.sh
./wavynum.sh
```

Press <kbd>q</kbd> or <kbd>Ctrl</kbd>+<kbd>C</kbd> to quit.

## Customization

```bash
# Purple, faster, and with four waves
./wavynum.sh --color purple --speed 18 --waves 4

# Rainbow binary waves
./wavynum.sh --color rainbow --numbers 01

# See every option
./wavynum.sh --help
```

Available colors are `cyan`, `green`, `blue`, `purple`, `amber`, `white`, and `rainbow`.

## Using it in a rice

Launch `wavynum.sh` in a transparent terminal window and combine it with your preferred compositor rules, terminal opacity, font, and color scheme. The animation uses the terminal's alternate screen, so your previous terminal contents return when it closes.

## Development approach

The foundational updates to `wavynum` will be vibe-coded: ideas will be explored quickly with AI-assisted development and refined through testing. Later updates will use a mix of vibe-coding and hands-on coding as the project grows and its design becomes more established.

Bug reports, ideas, and contributions are welcome. Changes should remain readable, lightweight, and friendly to common Linux setups.

## Open source

`wavynum` is open-source software released under the [MIT License](LICENSE). You may use, copy, modify, and redistribute it under the terms of that license.

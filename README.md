# remilia

windows stuff

personal windows desktop configuration.

this repo is the source of truth for the rice: layout, terminal, launcher, wallpaper, workspace behavior, scripts, and visual rules.

## current stack

- windows 10
- glazewm
- yasb — intentionally untouched
- windows terminal
- powershell 7
- flow launcher
- chrome
- visual studio
- vs code
- roblox studio
- remilia scarlet wallpaper
- 1920x1080 display

## workspace map

| key | workspace |
| --- | --- |
| alt+1 | main |
| alt+2 | code |
| alt+3 | roblox |
| alt+4 | lain |
| alt+5 | media |
| alt+6 | 6 |
| alt+7 | 7 |
| alt+8 | 8 |
| alt+9 | 9 |

## rules

- dark first
- all lowercase where text is visible
- red / magenta / black visual language
- compact spacing
- minimal chrome
- wallpaper stays visible
- terminal stays translucent without heavy blur
- glazewm handles tiling
- apps route to their workspace
- yasb is not modified by this project
- every consequential change is reversible
- back up before changing live configs

## repo layout

```
remilia/
├── configs/
│   ├── glazewm/
│   ├── terminal/
│   ├── powershell/
│   └── flow-launcher/
├── docs/
│   ├── design.md
│   ├── workspaces.md
│   ├── software.md
│   ├── wallpaper.md
│   ├── safety-rules.md
│   └── changelog.md
├── scripts/
│   ├── backup.ps1
│   └── restore.ps1
└── README.md
```

the repository stores configuration and instructions, not secrets or private machine data.

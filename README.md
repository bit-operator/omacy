# omachy

An Omarchy-inspired, keyboard-first macOS setup: tiling windows, Tokyo Night everywhere, terminal-centric.
The same shell / tmux / Neovim config also deploys to Linux servers and Coder workspaces.

| Layer | Tool |
|---|---|
| Tiling WM | [AeroSpace](https://github.com/nikitabobko/AeroSpace) + [JankyBorders](https://github.com/FelixKratz/JankyBorders) |
| Bar | [SketchyBar](https://github.com/FelixKratz/SketchyBar) (replaces the macOS menu bar) |
| Keyboard | [Karabiner-Elements](https://karabiner-elements.pqrs.org/): Caps = Esc / Hyper, Right ⌘ = EN/HE |
| Launcher | Raycast |
| Terminal | Ghostty → zsh (starship, fzf, atuin, zoxide) → tmux + sesh |
| Editor | Neovim + [LazyVim](https://www.lazyvim.org/) |
| Dotfiles | [chezmoi](https://www.chezmoi.io/) (`home/` is the source state) |
| Themes | `theme <name>`: tokyonight · catppuccin · gruvbox · kanagawa |

## Install

```sh
git clone <this repo> ~/Projects/MacOS-Personalization
cd ~/Projects/MacOS-Personalization && ./install.sh
```

`install.sh` is idempotent: `brew bundle` → `chezmoi apply` → start SketchyBar/borders → `scripts/macos-defaults.sh`.

### First run (manual, once)
1. **Karabiner-Elements**: open it, allow the driver extension and Input Monitoring in System Settings.
2. **AeroSpace**: open it, grant Accessibility. It starts at login from then on.
3. **Ghostty**: grant Accessibility (for the global Hyper+` quick terminal).
4. **Raycast**: set its hotkey to Hyper+Space (Caps+Space). Turn off AI features unless approved.
5. **Input sources**: ABC + Hebrew (System Settings → Keyboard → Text Input).
6. Log out and back in (key repeat, Spaces, menu bar).
7. **Dygma Defy** (Bazecor): OS layout = macOS. Map one thumb key to *Caps Lock* (→ Esc/Hyper via Karabiner)
   and one to *Right Cmd* (→ EN/HE toggle).

## Keys

Hyper = hold Caps Lock (⌘⌃⌥). Tap Caps = Esc.

| Keys | Action |
|---|---|
| Hyper + Enter / E / B | Ghostty / yazi (files) / Safari |
| Hyper + Space | Raycast |
| Hyper + ` | Drop-down terminal |
| Hyper + h j k l | Focus window |
| Hyper + Shift + h j k l | Move window |
| Hyper + 1…9 / Shift + 1…9 | Go to workspace / send window there (and follow) |
| Hyper + Tab | Last workspace |
| Hyper + . / Shift + . | Focus other screen / move window to other screen |
| Hyper + F / T / Q | Fullscreen / float ↔ tile / close |
| Hyper + / or , | Tiles ↔ accordion layouts |
| Hyper + R, then h j k l | Resize mode (Esc to leave) |
| Hyper + ; then r / b / f | Service mode: reload config / balance / float |
| Ctrl + Space, or Right ⌘ (tap) | English ↔ Hebrew |

Workspaces: **1–5 on the external screen** (1 terminal · 2 browser), **6–9 on the laptop** (6 Teams/Slack · 7 Outlook).
Laptop alone: all on one screen. Workspaces are pinned to screens; move *windows* between screens.

**tmux**: prefix `C-a` locally, `C-b` inside SSH sessions (so nested tmux works).
`prefix s` session picker (projects, `^s` SSH hosts) · `prefix Tab` last session · `prefix g` lazygit ·
`prefix | / -` split · `C-h/j/k/l` move across tmux panes *and* nvim splits.

**zsh**: vi mode (`Esc v` edits the line in nvim) · `C-r` atuin history · `C-t` files · `Alt-c` dirs ·
`C-f` accept suggestion · `t` session picker · `y` yazi (cd on quit) · `cd` is zoxide.
Commands running ≥ 30s send a desktop notification, even from remote hosts.

## Themes

```sh
theme              # fzf picker
theme gruvbox      # Ghostty, nvim (live), tmux, bar, borders, btop, wallpaper
```

Add a theme: `home/dot_config/omachy/themes/<name>/theme.env` (copy one), then
`uv run --with pillow --with numpy scripts/gen-wallpapers.py` to render its wallpaper.

## Remote hosts & Coder

```sh
dot-push <ssh-host>   # auto-detects internet on the remote
```
- **Online**: copies the repo; the remote installs chezmoi + tools via mise into `~/.local` (no root).
- **Offline**: builds a Linux bundle here (nvim, fzf, rg, fd, zoxide, starship, lazygit, tree-sitter, plugins)
  and ships it. Neovim then uses the host's own LSPs (e.g. its clangd) instead of Mason.
- **Coder**: point the workspace's dotfiles URL at this repo; `coder dotfiles` runs `install.sh`.

## Layers & hook points

This repo is generic and safe to publish. Anything machine- or employer-specific lives in a second, private
chezmoi source that only writes into these hook points:

| Hook | Purpose |
|---|---|
| `~/.config/zsh/conf.d/*.zsh` | env, aliases |
| `~/.config/git/work.gitconfig` | applied to repos under `~/work/` |
| `~/.config/git/local.gitconfig` | signing key etc. for this machine |
| `~/.config/nvim/lua/plugins/local/*.lua` | editor tweaks |
| `~/.config/sesh/local.toml` | named tmux sessions |
| `~/.config/sketchybar/plugins/local/*.sh` | extra bar items (e.g. VPN) |

`~/.ssh/config` is deliberately **not** managed: `coder config-ssh` owns its Coder block.

**Never commit secrets.** Tokens come from the macOS Keychain / session env, never from dotfiles.
Atuin history sync is disabled by design.

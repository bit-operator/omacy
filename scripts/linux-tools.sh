#!/usr/bin/env bash
# omacy Linux toolset — static release binaries from GitHub, installed under a prefix (default ~/.local).
# Needs only curl + tar + github.com access: no root, no apt, no PyPI, no mise.run. (zsh comes from the
# distro — see install.sh: a portable zsh-bin build could not read terminfo and garbled line editing.)
# Used by install.sh on Coder/servers, and by dot-push on the Mac to build offline bundles.
#
#   scripts/linux-tools.sh install [prefix] [arch]   install missing tools (OMACY_UPDATE=1 reinstalls)
#   scripts/linux-tools.sh check   [arch]            print the asset each tool resolves to

# "binary github-repo asset-regex(ERE)" — space-separated. Placeholders: @R rust arch (x86_64/aarch64),
# @G go arch (amd64/arm64), @A alt arch (x86_64/arm64), @T tree-sitter arch (x64/arm64). Static (musl) builds win.
OMACY_TOOLS=(
  "chezmoi twpayne/chezmoi ^chezmoi_[0-9.]+_linux(-musl)?_@G\\.tar\\.gz$"
  "fzf junegunn/fzf ^fzf-[0-9.]+-linux_@G\\.tar\\.gz$"
  "rg BurntSushi/ripgrep ^ripgrep-[0-9.]+-@R-unknown-linux-(musl|gnu)\\.tar\\.gz$"
  "fd sharkdp/fd ^fd-v[0-9.]+-@R-unknown-linux-(musl|gnu)\\.tar\\.gz$"
  "zoxide ajeetdsouza/zoxide ^zoxide-[0-9.]+-@R-unknown-linux-musl\\.tar\\.gz$"
  "starship starship/starship ^starship-@R-unknown-linux-musl\\.tar\\.gz$"
  "lazygit jesseduffield/lazygit ^lazygit_[0-9.]+_[Ll]inux_@A\\.tar\\.gz$"
  "eza eza-community/eza ^eza_@R-unknown-linux-(musl|gnu)\\.tar\\.gz$"
  "bat sharkdp/bat ^bat-v[0-9.]+-@R-unknown-linux-(musl|gnu)\\.tar\\.gz$"
  "delta dandavison/delta ^delta-[0-9.]+-@R-unknown-linux-(musl|gnu)\\.tar\\.gz$"
  "atuin atuinsh/atuin ^atuin-@R-unknown-linux-(musl|gnu)\\.tar\\.gz$"
  "sesh joshmedeski/sesh ^sesh_Linux_@A\\.tar\\.gz$"
  "tree-sitter tree-sitter/tree-sitter ^tree-sitter-linux-@T\\.gz$"
)
# Whole-directory installs (prefix/opt/<name>, bin symlinked).
OMACY_DIRS=(
  "nvim neovim/neovim ^nvim-linux-@A\\.tar\\.gz$ bin/nvim"
)

_ot_log() { printf '  %s\n' "$*"; }

_ot_arch() {
  case ${1:-$(uname -m)} in
    x86_64 | amd64) R=x86_64 G=amd64 A=x86_64 T=x64 ;;
    aarch64 | arm64) R=aarch64 G=arm64 A=arm64 T=arm64 ;;
    *) echo "linux-tools: unsupported arch ${1:-$(uname -m)}" >&2; return 1 ;;
  esac
}

_ot_regex() { local re=$1; re=${re//@R/$R}; re=${re//@G/$G}; re=${re//@A/$A}; printf '%s' "${re//@T/$T}"; }

# Latest-release asset URL matching an ERE. Uses github.com release pages, not api.github.com:
# the anonymous API allows 60 calls/hour per IP, which a shared Coder egress IP exhausts quickly.
_ot_asset() {
  local repo=$1 re=$2 tag names
  tag=$(curl -fsSI "https://github.com/$repo/releases/latest" | awk 'tolower($1) == "location:" { n = split($2, p, "/"); print p[n] }' | tr -d '\r')
  [[ -n $tag ]] || return 1
  names=$(curl -fsSL "https://github.com/$repo/releases/expanded_assets/$tag" |
    grep -oE "/$repo/releases/download/[^\"]+" | sed 's#.*/##' | sort -u | grep -E "$re") || return 1
  # Prefer static musl builds (they run on old glibc too), then anything else. Single awk: no
  # grep-with-no-match or SIGPIPE exit codes to trip callers running under `set -o pipefail`.
  awk -v base="https://github.com/$repo/releases/download/$tag/" \
    '/musl/ { print base $0; done = 1; exit } !first { first = $0 } END { if (!done && first) print base first }' <<<"$names"
}

_ot_fetch() { # url -> extracted dir on stdout
  local url=$1 tmp
  tmp=$(mktemp -d)
  case $url in
    *.tar.gz | *.tgz) curl -fsSL "$url" | tar -xz -C "$tmp" ;;
    *.gz) curl -fsSL "$url" | gunzip -c >"$tmp/$(basename "${url%.gz}")" ;;
  esac
  printf '%s' "$tmp"
}

omacy_linux_tools() { # prefix [arch]
  local prefix=${1:-$HOME/.local} entry name repo re bin url tmp found rel
  _ot_arch "${2:-}" || return 1
  mkdir -p "$prefix/bin" "$prefix/opt"

  for entry in "${OMACY_TOOLS[@]}"; do
    read -r name repo re <<<"$entry"
    [[ -x $prefix/bin/$name && -z ${OMACY_UPDATE:-} ]] && continue
    url=$(_ot_asset "$repo" "$(_ot_regex "$re")") || url=
    [[ -n $url ]] || { _ot_log "✗ $name: no release asset found ($repo)"; continue; }
    tmp=$(_ot_fetch "$url")
    if [[ $name == tree-sitter ]]; then found=$(find "$tmp" -type f | head -1); else found=$(find "$tmp" -type f -name "$name" | head -1); fi
    if [[ -n $found ]]; then install -m 755 "$found" "$prefix/bin/$name" && _ot_log "✓ $name ← ${url##*/}"; else _ot_log "✗ $name: binary missing in ${url##*/}"; fi
    rm -rf "$tmp"
  done

  for entry in "${OMACY_DIRS[@]}"; do
    read -r name repo re rel <<<"$entry"
    [[ -x $prefix/opt/$name/$rel && -z ${OMACY_UPDATE:-} ]] && continue
    url=$(_ot_asset "$repo" "$(_ot_regex "$re")") || url=
    [[ -n $url ]] || { _ot_log "✗ $name: no release asset found ($repo)"; continue; }
    tmp=$(_ot_fetch "$url")
    # Archives either wrap everything in one top folder (nvim) or unpack bin/ share/ directly.
    if [[ -e $tmp/$rel ]]; then found=$tmp; else found=$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -1); fi
    rm -rf "$prefix/opt/$name" && mv "$found" "$prefix/opt/$name"
    [[ $found == "$tmp" ]] || rm -rf "$tmp"
    ln -sfn "$prefix/opt/$name/$rel" "$prefix/bin/$name"
    _ot_log "✓ $name ← ${url##*/}"
  done
}

omacy_linux_tools_check() { # [arch]
  local entry name repo re rel
  _ot_arch "${1:-}" || return 1
  for entry in "${OMACY_TOOLS[@]}" "${OMACY_DIRS[@]}"; do
    read -r name repo re rel <<<"$entry"
    printf '%-12s %s\n' "$name" "$(_ot_asset "$repo" "$(_ot_regex "$re")" | sed 's#.*/##')"
  done
}

if [[ ${BASH_SOURCE[0]:-} == "$0" ]]; then
  set -euo pipefail
  case ${1:-} in
    install) omacy_linux_tools "${2:-$HOME/.local}" "${3:-}" ;;
    check) omacy_linux_tools_check "${2:-}" ;;
    *) sed -n '2,7s/^# \{0,1\}//p' "$0"; exit 2 ;;
  esac
fi

#!/usr/bin/env bash
# omamac macOS defaults — keyboard-first, quiet, tiling-friendly. Idempotent; user-level only.
# Originals were exported to ~/.dotfiles-backup-*/defaults before the first run.
set -uo pipefail
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
w() { defaults write "$@" || printf '  (skipped: %s)\n' "$*"; }

log "Keyboard"
w NSGlobalDomain KeyRepeat -int 2                    # fastest sane repeat
w NSGlobalDomain InitialKeyRepeat -int 15
w NSGlobalDomain ApplePressAndHoldEnabled -bool false # hold = repeat (vim!), not accent popup
w NSGlobalDomain AppleKeyboardUIMode -int 2           # Tab reaches every control in dialogs
w NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
w NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
w NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
w NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
w NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
w com.apple.HIToolbox AppleFnUsageType -int 1         # Globe key = change input source (fallback)
# Free ⌃Space / ⌃⌥Space (input source cycling) for the tmux prefix; Right ⌘ toggles EN/HE instead.
w com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '<dict><key>enabled</key><false/></dict>'
w com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '<dict><key>enabled</key><false/></dict>'

log "Windows, animations, tiling (AeroSpace owns layout)"
w NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
w NSGlobalDomain NSWindowResizeTime -float 0.001
w NSGlobalDomain NSWindowShouldDragOnGesture -bool true # ⌃⌘ + drag moves any window
w NSGlobalDomain AppleInterfaceStyle -string Dark
w NSGlobalDomain _HIHideMenuBar -bool true            # SketchyBar replaces it
w NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false
w com.apple.WindowManager GloballyEnabled -bool false  # Stage Manager off
w com.apple.WindowManager EnableTilingByEdgeDrag -bool false
w com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
w com.apple.WindowManager EnableTilingOptionAccelerator -bool false
w com.apple.WindowManager EnableTiledWindowMargins -bool false
w com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
w com.apple.spaces spans-displays -bool true          # one Space set across displays (AeroSpace recommendation; needs logout)

log "Dock & Mission Control"
w com.apple.dock autohide -bool true
w com.apple.dock autohide-delay -float 1000           # effectively never shows
w com.apple.dock autohide-time-modifier -float 0
w com.apple.dock show-recents -bool false
w com.apple.dock launchanim -bool false
w com.apple.dock mineffect -string scale
w com.apple.dock tilesize -int 40
w com.apple.dock mru-spaces -bool false               # don't reorder Spaces
w com.apple.dock expose-group-apps -bool true         # AeroSpace: sane Mission Control

log "Finder"
w com.apple.finder AppleShowAllFiles -bool true
w NSGlobalDomain AppleShowAllExtensions -bool true
w com.apple.finder ShowPathbar -bool true
w com.apple.finder ShowStatusBar -bool true
w com.apple.finder _FXShowPosixPathInTitle -bool true
w com.apple.finder _FXSortFoldersFirst -bool true
w com.apple.finder FXPreferredViewStyle -string Nlsv
w com.apple.finder FXDefaultSearchScope -string SCcf
w com.apple.finder FXEnableExtensionChangeWarning -bool false
w com.apple.finder NewWindowTarget -string PfHm
w com.apple.finder CreateDesktop -bool false          # clean desktop, wallpaper only
w com.apple.desktopservices DSDontWriteNetworkStores -bool true
w com.apple.desktopservices DSDontWriteUSBStores -bool true
w NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
w NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
w NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

log "Screenshots"
mkdir -p "$HOME/Pictures/Screenshots"
w com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
w com.apple.screencapture type -string png
w com.apple.screencapture disable-shadow -bool true

log "Trackpad: tap to click"
w com.apple.AppleMultitouchTrackpad Clicking -bool true
w com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
w NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

log "Applying"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
killall Dock Finder SystemUIServer 2>/dev/null || true
echo "Done. Log out and back in once for Spaces / menu-bar / key-repeat changes to fully apply."

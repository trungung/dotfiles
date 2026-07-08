#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_chrome="$dotfiles_dir/firefox/chrome"
firefox_dir="$HOME/Library/Application Support/Firefox"
profiles_ini="$firefox_dir/profiles.ini"
managed_marker=".dotfiles-managed"

if [[ ! -d "$source_chrome" ]]; then
  echo "Firefox chrome source does not exist: $source_chrome" >&2
  exit 1
fi

if [[ ! -f "$profiles_ini" ]]; then
  echo "Firefox profiles.ini not found; open Firefox once, then rerun scripts/firefox.sh."
  exit 0
fi

install_default="$(
  awk -F= '
    /^\[Install/ { in_install = 1; next }
    /^\[/ { in_install = 0 }
    in_install && $1 == "Default" { print $2; exit }
  ' "$profiles_ini"
)"

default_release="$(
  awk -F= '
    /^\[/ {
      if (name == "default-release" && path != "") {
        print path
        found = 1
        exit
      }
      name = ""
      path = ""
      next
    }
    $1 == "Name" { name = $2 }
    $1 == "Path" { path = $2 }
    END {
      if (!found && name == "default-release" && path != "") {
        print path
      }
    }
  ' "$profiles_ini"
)"

profile_path="${install_default:-$default_release}"
if [[ -z "$profile_path" ]]; then
  echo "Could not find a Firefox default-release profile in $profiles_ini." >&2
  exit 1
fi

if [[ "$profile_path" = /* ]]; then
  profile_dir="$profile_path"
else
  profile_dir="$firefox_dir/$profile_path"
fi

if [[ ! -d "$profile_dir" ]]; then
  echo "Firefox profile directory does not exist: $profile_dir" >&2
  exit 1
fi

target_chrome="$profile_dir/chrome"

if [[ -L "$target_chrome" ]]; then
  current_target="$(readlink "$target_chrome")"
  if [[ "$current_target" == "$source_chrome" ]]; then
    echo "Replacing symlinked Firefox chrome with a real directory for userContent asset compatibility."
    unlink "$target_chrome"
  else
    backup="$target_chrome.symlink.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing Firefox chrome symlink to: $backup"
    mv "$target_chrome" "$backup"
  fi
fi

if [[ -e "$target_chrome" && ! -f "$target_chrome/$managed_marker" ]]; then
  backup="$target_chrome.backup.$(date +%Y%m%d%H%M%S)"
  echo "Backing up existing Firefox chrome to: $backup"
  mv "$target_chrome" "$backup"
fi

mkdir -p "$target_chrome"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required to sync Firefox chrome files." >&2
  exit 1
fi

rsync -a --delete "$source_chrome"/ "$target_chrome"/
echo "Synced Firefox chrome from: $source_chrome"
echo "Firefox profile chrome directory: $target_chrome"

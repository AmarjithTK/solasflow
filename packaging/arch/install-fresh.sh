#!/usr/bin/env bash
set -euo pipefail

root="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"
flutter="$HOME/flutter/bin/flutter"
for command in git bsdtar makepkg fakeroot zstd flock pacman sudo gdbus nohup; do
  command -v "$command" >/dev/null || { printf 'Missing existing tool: %s\n' "$command" >&2; exit 1; }
done
[[ -x "$flutter" && -f "$root/.dart_tool/package_config.json" && -f "$root/.dart_tool/package_graph.json" ]] || {
  printf 'The existing Flutter SDK and resolved project dependencies are required.\n' >&2
  exit 1
}

clean_reinstall=false
if [[ $# == 1 && "$1" == --clean-reinstall ]]; then
  clean_reinstall=true
elif (( $# > 0 )); then
  printf 'Usage: %s [--clean-reinstall]\n' "$0" >&2
  exit 2
fi

# Reuse the existing package layout without altering the project's PKGBUILD.
source "$root/packaging/arch/PKGBUILD"
pacman -T "${depends[@]}" || {
  printf 'Required runtime packages are missing; no dependencies were installed automatically.\n' >&2
  exit 1
}
base="$root/build/arch"
mkdir -p "$base"
work="$(mktemp -d "$base/install.XXXXXX")"
printf '%s\n' "$work" > "$base/latest-run"
printf '%s\n' "$$" > "$work/installer.pid"
phase() { printf '%s\n' "$1" > "$work/state"; }
trap 'result=$?; if (( result != 0 )); then phase "failed:$result"; printf "Installation stopped (exit %s). Details: %s\n" "$result" "$work" >&2; fi' EXIT

srcdir="$work/src"
snapshot="$srcdir/$pkgname"
mkdir -p "$snapshot/.dart_tool"
phase snapshot
printf '[APP] Preparing the current working source without touching the running build.\n'
cd "$root"
git ls-files -z | bsdtar -c -f - --null -T - | bsdtar -x -f - -C "$snapshot"
cp "$root/.dart_tool/package_config.json" "$root/.dart_tool/package_graph.json" "$snapshot/.dart_tool/"
if [[ -f "$root/.flutter-plugins-dependencies" ]]; then
  cp "$root/.flutter-plugins-dependencies" "$snapshot/"
fi

exec 9>/tmp/flutter-build.lock
flock -n 9 || { printf 'Another Flutter/Android build holds the shared lock; no build was started.\n' >&2; exit 1; }
phase building
printf '[APP] Building a fresh Linux release using the existing SDK; no pub get or tests.\n'
(cd "$snapshot" && "$flutter" build linux --release --no-pub) 2>&1 | tee "$work/build.log"
version="$(pkgver)"
printf 'source %q\npkgver=%q\nBUILDDIR=%q\nPKGDEST=%q\nSRCDEST=%q\nLOGDEST=%q\noptions=(!strip !debug)\nCOMPRESSZST=(zstd -c -T2 -3 -)\n' \
  "$root/packaging/arch/PKGBUILD" "$version" "$work" "$work" "$work" "$work" > "$work/PKGBUILD"
phase packaging
# The fresh build is already complete. Repackage it without downloads or prepare/build/check hooks.
makepkg --dir "$work" --repackage --nodeps --nosign --nocheck --noprepare
flock -u 9
packages=("$work"/*.pkg.tar.*)
[[ ${#packages[@]} == 1 && -f "${packages[0]}" ]] || { printf 'Expected one completed Arch package.\n' >&2; exit 1; }
printf '%s\n' "${packages[0]}" > "$work/package-path"

app_running() {
  local owner
  owner="$(gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
    --method org.freedesktop.DBus.NameHasOwner com.atherpulse.solasflow)"
  [[ "$owner" == '(true,)' ]]
}
if app_running; then
  phase awaiting-app-exit
  printf '\n[APP] Use the Exit/power button in the existing app before replacing its installation.\n'
  printf 'Close timer does not quit the app. Settings and downloaded voice models will be retained.\n'
  read -r -p 'After exiting the existing app, press Enter to continue: ' _
  if app_running; then
    printf 'The existing app is still running; no installation files were removed.\n' >&2
    exit 1
  fi
fi
if $clean_reinstall; then
  phase removing
  printf '\n[APP] Removing the existing Solas Flow package before reinstalling. Dependencies and user data are retained.\n'
  if pacman -Q "$pkgname" >/dev/null 2>&1; then
    sudo pacman -R -- "$pkgname"
  fi
  sudo rm -rf -- /opt/solasflow
fi

phase awaiting-password
printf '\n[APP] Installing only the local Solas Flow package. Enter your password in this terminal when sudo asks.\n'
sudo pacman -U -- "${packages[0]}"
pacman -Q "$pkgname"
phase installed

# Retire the per-user installation that otherwise shadows the system launcher.
share_dir="${XDG_DATA_HOME:-"$HOME/.local/share"}"
rm -rf -- "$HOME/.local/opt/solasflow"
rm -f -- "$share_dir/applications/com.atherpulse.solasflow.desktop"
for size in 48 128 256 512; do
  rm -f -- "$share_dir/icons/hicolor/${size}x${size}/apps/solasflow.png"
done
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$share_dir/applications"
fi
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental
fi
phase launcher-refreshed

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  export GDK_BACKEND=wayland
fi
nohup /opt/solasflow/solasflow > "$work/app.log" 2>&1 < /dev/null &
printf '%s\n' "$!" > "$work/app.pid"
phase launch-requested
printf '\n[APP] Installed build launch requested. Package and runtime logs retained at %s\n' "$work"

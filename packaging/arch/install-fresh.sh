#!/usr/bin/env bash
set -euo pipefail

root="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"
flutter="$HOME/flutter/bin/flutter"
for command in git bsdtar makepkg fakeroot zstd flock pacman sudo gdbus nohup; do
  command -v "$command" >/dev/null || { printf 'Missing existing tool: %s\n' "$command" >&2; exit 1; }
done
[[ -x "$flutter" && -f "$root/.dart_tool/package_config.json" ]] || {
  printf 'The existing Flutter SDK and resolved project dependencies are required.\n' >&2
  exit 1
}

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
cp "$root/.dart_tool/package_config.json" "$snapshot/.dart_tool/"
if [[ -f "$root/.flutter-plugins-dependencies" ]]; then
  cp "$root/.flutter-plugins-dependencies" "$snapshot/"
fi

exec 9>/tmp/flutter-build.lock
flock -n 9 || { printf 'Another Flutter/Android build holds the shared lock; no build was started.\n' >&2; exit 1; }
phase building
printf '[APP] Building a fresh Linux release using the existing SDK; no pub get or tests.\n'
(cd "$snapshot" && "$flutter" build linux --release --no-pub)
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

phase awaiting-password
printf '\n[APP] Installing only the local Solas Flow package. Enter your password in this terminal when sudo asks.\n'
sudo pacman -U -- "${packages[0]}"
pacman -Q "$pkgname"
phase installed

app_running() {
  local owner
  owner="$(gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
    --method org.freedesktop.DBus.NameHasOwner com.atherpulse.solasflow)"
  [[ "$owner" == '(true,)' ]]
}
if app_running; then
  phase awaiting-app-exit
  printf '\n[APP] Installation succeeded. Use the Exit/power button in the existing app to close it gracefully.\n'
  printf 'This is a one-time restart to load the installed build; the Close timer button does not quit the app.\n'
  read -r -p 'After exiting the existing app, press Enter to launch the installed build: ' _
  if app_running; then
    printf 'The existing app is still running. Exit it, then launch /opt/solasflow/solasflow.\n' >&2
    exit 1
  fi
fi
nohup /opt/solasflow/solasflow > "$work/app.log" 2>&1 < /dev/null &
printf '%s\n' "$!" > "$work/app.pid"
phase launched
printf '\n[APP] Fresh installed build launched. Package and logs retained at %s\n' "$work"

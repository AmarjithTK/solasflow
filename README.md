# Solas Flow

`Solas Flow` is a Flutter focus app that combines a speaking clock, a configurable timer, and an immersive fullscreen focus mode.

## What it does

### Speaking Clock
- Shows a live digital clock with large, readable typography.
- Speaks the current time at a configurable interval (`1, 2, 5, 10, 15, 20, 30, 60` minutes); each next interval is measured from the scheduler's actual firing time, and its deadline survives app restarts. Pending clock messages are coalesced; stalled TTS operations time out so later speech can continue.
- Optional motivational quote after each spoken time.
- Quote category options:
	- `General`
	- `Focus`
	- `Discipline`
	- `Calm`
	- `Positivity`
	- `Historic Figures`
- Motivation delay options (`5, 10, 20, 30, 40, 60` seconds).

- Quote catalogs are expanded across all categories: English lists contain 12–55 quotes, with 25 quotes in each Malayalam speech category. Quotes play sequentially without repeats until their category-and-language list is exhausted. The 145 expanded Malayalam quotes use one shared Aoede recording per phrase, including when another Malayalam voice is selected.

### Timer
- Adjustable duration (`1` to `120` minutes).
- Quick preset values include `5, 10, 15, 20, 25, 30, 45, 60, 90, 120`.
- Start / Stop / Reset controls.
- Optional background noise playback while timer runs.
- Optional spoken remaining time, configurable cadence (`1, 2, 5, 10, 15, 20, 30` minutes).
- Chain timer mode with built-in presets:
	- `Pomodoro 25-5x4`
	- `Sprint 50-10x2`
	- `Quick 15-3x3`

### Fullscreen Focus mode
- Dedicated fullscreen screen for clock/timer focus.
- Auto-hides controls after 5 seconds; tap anywhere to toggle controls.
- Immersive state increases visual emphasis of time display.
- In-view controls:
	- Always-on screen toggle (wakelock)
	- Dark/light theme toggle
	- Dim brightness toggle
	- Rotate horizontal / unlock rotation toggle
	- Switch between `SpeakClock` and `Timer` views
- Fullscreen defaults are configurable from settings:
	- Use dark theme by default
	- Dim screen brightness in fullscreen
	- Start fullscreen in horizontal orientation

### Notification + background behavior
- Foreground service keeps timer/clock state alive in background. Android may defer app speech while backgrounded or suspended; on resume, the clock scheduler re-arms and starts a fresh interval after any delayed announcement.
- Notification buttons can control timer and clock speech state.
- App provides full-exit behavior that stops timer/clock/audio and foreground service.

### Voice and audio settings
- Nature sound selection (local bundled assets).
- Separate noise volume and speech volume controls.
- Four bundled Malayalam studio voices (Aoede, Kore, Puck, Charon) play offline on Android and Linux; automatic Malayalam rotation cycles through the four voices.
- Favorite voice selection.

### Quick Actions (launcher shortcuts)
- `Start 25m`
- `Resume Last`
- `Toggle Speech`

### Android Home Screen Widgets
- `Live Realtime Clock`: Live wall-clock display with real-time seconds ticking natively via Android `TextClock` without battery-draining polling alarms. Includes live date, tap-to-open Clock view, and quick 1-tap jump to fullscreen Focus Mode.
- `Timer Presets`: 15 quick-start buttons (`1m` to `90m`) to immediately initiate a timer session.
- `Speech Controls`: Master audio toggle and direct fullscreen clock launcher.

### Persistence
- Preferences are persisted with `shared_preferences`, including:
	- sound + volume choices
	- clock interval + motivation settings
	- timer speech/noise settings
	- fullscreen defaults
	- voice preferences

## Tech stack

- Flutter / Dart
- `flutter_tts`
- `audioplayers`
- `flutter_foreground_task`
- `flutter_local_notifications`
- `quick_actions`
- `wakelock_plus`
- `screen_brightness`
- `shared_preferences`

## Project structure (important paths)

- `lib/main.dart` — app orchestration, tabs, state, lifecycle
- `lib/widgets/clock_panel.dart` — speaking clock UI
- `lib/widgets/timer_panel.dart` — timer + chain timer UI
- `lib/widgets/fullscreen_focus_view.dart` — fullscreen focus mode
- `lib/widgets/settings_panel.dart` — settings UI
- `lib/services/settings_service.dart` — settings persistence
- `lib/models/app_settings.dart` — settings model
- `lib/core/pref_keys.dart` — preference keys
- `assets/audio/` — bundled local audio files

## Getting started

### Prerequisites

- Flutter stable with Dart `3.11.3` or newer (see `environment.sdk` in `pubspec.yaml`).
- Android Studio / Android SDK for Android builds.
- Xcode on macOS for iOS builds.

### Linux build prerequisites

Flutter's Linux desktop target needs GTK 3 development files. The Linux audio plugin also needs GStreamer development libraries when building and its base/good/ALSA plugins at runtime; install those with the compiler/build tools.

**Arch Linux**
```bash
sudo pacman -S --needed base-devel clang cmake flutter git \
  gstreamer gst-plugins-base-libs gst-plugins-good gtk3 libepoxy \
  ninja pkgconf alsa-lib
```

**Debian / Ubuntu**
```bash
sudo apt update
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good gstreamer1.0-alsa libasound2
```

**Fedora**
```bash
sudo dnf install clang cmake ninja-build pkgconf-pkg-config gtk3-devel \
  xz-devel gstreamer1-devel gstreamer1-plugins-base-devel \
  gstreamer1-plugins-base gstreamer1-plugins-good alsa-lib
```

Install Flutter from your distribution or from the [official Flutter Linux installation guide](https://docs.flutter.dev/get-started/install/linux/desktop). Confirm that `flutter doctor -v` reports Linux desktop support and GTK development dependencies before building. The distro package names above cover the native dependencies; Flutter itself may need to be installed separately on Debian, Ubuntu, and Fedora.

### Resolve dependencies and run from source
```bash
flutter pub get
flutter run -d linux
```

### Build and install the Linux release bundle
```bash
flutter build linux --release
./build/linux/x64/release/bundle/install-linux.sh
```

The installer copies the relocatable bundle to `~/.local/opt/solasflow` and adds a desktop launcher under `~/.local/share/applications`. Launch `Solas Flow` from the desktop menu or run:
```bash
~/.local/opt/solasflow/solasflow
```

Keep the entire generated `build/linux/x64/release/bundle` directory together when distributing the application; the executable needs its adjacent `data/` and `lib/` directories. GTK 3 and GStreamer runtime packages must be present on the target distro.

### Linux speech models

Linux bundles offline Sherpa-ONNX, Piper voices for English and Malayalam, and eSpeak-NG language data. On first Linux launch, a consent dialog offers **Accept and download** for the optional 140 MiB INT8 Kokoro v1.1 English model, or **Keep Piper**. No Kokoro bytes are fetched before acceptance. If declined, the download can be started later from **Settings → Kokoro English voice → Download**. The Settings card shows live transfer percentage and byte counts, then SHA-256 verification and installation status; cancel is available during transfer, and failed or cancelled downloads can be retried. English speech continues with bundled Piper until Kokoro is installed, or if the download fails. The verified model is cached under `~/.local/share/solasflow_runtime/assets/tts/models/en/kokoro`. Linux-generated WAV audio plays through the app's GStreamer-backed audio player, rather than relying on `paplay` or `aplay`.

The four bundled Malayalam studio voices (Aoede, Kore, Puck, Charon) play offline on Android and Linux for clock, timer, and quote announcements. Linux retains Piper Malayalam as a fallback for text without a matching recording; Kokoro v1.1 does not speak Malayalam. Use **Settings → Test voice** to check the selected voice and audio output. See `assets/tts/models_manifest.json` for runtime model selection.

Kokoro installation keeps its matching eSpeak language data with the model. Older caches containing only the weights are treated as incomplete; choose **Download** once to refresh them. Bundled Piper remains available until the refreshed model is ready.

Linux x64 keeps the Sherpa v1.12.34 C API in a reusable worker isolate: selected models are warmed once and reused across phrases. Inference stays off the UI isolate; cancelling speech interrupts synthesis and playback. Completed phrases play as WAV audio, not streaming PCM. Startup/model-load latency and audible gaps depend on the model, CPU, and audio device; no fixed latency or gapless guarantee is made. Ambient audio ducks to 25% of its configured level during speech, with a 350 ms fade, then restores that level.

#### Import a local Hugging Face / Sherpa model

Download a **trusted, Sherpa-converted** Piper/VITS voice or English Kokoro model folder, then choose **Settings → Local offline model → Model language → Import folder**. HF source weights and arbitrary ONNX exports cannot be loaded directly. The folder needs exactly one self-contained `.onnx` file with Sherpa metadata and `tokens.txt`; Kokoro additionally needs matching `voices.bin` and an English `lexicon-us-en.txt` or `lexicon.txt`. Compatible bundled eSpeak data is reused unless the folder supplies its own regular `espeak-ng-data` files. External ONNX tensors, symlinks, unsupported formats, and mismatched languages are rejected before installation.

**Model language** also selects and saves the app's speech language. It stays synchronized with **Language list**, so an explicit Malayalam choice survives leaving Settings and restarting the app instead of resetting to English.

Import copies model data into app-owned storage and persists separate English/Malayalam selections; it does not execute downloaded scripts. **Use built-in voice** clears the selected import. A native model is still trusted input, not a sandbox for malicious model files. Model redistribution must respect each model's license. Runtime attribution and corresponding-source links are in `assets/tts/Sherpa-runtime-NOTICE.txt` and `assets/tts/espeak-ng-LICENSE.txt`; distributors of the GPLv3 eSpeak runtime/data must also satisfy its corresponding-source obligations.

### App appearance

**Settings → Dark theme** switches the whole app between the fixed light and dark palettes immediately and saves the choice across launches. Settings, clock, timer, stopwatch, dialogs, and navigation follow the selected theme. **Dark fullscreen** remains a separate fullscreen-focus preference; Drive Mode is always dark. No wallpaper-derived or Material You dynamic colors are used.

The normal **Timer finished** dialog fills the app window. Presets use uniform buttons; **Close timer** and **Start custom** share an equal-width footer row with compact 48 px height. The fullscreen-focus completion view also uses a 48 px-high Close timer button. Close timer stops the timer alert and dismisses the timer without quitting the app.

### Linux window and background operation

- Starts at approximately **400×860**, centered and clamped to the monitor work area; remains resizable for landscape use.
- **Desktop controls (⋮) → Keep running when closed** persists independently of audio settings. Closing then hides the window while timers and speech keep running. Relaunching presents the same process/window; X11 also offers a legacy tray **Open/Quit** menu when the desktop supports it.
- **Hide window** enables background mode before hiding. Hidden speech and timer completion send desktop notifications with an **Open** action. Notification visibility depends on the desktop notification service.
- **Always on top** is a window-manager hint. Wayland compositors may ignore it; use compositor window rules when necessary. Wayland does not use the legacy X11 tray.
- **Drive Mode** provides compact or fullscreen dark controls for clock, timer, and stopwatch, large pause/resume and speak-now buttons, audio toggle, and explicit 15/25/45-minute presets. Closing Drive Mode returns to the normal interface and exits fullscreen.
- **Exit / Quit** stops audio and timers, releases native speech engines, flushes settings, and terminates the app. Background mode does not survive process termination or make timers run while the machine is suspended. Configure Drive Mode before driving; do not interact with the screen while driving.

**Settings → Start with desktop** manages a per-user `systemd --user` unit that launches Solas Flow with your graphical desktop session. Enable, remove, and refresh its installed/enabled/running status in the app. It starts after you log in, not at the login screen; it writes only under `~/.config/systemd/user` and does not need Polkit or administrator access. Removing the unit disables future autostart but does not quit the currently open app.


### Arch Linux package
```bash
cd packaging/arch
makepkg -si
```

The `solasflow-git` package builds the Linux release from the current `master` branch and declares its GTK/GStreamer runtime dependencies. `makepkg` installs the package with pacman when `-i` is supplied.

To build and install the current working source with the existing `$HOME/flutter` SDK:

```bash
./packaging/arch/install-fresh.sh
```

Run this in a terminal. It builds an isolated source snapshot without `pub get` or tests, packages it using the existing installation layout, and prompts for `sudo pacman -U`. It does not install toolchains or missing dependencies. Exit any running Solas Flow app when prompted before replacing its installation. After successful installation, it removes the obsolete per-user bundle, launcher, and icons so the application menu uses `/opt/solasflow/solasflow`, then refreshes the desktop caches and requests launch. Settings and downloaded voice models are retained. The package and logs remain under `build/arch/install.*`.

For a Polkit-based install, run:

```bash
./packaging/arch/install-fresh.sh --polkit
```

This uses the desktop Polkit authentication agent and noninteractive pacman confirmation. Close any running app when prompted before package replacement.

For a complete application removal followed by reinstallation, use:

```bash
./packaging/arch/install-fresh.sh --clean-reinstall
```

This builds the replacement package first, then removes the existing `solasflow-git` package and remaining `/opt/solasflow` installation files before installing the new package. Confirm the removal and installation prompts in the terminal; dependencies and user data are not removed.

### Debian, Ubuntu, Fedora, and other distributions

Install the Linux build prerequisites above, then build and install with the bundle commands. For a prebuilt release bundle, extract it without changing its directory structure, install the target distro's GTK 3 and GStreamer runtime packages, and run `./install-linux.sh` from inside the extracted bundle. The installer creates a per-user launcher and does not register distro package dependencies. Do not copy only the `solasflow` executable.

### Other platforms
```bash
flutter pub get
flutter run
```

Build Android or iOS from the corresponding Flutter target. Desktop Kokoro bootstrap is Linux-only; existing platform speech engines remain in use elsewhere.

### Test
```bash
flutter test
```
## Notes

- App display name is `Solas Flow`.
- Android package namespace and notification metadata still use `com.example.speakertimer` in platform config for compatibility.
- Audio assets are local (`assets/audio/`) to support offline/background behavior.

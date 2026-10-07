import 'dart:io';

class DesktopAutostartStatus {
  const DesktopAutostartStatus({
    required this.installed,
    required this.enabled,
    required this.serviceState,
  });

  final bool installed;
  final bool enabled;
  final String serviceState;

  bool get active => serviceState == 'active';

  String get summary {
    if (!installed) return 'Not configured';
    if (!enabled) return 'Installed, disabled';
    if (serviceState == 'failed') return 'Enabled, service failed';
    return active ? 'Enabled and running' : 'Enabled for next login';
  }
}

/// Manages the current user's graphical-session systemd autostart unit.
class DesktopAutostartService {
  static const String _unitName = 'com.atherpulse.solasflow.service';

  String get _unitPath {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('HOME is not set; cannot configure user autostart.');
    }
    return '$home/.config/systemd/user/$_unitName';
  }

  Future<DesktopAutostartStatus> status() async {
    await _systemctl(['show-environment']);
    final unitExists = await File(_unitPath).exists();
    final enabledResult = await Process.run('systemctl', [
      '--user',
      'is-enabled',
      _unitName,
    ]);
    final activeResult = await Process.run('systemctl', [
      '--user',
      'is-active',
      _unitName,
    ]);
    return DesktopAutostartStatus(
      installed: unitExists,
      enabled: enabledResult.exitCode == 0 &&
          (enabledResult.stdout as String).trim() == 'enabled',
      serviceState: (activeResult.stdout as String).trim(),
    );
  }

  Future<void> enable() async {
    final executable = _escapeExecArgument(Platform.resolvedExecutable);
    final unit = '''[Unit]
Description=Solas Flow desktop app
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart="$executable"

[Install]
WantedBy=graphical-session.target
''';
    final file = File(_unitPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(unit, flush: true);
    await _systemctl(['daemon-reload']);
    await _systemctl(['enable', _unitName]);
  }

  Future<void> disable() async {
    await _systemctl(['disable', _unitName]);
    final file = File(_unitPath);
    if (await file.exists()) await file.delete();
    await _systemctl(['daemon-reload']);
  }

  Future<void> _systemctl(List<String> arguments) async {
    final result = await Process.run('systemctl', ['--user', ...arguments]);
    if (result.exitCode != 0) {
      final detail = (result.stderr as String).trim();
      throw StateError(
        detail.isEmpty
            ? 'systemctl ${arguments.join(' ')} failed (${result.exitCode}).'
            : detail,
      );
    }
  }

  static String _escapeExecArgument(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('%', '%%');
}

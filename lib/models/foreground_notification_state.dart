import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../l10n/app_localizations.dart';

/// Semantic foreground notification state.
class ForegroundNotificationState {
  final bool isTimerRunning;
  final bool isStopwatchRunning;
  final bool isClockRunning;
  final String timerValue;
  final String stopwatchValue;
  final String currentTimeDisplay;
  final bool speechMasterOn;
  final bool isTimerFinished;

  const ForegroundNotificationState({
    required this.isTimerRunning,
    required this.isStopwatchRunning,
    required this.isClockRunning,
    required this.timerValue,
    required this.stopwatchValue,
    required this.currentTimeDisplay,
    required this.speechMasterOn,
    this.isTimerFinished = false,
  });
}

class ForegroundNotificationPresentation {
  final String title;
  final String text;
  final List<NotificationButton> buttons;

  const ForegroundNotificationPresentation({
    required this.title,
    required this.text,
    required this.buttons,
  });

  factory ForegroundNotificationPresentation.fromState(
    ForegroundNotificationState state,
    AppLocalizations l10n,
  ) {
    final title = state.isTimerFinished
        ? '${l10n.appTitle} - ${l10n.timerFinishedNotificationTitle}'
        : state.isTimerRunning
        ? '${l10n.appTitle} - ${l10n.timerNotificationTitle}'
        : state.isStopwatchRunning
        ? '${l10n.appTitle} - ${l10n.stopwatchNotificationTitle}'
        : state.isClockRunning
        ? '${l10n.appTitle} - ${l10n.clockNotificationTitle}'
        : l10n.appTitle;
    final audioLabel = state.speechMasterOn
        ? l10n.audioOnLabel
        : l10n.audioOffLabel;
    final message = state.isTimerFinished
        ? l10n.timerFinishedNotificationText
        : state.isTimerRunning
        ? l10n.notificationTimeRemaining(state.timerValue)
        : state.isStopwatchRunning
        ? l10n.notificationElapsed(state.stopwatchValue)
        : state.currentTimeDisplay;
    final text = message.isEmpty ? audioLabel : '$audioLabel  |  $message';
    final audioButton = NotificationButton(
      id: state.speechMasterOn ? 'audio:set:off' : 'audio:set:on',
      text: audioLabel,
    );
    final buttons = state.isTimerFinished
        ? <NotificationButton>[
            NotificationButton(
              id: 'btn_timer_repeat',
              text: l10n.repeatButton,
            ),
            NotificationButton(
              id: 'btn_timer_dismiss',
              text: l10n.dismissButton,
            ),
            NotificationButton(id: 'open_app', text: l10n.openButton),
          ]
        : <NotificationButton>[
            audioButton,
            NotificationButton(id: 'open_app', text: l10n.openButton),
            NotificationButton(id: 'btn_exit', text: l10n.exitButton),
          ];
    return ForegroundNotificationPresentation(
      title: title,
      text: text,
      buttons: buttons,
    );
  }
}

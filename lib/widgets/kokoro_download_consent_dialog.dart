import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class KokoroDownloadConsentDialog extends StatelessWidget {
  const KokoroDownloadConsentDialog({
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.kokoroDownloadTitle),
      content: Text(AppLocalizations.of(context)!.kokoroDownloadDescription),
      actions: [
        TextButton(
          onPressed: onDecline,
          child: Text(AppLocalizations.of(context)!.kokoroKeepPiper),
        ),
        FilledButton.icon(
          onPressed: onAccept,
          icon: const Icon(Icons.download_rounded),
          label: Text(AppLocalizations.of(context)!.kokoroAcceptAndDownload),
        ),
      ],
    );
  }
}

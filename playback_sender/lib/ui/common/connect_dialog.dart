import 'package:chrome_tube/ui/common/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cast_button/flutter_cast_button.dart';

class ConnectChromeCastDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConnectChromeCastDialogState();
}

class _ConnectChromeCastDialogState
    extends CachingState<ConnectChromeCastDialog> {
  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text(locale.translate('diag_co_cast_title')),
      content: Text(locale.translate('diag_co_cast_text')),
      actions: [
        MaterialButton(
          onPressed: () {
            FlutterCastButton.showCastDialog();
            Navigator.of(context).pop();
          },
          color: theme.primaryColor,
          child: Text(locale.translate('ok')),
        ),
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(locale.translate('cancel')),
        ),
      ],
    );
  }
}

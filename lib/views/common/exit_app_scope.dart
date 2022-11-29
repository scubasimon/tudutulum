import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tudu/generated/l10n.dart';

class ExitAppScope extends StatelessWidget {

  final Widget child;

  const ExitAppScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async => (await showDialog<bool>(
        context: context,
        builder: (c) => _alert(c),
      )) ?? false,
      child: child,
    );
  }

  Widget _alert(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.warning),
      content: Text(S.current.exit_app_message),
      actions: [
        TextButton(
          onPressed: () => SystemNavigator.pop(animated: true),
          child: Text(S.current.yes),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(S.current.no),
        )
      ],
    );
  }

}
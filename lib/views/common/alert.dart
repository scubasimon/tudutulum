import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudu/generated/l10n.dart';

import 'package:tudu/consts/urls/URLConst.dart';

class ErrorAlert {
  static Widget alert(BuildContext context, String message) {
    if (Platform.isAndroid) {
      var okAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.current.ok),
      );
      return AlertDialog(
        title: Text(S.current.error),
        content: Text(message),
        actions: [
          okAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.error),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }
  }

  static Widget alertLogin(BuildContext context) {
    if (Platform.isAndroid) {
      var okAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(URLConsts.login);
        },
        child: Text(S.current.ok),
      );
      return AlertDialog(
        title: Text(S.current.error),
        content: Text(S.current.login_message),
        actions: [
          okAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.error),
        content: Text(S.current.login_message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.ok),
            onPressed: () {
              Navigator.of(context).popUntil((route) {
                return (route.isFirst);
              });
              Navigator.of(context).pushNamedAndRemoveUntil(URLConsts.login, (Route<dynamic> route) => false);
            },
          )
        ],
      );
    }
  }
}

class NotificationAlert {
  static Widget alert(BuildContext context, String message) {
    if (Platform.isAndroid) {
      var okAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.current.ok),
      );
      return AlertDialog(
        title: Text(S.current.notification),
        content: Text(message),
        actions: [
          okAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.notification),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }
  }
}
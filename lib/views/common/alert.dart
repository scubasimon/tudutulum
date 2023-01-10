import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'package:tudu/consts/urls/URLConst.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text(S.current.login_title),
        content: Text(S.current.login_message),
        actions: [
          okAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.login_title),
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

  static Widget alertPermission(BuildContext context, String message) {
    if (Platform.isAndroid) {
      var cancelAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.current.cancel),
      );

      var openSetting = TextButton(
        onPressed: () {
          openAppSettings();
        },
        child: Text(S.current.open_setting),
      );

      return AlertDialog(
        title: Text(S.current.error),
        content: Text(message),
        actions: [
          cancelAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.error),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(S.current.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.open_setting),
            onPressed: () {
              openAppSettings();
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

class TwoButtonAlert {
  static Widget reportAlert(BuildContext context, String whatsapp, String email) {
    if (Platform.isAndroid) {
      var firstButtonAction = TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          final url = Uri.parse("whatsapp://send?phone=$whatsapp");
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            showDialog(
              context: context,
              builder: (context) =>
              ErrorAlert.alert(context, S.current.app_not_installed("Whatsapp")));
          }
        },
        child: Text(S.current.report_via("Whatsapp")),
      );
      var secondButtonAction = TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          final url = Uri.parse("mailto:$email");
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorAlert.alert(context, S.current.app_not_installed("Mail")));
          }
        },
        child: Text(S.current.report_via("Email")),
      );
      return AlertDialog(
        title: Text(S.current.report),
        content: Text(S.current.report_description),
        actions: [
          firstButtonAction,
          secondButtonAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.report),
        content: Text(S.current.report_description),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.report_via("Whatsapp")),
            onPressed: () async {
              Navigator.of(context).pop();
              final url = Uri.parse("whatsapp://send?phone=$whatsapp");
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                showDialog(
                    context: context,
                    builder: (context) =>
                        ErrorAlert.alert(context, S.current.app_not_installed("Whatsapp")));
              }
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.report_via("Email")),
            onPressed: () async {
              Navigator.of(context).pop();
              final url = Uri.parse("mailto:$email");
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                showDialog(
                    context: context,
                    builder: (context) =>
                        ErrorAlert.alert(context, S.current.app_not_installed("Mail")));
              }
            },
          )
        ],
      );
    }
  }
}

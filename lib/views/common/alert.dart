import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class TwoButtonAlert {
  static Widget reportAlert(BuildContext context, String whatsapp, String email) {
    if (Platform.isAndroid) {
      var firstButtonAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          print(whatsapp);
          UrlLauncher.launch("https://wa.me/${whatsapp}?text=Tudu Information Update");
        },
        child: Text("Report via Whatsapp"),
      );
      var secondButtonAction = TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          Uri params = Uri(
            scheme: 'mailto',
            path: email,
            query: 'subject=Tudu Information Update', //add subject and body here
          );

          var url = params.toString();
          if (await canLaunch(url)) {
            await launch(url);
          }
        },
        child: Text("Report via Email"),
      );
      return AlertDialog(
        title: Text("Report"),
        content: Text("Please send us an Email or a message via Whatsapp"),
        actions: [
          firstButtonAction,
          secondButtonAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text("Report"),
        content: Text("Please send us an Email or a message via Whatsapp"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Report via Whatsapp"),
            onPressed: () async {
              Navigator.of(context).pop();
              print(whatsapp);
              // UrlLauncher.launch("https://wa.me/${whatsapp}?text=Tudu Information Update");

              var iosUrl = "https://wa.me/$whatsapp?text=${Uri.parse('Hi, I need some help')}";

              try{
                await launchUrl(Uri.parse(iosUrl));
              } on Exception{
                print('WhatsApp is not installed.');
              }
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Report via Email"),
            onPressed: () async {
              Navigator.of(context).pop();
              Uri params = Uri(
                scheme: 'mailto',
                path: email,
                query: 'subject=Tudu Information Update', //add subject and body here
              );

              var url = params.toString();

              try{
                await launchUrl(Uri.parse(url));
              } on Exception{
                print('Email is not installed.');
              }
            },
          )
        ],
      );
    }
  }
}

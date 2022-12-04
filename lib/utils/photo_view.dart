import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:notification_center/notification_center.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/views/what_tudu/what_tudu_screen.dart';
import 'package:tudu/views/events/events_view.dart';
import 'package:tudu/views/deals/deals_view.dart';
import 'package:tudu/views/bookmarks/bookmarks_view.dart';
import 'package:tudu/views/profile/profile_view.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';


class PhotoViewUtil extends StatefulWidget {
  final String banner;
  const PhotoViewUtil({
    Key? key,
    required this.banner,
  }) : super(key: key);

  @override
  State<PhotoViewUtil> createState() => _PhotoViewUtil();
}

class _PhotoViewUtil extends State<PhotoViewUtil> with WidgetsBindingObserver {

  @override
  void initState() {
    //set orientation is portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Action after build()
    });

  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: PhotoView(
                imageProvider: NetworkImage(
                    widget.banner
                )
            )
        )
    );
  }
}

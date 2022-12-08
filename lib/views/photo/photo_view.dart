import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:tudu/views/what_tudu/what_tudu_view.dart';
import 'package:tudu/views/events/events_view.dart';
import 'package:tudu/views/deals/deals_view.dart';
import 'package:tudu/views/bookmarks/bookmarks_view.dart';
import 'package:tudu/views/profile/profile_view.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';

class PhotoViewUtil extends StatefulWidget {
  final List<String> banner;
  const PhotoViewUtil({
    Key? key,
    required this.banner,
  }) : super(key: key);

  @override
  State<PhotoViewUtil> createState() => _PhotoViewUtil();
}

class _PhotoViewUtil extends State<PhotoViewUtil> with WidgetsBindingObserver {
  final PageController controller = PageController();
  int currentItem = 0;

  @override
  void initState() {
    //set orientation is portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    controller.addListener(() {
      if (controller.page != null) currentItem = controller.page!.round();
      setState(() {});
    });

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Action after build()
    });
  }

  @override
  dispose() {
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
        body: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller,
              children: widget.banner
                  .map((item) => PhotoView(
                imageProvider: CachedNetworkImageProvider(
                    item,
                ),
                loadingBuilder: (context, event) => Center(
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    child: const CupertinoActivityIndicator(
                      radius: 20,
                      color: ColorStyle.primary,
                    ),
                  ),
                ),
              )).toList(),
            ),
            Positioned(
              left: 40,
              bottom: 30 + MediaQuery.of(context).padding.bottom,
              child: InkWell(
                  onTap: () {
                    if (controller.page != null) {
                      controller.animateToPage(
                          controller.page!.toInt() - 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn
                      );
                    }
                  },
                  child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: Image.asset(ImagePath.leftArrowIcon, fit: BoxFit.contain, height: 20.0)
                  )
              ),
            ),
            Positioned(
              right: 40,
              bottom: 30 + MediaQuery.of(context).padding.bottom,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(180 / 360),
                child: InkWell(
                    onTap: () {
                      if (controller.page != null) {
                        controller.animateToPage(
                            controller.page!.toInt() + 1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn
                        );
                      }
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: Image.asset(ImagePath.leftArrowIcon, fit: BoxFit.contain, height: 20.0)
                    )
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 30 + MediaQuery.of(context).padding.bottom,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                child: Text(
                  "${currentItem+1}/${widget.banner.length}",
                  style: const TextStyle(
                    fontFamily: FontStyles.raleway,
                    fontSize: FontSizeConst.font18,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.lightLabel,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 30 + MediaQuery.of(context).padding.top,
              child: InkWell(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(ImagePath.leftArrowIcon, fit: BoxFit.contain, height: 20.0),
                    Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: Text(
                          S.current.back,
                          style: const TextStyle(
                            color: ColorStyle.primary,
                            fontWeight: FontWeight.w400,
                            fontSize: FontSizeConst.font16,
                            fontFamily: FontStyles.mouser,
                          ),
                        ))
                  ],
                ),
                onTap: () { Navigator.pop(context); },
              ),
            )
          ],
        ));
  }
}

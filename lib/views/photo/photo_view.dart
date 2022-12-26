import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
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
    return ExitAppScope(
      child: Container(
        color: ColorStyle.getSystemBackground(),
        child: Scaffold(
            body: Stack(
              children: [
                WillPopScope(
                  onWillPop: () async {
                    return true;
                  },
                  child: PageView.builder(
                    pageSnapping: false,
                    physics: const PageOverscrollPhysics(velocityPerOverscroll: 1000),
                    controller: controller,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: PhotoView(
                          imageProvider: CachedNetworkImageProvider(
                            cacheManager: CacheManager(
                              Config(
                                "cachedImg", //featureStoreKey
                                stalePeriod: const Duration(seconds: 15),
                                maxNrOfCacheObjects: 1,
                                repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                                fileService: HttpFileService(),
                              ),
                            ),
                            widget.banner[i % widget.banner.length],
                          ),
                          loadingBuilder: (context, event) => const Center(
                            child: SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CupertinoActivityIndicator(
                                radius: 20,
                                color: ColorStyle.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
            )),
      ),
    );
  }
}

class PageOverscrollPhysics extends ScrollPhysics {
  final double velocityPerOverscroll;

  const PageOverscrollPhysics({
    ScrollPhysics? parent,
    this.velocityPerOverscroll = 1000,
  }) : super(parent: parent);

  @override
  PageOverscrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PageOverscrollPhysics(
      parent: buildParent(ancestor)!,
    );
  }

  double _getTargetPixels(ScrollMetrics position, double velocity) {
    double page = position.pixels / position.viewportDimension;
    page += velocity / velocityPerOverscroll;
    double pixels = page.roundToDouble() * position.viewportDimension;
    return pixels;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final double target = _getTargetPixels(position, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

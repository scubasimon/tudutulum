import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/viewmodels/deal_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/photo/photo_view.dart';
import 'package:tudu/views/what_tudu/what_tudu_site_content_detail_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DealDetailView extends StatefulWidget {

  final Deal deal;
  final bool preview;

  const DealDetailView({super.key, required this.deal, this.preview = false});

  @override
  State<StatefulWidget> createState() {
    return _DealDetailView();
  }
}

class _DealDetailView extends State<DealDetailView> {

  final _dealViewModel = DealViewModel();
  final _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    _dealViewModel.deal.add(widget.deal);
    _dealViewModel.error.listen((event) {
      showDialog(context: context, builder: (context){
        return ErrorAlert.alert(context, event.message ?? S.current.failed);
      });
    });
    _dealViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        _refreshController.refreshCompleted();
        Navigator.of(context).pop();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            color: ColorStyle.navigation,
            child: Container(
                height: 36.0,
                alignment: Alignment.centerLeft,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            ImagePath.leftArrowIcon,
                            fit: BoxFit.contain,
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              S.current.back,
                              style: const TextStyle(
                                color: ColorStyle.primary,
                                fontSize: FontSizeConst.font16,
                                fontWeight: FontWeight.w400,
                                fontFamily: FontStyles.mouser,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    StreamBuilder(
                      stream: _dealViewModel.deal,
                      builder: (context, snapshot) {
                        if (snapshot.data != null && snapshot.data!.titleShort.isNotEmpty) {
                          return Center(
                            child: Text(
                              snapshot.data!.titleShort,
                              style: TextStyle(
                                fontFamily: FontStyles.sfProText,
                                fontSize: FontSizeConst.font17,
                                fontWeight: FontWeight.w700,
                                color: ColorStyle.getDarkLabel(),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
            ),
          ),
        ),
        backgroundColor: ColorStyle.getSystemBackground(),
        body: StreamBuilder(
          stream: _dealViewModel.deal,
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.data!.titleShort.isEmpty) {
              return Container(
                color: ColorStyle.getSystemBackground(),
              );
            } else {
              final deal = snapshot.data!;
              return Container(
                color: ColorStyle.getSystemBackground(),
                child: SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  header: const WaterDropHeader(),
                  onRefresh: _refresh,
                  child: ListView(
                    children: _dealDetail(deal),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _dealDetail(Deal deal) {
    var darkMode = PrefUtil.getValue(StrConst.isDarkMode, false) as bool;
    List<Widget> items = [
      InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PhotoViewUtil(banner: deal.images))
          );
        },
        child: Container(
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
            cacheManager: CacheManager(
              Config(
                "cachedImg", //featureStoreKey
                stalePeriod: const Duration(seconds: 15),
                maxNrOfCacheObjects: 1,
                repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                fileService: HttpFileService(),
              ),
            ),
            imageUrl: deal.images.first,
            width: MediaQuery.of(context).size.width,
            height: 300,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => const CupertinoActivityIndicator(
              radius: 20,
              color: ColorStyle.primary,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
        child: Row(
          children: [
            Text(
              deal.title,
              style: TextStyle(
                color: ColorStyle.getDarkLabel(),
                fontFamily: FontStyles.raleway,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () { _openNavigationApp(deal); },
              child: Image.asset(
                ImagePath.mapIcon,
                width: 28,
                height: 28,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
        child: Text(
          deal.description ?? "",
          maxLines: widget.preview ? 3 : null,
          style: TextStyle(
            color: ColorStyle.getDarkLabel(),
            fontWeight: FontWeight.normal,
            fontSize: FontSizeConst.font12,
            fontFamily: FontStyles.raleway,
          ),
        ),
      ),
    ];
    if (widget.preview) {
      items.addAll(
        [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
            child: Text(
              S.current.preview_deal_message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontStyles.mouser,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorStyle.getDarkLabel(),
              ),
            ),
          )
        ]
      );
    } else {
      items.addAll([
        Padding(
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Text(
            S.current.term_and_conditions,
            style: TextStyle(
              fontFamily: FontStyles.mouser,
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: ColorStyle.getDarkLabel(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child:  Text(
            deal.terms ?? "",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              fontFamily: FontStyles.raleway,
              color: ColorStyle.getDarkLabel(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Divider(
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        InkWell(
          onTap: () {
            WhatTuduSiteContentDetailViewModel().setSiteContentDetailCover(deal.site);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WhatTuduSiteContentDetailView(),
                settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene))
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      S.current.deal_available,
                      style: TextStyle(
                        color: ColorStyle.getDarkLabel(),
                        fontFamily: FontStyles.raleway,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
                    child: Text(
                      deal.site.title.toString(),
                      style: TextStyle(
                        color: ColorStyle.getDarkLabel(),
                        fontFamily: FontStyles.mouser,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                alignment: Alignment.centerRight,
                height: 50,
                padding: const EdgeInsets.only(right: 16),
                constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 48.0) * 0.3),
                child: CachedNetworkImage(
                  cacheManager: CacheManager(
                    Config(
                      "cachedImg", //featureStoreKey
                      stalePeriod: const Duration(seconds: 15),
                      maxNrOfCacheObjects: 1,
                      repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                      fileService: HttpFileService(),
                    ),
                  ),
                  imageUrl: deal.logo,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Divider(
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, bottom: 16, right: 16),
          child: InkWell(
            onTap: _showReport,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: ColorStyle.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  S.current.redeem_here,
                  style: TextStyle(
                    color: ColorStyle.getLightLabel(),
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    fontFamily: FontStyles.sfProText,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16,),
      ]);
    }
    return items;
  }

  void _showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Container(
              decoration: const BoxDecoration(),
              child: const Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                  color: ColorStyle.primary,
                ),
              )
          );
        }
    );
  }

  void _refresh() {
    _dealViewModel.refresh().then((value) => _refreshController.loadComplete());
  }

  void _showReport() {
    showDialog(context: context, builder: (context) => _alertReport());
  }

  Widget _alertReport() {
    if (Platform.isAndroid) {
      var cancelAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.current.cancel),
      );

      var successful = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _dealViewModel.redeem();
        },
        child: Text(S.current.successful),
      );

      var issue = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          showDialog(context: context, builder: (context) => _sheetContact());
        },
        child: Text(S.current.issue),
      );

      return AlertDialog(
        title: Text(S.current.redeem_report_title),
        content: Text(S.current.redeem_report_message),
        actions: [
          successful,
          issue,
          cancelAction,
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(S.current.redeem_report_title),
        content: Text(S.current.redeem_report_message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.successful),
            onPressed: () {
              Navigator.of(context).pop();
              _dealViewModel.redeem();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.issue),
            onPressed: () {
              Navigator.of(context).pop();
              showCupertinoModalPopup(context: context, builder: (context) => _sheetContact());
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(S.current.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }

  Widget _sheetContact() {
    if (Platform.isAndroid) {
      var cancelAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.current.redeem_later),
      );

      var email = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _openMail("info@thetudu.app");
        },
        child: Text("Via ${S.current.email}"),
      );

      var whatsapp = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _openWhatsapp("+529842105598");
        },
        child: const Text("Via Whatsapp"),
      );

      return AlertDialog(
        content: Text(S.current.select_contact_message),
        actions: [
          whatsapp,
          email,
          cancelAction,
        ],
      );
    } else {
      return CupertinoActionSheet(
        message: Text(S.current.select_contact_message),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _openWhatsapp("+529842105598");
            },
            child: const Text("Via Whatsapp"),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _openMail("info@thetudu.app");
            },
            child: Text("Via ${S.current.email}"),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.current.redeem_later),
          )
        ],
      );
    }
  }

  void _openNavigationApp(Deal deal) async {
    var map = PrefUtil.getValue(StrConst.selectMap, "") as String;
    if (map.isNotEmpty) {
      try {
        final availableMaps = await MapLauncher.installedMaps;
        await availableMaps.firstWhere((element){
          return element.mapName == map;
        }).showDirections(destination: Coords(deal.site.locationLat!, deal.site.locationLon!));
        return;
      } catch (e) {
        print(e);
      }
    }
    if (Platform.isAndroid) {
      _openMap("Google Maps", deal);
    } else {
      showCupertinoModalPopup(context: context, builder: (context) => _sheetNavigation(deal));
    }
  }

  Widget _sheetNavigation(Deal deal) {
    return CupertinoActionSheet(
      message: Text(S.current.select_navigation_app),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () async {
            Navigator.of(context).pop();
            _openMap("Apple Maps", deal);
          },
          child: const Text("Apple Maps"),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () async {
            Navigator.of(context).pop();
            _openMap("Google Maps", deal);
          },
          child: const Text("Google Maps"),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        )
      ],
    );
  }

  void _openMap(String name, Deal deal) async {
    try {
      PrefUtil.setValue(StrConst.selectMap, name);
      final availableMaps = await MapLauncher.installedMaps;
      await availableMaps.firstWhere((element){
        return element.mapName == name;
      }).showDirections(destination: Coords(deal.site.locationLat!, deal.site.locationLon!));
    } catch (e) {
      print(e);
      showDialog(context: context, builder: (context) => ErrorAlert.alert(context, S.current.app_not_installed(name)));
    }
  }

  void _openMail(String mail) async {
    final url = Uri.parse("mailto:$mail");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showDialog(context: context, builder: (context) => ErrorAlert.alert(context, S.current.app_not_installed("Mail")));
    }
  }

  void _openWhatsapp(String phone) async {
    final url = Uri.parse("whatsapp://send?phone=$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showDialog(context: context, builder: (context) => ErrorAlert.alert(context, S.current.app_not_installed("Whatsapp")));
    }
  }
}
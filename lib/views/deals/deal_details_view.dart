import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/viewmodels/deal_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/views/common/alert.dart';
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
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Image.asset(
                            ImagePath.chevronLeftIcon,
                            width: 32,
                            height: 32,
                          ),
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        Text(
                          S.current.back,
                          style: const TextStyle(
                            color: ColorStyle.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: FontStyles.mouser,
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder(
                      stream: _dealViewModel.deal,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Center(
                            child: Text(
                              snapshot.data!.titleShort,
                              style: const TextStyle(
                                fontFamily: FontStyles.sfProText,
                                fontSize: FontSizeConst.font17,
                                fontWeight: FontWeight.w700,
                                color: ColorStyle.darkLabel,
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
        body: StreamBuilder(
          stream: _dealViewModel.deal,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              final deal = snapshot.data!;
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: false,
                header: const WaterDropHeader(),
                onRefresh: _refresh,
                child: ListView(
                  children: _dealDetail(deal),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _dealDetail(Deal deal) {
    List<Widget> items = [
      InkWell(
        onTap: () {},
        child: Container(
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
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
              style: const TextStyle(
                color: ColorStyle.darkLabel,
                fontFamily: FontStyles.raleway,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                final availableMaps = await MapLauncher.installedMaps;
                print(availableMaps);
                await availableMaps.firstWhere((element){
                  return element.mapName == "Google Maps";
                }).showDirections(destination: Coords(deal.site.locationLat!, deal.site.locationLon!));
              },
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
          style: const TextStyle(
            color: ColorStyle.darkLabel,
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
              style: const TextStyle(
                fontFamily: FontStyles.mouser,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorStyle.darkLabel,
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
            style: const TextStyle(
              fontFamily: FontStyles.mouser,
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: ColorStyle.darkLabel,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child:  Text(
            deal.terms ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              fontFamily: FontStyles.raleway,
              color: ColorStyle.darkLabel,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Divider(color: Colors.black,),
        ),
        Row(
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
                    style: const TextStyle(
                      color: ColorStyle.darkLabel,
                      fontFamily: FontStyles.raleway,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
                  child: Text(
                    deal.site.title,
                    style: const TextStyle(
                      color: ColorStyle.darkLabel,
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
                imageUrl: deal.logo,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Divider(color: Colors.black,),
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
                  style: const TextStyle(
                    color: ColorStyle.lightLabel,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    fontFamily: FontStyles.sfProText,
                  ),
                ),
              ),
            ),
          ),
        ),
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
    showDialog(context: context, builder: (context) => _alert());
  }

  Widget _alert() {
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
        },
        child: Text(S.current.successful),
      );

      var issue = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          showDialog(context: context, builder: (context) => _sheet());
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
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(S.current.issue),
            onPressed: () {
              Navigator.of(context).pop();
              showCupertinoModalPopup(context: context, builder: (context) => _sheet());
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

  Widget _sheet() {
    if (Platform.isAndroid) {
      var cancelAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(S.current.cancel),
      );

      var email = TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          await launchUrl(Uri.parse("mailto:info@thetudu.app"));

        },
        child: Text(S.current.email),
      );

      var whatsapp = TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          await launchUrl(Uri.parse("whatsapp://send?phone=+529842105598"));
        },
        child: const Text("Whatsapp"),
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
            onPressed: () async {
              Navigator.of(context).pop();
              await launchUrl(Uri.parse("whatsapp://send?phone=+529842105598"));
            },
            child: const Text("Whatsapp"),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await launchUrl(Uri.parse("mailto:info@thetudu.app"));
            },
            child: Text(S.current.email),
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
  }

}
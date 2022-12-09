import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/viewmodels/deals_viewmodel.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/generated/l10n.dart';

class DealsView extends StatefulWidget {
  const DealsView({super.key});

  @override
  State<StatefulWidget> createState() => _DealsView();
}

class _DealsView extends State<DealsView> {
  final _dealsViewModel = DealsViewModel();

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _refreshController = RefreshController(initialRefresh: false);

  var _enableAllLocation = false;
  bool _isAtTop = true;

  @override
  void initState() {
    _dealsViewModel.userLoginStream.listen((event) {
      if (!event) {
        showDialog(context: context, builder: (context){
          return ErrorAlert.alertLogin(context);
        });
      }
    });

    _dealsViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        Navigator.of(context).pop();
      }
    });

    _scrollController.addListener(() {
      print(_scrollController.offset);
      if (_scrollController.position.pixels == 0.0) {
        _isAtTop = true;
        setState(() {});
      } else {
        _isAtTop = false;
        setState(() {});
      }
    });
    _searchController.addListener(() {
      _dealsViewModel.searchWithParam(
        title: _searchController.text,
      );
    });
    _dealsViewModel.error.listen((event) {
      showDialog(context: context, builder: (context){
        return ErrorAlert.alert(context, event.message ?? S.current.failed);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> array = [
      Container(
        height: 36.0,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              child: Image.asset(
                ImagePath.humbergerIcon,
                width: 28,
                height: 28,
              ),
              onTap: () {
                NotificationCenter().notify(StrConst.openMenu);
              },
            ),
            const Spacer(),
            InkWell(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Image.asset(
                          ImagePath.sortIcon,
                          fit: BoxFit.contain,
                          width: 16.0)
                  ),
                  Text(
                    S.current.sort,
                    style: const TextStyle(
                      color: ColorStyle.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: FontStyles.raleway,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0,),
            PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: S.current.business_type,
                  iconWidget: Image.asset(
                    ImagePath.cenoteIcon,
                    width: 28, height: 28,
                  ),
                  itemTheme: const PullDownMenuItemTheme(
                    textStyle: TextStyle(
                        fontFamily: FontStyles.sfProText,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: ColorStyle.menuLabel
                    ),

                  ),
                  onTap: () {},
                ),
                const PullDownMenuDivider(),
                PullDownMenuItem(
                  title: S.current.beach_clubs,
                  itemTheme: const PullDownMenuItemTheme(
                    textStyle: TextStyle(
                        fontFamily: FontStyles.sfProText,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: ColorStyle.menuLabel
                    ),

                  ),
                  iconWidget: Image.asset(
                    ImagePath.sunAndHorizonCircleIcon,
                    width: 28, height: 28,
                  ),
                  onTap: () {},
                ),
                const PullDownMenuDivider(),
                PullDownMenuItem(
                  title: S.current.work_spots,
                  itemTheme: const PullDownMenuItemTheme(
                    textStyle: TextStyle(
                        fontFamily: FontStyles.sfProText,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: ColorStyle.menuLabel
                    ),

                  ),
                  iconWidget: Image.asset(
                    ImagePath.desktopComputerIcon,
                    width: 28, height: 28,
                  ),
                  onTap: () {},
                ),
                const PullDownMenuDivider.large(),
                PullDownMenuItem(
                  title: S.current.all_location,
                  itemTheme: const PullDownMenuItemTheme(
                    textStyle: TextStyle(
                        fontFamily: FontStyles.sfProText,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: ColorStyle.menuLabel
                    ),

                  ),
                  iconWidget: Image.asset(
                    _enableAllLocation
                        ? ImagePath.mappinIcon
                        : ImagePath.mappinDisableIcon,
                    width: 28, height: 28,
                  ),
                  enabled: _enableAllLocation,
                  onTap: () {},
                ),
              ],
              position: PullDownMenuPosition.automatic,
              buttonBuilder: (context, showMenu) => Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: InkWell(
                  onTap: showMenu,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          ImagePath.filterIcon,
                          fit: BoxFit.contain,
                          width: 16,
                        ),
                      ),
                      Text(
                        S.current.filter,
                        style: const TextStyle(
                            color: ColorStyle.primary,
                            fontSize: FontSizeConst.font10,
                            fontWeight: FontWeight.w500,
                            fontFamily: FontStyles.raleway
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    if (_isAtTop) {
      array.add(CupertinoSearchTextField(
        controller: _searchController,
        style: const TextStyle(
            color: ColorStyle.darkLabel,
            fontFamily: FontStyles.sfProText,
            fontSize: FontSizeConst.font17,
            fontWeight: FontWeight.w400
        ),
        placeholder: S.current.search_placeholder,
        placeholderStyle: const TextStyle(
          color: ColorStyle.placeHolder,
          fontWeight: FontWeight.w400,
          fontSize: FontSizeConst.font17,
          fontFamily: FontStyles.sfProText,
        ),
      ));
    }
    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: (_isAtTop) ? 94 : 56,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 8,),
            color: ColorStyle.navigation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: array,
            ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _refresh,
          child: StreamBuilder(
            stream: _dealsViewModel.userLoginStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return ListView(
                  controller: _scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                      child: createDealsView(),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget createDealsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.current.explore_deals,
                style: const TextStyle(
                  color: ColorStyle.darkLabel,
                  fontSize: FontSizeConst.font16,
                  fontFamily: FontStyles.mouser,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {},
                child: Column(
                  children: [
                    Image.asset(
                      ImagePath.pinMapIcon,
                      width: 16,
                      height: 16,
                    ),
                    Text(
                      S.current.map,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: FontStyles.raleway,
                          fontSize: FontSizeConst.font10,
                          color: ColorStyle.primary
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
        getExploreDealsView(),
      ],
    );
  }

  Widget getExploreDealsView() {
    return StreamBuilder<List<Deal>>(
      stream: _dealsViewModel.deals,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 7,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                          ),
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data![index].images.first,
                              width: MediaQuery.of(context).size.width,
                              height: 236,
                              fit: BoxFit.cover,
                            ),
                          )
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.only(top: 16, left: 16),
                      decoration: const BoxDecoration(
                        color: ColorStyle.tertiaryBackground75,
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                        ),
                      ),
                      child: Image.asset(
                        ImagePath.tab1stActiveIcon,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: IntrinsicWidth(
                        child: Container(
                          height: 50.0,
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 110,
                            minWidth: 130,
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: FractionalOffset.centerLeft,
                                  end: FractionalOffset.centerRight,
                                  colors: [
                                    ColorStyle.systemBackground.withOpacity(0.8),
                                    ColorStyle.systemBackground.withOpacity(0.0),
                                  ],
                                  stops: const [0.2, 1.0]
                              )),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data![index].title,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: ColorStyle.darkLabel,
                                    fontFamily: FontStyles.mouser,
                                    fontWeight: FontWeight.w400,
                                    fontSize: FontSizeConst.font12,
                                  ),
                                ),
                                Text(
                                  snapshot.data![index].titleShort,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontFamily: FontStyles.raleway,
                                    fontSize: FontSizeConst.font12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorStyle.darkLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 16,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data![index].logo,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      ),
                    )

                  ],
                );
              });
        } else {
          return Container(
            color: ColorStyle.systemBackground,
          );
        }

      },
    );
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
    print("refresh");
    _isAtTop = true;
    setState(() {

    });
    _dealsViewModel.refresh().then((value) => _refreshController.refreshCompleted());
  }
}
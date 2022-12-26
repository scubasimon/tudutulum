import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/models/onboard.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/login/login_view.dart';
import 'package:tudu/views/onboard/card_board_view.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/utils/pref_util.dart';

class OnboardView extends StatefulWidget {
  const OnboardView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OnboardState();
  }
}

class _OnboardState extends State<OnboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CarouselController buttonCarouselController =  CarouselController();

  double _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    var darkMode = PrefUtil.getValue(StrConst.isDarkMode, false) as bool;
    return ExitAppScope(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorStyle.getSystemBackground(),
        body: Container(
          color: ColorStyle.getSystemBackground(),
          child: SafeArea(
            child: Container(
                color: ColorStyle.getSystemBackground(),
                child:  Column(
                  children: [
                    Image.asset(
                      darkMode ? ImagePath.logoTuduTulumWhite : ImagePath.logoTuduTulumBlack,
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 1,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                          initialPage: 0,
                          onPageChanged: _onPageChanged,
                        ),
                        carouselController: buttonCarouselController,
                        items: Onboard.data.map((element) {
                          return Builder(
                            builder: (BuildContext context) {
                              return CardBoardView(element);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    DotsIndicator(
                      dotsCount: Onboard.data.length,
                      position: _currentPage,
                      decorator: const DotsDecorator(
                        color: ColorStyle.secondary25,
                        activeColor: ColorStyle.secondary,
                      ),
                    ),
                    const Spacer(flex: 3),
                    InkWell(
                      onTap: () {
                        _nextAction();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: ColorStyle.secondary80,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2.0,
                                blurRadius: 2.0,
                                offset: const Offset(0, 4),
                              )
                            ]
                        ),
                        padding: const EdgeInsets.fromLTRB(48, 18, 48, 18),
                        child: Text(
                          _currentPage == Onboard.data.length - 1 ? S.current.get_started : S.current.next,
                          style: TextStyle(
                              color: ColorStyle.getSystemBackground(),
                              fontFamily: FontStyles.roboto,
                              fontSize: 21,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(16.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.all(16.0)),
                        InkWell(
                          onTap: () {
                            _routeLogin();
                          },
                          child: Text(
                            S.current.skip,
                            style: const TextStyle(
                                color: ColorStyle.secondary,
                                fontFamily: FontStyles.sfProText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(8.0)),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }

  void _nextAction() {
    if (_currentPage == Onboard.data.length - 1) {
      _routeLogin();
    } else {
      buttonCarouselController.nextPage();
    }
  }

  void _onPageChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      _currentPage = index.toDouble();
    });
  }

  void _routeLogin() {
    SharedPreferences.getInstance()
    .then((prefs) => prefs.setBool("open_first", false));
    Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) { return child; }
        )
    );
  }

}


import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/models/onboard.dart';
import 'package:tudu/views/login/login_view.dart';
import 'package:tudu/views/onboard/card_board_view.dart';
import 'package:tudu/generated/l10n.dart';

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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorStyle.systemBackground,
      body: SafeArea(
        child: Container(
            color: ColorStyle.systemBackground,
            child:  Column(
              children: [
                Image.asset(
                  ImagePath.logoTuduTulum,
                  height: 150,
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 1,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    onPageChanged: onPageChanged,
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
                DotsIndicator(
                  dotsCount: Onboard.data.length,
                  position: _currentPage,
                  decorator: const DotsDecorator(
                    color: ColorStyle.secondary25,
                    activeColor: ColorStyle.secondary,
                  ),
                ),
                const Spacer(flex: 1),
                TextButton(
                    onPressed: nextAction,
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
                        style: const TextStyle(
                            color: ColorStyle.systemBackground,
                            fontFamily: FontStyles.roboto,
                            fontSize: 21,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        routeLogin();
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
              ],
            )
        ),
      ),
    );
  }

  void nextAction() {
    if (_currentPage == Onboard.data.length - 1) {
      routeLogin();
    } else {
      buttonCarouselController.nextPage();
    }
  }

  void onPageChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      _currentPage = index.toDouble();
    });
  }

  void routeLogin() {
    Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) { return child; }
        )
    );
  }

}


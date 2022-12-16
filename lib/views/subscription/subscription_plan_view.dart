import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/models/subscription.dart';
import 'package:tudu/viewmodels/subscription_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPlanView extends StatefulWidget {
  const SubscriptionPlanView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SubscriptionPlanView();
  }

}

class _SubscriptionPlanView extends State<SubscriptionPlanView> {

  final _subscriptionViewModel = SubscriptionViewModel();

  @override
  Widget build(BuildContext context) {

    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            color: ColorStyle.systemBackground,
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
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: ColorStyle.systemBackground,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ListView(
            children: [
              Image.asset(
                ImagePath.tab1stActiveIcon,
                height: 92,
                fit: BoxFit.contain,
              ),
              Center(
                child: Text(
                  S.current.choose_your_plan,
                  style: const TextStyle(
                      color: ColorStyle.primary,
                      fontFamily: FontStyles.sfProText,
                      fontWeight: FontWeight.w700,
                      fontSize: 34
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              Text(
                "• ${S.current.discover_offer_deals}",
                style: const TextStyle(
                  color: ColorStyle.tertiaryDarkLabel60,
                  fontFamily: FontStyles.raleway,
                  fontSize: FontSizeConst.font14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "• ${S.current.option_hide_ads}",
                style: const TextStyle(
                  color: ColorStyle.tertiaryDarkLabel60,
                  fontFamily: FontStyles.raleway,
                  fontSize: FontSizeConst.font14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48,),
              StreamBuilder(
                stream: _subscriptionViewModel.subscriptions,
                builder: (context, snapshot){
                  if (snapshot.hasData) {
                    List<Widget> list = [];
                    for (var element in snapshot.data!) {
                      list.add(
                        InkWell(
                          onTap: () {
                            _subscriptionViewModel.chooseSubscription(element.id);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: element.selection
                                  ? ColorStyle.primary
                                  : ColorStyle.systemBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: element.selection
                                ? null
                                  : Border.all(
                                color: ColorStyle.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16,
                                  right: 16,
                                  left: 16,
                                  bottom: 16
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    element.name,
                                    style: TextStyle(
                                      color: element.selection
                                          ? ColorStyle.lightLabel
                                          : ColorStyle.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSizeConst.font17,
                                      fontFamily: FontStyles.sfProText,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "\$${element.price}",
                                    style: TextStyle(
                                        color: element.selection
                                            ? ColorStyle.lightLabel
                                            : ColorStyle.primary,
                                        fontFamily: FontStyles.sfProText,
                                        fontSize: FontSizeConst.font14,
                                        fontWeight: FontWeight.w400
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                      list.add(const SizedBox(height: 8,),);
                    }
                    return Column(
                      children: list,
                    );
                  } else {
                    return const Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                        color: ColorStyle.primary,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8,),
              Text(
                S.current.subscription_description,
                style: const TextStyle(
                  color: ColorStyle.quaternaryDarkLabel,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizeConst.font12,
                  fontFamily: FontStyles.raleway
                ),
              ),
              const SizedBox(height: 48,),
              InkWell(
                child: Center(
                  child: Text(
                    S.current.restore_purchase,
                    style: const TextStyle(
                      color: ColorStyle.tertiaryDarkLabel,
                      fontFamily: FontStyles.mouser,
                      fontSize: FontSizeConst.font14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24,),
              Center(
                child: InkWell(
                  onTap: () async {
                    await launchUrl(Uri.parse(URLConsts.termAndConditions));
                  },
                  child: Text(
                    S.current.term_and_conditions,
                    style: const TextStyle(
                      color: ColorStyle.quaternaryDarkLabel,
                      fontWeight: FontWeight.w400,
                      fontSize: FontSizeConst.font14,
                      fontFamily: FontStyles.raleway,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
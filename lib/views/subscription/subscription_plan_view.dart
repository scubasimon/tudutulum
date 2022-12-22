import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notification_center/notification_center.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/viewmodels/subscription_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/consts/strings/str_const.dart';

class SubscriptionPlanView extends StatefulWidget {
  final bool dismissWhenCompleted;
  const SubscriptionPlanView({super.key, this.dismissWhenCompleted = false});

  @override
  State<StatefulWidget> createState() {
    return _SubscriptionPlanView();
  }

}

class _SubscriptionPlanView extends State<SubscriptionPlanView> {

  final _subscriptionViewModel = SubscriptionViewModel();
  ObservableService _observableService = ObservableService();

  @override
  void initState() {
    _subscriptionViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        Navigator.of(context).pop();
      }
    });

    _subscriptionViewModel.error.listen((event) {
      var message = event.message != null ? event.message! : S.current.failed;
      _showAlertError(message);
    });
    _subscriptionViewModel.subscriptionSuccess.listen((event) {
      if (event) {
        if (widget.dismissWhenCompleted) {
          showDialog(context: context, builder: (context) => _alert(context, S.current.purchase_success));
        } else {
          NotificationCenter().notify(StrConst.purchaseSuccess);
          showDialog(context: context, builder: (context) => NotificationAlert.alert(context, S.current.purchase_success));
        }
      } else {
        _showAlertError(S.current.purchase_failed);
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
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            color: ColorStyle.getSystemBackground(),
            child: Container(
              height: 36.0,
              alignment: Alignment.centerLeft,
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (widget.dismissWhenCompleted) {
                        _observableService.redirectTabController.add(0);
                      }
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
          color: ColorStyle.getSystemBackground(),
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
              const SizedBox(height: 12,),
              Center(
                child: Text(
                  S.current.try_a_week,
                  style: const TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font11,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.tertiaryDarkLabel,
                  ),
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
                                  : ColorStyle.getSystemBackground(),
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
                                          ? ColorStyle.getLightLabel()
                                          : ColorStyle.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSizeConst.font17,
                                      fontFamily: FontStyles.sfProText,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    element.priceString,
                                    style: TextStyle(
                                        color: element.selection
                                            ? ColorStyle.getLightLabel()
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
                onTap: _subscriptionViewModel.restore,
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

  void _showAlertError(String message) {
    showDialog(context: context, builder: (BuildContext context) {
      return ErrorAlert.alert(context, message);
    });
  }

  Widget _alert(BuildContext context, String message) {
    if (Platform.isAndroid) {
      var okAction = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          NotificationCenter().notify(StrConst.purchaseSuccess);
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
              Navigator.of(context).pop();
              NotificationCenter().notify(StrConst.purchaseSuccess);
            },
          )
        ],
      );
    }
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/viewmodels/setting_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';

import '../../consts/strings/str_const.dart';
import '../../services/observable/observable_serivce.dart';
import '../../utils/pref_util.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingView();
  }
}

class _SettingView extends State<SettingView> {

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
                    Center(
                      child: Text(
                        S.current.setting,
                        style: TextStyle(
                          color: ColorStyle.getDarkLabel(),
                          fontSize: FontSizeConst.font16,
                          fontFamily: FontStyles.mouser,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    )
                  ],
                ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
          color: ColorStyle.getSystemBackground(),
          child: Consumer<SettingViewModel>(
            builder: (context, model, child){
              return ListView(
                children: [
                  Row(
                    children: [
                      Text(
                        S.current.push_notification,
                        style: TextStyle(
                          color: ColorStyle.getDarkLabel(),
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.mouser,
                          fontSize: FontSizeConst.font16,
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                        value: model.isPushNotification,
                        activeColor: ColorStyle.primary,
                        side: BorderSide(
                          color: model.enableDarkMode ? Colors.white : Colors.black
                        ),
                        onChanged: (value) {
                          setState(() {
                            model.setPushNotification(value ?? false);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        S.current.push_notification_new_offer,
                        style: TextStyle(
                          fontSize: FontSizeConst.font14,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          color: ColorStyle.getDarkLabel(),
                        ),
                      ),
                      const Spacer(),
                      CupertinoSwitch(
                        value: model.enableNewOffer,
                        activeColor: ColorStyle.primary,
                        onChanged: (value) {
                          setState(() {
                            model.setNewOffer(value);
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8,),
                  Row(
                    children: [
                      Text(
                        S.current.push_notification_available_offer,
                        style: TextStyle(
                          fontSize: FontSizeConst.font14,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          color: ColorStyle.getDarkLabel(),
                        ),
                      ),
                      const Spacer(),
                      CupertinoSwitch(
                        value: model.enableAvailableOffer,
                        activeColor: ColorStyle.primary,
                        onChanged: (value) async {
                          try {
                            await model.setAvailableOffer(value);
                          } catch (e) {
                            print(e);
                            showDialog(context: context, builder: (context) => ErrorAlert.alertPermission(context, S.current.location_permission_message));
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 24),
                    child: Divider(
                      height: 1.0,
                    ),
                  ),
                  Text(
                    S.current.preferences,
                    style: TextStyle(
                      color: ColorStyle.getDarkLabel(),
                      fontWeight: FontWeight.w400,
                      fontFamily: FontStyles.mouser,
                      fontSize: FontSizeConst.font16,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        S.current.dark_mode,
                        style: TextStyle(
                          fontSize: FontSizeConst.font14,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          color: ColorStyle.getDarkLabel(),
                        ),
                      ),
                      const Spacer(),
                      CupertinoSwitch(
                        value: model.enableDarkMode,
                        activeColor: ColorStyle.primary,
                        onChanged: (value) {
                          setState(() {
                            model.setDarkMode(value);
                          });
                        },
                      )
                    ],
                  ),
                  Text(
                    S.current.dark_mode_enable_info,
                    style: TextStyle(
                      fontSize: FontSizeConst.font10,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontStyles.raleway,
                      color: ColorStyle.getDarkLabel(),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    children: [
                      Text(
                        S.current.hide_articles,
                        style: TextStyle(
                          fontSize: FontSizeConst.font14,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          color: ColorStyle.getDarkLabel(),
                        ),
                      ),
                      const Spacer(),
                      CupertinoSwitch(
                        value: model.hideArticles,
                        activeColor: ColorStyle.primary,
                        onChanged: (value) {
                          setState(() {
                            model.setHideArticles(value);
                          });
                        },
                      )
                    ],
                  ),
                  Text(
                    S.current.hide_articles_info,
                    style: TextStyle(
                      fontSize: FontSizeConst.font10,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontStyles.raleway,
                      color: ColorStyle.getDarkLabel(),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 24),
                    child: Divider(
                      height: 1.0,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        S.current.clear_saved_data,
                        style: TextStyle(
                          fontSize: FontSizeConst.font14,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          color: ColorStyle.getDarkLabel(),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          model.clearData(context);
                        },
                        child: Image.asset(
                          ImagePath.removeIcon,
                          height: 20,
                          width: 18,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Text(
                      S.current.clear_saved_data_info,
                      style: TextStyle(
                        fontSize: FontSizeConst.font10,
                        fontWeight: FontWeight.w600,
                        fontFamily: FontStyles.raleway,
                        color: ColorStyle.getDarkLabel(),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}
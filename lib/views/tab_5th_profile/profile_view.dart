import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/profile_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/tab_1st_what_tudu/what_tudu_site_content_detail_view.dart';
import '../../localization/language_constants.dart';
import '../../utils/audio_path.dart';
import '../../utils/colors_const.dart';
import '../../utils/dimens_const.dart';
import '../../utils/font_size_const.dart';
import '../../utils/icon_path.dart';
import '../../utils/str_const.dart';
import '../../utils/str_language_key.dart';
import '../../viewmodels/deals_viewmodel.dart';

class ProfileView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  ProfileViewModel profileViewModel = ProfileViewModel();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppScope(
      child: Scaffold(
        body: Container(
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              createBackView(),
              createIconView(),
              createProfileView(),
              createPasswordView(),
              createTermView(),
              getButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget createBackView() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 8,),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route){
                return (route.settings.name == StrConst.whatTuduScene || route.isFirst);
              });
            },
            child: Image.asset(
                IconPath.iconLeftArrow,
                fit: BoxFit.contain,
                height: 20.0),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route){
                return (route.settings.name == StrConst.whatTuduScene || route.isFirst);
              });
            },
            child: Container(
                margin: EdgeInsets.only(left: 8),
                child: Text(
                  "Back",
                  style: const TextStyle(
                      color: ColorsConst.defaulOrange,
                      fontSize: FontSizeConst.font16,
                      fontWeight: FontWeight.w400),
                )
            ),
          )
        ],
      ),
    );
  }

  Widget createIconView() {
    return Container(
      margin: EdgeInsets.only(bottom: 52),
      child: Column(
        children: [
          Container(
            child: Image.asset(
              IconPath.iconTab1stActive,
              height: 92,
              fit: BoxFit.contain,
            ),
          ),
          Text(
              "Your Account",
              style: const TextStyle(
                  color: ColorsConst.defaulOrange,
                  fontSize: FontSizeConst.font34,
                  fontWeight: FontWeight.w700)),
          Text(
              "Hello 'FirstName'",
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: ColorsConst.defaulGray6,
                  fontSize: FontSizeConst.font17,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget createProfileView() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Update Details",
              style: const TextStyle(
                  color: ColorsConst.defaulGray6,
                  fontSize: FontSizeConst.font17,
                  fontWeight: FontWeight.w400)),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                    onSubmitted: null,
                    decoration: InputDecoration(
                      hintText: "firstName",
                      hintStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: ColorsConst.defaulGray3,
                          fontSize: FontSizeConst.font17,
                          fontWeight: FontWeight.w400),
                    )),
              ),
              Container(width: 10,),
              Expanded(
                flex: 1,
                child: TextField(
                    onSubmitted: null,
                    decoration: InputDecoration(
                      hintText: "familyName",
                      hintStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: ColorsConst.defaulGray3,
                          fontSize: FontSizeConst.font17,
                          fontWeight: FontWeight.w400),
                    )),
              ),
            ],
          ),
          TextField(
              onSubmitted: null,
              decoration: InputDecoration(
                hintText: "email",
                hintStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: ColorsConst.defaulGray3,
                    fontSize: FontSizeConst.font17,
                    fontWeight: FontWeight.w400),
              )),
          TextField(
              onSubmitted: null,
              decoration: InputDecoration(
                hintText: "mobileNumber",
                hintStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: ColorsConst.defaulGray3,
                    fontSize: FontSizeConst.font17,
                    fontWeight: FontWeight.w400),
              )),
        ],
      ),
    );
  }

  Widget createPasswordView() {
    return Container(
      padding: EdgeInsets.only(top: 30, left: 8, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Change Password",
              style: const TextStyle(
                  color: ColorsConst.defaulGray6,
                  fontSize: FontSizeConst.font17,
                  fontWeight: FontWeight.w400)),
          Stack(
            children: [
              TextField(
                  onSubmitted: null,
                  decoration: InputDecoration(
                    hintText: "New Password",
                    hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: ColorsConst.defaulGray3,
                        fontSize: FontSizeConst.font17,
                        fontWeight: FontWeight.w400),
                  )),
              Positioned(
                right: 0,
                bottom: 15,
                child: InkWell(
                  onTap: () {
                    //TODO: IMPLEMENT FORGOT FEATURE
                    showToast(
                        "FORGOT NOT IMPL YET",
                        context: context,
                        duration: Duration(seconds: 3),
                        axis: Axis.horizontal,
                        alignment: Alignment.center,
                        position: StyledToastPosition.bottom,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: ColorsConst.white,
                            fontSize: FontSizeConst.font12));
                  },
                  child: Text(
                    "Forgot password?",
                    style: const TextStyle(
                        color: ColorsConst.defaulOrange,
                        fontSize: FontSizeConst.font13,
                        fontWeight: FontWeight.w600)),
                ))
            ],
          ),
          TextField(
              onSubmitted: null,
              decoration: InputDecoration(
                hintText: "Repeat New Password",
                hintStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: ColorsConst.defaulGray3,
                    fontSize: FontSizeConst.font17,
                    fontWeight: FontWeight.w400),
              )),
        ],
      ),
    );
  }

  Widget createTermView() {
    return Container(
      margin: EdgeInsets.only(top: 30, left: 4, right: 4),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              //TODO: IMPLEMENT CHECK/UNCHECK TERM FEATURE
              showToast(
                  "CHECK/UNCHECK TERM NOT IMPL YET",
                  context: context,
                  duration: Duration(seconds: 3),
                  axis: Axis.horizontal,
                  alignment: Alignment.center,
                  position: StyledToastPosition.bottom,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: ColorsConst.white,
                      fontSize: FontSizeConst.font12));
            },
            child: Row(
              children: [
                Image.asset(
                  IconPath.iconChooseActive,
                  width: 24,
                  fit: BoxFit.contain,
                ),
                Text(
                    " Receive new offer notification emails",
                    style: const TextStyle(
                        color: ColorsConst.defaulGray6,
                        fontSize: FontSizeConst.font13,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              //TODO: IMPLEMENT CHECK/UNCHECK TERM FEATURE
              showToast(
                  "CHECK/UNCHECK TERM NOT IMPL YET",
                  context: context,
                  duration: Duration(seconds: 3),
                  axis: Axis.horizontal,
                  alignment: Alignment.center,
                  position: StyledToastPosition.bottom,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: ColorsConst.white,
                      fontSize: FontSizeConst.font12));
            },
            child: Row(
              children: [
                Image.asset(
                  IconPath.iconChooseActive,
                  width: 24,
                  fit: BoxFit.contain,
                ),
                Text(
                    " Receive monthly newsletter email",
                    style: const TextStyle(
                        color: ColorsConst.defaulGray6,
                        fontSize: FontSizeConst.font13,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getButton() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: ColorsConst.defaulOrange,
                fixedSize: Size(MediaQuery.of(context).size.width-16, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                //TODO: IMPLEMENT CHANGE ACCOUNT INFO FEATURE
                showToast(
                    "CHANGE ACCOUNT INFO NOT IMPL YET",
                    context: context,
                    duration: Duration(seconds: 3),
                    axis: Axis.horizontal,
                    alignment: Alignment.center,
                    position: StyledToastPosition.bottom,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: ColorsConst.white,
                        fontSize: FontSizeConst.font12));
              },
              child: Text(
                "Save Changes",
                style: TextStyle(
                    color: ColorsConst.white,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4, bottom: 30),
            child: Text(
                " Receive new offer notification emails",
                style: const TextStyle(
                    color: ColorsConst.defaulGray6,
                    fontSize: FontSizeConst.font13,
                    fontWeight: FontWeight.w400)),
          )
        ],
      ),
    );
  }
}
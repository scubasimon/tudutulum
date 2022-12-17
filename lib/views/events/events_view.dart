import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/localization/language_constants.dart';
import 'package:tudu/utils/colors_const.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_language_key.dart';

import 'package:tudu/consts/images/ImagePath.dart';

import '../../consts/strings/str_const.dart';
import 'event_content_detail_view.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<StatefulWidget> createState() => _EventsView();
}

class _EventsView extends State<EventsView> {
  EventsViewModel eventsViewModel = EventsViewModel();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      eventsViewModel.showData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 88,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top+8,
                left: 16,
                right: 16,
                bottom: 8,),
            color: ColorsConst.defaulGreen2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 36.0,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
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
                                getTranslated(context, StrLanguageKey.sort),
                                style: const TextStyle(
                                    color: ColorsConst.defaulOrange,
                                    fontSize: FontSizeConst.font10,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        onTap: () {
                          //TODO: IMPLEMENT SORT FEATURE
                          showToast(
                              "SORT NOT IMPL YET",
                              context: context,
                              duration: const Duration(seconds: 3),
                              axis: Axis.horizontal,
                              alignment: Alignment.center,
                              position: StyledToastPosition.bottom,
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: ColorsConst.white,
                                  fontSize: FontSizeConst.font12));                        },
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Image.asset(
                                      ImagePath.filterIcon,
                                      fit: BoxFit.contain,
                                      width: 16.0)
                              ),
                              Text(
                                  getTranslated(context, StrLanguageKey.filter),
                                  style: const TextStyle(
                                      color: ColorsConst.defaulOrange,
                                      fontSize: FontSizeConst.font10,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          onTap: () {
                            //TODO: IMPLEMENT FILTER FEATURE
                            showToast(
                                "FILTER NOT IMPL YET",
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
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36.0,
                  padding:const EdgeInsets.only(left: 8, right: 8),
                  decoration: const BoxDecoration(
                    color: ColorsConst.defaulGray3,
                    borderRadius: BorderRadius.all(
                        Radius.circular(10.0)
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                          ImagePath.searchIcon,
                          fit: BoxFit.contain,
                          width: 16.0),
                      Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          "Search here or use the filter above",
                          style: const TextStyle(
                              color: ColorsConst.defaulGray4,
                              fontSize: FontSizeConst.font17,
                              fontWeight: FontWeight.w400),
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: Container(
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              createExploreEventsView()
            ],
          ),
        ),
      ),
    );
  }

  Widget createExploreEventsView() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              "Explore Events",
              style: const TextStyle(
                  color: ColorsConst.black,
                  fontSize: FontSizeConst.font16,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              "November",
              style: const TextStyle(
                  color: ColorsConst.black,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400),
            ),
          ),
          getExploreAllLocationView(),
        ],
      ),
    );
  }

  Widget getExploreAllLocationView() {
    return StreamBuilder<List<EventData>?>(
      stream: eventsViewModel.listEventsStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("snapshot.hasError"));
        } else {
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventContentDetailView(),
                            settings: const RouteSettings(name: StrConst.eventContentDetailScene)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset(
                          ImagePath.internetIcon,
                          width: 22,
                          fit: BoxFit.contain,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(snapshot.data![index].date),
                              Text(snapshot.data![index].timestart)
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data![index].event),
                              Text(snapshot.data![index].eventSite)
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data![index].cost),
                              Text(snapshot.data![index].currency)
                            ],
                          ),
                        ),
                        Image.asset(
                          ImagePath.internetIcon,
                          width: 22,
                          fit: BoxFit.contain,
                        ),
                      ],
                    )
                  ),
                );
              });
        }
      },
    );
  }
}
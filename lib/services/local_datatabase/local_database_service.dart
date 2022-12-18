import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localstore/localstore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../consts/strings/str_const.dart';

abstract class LocalDatabaseService {
  Future<List<Map<String, dynamic>>?> getArticles();

  Future<List<Map<String, dynamic>>?> getSites();

  Future<List<Map<String, dynamic>>?> getEvents();

  Future<List<Map<String, dynamic>>?> getPartners();

  Future<List<Map<String, dynamic>>?> getAmenities();

  Future<List<Map<String, dynamic>>?> getBusinesses();
}

class LocalDatabaseServiceImpl extends LocalDatabaseService {
  static final LocalDatabaseServiceImpl _singleton = LocalDatabaseServiceImpl._internal();

  factory LocalDatabaseServiceImpl() {
    return _singleton;
  }
  LocalDatabaseServiceImpl._internal();

  @override
  Future<List<Map<String, dynamic>>?> getArticles() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listArticlesResult = await Localstore.instance.collection("articles").doc(i.toString()).get();
      if (listArticlesResult != null) {
        listResult.add(listArticlesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getSites() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection("sites").doc(i.toString()).get();
      if (listSitesResult != null) {
        listResult.add(listSitesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getEvents() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection("events").doc(i.toString()).get();
      if (listSitesResult != null) {
        listResult.add(listSitesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getPartners() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listPartnerResult = await Localstore.instance.collection("partners").doc(i.toString()).get();
      if (listPartnerResult != null) {
        listResult.add(listPartnerResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getAmenities() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listAmenities = await Localstore.instance.collection("amenities").doc(i.toString()).get();
      if (listAmenities != null) {
        listResult.add(listAmenities);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getBusinesses() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listBusinesses = await Localstore.instance.collection("businesses").doc(i.toString()).get();
      if (listBusinesses != null) {
        listResult.add(listBusinesses);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }
}

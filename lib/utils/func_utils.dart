import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:url_launcher/url_launcher.dart';

class FuncUlti {
  // static void checkSoundOnOff(String sound) {
  //   final assetsAudioPlayer = AssetsAudioPlayer();
  //
  //   // (PrefUtil.getValue(StrConst.SOUND_STATUS, false) as bool)
  //   //     ? assetsAudioPlayer.open(Audio(sound))
  //   //     : () {};
  //
  //   assetsAudioPlayer.open(Audio(sound));
  // }

  static bool validateEmail(String email) {
    RegExp emailRegex = RegExp(StrConst.emailRegex);
    return emailRegex.hasMatch(email);
  }

  static List<int> getListIntFromListDynamic(List<dynamic> input) {
    List<int> result = [];
    input.forEach((element) {
      var intValue = int.tryParse(element.toString());
      if (intValue != null) result.add(element as int);
    });
    return result;
  }

  static List<String> getListStringFromListDynamic(List<dynamic> input) {
    List<String> result = [];
    input.forEach((element) {
      result.add(element.toString());
    });
    return result;
  }

  static Map<String, List<String>> getMapStringListFromStringDynamic(Map<String, dynamic> input) {
    Map<String, List<String>> result = {};
    for (var item in input.keys) {
      List<String> listStr = [];
      for (var newItem in List.from(input[item])) {
        listStr.add(newItem.toString());
      }
      result[item.toString()] = listStr;
    }
    return result;
  }

  static Map<String, String> getMapStringStringFromStringDynamic(Map<String, dynamic> input) {
    Map<String, String> result = {};
    for (var item in input.keys) {
      result[item.toString()] = input[item].toString();
    }
    return result;
  }

  static String getDayInWeekFromKeyword(String input) {
    switch (input) {
      case "mon":
        return "Monday";
      case "tue":
        return "Tuesday";
      case "wed":
        return "Wednesday";
      case "fri":
        return "Friday";
      case "thu":
        return "Thursday";
      case "sat":
        return "Saturday";
      case "sun":
        return "Sunday";
      case "other":
        return "Other";
      default:
        return "NaN";
    }
  }

  static String getSortTypeByInt(int input) {
    switch (input) {
      case 0:
        return "title"; // Alphabet
      case 1:
        return "title"; // TODO: IMPL LOGIC FOR SORT WITH Distance
      default:
        return "title"; // Alphabet
    }
  }

  static void printLongLog(String input) {
    for (var i = 0; i < (input.length / 1000) - 2; i++) {
      if ((i + 1) * 1000 < input.length) {
        print(input.substring(i * 1000 + (i + 1) * 1000));
      } else {
        print(input.substring(i * 1000 + input.length));
      }
    }
  }

  static String getRandomText(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static Future<bool?> NetworkChecking() async {
    try {
      final result = await InternetAddress.lookup('firestore.googleapis.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return null;
  }

  static Future<bool> redirectAndDirection(GeoPoint from, GeoPoint to) async {
    // final availableMaps = await MapLauncher.installedMaps;
    // await availableMaps.first.showDirections(
    //     origin: Coords(from.latitude, from.longitude),
    //     destination: Coords(to.latitude, to.longitude));

    final availableMaps = await MapLauncher.installedMaps;
    try {
      await availableMaps.firstWhere((element) {
        return element.mapName == "Google Maps";
      }).showDirections(origin: Coords(from.latitude, from.longitude), destination: Coords(to.latitude, to.longitude));
      return true;
    } catch (e) {
      print("redirectAndDirection $e");
      print("redirectAndDirection -> Open installed (Apple) Map");
      final availableMaps = await MapLauncher.installedMaps;
      await availableMaps.first.showDirections(
          origin: Coords(from.latitude, from.longitude),
          destination: Coords(to.latitude, to.longitude));
      return true;
    }
  }

  static Future<void> redirectAndMoveToLocation(GeoPoint position, String title) async {
    // final availableMaps = await MapLauncher.installedMaps;
    // await availableMaps.first.showMarker(
    //     coords: Coords(position.latitude, position.longitude),
    //     title: title,
    // );

    final availableMaps = await MapLauncher.installedMaps;
    try {
      await availableMaps.firstWhere((element) {
        return element.mapName == "Google Maps";
      }).showMarker(
        coords: Coords(position.latitude, position.longitude),
        title: title,
      );
    } catch (e) {
      print("redirectAndDirection $e");
      print("redirectAndDirection -> Open installed (Apple) Map");
      final availableMaps = await MapLauncher.installedMaps;
      await availableMaps.first.showMarker(
          coords: Coords(position.latitude, position.longitude),
          title: title,
      );
    }
  }

  static Future<void> redirectToBrowserWithUrl(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

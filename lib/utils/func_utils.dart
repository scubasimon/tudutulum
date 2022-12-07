import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';

class FuncUlti {
  static void checkSoundOnOff(String sound) {
    final assetsAudioPlayer = AssetsAudioPlayer();

    // (PrefUtil.getValue(StrConst.SOUND_STATUS, false) as bool)
    //     ? assetsAudioPlayer.open(Audio(sound))
    //     : () {};

    assetsAudioPlayer.open(Audio(sound));
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
      case "mon": return "Monday";
      case "tue": return "Tueday";
      case "wed": return "Wedday";
      case "fri": return "Friday";
      case "thu": return "Thuday";
      case "sat": return "Satday";
      case "sun": return "Sunday";
      case "other": return "Other";
      default: return "NaN";
    }
  }

  static String getOrderTypeByInt(int input) {
    switch (input) {
      case 0: return "title"; // Alphabet
      case 1: return "title"; // Alphabet
      default: return "title"; // Alphabet
    }
  }

  static void printLongLog(String input) {
    for (var i = 0; i < (input.length / 1000) - 2; i++) {
      if ((i+1)*1000 < input.length) {
        print(input.substring(i*1000 + (i+1)*1000));
      } else {
        print(input.substring(i*1000 + input.length));
      }
    }
  }

  static String getRandomText(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}


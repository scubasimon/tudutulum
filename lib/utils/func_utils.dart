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
}


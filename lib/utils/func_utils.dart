import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:tudu/consts/strings/str_const.dart';

class FuncUlti {
  static void checkSoundOnOff(String sound) {
    final assetsAudioPlayer = AssetsAudioPlayer();

    // (PrefUtil.getValue(StrConst.SOUND_STATUS, false) as bool)
    //     ? assetsAudioPlayer.open(Audio(sound))
    //     : () {};

    assetsAudioPlayer.open(Audio(sound));
  }

  static bool validateEmail(String email) {
    RegExp emailRegex = RegExp(StrConst.emailRegex);
    return emailRegex.hasMatch(email);

  }
}


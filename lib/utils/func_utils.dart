import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/utils/str_const.dart';

class FuncUlti {
  static void checkSoundOnOff(String sound) {
    final assetsAudioPlayer = AssetsAudioPlayer();

    // (PrefUtil.getValue(StrConst.SOUND_STATUS, false) as bool)
    //     ? assetsAudioPlayer.open(Audio(sound))
    //     : () {};

    assetsAudioPlayer.open(Audio(sound));
  }
}


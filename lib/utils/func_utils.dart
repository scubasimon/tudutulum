import 'package:assets_audio_player/assets_audio_player.dart';

class FuncUlti {
  static void checkSoundOnOff(String sound) {
    final assetsAudioPlayer = AssetsAudioPlayer();

    // (PrefUtil.getValue(StrConst.SOUND_STATUS, false) as bool)
    //     ? assetsAudioPlayer.open(Audio(sound))
    //     : () {};

    assetsAudioPlayer.open(Audio(sound));
  }
}


import 'package:tudu/generated/l10n.dart';

class Onboard {
  int id = 0;
  String title = "";
  String description = "";
  String image = "";

  Onboard(this.id, this.title, this.description, this.image);

  static List<Onboard> data = [
    Onboard(0, S.current.onboard_title_1, S.current.onboard_description_1, "assets/images/onboard_1.png"),
    Onboard(1, S.current.onboard_title_2, S.current.onboard_description_2, "assets/images/onboard_2.png"),
    Onboard(2, S.current.onboard_title_3, S.current.onboard_description_3, "assets/images/onboard_3.png"),
    Onboard(3, S.current.onboard_title_4, S.current.onboard_description_4, "assets/images/onboard_4.png")
  ];


}
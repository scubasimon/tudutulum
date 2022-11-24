import 'package:flutter/cupertino.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/models/onboard.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/color/Colors.dart';


class CardBoardView extends StatelessWidget {

  final Onboard? _onboard;

  const CardBoardView(this._onboard, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        // color: Colors.amber
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            _onboard!.image,
            height: 180.0,
            alignment: Alignment.center,
            fit: BoxFit.fitHeight,
          ),
          _buildTitle(context),
          Text(
            _onboard!.description,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: FontStyles.raleway,
              color: ColorStyle.tertiaryDarkLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (_onboard?.id == 0) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 44, 0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _onboard!.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: FontStyles.mouser,
                fontSize: 24.0,
                color: ColorStyle.secondaryDarkLabel,
              ),
            ),
            Image.asset(
              ImagePath.logoTuduBB,
              width: 24,
              height: 24,
            ),
            const Text(
              "tudu ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontStyles.mouser,
                fontSize: 24.0,
                color: ColorStyle.secondaryDarkLabel,
              ),
            ),
            const Text(
              "?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                color: ColorStyle.secondaryDarkLabel,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 44, 0, 8.0),
        child: Text(
          _onboard!.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: FontStyles.mouser,
            fontSize: 24.0,
            color: ColorStyle.secondaryDarkLabel,
          ),
        ),
      );
    }
  }

}
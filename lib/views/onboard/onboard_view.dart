
import 'package:flutter/cupertino.dart';

class OnboardView extends StatelessWidget {
  const OnboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xffffffff)),
      child: const Center(
        child: Text(
          "Hello, world!",
          textDirection: TextDirection.ltr,
          style: TextStyle(
              fontSize: 14.0,
              color: Color(0xff000000)
          ),
        ),
      ),
    );
  }


}
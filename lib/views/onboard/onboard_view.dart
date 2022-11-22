import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../consts/color/Colors.dart';

class OnboardView extends StatelessWidget {
  const OnboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(height: 400.0),
              items: [1,2,3,4].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            color: Color(0xff112233)
                        ),
                        child: Text('text $i', style:  const TextStyle(fontSize: 16.0),)
                    );
                  },
                );
              }).toList(),
            ),
            const Spacer(flex: 1),
            TextButton(
                onPressed: nextAction,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorStyle.electricPink,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2.0,
                        blurRadius: 2.0,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  padding: const EdgeInsets.fromLTRB(48, 18, 48, 18),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                        color: ColorStyle.electricPink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }

  void nextAction() {

  }
}


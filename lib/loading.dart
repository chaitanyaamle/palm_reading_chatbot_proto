import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("LOADING");
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 203, 238),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitPulse(
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 30,),
          AnimatedTextKit(
            animatedTexts: [
              FadeAnimatedText(
                'Analysing your palm.',
                textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              FadeAnimatedText(
                'Scanning the Lines.',
                textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

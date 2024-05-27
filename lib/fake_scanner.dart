import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late File imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraCamera(
          onFile: (File file) {
            imagePath = file;
            Navigator.pop(context, imagePath);
          },
        ),
        Center(
            child: Image.asset(
          "images/hand_palm.png",
          color: const Color.fromARGB(255, 170, 203, 238),
        )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

class PhotoboothBackground extends StatelessWidget {
  const PhotoboothBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image.asset(
        //   'assets/backgrounds/photobooth_background.jpg',
        //   repeat: ImageRepeat.repeat,
        //   filterQuality: FilterQuality.high,
        // ),
        Padding(
          padding: const EdgeInsetsGeometry.directional(top: 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/backgrounds/lovedorco_logo_2.png',
              filterQuality: FilterQuality.high,
              cacheWidth: 320,
              width: size.width * 0.75,
            ),
          ),
        ),
      ],
    );
  }
}

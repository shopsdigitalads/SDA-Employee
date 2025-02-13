import 'package:flutter/material.dart';

class ScreenRouter {
  // Function to push a new screen onto the navigation stack
  static Future<void> addScreen(BuildContext context, Widget screen, {bool slide = false}) async {
  if (slide) {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); 
          const end = Offset(0.0, 0.0);
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  } else {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}


  static Future<void> replaceScreen(BuildContext context, Widget screen) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

 
  static Future<void> navigate(BuildContext context, Widget screen, {bool replace = false}) async {
    if (replace) {
      await replaceScreen(context, screen);
    } else {
      await addScreen(context, screen);
    }
  }
}

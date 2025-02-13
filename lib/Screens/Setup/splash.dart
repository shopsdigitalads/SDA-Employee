import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Setup/login.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';
import '../Home/start_point.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
  //  await SharePrefs().storePrefs("isLogin", false, "Bool");
    bool isLogin = await SharePrefs().getPrefs("isLogin", "Bool")?? false;

    await Future.delayed(Duration(seconds: 3)); // Simulating a splash screen delay
    if (isLogin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StartPoint()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/logo1.png'), // Replace with your logo path
            ),
          ),
        ),
      ),
    );
  }
}
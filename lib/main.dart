import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Screens/Setup/splash.dart';
import 'package:sdaemployee/Services/State/admin_ads_state.dart';
import 'package:sdaemployee/Services/State/app_state.dart';
import 'package:sdaemployee/Services/State/location_state.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AppState()),
    ChangeNotifierProvider(create: (context) => AdProvider()),
    ChangeNotifierProvider(create: (context) => LocationProvider())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shop Digital Ads',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        home: SplashScreen());
  }
}

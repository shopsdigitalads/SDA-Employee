import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Home/home.dart';
import 'package:sdaemployee/Screens/Home/profile.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';

class StartPoint extends StatefulWidget {
  const StartPoint({Key? key}) : super(key: key);

  @override
  _StartPointState createState() => _StartPointState();
}

class _StartPointState extends State<StartPoint> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pages to display based on selected index
    final List<Widget> pages = [
      Center(
        child: Home()
      ),
      ProfileScreen()
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildHomeAppBar(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person_2),
                icon: Icon(Icons.person_2),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
      body: pages[currentPageIndex], // Switch content based on index
    );
  }
}

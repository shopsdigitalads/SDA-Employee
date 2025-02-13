import 'package:flutter/material.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Screens/Leads/view_leads.dart';
import 'package:sdaemployee/Screens/Partner/partner_history.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';
import 'package:sdaemployee/Widgets/Section.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoaded = false;
  late User user;

  void getUser() async {
    user = await SharePrefs().getUser();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.all(screenHeight * 0.025),
                height: screenHeight * 0.25,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20), // Clip the child content
                  child: Image.network(
                    'https://images.unsplash.com/photo-1735327854928-6111ac6105c8?q=80&w=1228&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Replace with your image URL
                    fit: BoxFit.cover, // Ensure the image covers the container
                  ),
                ),
              ),
            ),
            isLoaded?
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05, right: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Section().buildEarningCard(
                    screenWidth,
                    screenHeight,
                    title: "Ads Count",
                    amount: "${user.ads_count}",
                    color: Colors.orangeAccent,
                  ),
                  Section().buildEarningCard(
                    screenWidth,
                    screenHeight,
                    title: "User Count",
                    amount: "${user.user_count}",
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ):Container(),
             Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05, right: screenWidth * 0.05),
              child: Column(
                children: [
                 Section().buildHomeButton(screenWidth, screenHeight, "Partners", Icons.history, () {
                  ScreenRouter.addScreen(context, PartnerHistory());
                }),
                  Section().buildHomeButton(screenWidth, screenHeight, "Leads", Icons.leaderboard_sharp, () {
                  ScreenRouter.addScreen(context, Leads());
                }),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Business/business_register.dart';
import 'package:sdaemployee/Screens/Partner/partner_dashboard.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

// ignore: must_be_immutable
class Partner extends StatefulWidget {
  Map<String,dynamic> user;
  Partner({required this.user, super.key});

  @override
  State<Partner> createState() => _PartnerState();
}

class _PartnerState extends State<Partner> {
  bool isBusinessLoading = true;
  Map<String, dynamic> business = {};

  dynamic last_7_days_income = 0;

  Future<bool> fetchBusiness() async {
    try {
      Map<String, dynamic> res = await BusinessApi().getBusinessOfUser(widget.user['user_id']);

      if (!mounted) return false; 
      setState(() {
        isBusinessLoading = false;
      });

      if (res['status']) {
        business = res['business'];
        last_7_days_income = (res['last_7_days_income']);
         setState(() {
        isBusinessLoading = false;
      });
        return true;
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Business",
          message: res['message'],
        );
        return false;
      }
    } catch (e) {
      print(e);
      if (!mounted) return false; // ✅ Prevent calling setState after dispose
      setState(() {
        isBusinessLoading = false;
      });
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBusiness();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppbarClass().buildSubScreenAppBar(context, "Business"),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.user['is_partner']==1
                        ? isBusinessLoading
                            ? Section().buildShimmerList(50, 40, 5)
                            : PartnerDashboard(last_7_days_income: last_7_days_income, user:widget.user, businesses: business)
                                .partnerDashboard(context)
                        : Center(
                            child: Container(
                              margin: EdgeInsets.all(screenHeight * 0.025),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.03,
                                horizontal: screenWidth * 0.05,
                              ),
                              width: screenWidth * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Register as a Display Partner",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  const Text(
                                    "Join us and become a display partner to earn more and expand your reach.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScreenRouter.addScreen(
                                          context, BusinessRegister(user:widget.user));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.redAccent,
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015,
                                        horizontal: screenWidth * 0.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Register Now",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
              ],
            ),
          ),
  
            if (widget.user['is_partner']==1)
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    ScreenRouter.addScreen(context, BusinessRegister(user: widget.user,));
                  },
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Ads/Self%20Ads/create_self_ads.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';


// ignore: must_be_immutable
class ViewSelfAds extends StatefulWidget {
  String business_type_id;
  List<int> display;
  Map<String,dynamic> user;
  ViewSelfAds({required this.user, required this.business_type_id, required this.display,  super.key});

  @override
  State<ViewSelfAds> createState() => _ViewSelfAdsState();
}

class _ViewSelfAdsState extends State<ViewSelfAds> {

   List<dynamic> self_ads = [];
  bool isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAdvertisement();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void fetchAdvertisement() async {
    try {
      if (!_isMounted) return;

      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> res = await AdvertisementApi().fetchSelfAdsOfUser(widget.user['user_id']);
      print("Self Ads : $res");
      if (_isMounted) {
        isLoading = false;
        if (res['status']) {
          self_ads = res['self_ads'];
        } else {
          DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: res['message'],
          );
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (_isMounted) {
        isLoading = false;
        DialogClass().showLoadingDialog(context: context, isLoading: false);
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong",
        );
        setState(() {
           isLoading = false;
        });
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppbarClass().buildSubScreenAppBar(context, "Self Ads"),
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Buttons().submitButton(
            buttonText: "Upload Self Ad",
            onPressed: () {
              ScreenRouter.addScreen(context, UploadSelfAdvertisement(
                user: widget.user, display:widget.display, business_type_id: widget.business_type_id,));
            },
            isLoading: false,
          ),
          const SizedBox(height: 20), // Add spacing for better UI
          
          Expanded( // This takes remaining space
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loader
                : self_ads.isEmpty
                    ? Center(child: Section().buildEmptyState("NO Self Ads", Icons.hourglass_empty)) // Center empty state
                    : ListView.builder(
                        itemCount: self_ads.length,
                        itemBuilder: (context, index) {
                          return buildUploadCard(context, self_ads[index]);
                        },
                      ),
          ),
        ],
      ),
    ),
  );
}


  Widget buildUploadCard(BuildContext context, dynamic ad) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                returnRow("Ad ID", ad['ads_id'].toString(), Icons.ad_units, Colors.blue, isBold: true),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    ad['ad_status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ad['ad_status'] == "On Review"
                          ? Colors.orange
                          : ad['ad_status'] == "Approved" || ad['ad_status'] == "Published"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
             returnRow("Ad Campaign", ad['ad_campaign_name'], Icons.campaign, Colors.pinkAccent),
             SizedBox(height: 8),
            returnRow("Ad Type", ad['ad_type'], Icons.category, Colors.purple),
            SizedBox(height: 6),
            returnRow("Ad Goal", ad['ad_goal'], Icons.flag, Colors.teal),
            SizedBox(height: 12),
            returnRow("Start", ad['start_date'].substring(0, 10), Icons.calendar_today, Colors.green),
            SizedBox(height: 6),
            returnRow("End", ad['end_date'].substring(0, 10), Icons.calendar_today_outlined, Colors.red),
            SizedBox(height: 6),
            returnRow("Business", ad['business_type_name'], Icons.business_center, Colors.orange),
          ],
        ),
      ),
    );
  }

   Widget returnRow(String label, String value, IconData icon, Color iconColor, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 8),
        Text(
          "$label: $value",
          style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
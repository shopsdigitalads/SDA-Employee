import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Ads/View%20Advertisement/view_advertisement.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';

class AdvertisementWidget {
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
            SizedBox(height: 16),
            
            // View Ad Button
            Center(
              child: Buttons().updateButton
              (
                buttonText: "View Ad",
                onPressed: () {
                  ScreenRouter.addScreen(context, AdDetailsScreen(adData: ad));
                },)
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMakeCard(BuildContext context, dynamic ad) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                returnRow("Ad ID", ad['make_ad_id'].toString(), Icons.ad_units, Colors.blue),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ad['make_ad_status'] == "On Review" || ad['make_ad_status'] == "Expire"
                        ? Colors.yellow[100]
                        : ad['make_ad_status'] == "Rejected"
                            ? Colors.red[100]
                            : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ad['make_ad_status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ad['make_ad_status'] == "On Review"
                          ? Colors.orange
                          : ad['make_ad_status'] == "Approved"
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
            returnRow("Ad Type", ad['make_ad_type'], Icons.category, Colors.purple),
            SizedBox(height: 6),
            returnRow("Ad Goal", ad['make_ad_goal'], Icons.flag, Colors.teal),
            SizedBox(height: 12),
            returnRow("Budget", ad['budget'].toString(), Icons.money, Colors.green),
            SizedBox(height: 6),
            returnRow("Business", ad['business_type_name'], Icons.business_center, Colors.orange),
            SizedBox(height: 16),
            
            Center(
              child: Buttons().updateButton(
                buttonText: "View Ad",
                onPressed: (){})
            ),
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

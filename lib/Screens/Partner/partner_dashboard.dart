import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Business/update_business.dart';
import 'package:sdaemployee/Screens/Display/display_history.dart';
import 'package:sdaemployee/Screens/Display/register_display.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';

class PartnerDashboard {
  Map<String, dynamic> user;
  Map<String, dynamic> businesses;
  PartnerDashboard({required this.user, required this.businesses});
  Widget partnerDashboard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              "${user['first_name']}'s! 👋 dashboard.",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Earnings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEarningCard(
                  screenWidth,
                  screenHeight,
                  title: "Today's Income",
                  amount: "00",
                  color: Colors.orangeAccent,
                ),
                _buildEarningCard(
                  screenWidth,
                  screenHeight,
                  title: "Monthly Income",
                  amount: "00",
                  color: Colors.blueAccent,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // Business List Section
            Text(
              "Businesses",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            ...businesses.entries.map((entry) {
              return _buildBusinessCard(context, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningCard(double screenWidth, double screenHeight,
      {required String title, required String amount, required Color color}) {
    return Container(
      height: screenHeight * 0.15,
      width: screenWidth * 0.42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(
      BuildContext context, Map<String, dynamic> business) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Business Name, Type, and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business['client_business_name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Type: ${business['business_type_name']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                // Status on the right
                Text(
                  business['client_business_status'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: business['client_business_status'] == "On Review"
                        ? const Color.fromARGB(255, 230, 211, 42)
                        : business['client_business_status'] == "Approved"
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            if (business['displays'].isNotEmpty &&
                business['client_business_status'] == "Approved")
              Text(
                "Displays:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            SizedBox(height: 8),
            if (business['client_business_status'] == "Approved")
              ..._buildDisplayList(
                  business['client_business_name'],
                  business['client_business_id'],
                  business['displays'],
                  context),

            // Bottom Button (if status is false)
            if (business['client_business_status'] == "Rejected") ...[
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ScreenRouter.addScreen(
                      context,
                      BusinessUpdate(
                          user: user,
                          client_business_name:
                              business['client_business_name'],
                          client_business_id: business['client_business_id'],
                          business: business));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Text(
                  "Update Business",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ] else if (business['client_business_status'] == "Approved") ...[
              if (business['client_business_status'] == "Approved") ...[
                SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Buttons().actionButton(
                        title: "Upload Display",
                        color: Colors.blueAccent,
                        onPressed: () {
                          ScreenRouter.addScreen(
                            context,
                            RegisterDisplay(
                              user: user,
                              client_business_id:
                                  business['client_business_id'],
                              client_business_name:
                                  business['client_business_name'],
                              isUpdate: false,
                            ),
                          );
                        },
                      ),
                      (business['business_update'] == "Accepted")
                          ? Buttons().actionButton(
                              title: "Update",
                              color: Colors.blueAccent,
                              onPressed: () {
                                ScreenRouter.addScreen(
                                    context,
                                    BusinessUpdate(
                                        user: user,
                                        client_business_name:
                                            business['client_business_name'],
                                        client_business_id:
                                            business['client_business_id'],
                                        business: business));
                              },
                            )
                          : (business['business_update'] == "Rejected" ||
                                  business['business_update'] == '')
                              ? Buttons().actionButton(
                                  title: "Request Update",
                                  color: Colors.purpleAccent,
                                  onPressed: () async {
                                    await DialogClass().showFullScreenDialog(
                                      context: context,
                                      module: "Business",
                                      id: business['client_business_id'],
                                    );
                                  })
                              : Text(
                                  "Update Request: \nSubmitted",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple),
                                ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

   List<Widget> _buildDisplayList(String client_business_name,
      int client_business_id, List<dynamic> displays, BuildContext context) {
    return displays.map((display) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Display ID: ${display['display_id']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Type: ${display['display_type']}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Status Indicator
            Text(
              "Status: ${display['display_status']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: display['display_status'] == "Active" ||
                        display['display_status'] == "Approved"
                    ? Colors.green
                    : display['display_status'] == "On Review"
                        ? const Color.fromARGB(255, 230, 211, 42)
                        : Colors.red,
              ),
            ),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Buttons().actionButton(
                  icon: Icons.history,
                  title: "History",
                  color: Colors.orangeAccent,
                  onPressed: () {
                    ScreenRouter.addScreen(
                        context,
                        DisplayHistory(
                          display_id: display['display_id'],
                        ));
                  },
                ),
                (display['display_update'] == "Accepted")
                    ? Buttons().actionButton(
                        icon: Icons.refresh,
                        title: "Update",
                        color: Colors.green,
                        onPressed: () {
                          ScreenRouter.addScreen(
                              context,
                              RegisterDisplay(
                                user: user,
                                isUpdate: true,
                                client_business_id: client_business_id,
                                client_business_name: client_business_name,
                                display_id: display['display_id'],
                              ));
                        },
                      )
                    : (display['display_update'] == "Submitted")
                        ? Text(
                            "Update Request: \nSubmitted",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ):  Buttons().actionButton(
                            icon: Icons.request_page,
                            title: "Request Update",
                            color: Colors.purpleAccent,
                            onPressed: () async {
                              await DialogClass().showFullScreenDialog(
                                  context: context,
                                  module: "Display",
                                  id: display['display_id']);
                            })
                        
              ],
            ),

            // Display Action Button (only if inactive)
            if (display['display_status'] == "Rejected" ||
                display['display_status'] == "Inactive") ...[
              ElevatedButton(
                onPressed: () {
                  print("Update Display ${display['displayId']} clicked!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                child: Text(
                  "Update Display",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }
}

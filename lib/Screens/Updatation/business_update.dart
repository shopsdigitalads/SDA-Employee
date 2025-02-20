import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Business/update_business.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';

// ignore: must_be_immutable
class BusinessUpdateRequest extends StatefulWidget {
    Map<String, dynamic> user;
   BusinessUpdateRequest({required this.user, super.key});

  @override
  State<BusinessUpdateRequest> createState() => _BusinessUpdateRequestState();
}

class _BusinessUpdateRequestState extends State<BusinessUpdateRequest> {
  List<dynamic> BusinessUpdateRequest = [];

  void fetchBusinessUpdateRequest() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res = await BusinessApi().fetchBusinessUpdateRequest(widget.user['user_id']);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        setState(() {
          BusinessUpdateRequest = res['business'];
        });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Display",
          message: res['message'],
        );
      }
    } catch (e) {
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something went wrong",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBusinessUpdateRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarClass().buildSubScreenAppBar(context, "Business Update Requests"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: BusinessUpdateRequest.isEmpty
            ? Center(
                child: Text(
                  "No update requests available",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              )
            : ListView.builder(
                itemCount: BusinessUpdateRequest.length,
                itemBuilder: (context, index) {
                  return _buildBusinessCard(context, BusinessUpdateRequest[index]);
                },
              ),
      ),
    );
  }

  Widget _buildBusinessCard(
      BuildContext context,dynamic business) {
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


            // Bottom Button (if status is false)
            if (business['client_business_status'] == "Rejected") ...[
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ScreenRouter.addScreen(
                      context,
                      BusinessUpdate(
                        user: widget.user,
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
                      (business['update_request'] == "Accepted")
                          ? Buttons().actionButton(
                              title: "Update",
                              color: Colors.blueAccent,
                              onPressed: () {
                                ScreenRouter.addScreen(
                                    context,
                                    BusinessUpdate(
                                      user: widget.user,
                                        client_business_name:
                                            business['client_business_name'],
                                        client_business_id:
                                            business['client_business_id'],
                                        business: business));
                              },
                            )
                          : (business['update_request'] == "Submitted")
                              ? Text(
                                  "Update Request: \nSubmitted",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple),
                                )
                              : Buttons().actionButton(
                                  title: "Request Update",
                                  color: Colors.purpleAccent,
                                  onPressed: () async {
                                    await DialogClass().showFullScreenDialog(
                                      context: context,
                                      module: "Business",
                                      id: business['client_business_id'],
                                    );
                                  })
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

}

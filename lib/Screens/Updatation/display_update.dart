import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Display/register_display.dart';
import 'package:sdaemployee/Services/API/Display/display_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';


// ignore: must_be_immutable
class DisplayUpdate extends StatefulWidget {
    Map<String, dynamic> user;
   DisplayUpdate({required this.user, super.key});

  @override
  State<DisplayUpdate> createState() => _DisplayUpdateState();
}

class _DisplayUpdateState extends State<DisplayUpdate> {
  List<dynamic> displayUpdateRequest = [];

  void fetchDisplayUpdateRequest() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res = await DisplayApi().fetchDisplayUpdateRequest(widget.user['user_id']);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        setState(() {
          displayUpdateRequest = res['display'];
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
      fetchDisplayUpdateRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarClass().buildSubScreenAppBar(context, "Display Update Requests"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: displayUpdateRequest.isEmpty
            ? Center(
                child: Text(
                  "No update requests available",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              )
            : ListView.builder(
                itemCount: displayUpdateRequest.length,
                itemBuilder: (context, index) {
                  return _buildDisplayList(context, displayUpdateRequest[index]);
                },
              ),
      ),
    );
  }

  Widget _buildDisplayList(BuildContext context, dynamic display) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_display, color: Colors.blueAccent, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Display ID: ${display['display_id']}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "Business: ${display['client_business_name']}",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 8),

            // Status Chip
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.grey),
                SizedBox(width: 5),
                Chip(
                  label: Text(
                    display['display_status'],
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(display['display_status']),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Action Buttons
            if (display['update_request'] == "Accepted")
              _buildActionButton(
                context,
                title: "Update Display",
                color: Colors.orangeAccent,
                icon: Icons.edit,
                onPressed: () {
                  ScreenRouter.addScreen(
                    context,
                    RegisterDisplay(
                      user: widget.user,
                      isUpdate: true,
                      client_business_id: display['client_business_id'],
                      client_business_name: display['client_business_name'],
                      display_id: display['display_id'],
                    ),
                  );
                },
              )
            else if (display['update_request'] == "Submitted")
              Center(
                child: Text(
                  "Update Request Submitted",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              )
            else
              _buildActionButton(
                context,
                title: "Request Update",
                color: Colors.purpleAccent,
                icon: Icons.request_page,
                onPressed: () async {
                  await DialogClass().showFullScreenDialog(
                    context: context,
                    module: "Display",
                    id: display['display_id'],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String title, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Active":
      case "Approved":
        return Colors.green;
      case "On Review":
        return Color.fromARGB(255, 230, 211, 42);
      default:
        return Colors.red;
    }
  }
}

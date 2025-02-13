import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Screens/Leads/create_lead.dart';
import 'package:sdaemployee/Services/API/Leads/leads_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/State/app_state.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: must_be_immutable
class Leads extends StatefulWidget {
   Leads({
    super.key});

  @override
  State<Leads> createState() => _LeadsState();
}

class _LeadsState extends State<Leads>
    with SingleTickerProviderStateMixin {
    List<dynamic> ads = [];
  List<dynamic> display = [];
  bool isLoading = false;
  late TabController _tabController;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLeads();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _tabController.dispose();
    super.dispose();
  }

  void fetchLeads() async {
    try {
      if (!_isMounted) return;

      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> res = await LeadApi().fetchLeads();

      if (_isMounted) {
        isLoading = false;
        if (res['status']) {
          display = res['display_leads'];
          ads = res['ads_leads'];
        } else {
          DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: res['message'],
          );
        }
        setState(() {});
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
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Advertisement"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading and Buttons
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leads Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAdActionButton(screenWidth,
                        title: "Display Lead",
                        color: Colors.orangeAccent, onPressed: () {
                      Provider.of<AppState>(context, listen: false)
                          .setIsAdUpload(false);
                      ScreenRouter.addScreen(context, CreateLead(lead_type: "Display"));
                    }),
                    _buildAdActionButton(screenWidth,
                        title: "Ad Lead",
                        color: Colors.blueAccent, onPressed: () {
                      ScreenRouter.addScreen(context, CreateLead(lead_type: "Ads"));
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Tabs Section (Fixed)
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: "Display Leads"),
              Tab(text: "Ads Ads"),
            ],
          ),

          !isLoading
              ? Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // First tab: Uploaded Ads
                      display.isNotEmpty
                          ?  _buildLeadsList(display)
                          : Section().buildEmptyState(
                              "No Display Ads", Icons.cloud_upload),

                      // Second tab: Make Ads
                      ads.isNotEmpty
                          ?  _buildLeadsList(ads)
                          : Section()
                              .buildEmptyState("No Ads List", Icons.add_box),
                    ],
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Section().buildShimmerList(50, 30, 5);
                    },
                  ),
                ),
        ],
      ),
    );
  }

    void _callLead(String mobile) async {
    final Uri callUri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Call Error",
        message: "Could not launch call",
      );
    }
  }


  Widget _buildAdActionButton(double screenWidth,
      {required String title,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: screenWidth * 0.1,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

 Widget _buildLeadsList(List<dynamic> leads) {
  return  ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: leads.length,
          itemBuilder: (context, index) {
            final lead = leads[index];
            bool isExpanded = false;

            return StatefulBuilder(
              builder: (context, setState) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      lead['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Org: ${lead['org_name']}"),
                        Text("Mobile: ${lead['mobile']}"),
                        Text("Email: ${lead['email']}"),
                        Text("Follow-up: ${lead['follow_up_date']}"),
                        SizedBox(height: 5),
                        Text(
                          "Remark:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lead['remark'],
                                maxLines: isExpanded ? null : 2,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black87),
                              ),
                              if (lead['remark'].length > 50)
                                Text(
                                  isExpanded ? "Show Less" : "Show More",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.phone, color: Colors.green),
                          onPressed: () => _callLead(lead['mobile']),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Navigate to update lead screen
                            // ScreenRouter.addScreen(context, CreateLead(leadData: lead));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
}

}
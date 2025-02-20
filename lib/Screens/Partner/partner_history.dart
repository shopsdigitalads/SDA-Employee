import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Display%20Owner/verify_mobile.dart';
import 'package:sdaemployee/Screens/Updatation/update_request.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Section.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sdaemployee/Screens/KYC/view_kyc.dart';
import 'package:sdaemployee/Screens/Ads/advertistment.dart';
import 'package:sdaemployee/Screens/Home/partner.dart';
import 'package:sdaemployee/Services/API/Partner/partner_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';

class PartnerHistory extends StatefulWidget {
  const PartnerHistory({super.key});

  @override
  State<PartnerHistory> createState() => _PartnerHistoryState();
}

class _PartnerHistoryState extends State<PartnerHistory> {
  List<dynamic> partners = [];
  bool isLoading = true;

  void fetchPartners() async {
    try {
      Map<String, dynamic> res = await PartnerApi().fetchClients();
      if (res['status']) {
        setState(() {
          partners = res['partners'];
        });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Business Types",
          message: res['message'],
        );
      }
    } catch (e) {
      print(e);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPartners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Partner History"),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: isLoading
                ?Section().buildShimmerList(50, 30, 5)
                : partners.isEmpty
                    ? Section()
                        .buildEmptyState("No Partner Found", Icons.delete)
                    : ListView.builder(
                        itemCount: partners.length,
                        itemBuilder: (context, index) {
                          return _buildPartnerCard(partners[index]);
                        },
                      ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Implement the navigation to add partner screen
                ScreenRouter.addScreen(context, VerifyDisplayOwnerMobile());
              },
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Partner",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  partner['first_name'][0],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "${partner['first_name']} ${partner['middle_name']} ${partner['last_name']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(partner['email']),
              trailing: SizedBox(
                width: 100, // Adjust width as needed
                child: Buttons().actionButton(title: "Update",color: Colors.green, onPressed: () {
                  ScreenRouter.addScreen(context, UpdateRequest(user: partner));
                }),
              ),
            ),
            _buildInfoRow("Mobile:", partner['mobile']),
            const Divider(),
            _buildActionButtons(partner),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> partner) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.remove_red_eye, "Display", Colors.blueAccent,
            () {
          ScreenRouter.addScreen(context, Partner(user: partner));
        }),
        _buildIconButton(Icons.ad_units, "View Ads", Colors.greenAccent, () {
          ScreenRouter.addScreen(context, Advertisement(user: partner));
        }),
        _buildIconButton(Icons.call, "Call", Colors.orange, () {
          _makePhoneCall(partner['mobile']);
        }),
        _buildIconButton(Icons.verified_user, "KYC", Colors.purple, () {
          ScreenRouter.addScreen(context, ViewKyc(user: partner));
        }),
      ],
    );
  }

  Widget _buildIconButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: color),
        ),
        Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }
}

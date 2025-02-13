import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Screens/Ads/Create%20%20Advertisement/create_advertisement.dart';
import 'package:sdaemployee/Screens/Ads/Upload%20Advertisement/advertisement_upload.dart';
import 'package:sdaemployee/Screens/Ads/View%20Advertisement/make_advertisement.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/State/app_state.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

// ignore: must_be_immutable
class Advertisement extends StatefulWidget {
  Map<String,dynamic> user;
   Advertisement({
    required this.user,
    super.key});

  @override
  State<Advertisement> createState() => _AdvertisementState();
}

class _AdvertisementState extends State<Advertisement>
    with SingleTickerProviderStateMixin {
    List<dynamic> make_ads = [];
  List<dynamic> upload_ads = [];
  bool isLoading = false;
  late TabController _tabController;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAdvertisement();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _tabController.dispose();
    super.dispose();
  }

  void fetchAdvertisement() async {
    try {
      if (!_isMounted) return;

      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> res = await AdvertisementApi().fetchAdsOfUser(widget.user);

      if (_isMounted) {
        isLoading = false;
        if (res['status']) {
          upload_ads = res['upload_ads'];
          make_ads = res['make_ads'];
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
                  "Advertisement Dashboard",
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
                        title: "Upload Ad",
                        color: Colors.orangeAccent, onPressed: () {
                      Provider.of<AppState>(context, listen: false)
                          .setIsAdUpload(false);
                      ScreenRouter.addScreen(context, UploadAdvertisement(user: widget.user,));
                    }),
                    _buildAdActionButton(screenWidth,
                        title: "Make Ad",
                        color: Colors.blueAccent, onPressed: () {
                      ScreenRouter.addScreen(context, CreateAdvertisement(user: widget.user,));
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
              Tab(text: "Uploaded Ads"),
              Tab(text: "Make Ads"),
            ],
          ),

          !isLoading
              ? Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // First tab: Uploaded Ads
                      upload_ads.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05),
                              itemCount: upload_ads.length,
                              itemBuilder: (context, index) {
                                return AdvertisementWidget().buildUploadCard(
                                    context, upload_ads[index]);
                              },
                            )
                          : Section().buildEmptyState(
                              "No Uploaded Ads", Icons.cloud_upload),

                      // Second tab: Make Ads
                      make_ads.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05),
                              itemCount: make_ads.length,
                              itemBuilder: (context, index) {
                                return AdvertisementWidget()
                                    .buildMakeCard(context, make_ads[index]);
                              },
                            )
                          : Section()
                              .buildEmptyState("No Make Ads", Icons.add_box),
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
}

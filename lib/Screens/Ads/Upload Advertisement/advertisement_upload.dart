import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Screens/Ads/Upload%20Advertisement/advertisement_location.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/State/app_state.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/Upload/video_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class UploadAdvertisement extends StatefulWidget {
  Map<String,dynamic> user;
  UploadAdvertisement({required this.user, super.key});

  @override
  State<UploadAdvertisement> createState() => _UploadAdvertisementState();
}

class _UploadAdvertisementState extends State<UploadAdvertisement> {
  List<dynamic> businessTypes = [];
  late int ad_id;
  String? selectedBusinessId;
  String? selectedAdType;
  String? selectedAdGoal;
  bool isBusinessTypesFetched = false;
  bool _isLoading = false;

  TextEditingController make_ad_description = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController camp_name = TextEditingController();

  List<dynamic> ad_type = [
    {"ad_type": "IMAGE"},
    {"ad_type": "VIDEO"}
  ];

  List<dynamic> ad_goal = [
    {"ad_goal": "Brand awareness"},
    {"ad_goal": "Lead generation"},
    {"ad_goal": "Sales conversions"},
    {"ad_goal": "Event promotion"},
    {"ad_goal": "Product/service launch"}
  ];

  File? uploadedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBusinessTypes();
    });
  }

  void fetchBusinessTypes() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res = await BusinessApi().fetchBusinessTypes();
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        businessTypes = res['business_type'];
        setState(() {});
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Business Types",
          message: res['message'],
        );
      }
    } catch (e) {
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    }
  }

  void submitAdvertisement() async {
    if (Validation().isEmpty(camp_name.text)) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Advertisement",
        message: "Enter Campaign Name",
      );
      return;
    } else if (Validation().isEmpty(selectedBusinessId)) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Advertisement",
        message: "Select Business Type",
      );
      return;
    } else if (selectedAdType == null || uploadedFile == null) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Advertisement",
        message: "Please select media type and upload the file.",
      );
      return;
    } else if (Validation().isEmpty(selectedAdGoal)) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Advertisement",
        message: "Please select Ad Goal.",
      );
      return;
    }

    DateTime? startDate = startDateController.text.isNotEmpty
        ? DateTime.parse(startDateController.text)
        : null;
    DateTime? endDate = endDateController.text.isNotEmpty
        ? DateTime.parse(endDateController.text)
        : null;
    if (startDate == null) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Advertisement",
        message: "Please select a start date.",
      );
      return;
    } else if (endDate == null) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Advertisement",
        message: "Please select an end date.",
      );
      return;
    } 

    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> advertisement = await AdvertisementApi()
          .submitUploadAd(
            widget.user,
              camp_name.text.trim(),
              selectedAdType!,
              make_ad_description.text.trim(),
              selectedAdGoal!,
              selectedBusinessId!,
              startDateController.text,
              endDateController.text,
              uploadedFile!);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (advertisement['status']) {
         User user1 = await SharePrefs().getUser();
            user1.ads_count = user1.ads_count+1;
            await SharePrefs().storeUser(user1);
        final res = advertisement['response'];
        Provider.of<AppState>(context, listen: false).setIsAdUpload(true);
        ad_id = res['ads_id'];
        ScreenRouter.addScreen(
            context,
            AdvertisementLocation(
                ad_id: res['ads_id'],
                business_type_id: int.parse(selectedBusinessId!)),slide: true);
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something went wrong!",
        );
      }
    } catch (e) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something went wrong!",
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool ad_uploaded = Provider.of<AppState>(context).getAdUpload();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppbarClass().buildSubScreenAppBar(context, "Upload Advertisement"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Upload Advertisement',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Inputfield().textFieldInput(
                context: context,
                controller: camp_name,
                labelText: "Campaign Name",
                hintText: "Campaign Name",
                prefixIcon: Icons.location_city,
                keyboardType: TextInputType.text),
            const SizedBox(height: 20),
            Inputfield().buildDropdownField(
              context: context,
              selectedValue: selectedAdType,
              items: ad_type,
              value: "ad_type",
              name: "ad_type",
              labelText: "Advertisement Media Type",
              onChanged: (value) {
                setState(() {
                  selectedAdType = value;
                  uploadedFile = null; // Reset the file on type change
                });
              },
            ),
            const SizedBox(height: 15),
            if (businessTypes.isNotEmpty)
              Inputfield().buildDropdownField(
                context: context,
                selectedValue: selectedBusinessId,
                items: businessTypes,
                labelText: "Business Type",
                onChanged: (value) {
                  setState(() {
                    selectedBusinessId = value;
                  });
                },
                value: "business_type_id",
                name: "business_type_name",
              ),
            const SizedBox(height: 15),
            Inputfield().buildDropdownField(
              context: context,
              selectedValue: selectedAdGoal,
              items: ad_goal,
              value: "ad_goal",
              name: "ad_goal",
              labelText: "Advertisement Goal",
              onChanged: (value) {
                setState(() {
                  selectedAdGoal = value;
                });
              },
            ),
            const SizedBox(height: 15),
            Inputfield().textFieldInput(
              context: context,
              controller: make_ad_description,
              labelText: "Ad Description(Optional)",
              hintText: "Ad Description",
              prefixIcon: Icons.description,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Inputfield().datePickerInput(
                    context: context,
                    controller: startDateController,
                    labelText: "Start Date",
                    hintText: "yyyy-mm-dd",
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
                SizedBox(width: 16), // Spacing
                Expanded(
                  child: Inputfield().datePickerInput(
                    context: context,
                    controller: endDateController,
                    labelText: "End Date",
                    hintText: "yyyy-mm-dd",
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (selectedAdType == "IMAGE")
               ImageUpload(
                labelText: "Select an Image",
                onImagePicked: (File? image) {
                  setState(() {
                    uploadedFile = image;
                  });
                },
              ),
            if (selectedAdType == "VIDEO")
              VideoUpload().videoPickerField(
                context: context,
                labelText: "Upload Video",
                onVideoPicked: (file) {
                  setState(() {
                    uploadedFile = file;
                  });
                },
                selectedVideo: uploadedFile,
              ),
            const SizedBox(height: 15),
            Buttons().submitButton(
              buttonText: ad_uploaded ? "Next ->" : "Submit",
              onPressed: ad_uploaded
                  ? () {
                      ScreenRouter.addScreen(
                          context,
                          AdvertisementLocation(
                              ad_id: ad_id,
                              business_type_id:
                                  int.parse(selectedBusinessId!)),slide: true);
                    }
                  : submitAdvertisement,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

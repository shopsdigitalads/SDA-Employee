import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/Upload/video_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';
// ignore: must_be_immutable
class UploadSelfAdvertisement extends StatefulWidget {
  String business_type_id;
  List<int> display;
  Map<String,dynamic> user;
  UploadSelfAdvertisement(
      {required this.user, required this.display, required this.business_type_id, super.key});

  @override
  State<UploadSelfAdvertisement> createState() =>
      _UploadSelfAdvertisementState();
}

class _UploadSelfAdvertisementState extends State<UploadSelfAdvertisement> {
  List<dynamic> businessTypes = [];
  late int ad_id;
  String? selectedAdType;
  String? selectedAdGoal;

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
              widget.business_type_id,
              startDateController.text,
              endDateController.text,
              uploadedFile!,
              "1");
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      print("Advertisemetn : $advertisement");
      if (advertisement['status']) {
        final res = advertisement['response'];
        int ad_id = res['ads_id'];
        Map<String, dynamic> displayads = await AdvertisementApi()
            .submitDisplay(widget.display, ad_id);
        if (displayads["status"]) {
          DialogClass().showCustomDialog(
              context: context,
              icon: Icons.done,
              title: "Self Ad",
              message: "Ad Uploaded Succesfully!",
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
        }
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something went wrong!",
        );
      }
    } catch (e) {
      print((e));
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something went wrong!",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          AppbarClass().buildSubScreenAppBar(context, "Upload Advertisement"),
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
              maxLines: 5
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
              VideoUpload(
                labelText: "Upload Video",
                onVideoPicked: (File? video) {
                  setState(() {
                    uploadedFile = video;
                  });
                },
              ),
            const SizedBox(height: 15),
            Buttons().submitButton(
                buttonText: "Submit",
                onPressed: submitAdvertisement,
                isLoading: false),
          ],
        ),
      ),
    );
  }
}

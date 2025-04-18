import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/State/app_state.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/Upload/video_upload.dart';
import 'dart:io';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';


// ignore: must_be_immutable
class UpdateAdvertistment extends StatefulWidget {
  dynamic ad;
  UpdateAdvertistment({required this.ad, super.key});

  @override
  State<UpdateAdvertistment> createState() => _UpdateAdvertistmentState();
}

class _UpdateAdvertistmentState extends State<UpdateAdvertistment> {
  List<dynamic> businessTypes = [];
  String? selectedBusinessId;
  String? selectedAdType;
  bool isBusinessTypesFetched = false;
  bool _isLoading = false;

  List<dynamic> ad_type = [
    {"ad_type": "IMAGE"},
    {"ad_type": "VIDEO"}
  ];

  File? uploadedFile;

  @override
  void initState() {
     super.initState();
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

  void submitAdvertistment() async {
    if (selectedAdType == null || uploadedFile == null) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Please select media type and upload the file.",
      );
      return;
    }
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      String add_action = widget.ad['ad_status'] == "Published"? "New Add" :"Update";
      print(add_action);
      Map<String, dynamic> advertisement = await AdvertisementApi().updateUploadAd(
              selectedAdType!, 
              widget.ad, 
              add_action, 
              uploadedFile!);
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      if (advertisement['status']) {
        final res = advertisement['response'];
        print(res);
        Provider.of<AppState>(context, listen: false).setIsAdUpload(true);
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "Advertisement",
            message: res['message'],
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something went wrong!",
        );
      }
    } catch (e) {
      print(e);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          AppbarClass().buildSubScreenAppBar(context, "Update Advertistment"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Update Advertisement',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
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
            // if (businessTypes.isNotEmpty)
            //   Inputfield().buildDropdownField(
            //     context: context,
            //     selectedValue: selectedBusinessId,
            //     items: businessTypes,
            //     labelText: "Business Type",
            //     onChanged: (value) {
            //       setState(() {
            //         selectedBusinessId = value;
            //       });
            //     },
            //     value: "business_type_id",
            //     name: "business_type_name",
            //   ),

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
              onPressed: submitAdvertistment,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

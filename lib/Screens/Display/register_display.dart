import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Display/display_api.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/Upload/video_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class RegisterDisplay extends StatefulWidget {
  Map<String, dynamic> user;
  String client_business_name;
  int client_business_id;
  bool isUpdate;
  int? display_id;
  RegisterDisplay(
      {required this.user,
      required this.isUpdate,
      required this.client_business_id,
      required this.client_business_name,
      this.display_id,
      super.key});

  @override
  State<RegisterDisplay> createState() => _RegisterDisplayState();
}

class _RegisterDisplayState extends State<RegisterDisplay> {
  List<dynamic> displayTypes = [];
  String? selectedDisplayId;
  bool isBusinessTypesFetched = false;

  File? displayImage;
  File? displayVideo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDisplayTypes();
    });
  }

  void submitDisplay() async {
    try {
      if (Validation().isEmpty(selectedDisplayId)) {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Display",
          message: "Select Display Type",
        );
        return;
      } else if (displayImage == null || displayVideo == null) {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Display",
          message: "Upload Image and Video",
        );
        return;
      }
      // Show the loading dialog
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      String display_type = "";
      displayTypes.forEach((display) {
        if (display['display_type_id'].toString() == selectedDisplayId) {
          display_type = display['display_type'];
        }
      });
      Map<String, dynamic> display;
      if (widget.isUpdate) {
        display = await DisplayApi().updateDisplay(
          widget.user,
            widget.client_business_name,
            widget.client_business_id.toString(),
            widget.display_id!.toString(),
            selectedDisplayId!,
            display_type,
            displayImage!,
            displayVideo!);
      } else {
        display = await DisplayApi().uploadDisplay(
            widget.user,
            widget.client_business_name,
            widget.client_business_id.toString(),
            selectedDisplayId!,
            display_type,
            displayImage!,
            displayVideo!);
      }

      DialogClass().showLoadingDialog(context: context, isLoading: false);

      // Show the success dialog if the API response is successful
      if (display['status']) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "Display",
            message: display['message'],
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error Occurred",
          message: "Something Went Wrong",
        );
      }
    } catch (e) {
      // Close the loading dialog and show error dialog
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong!",
      );
    }
  }

  void fetchDisplayTypes() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res = await DisplayApi().fetchDisplayTypes();
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        displayTypes = res['display_type'];
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
      print(e);
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, 'Display'),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 35,
            right: 35,
          ),
          child: Column(
            children: [
              SizedBox(height: 10.0),
              Text(
                '${widget.isUpdate ? "Update" : "Register"} Display',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 20.0),
              SizedBox(height: 10.0),
              if (displayTypes.isNotEmpty)
                Inputfield().buildDropdownField(
                  context: context,
                  selectedValue: selectedDisplayId,
                  items: displayTypes,
                  labelText: "Display Type",
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      selectedDisplayId = value;
                    });
                  },
                  value: "display_type_id",
                  name: "display_type",
                ),
              SizedBox(height: 15.0),
              ImageUpload(
                labelText: "Display Image",
                onImagePicked: (image) {
                  setState(() {
                    displayImage = image;
                  });
                },
              ),
              SizedBox(height: 15.0),
              VideoUpload(
                labelText: "Upload Video",
                selectedVideo: displayVideo, 
                onVideoPicked: (video) {
                  setState(() {
                    displayVideo =
                        video; 
                  });
                },
              ),
              SizedBox(height: 15.0),
              Buttons()
                  .submitButton(onPressed: submitDisplay, isLoading: _isLoading)
            ],
          ),
        ),
      ),
    );
  }
}

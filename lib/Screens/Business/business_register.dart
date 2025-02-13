import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Business/business_address.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';


// ignore: must_be_immutable
class BusinessRegister extends StatefulWidget {
  Map<String,dynamic> user;
  BusinessRegister({required this.user, super.key});

  @override
  State<BusinessRegister> createState() => _BusinessRegisterState();
}

class _BusinessRegisterState extends State<BusinessRegister> {
  final TextEditingController _clientBusinessName = TextEditingController();

  List<dynamic> businessTypes = [];
  String? selectedBusinessId;
  bool isBusinessTypesFetched = false;

  File? interiorImage;
  File? exteriorImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBusinessTypes();
    });
  }

  void submitBusiness() async {
    if (Validation().isEmpty(_clientBusinessName.text)) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Business",
        message: "Enter Valid Business Name",
      );
      return;
    } else if (Validation().isEmpty(selectedBusinessId)) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Business",
        message: "Select Valid Business Type",
      );
      return;
    } else if (interiorImage == null || exteriorImage == null) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Business",
        message: "Upload Images",
      );
      return;
    }
    ScreenRouter.addScreen(
        context,
        BusinessAddress(
          user : widget.user,
            client_business_name: _clientBusinessName.text.trim(),
            business_type_id: selectedBusinessId!,
            exteriorImage: exteriorImage!,
            interiorImage: interiorImage!));
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
      appBar: AppbarClass().buildSubScreenAppBar(context, 'Business'),
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
                'Register Business',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 20.0),
              Inputfield().textFieldInput(
                context: context,
                controller: _clientBusinessName,
                labelText: "Business Name",
                hintText: "Business Name",
                prefixIcon: Icons.business,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 10.0),
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
              SizedBox(height: 15.0),
              ImageUpload(
                labelText: "Select an Image",
                onImagePicked: (File? image) {
                  setState(() {
                    interiorImage = image;
                  });
                },
              ),
              SizedBox(height: 15.0),
              ImageUpload(
                labelText: "Exterior Image",
                onImagePicked: (image) {
                  setState(() {
                    exteriorImage = image;
                  });
                },
              ),
              SizedBox(height: 15.0),
              Buttons().submitButton(
                  buttonText: "Next ->",
                  onPressed: submitBusiness,
                  isLoading: _isLoading)
            ],
          ),
        ),
      ),
    );
  }
}

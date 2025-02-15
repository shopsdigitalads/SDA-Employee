import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Setup/address.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class BusinessUpdate extends StatefulWidget {
  Map<String, dynamic> user;
  String client_business_name;
  int client_business_id;
  Map<String, dynamic> business;

  BusinessUpdate(
      {required this.user,
      required this.client_business_name,
      required this.client_business_id,
      required this.business,
      super.key});

  @override
  State<BusinessUpdate> createState() => _BusinessUpdateState();
}

class _BusinessUpdateState extends State<BusinessUpdate> {
  TextEditingController _clientBusinessName = TextEditingController();

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
    _clientBusinessName =
        TextEditingController(text: widget.client_business_name);
  }

  void submitBusiness() async {
    try {
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
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> business = await BusinessApi().updateBusiness(
          widget.user,
          _clientBusinessName.text.trim(),
          widget.client_business_id.toString(),
          selectedBusinessId!,
          interiorImage!,
          exteriorImage!);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (business['status']) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "Business",
            message: business['message'],
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
      } else {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Error Occured",
            message: "Something Went Wrong");
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Business",
          message: "Something Went Wrong!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                'Update Business',
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
                labelText: "Interior Image",
                onImagePicked: (image) {
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
                  buttonText: "Update",
                  onPressed: submitBusiness,
                  isLoading: _isLoading),
              SizedBox(height: 10.0),
              Buttons().submitButton(
                  buttonText: "Click to Update Address",
                  onPressed: () {
                    ScreenRouter.addScreen(context, Address(user_id: widget.user['user_id'].toString(), isUpdate: true,pin_code: widget.business['pin_code'],landmark: widget.business['landmark'], address_line: widget.business['address_line'], area: widget.business['area'],cluster: widget.business['cluster'],district: widget.business['district'],state: widget.business['state'],address_id: widget.business['address_id'],isBusiness: true,));
                  },
                  isLoading: false)
            ],
          ),
        ),
      ),
    );
  }
}

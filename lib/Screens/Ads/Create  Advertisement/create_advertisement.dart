import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class CreateAdvertisement extends StatefulWidget {
  Map<String,dynamic> user;
  CreateAdvertisement({required this.user, super.key});

  @override
  State<CreateAdvertisement> createState() => _CreateAdvertisementState();
}

class _CreateAdvertisementState extends State<CreateAdvertisement> {
  TextEditingController make_ad_type = TextEditingController();
  TextEditingController make_ad_description = TextEditingController();
  TextEditingController make_ad_goal = TextEditingController();
  TextEditingController budget = TextEditingController();
  TextEditingController camp_name = TextEditingController();

  List<dynamic> businessTypes = [];
  String? selectedBusinessId;
  bool isBusinessTypesFetched = false;
  bool _isLoading = false;

  List<dynamic> ad_type = [
    {"ad_type": "IMAGE"},
    {"ad_type": "VEDIO"}
  ];
  String? selectedAdType;

  List<dynamic> ad_goal = [
    {"ad_goal": "Brand awareness"},
    {"ad_goal": "Lead generation"},
    {"ad_goal": "Sales conversions"},
    {"ad_goal": "Event promotion"},
    {"ad_goal": "Product/service launch"}
  ];
  String? selectedAdGoal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBusinessTypes();
    });
  }

  void submitAdvertisement() async {
    try {
      if (Validation().isEmpty(camp_name.text)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: "Enter Campaign Name");
        return;
      } else if (Validation().isEmpty(selectedAdType)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: "Select Ad Type");
        return;
      } else if (Validation().isEmpty(selectedBusinessId)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: "Select Business Type");
        return;
      } else if (Validation().isEmpty(selectedAdGoal)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: "Select Ad Goal");
        return;
      }else if(Validation().isEmpty(budget.text)){
         DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement",
            message: "Enter Budget");
            return ;
      }

      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> advertisement = await AdvertisementApi()
          .submitCreateAd(
              widget.user,
              camp_name.text.trim(),
              selectedAdType!,
              selectedBusinessId!,
              selectedAdGoal!,
              make_ad_description.text,
              int.parse(budget.text));
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (advertisement['status']) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "Advertisement",
            message: advertisement['message'],
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
          title: "Advertisement",
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Make Advertisement"),
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
                'Request Advertisement',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
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
              SizedBox(height: 20.0),
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
                  });
                },
              ),
              SizedBox(height: 15.0),
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
              SizedBox(height: 15.0),
              Inputfield().textFieldInput(
                  context: context,
                  controller: make_ad_description,
                  labelText: "Ad Description(Optional)",
                  hintText: "Ad Description",
                  prefixIcon: Icons.description,
                  keyboardType: TextInputType.text),
              SizedBox(height: 15.0),
              Inputfield().textFieldInput(
                  context: context,
                  controller: budget,
                  labelText: "Ad Budget",
                  hintText: "Ad Budget",
                  prefixIcon: Icons.money,
                  keyboardType: TextInputType.number),
              SizedBox(height: 15.0),
              Buttons().submitButton(
                  onPressed: submitAdvertisement, isLoading: _isLoading)
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Leads/leads_api.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class CreateLead extends StatefulWidget {
 String lead_type;
  CreateLead({required this.lead_type, super.key});

  @override
  State<CreateLead> createState() => _CreateLeadState();
}

class _CreateLeadState extends State<CreateLead> {
  TextEditingController name = TextEditingController();
  TextEditingController orgnization_name = TextEditingController();
  TextEditingController mobile_no = TextEditingController();
  TextEditingController email = TextEditingController();
    TextEditingController contact_date = TextEditingController();
  TextEditingController follow_up_date = TextEditingController();
    TextEditingController remark = TextEditingController();

  File? selected_img;




  @override
  void initState() {
    super.initState();
  }

  void submitLead() async {
    try {
      if (Validation().isEmpty(name.text) || Validation().isEmpty(contact_date.text.trim()) || Validation().isEmpty(follow_up_date.text) || Validation().isEmpty(orgnization_name.text)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Leads",
            message: "Enter All Requird Fields");
        return;
      } else if (!Validation().validateMobile(mobile_no.text.trim())) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Leads",
            message: "Enter Valid Mobile");
        return;
      }
      // else if (!Validation().validateEmail(email.text.trim())) {
      //   DialogClass().showCustomDialog(
      //       context: context,
      //       icon: Icons.error,
      //       title: "Leads",
      //       message: "Enter Valid Email");
      //   return;
      // } 

      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> lead = await LeadApi()
          .submitLead(
              name.text.trim(),
              orgnization_name.text.trim(),
              email.text.trim(),
              mobile_no.text.trim(),
              widget.lead_type,
              contact_date.text.trim(),
              follow_up_date.text.trim(),
          remark.text.trim(),
          selected_img);
      DialogClass().showLoadingDialog(context: context, isLoading: false);
    print(lead);
      if (lead['status']) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "lead",
            message: lead['message'],
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
          title: "lead",
          message: "Something Went Wrong!");
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Leads"),
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
                'Add Leads Data',
                textAlign: TextAlign.center,
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
                  controller: name,
                  labelText: "Lead Name",
                  hintText: "Lead Name",
                  prefixIcon: Icons.location_city,
                  keyboardType: TextInputType.text),
        
              SizedBox(height: 15.0),
              Inputfield().textFieldInput(
                  context: context,
                  controller: orgnization_name,
                  labelText: "Orgnization Name",
                  hintText: "Orgnization Name",
                  prefixIcon: Icons.description,
                  keyboardType: TextInputType.text),
              SizedBox(height: 15.0),
              Inputfield().textFieldInput(
                  context: context,
                  controller: email,
                  labelText: "Email",
                  hintText: "Email",
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.text),
                   SizedBox(height: 15.0),
                Inputfield().textFieldInput(
                  context: context,
                  controller: mobile_no,
                  labelText: "Mobile",
                  hintText: "Mobile",
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.number),
                   SizedBox(height: 15.0),
                  Inputfield().datePickerInput(
                    context: context,
                    controller: contact_date,
                    labelText: "Contact Date",
                    hintText: "yyyy-mm-dd",
                    prefixIcon: Icons.calendar_today,
                  ),
                   SizedBox(height: 15.0),
                  Inputfield().datePickerInput(
                    context: context,
                    controller: follow_up_date,
                    labelText: "Follow up Date",
                    hintText: "yyyy-mm-dd",
                    prefixIcon: Icons.calendar_month,
                  ),
                   SizedBox(height: 15.0),
                  ImageUpload(labelText: "Visiting card", onImagePicked: (image){
                    selected_img = image;
                  }),
              SizedBox(height: 15.0),
              TextField(
                  controller: remark,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your reason here...',
                  ),
                ),
                SizedBox(height: 15.0),
              Buttons().submitButton(
                  onPressed: submitLead, isLoading: false)
            ],
          ),
        ),
      ),
    );
  }
}

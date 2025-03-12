import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/KYC/kyc_api.dart';
import 'package:sdaemployee/Services/Upload/image_upload.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class KYC extends StatefulWidget {
  Map<String, dynamic> user;
  final String? adharCardNo;
  final String? panNo;
  final String? accHolderName;
  final String? accNo;
  final String? bankIfsc;
  final String? bankName;
  final String? bankBranchName;
  final File? adharFrontImg;
  final File? adharBackImg;
  final File? panImg;
  final File? bankProofImg;
   final File? profile;
  final bool isUpdate;

  KYC({
    super.key,
    required this.user,
    this.adharCardNo,
    this.panNo,
    this.accHolderName,
    this.accNo,
    this.bankIfsc,
    this.bankName,
    this.bankBranchName,
    this.adharFrontImg,
    this.adharBackImg,
    this.panImg,
    this.bankProofImg,
      this.profile,
    required this.isUpdate,
  });

  @override
  State<KYC> createState() => _KYCState();
}

class _KYCState extends State<KYC> {
  TextEditingController adhar_card_no = TextEditingController();
  TextEditingController pan_no = TextEditingController();
  TextEditingController acc_holder_name = TextEditingController();
  TextEditingController acc_no = TextEditingController();
  TextEditingController bank_ifsc = TextEditingController();
  TextEditingController bank_name = TextEditingController();
  TextEditingController bank_branch_name = TextEditingController();

  File? adhar_front_img, adhar_back_img, pan_img, bank_proof_img,profile;
  File? exteriorImage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    adhar_card_no = TextEditingController(text: widget.adharCardNo ?? '');
    pan_no = TextEditingController(text: widget.panNo ?? '');
    acc_holder_name = TextEditingController(text: widget.accHolderName ?? '');
    acc_no = TextEditingController(text: widget.accNo ?? '');
    bank_ifsc = TextEditingController(text: widget.bankIfsc ?? '');
    bank_name = TextEditingController(text: widget.bankName ?? '');
    bank_branch_name = TextEditingController(text: widget.bankBranchName ?? '');

    // Assign image files if provided
    adhar_front_img = widget.adharFrontImg;
    adhar_back_img = widget.adharBackImg;
    pan_img = widget.panImg;
    bank_proof_img = widget.bankProofImg;
     profile = widget.profile;
  }

  void submitKYC() async {
    try {
      if (!Validation().validateAadhaar(adhar_card_no.text)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "KYC",
            message: "Enter Valid Adhar No");
        return;
      } else if (!Validation().validatePAN(pan_no.text)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "KYC",
            message: "Enter Valid Pan No!");
        return;
      } else if (Validation().isEmpty(bank_branch_name.text) ||
          Validation().isEmpty(bank_name.text) ||
          Validation().isEmpty(bank_ifsc.text) ||
          Validation().isEmpty(acc_holder_name.text) ||
          Validation().isEmpty(acc_no.text)) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "KYC",
            message: "Enter Valid Bank Details!");
        return;
      }
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> kyc;
      if (widget.isUpdate) {
        kyc = await KycApi().updateKYC(
            widget.user,
            adhar_card_no.text.trim(),
            adhar_front_img!,
            adhar_back_img!,
            pan_no.text.trim(),
            pan_img!,
            bank_name.text.trim(),
            bank_ifsc.text.trim(),
            acc_holder_name.text.trim(),
            acc_no.text.trim(),
            bank_proof_img!,
            bank_branch_name.text.trim(),
            profile!);
      } else {
        kyc = await KycApi().applyForKYC(
            widget.user,
            adhar_card_no.text,
            adhar_front_img!,
            adhar_back_img!,
            pan_no.text,
            pan_img!,
            bank_name.text,
            bank_ifsc.text,
            acc_holder_name.text,
            acc_no.text,
            bank_proof_img!,
            bank_branch_name.text,
            profile!);
      }

      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (kyc['status']) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "KYC",
            message: kyc['message'],
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
      } else {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Error",
            message: "Something Went Wrong");
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "KYC",
          message: "Something Went Wrong!");
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
        appBar: AppbarClass().buildSubScreenAppBar(context, 'KYC'),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 10.0),
                  const Center(
                    child: Text(
                      'KYC Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                    ImageUpload(
                    labelText: "Photograph",
                    onImagePicked: (image) {
                      setState(() {
                        profile = image;
                      });
                    },
                  ),
                   SizedBox(height: 15.0),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: adhar_card_no,
                      labelText: "Adhar Card NO",
                      hintText: "Adhar",
                      prefixIcon: Icons.local_post_office,
                      keyboardType: TextInputType.number),
                  SizedBox(height: 15),
                  ImageUpload(
                    labelText: "Adhar Front Image",
                    onImagePicked: (image) {
                      setState(() {
                        adhar_front_img = image;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  ImageUpload(
                    labelText: "Adhar Back Image",
                    onImagePicked: (image) {
                      setState(() {
                        adhar_back_img = image;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: pan_no,
                      labelText: "Pan Card NO",
                      hintText: "Pan",
                      prefixIcon: Icons.local_post_office_rounded,
                      keyboardType: TextInputType.text),
                  SizedBox(height: 15),
                  ImageUpload(
                    labelText: "Pan Image",
                    onImagePicked: (image) {
                      setState(() {
                        pan_img = image;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: bank_name,
                      labelText: "Bank Name",
                      hintText: "Bank Name",
                      prefixIcon: Icons.local_post_office_rounded,
                      keyboardType: TextInputType.text),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: bank_branch_name,
                      labelText: "Bank Branch Name",
                      hintText: "Branch Name",
                      prefixIcon: Icons.local_post_office_rounded,
                      keyboardType: TextInputType.text),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: bank_ifsc,
                      labelText: "Bank IFSC",
                      hintText: "ifcs code",
                      prefixIcon: Icons.local_post_office_rounded,
                      keyboardType: TextInputType.text),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: acc_holder_name,
                      labelText: "Account holder name",
                      hintText: "Name",
                      prefixIcon: Icons.local_post_office_rounded,
                      keyboardType: TextInputType.text),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                      context: context,
                      controller: acc_no,
                      labelText: "Account No",
                      hintText: "Account No",
                      prefixIcon: Icons.local_post_office_rounded,
                      keyboardType: TextInputType.text),
                  SizedBox(height: 15),
                  ImageUpload(
                    labelText: "Bank Account Proof",
                    onImagePicked: (image) {
                      setState(() {
                        bank_proof_img = image;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Buttons().submitButton(
                      buttonText: widget.isUpdate ? "Update" : "Submit",
                      onPressed: submitKYC,
                      isLoading: _isLoading)
                ],
              ),
            ),
          ),
        ));
  }
}

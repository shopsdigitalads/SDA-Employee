import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Display%20Owner/display_owner_registration.dart';
import 'package:sdaemployee/Services/API/Setup/auth_api.dart';
import 'package:sdaemployee/Services/API/Setup/register_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';
import 'package:sdaemployee/Widgets/Section.dart';
import 'dart:async';

import '../../Widgets/Buttons.dart';

class VerifyDisplayOwnerMobile extends StatefulWidget {
  const VerifyDisplayOwnerMobile({Key? key}) : super(key: key);

  @override
  _VerifyDisplayOwnerMobileState createState() =>
      _VerifyDisplayOwnerMobileState();
}

class _VerifyDisplayOwnerMobileState extends State<VerifyDisplayOwnerMobile> {
  late AuthApi authApi;
  bool _isLoading = false;
  bool _isOTPVisible = false;
  bool _isResendVisible = false;
  int _timerSeconds = 120;
  late Timer _timer;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  void _submitMobile() async {
    try {
      if (Validation().validateMobile(_mobileController.text)) {
        setState(() {
          _isLoading = true;
        });
        Map<String, dynamic> response = await RegisterApi().sendOtp("Mobile",_mobileController.text);
        if (response['status']) {
          setState(() {
            _isLoading = false;
            _isOTPVisible = true;
            _startTimer();
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          DialogClass().showCustomDialog(
              context: context,
              icon: Icons.error,
              title: "Error Occured",
              message: response['message']);
        }
      } else {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Invalid Mobile",
            message: "Enter Valid 10 Digit Mobile No!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error Occured",
          message: "Something Went Wrong!");
    }
  }

  void _verifyOtp() async {
    try {
      if (_otpController.text.length == 6) {
        setState(() {
          _isLoading = true;
        });

        Map<String, dynamic> response = await RegisterApi().verifyOtp(_mobileController.text,_otpController.text);
        if (response['status']) {
          setState(() {
            _isLoading = false;
          });
          if (response['user_exists']) {
              DialogClass().showCustomDialog(
                  context: context,
                  icon: Icons.abc,
                  title: "Already Exists",
                  message: "User with given mobile no already exists");
              return;
          } else {
           ScreenRouter.addScreen(context,DisplayOwnerRegistration(mobile_no: _mobileController.text,));
            setState(() {
              _isOTPVisible = false;
            });
          }
        } else {
          print(response);
          setState(() {
            _isLoading = false;
          });
          DialogClass().showCustomDialog(
              context: context,
              icon: Icons.error,
              title: "Error Occured",
              message: response['message']);
        }
      } else {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Invalid OTP",
            message: "OTP should be of 6 digit only!");
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error Occured",
          message: "Something Went Wrong!");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _isResendVisible = true;
        });
        _timer.cancel();
      }
    });
  }

  void _resetTimer() {
    _submitMobile();
    setState(() {
      _isResendVisible = false;
      _timerSeconds = 120;
      _startTimer();
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Verify Mobile"),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo1.png', height: 100),
              Section().buildSectionTitle("Shop Digital Ads"),

              Section().buildSectionTitle("Enter Mobile NO"),
              SizedBox(height: 20.0),
              !_isOTPVisible
                  ? Inputfield().textFieldInput(
                      context: context,
                      controller: _mobileController,
                      labelText: "Mobile",
                      hintText: "Mobile No",
                      prefixIcon: Icons.call,
                      keyboardType: TextInputType.number)
                  : Column(
                      children: [
                        Inputfield().textFieldInput(
                          context: context,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          labelText: 'Enter OTP',
                          prefixIcon: Icons.lock,
                          hintText: "Enter OTP",
                        ),
                        SizedBox(height: 20.0),
                        Buttons().submitButton(
                            onPressed: _verifyOtp, isLoading: _isLoading),
                        Text(
                          'Time remaining: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
              SizedBox(height: 20.0),
              !_isOTPVisible
                  ? Buttons().submitButton(
                      onPressed: _submitMobile, isLoading: _isLoading)
                  : SizedBox.shrink(),
              _isResendVisible
                  ? Buttons().submitButton(
                      onPressed: _resetTimer,
                      isLoading: _isLoading,
                      buttonText: "Send Again")
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

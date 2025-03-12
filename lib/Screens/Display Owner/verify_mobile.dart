import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Display%20Owner/display_owner_registration.dart';
import 'package:sdaemployee/Services/API/Setup/auth_api.dart';
import 'package:sdaemployee/Services/API/Setup/register_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';
import 'dart:async';

class VerifyDisplayOwnerMobile extends StatefulWidget {
  const VerifyDisplayOwnerMobile({Key? key}) : super(key: key);

  @override
  _VerifyDisplayOwnerMobileState createState() =>
      _VerifyDisplayOwnerMobileState();
}

class _VerifyDisplayOwnerMobileState extends State<VerifyDisplayOwnerMobile> {
  bool otpSend = false;
  bool isMobileEdit = true;
  late AuthApi authApi;
  bool _isLoading = false;
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
        Map<String, dynamic> response =
            await RegisterApi().sendOtp("Mobile", _mobileController.text);
        if (response['status']) {
          setState(() {
            _isLoading = false;
            otpSend = true;
            isMobileEdit = false;
            _startTimer();
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          DialogClass().showCustomDialog(
              context: context,
              icon: Icons.error,
              title: "Error",
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
          title: "Error",
          message: "Something Went Wrong!");
    }
  }

  void _verifyOtp() async {
    try {
      if (_otpController.text.length == 6) {
        setState(() {
          _isLoading = true;
        });

        Map<String, dynamic> response = await RegisterApi()
            .verifyOtp(_mobileController.text, _otpController.text);
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
            ScreenRouter.addScreen(
                context,
                DisplayOwnerRegistration(
                  mobile_no: _mobileController.text,
                ));
            setState(() {
              _isLoading = false;
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
              title: "Error",
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
          title: "Error",
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

  void editNumber() {
    setState(() {
      isMobileEdit = true;
      otpSend = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return  Scaffold(
        appBar: AppbarClass().buildSubScreenAppBar(context, "New Partner"),
          backgroundColor: Colors.white,
          body: 
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    top: screenHeight*0.15,
                    left: screenWidth*.1,
                    right:screenWidth*.1,
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png'),
                      SizedBox(height: 30.0),
                      Inputfield().textFieldInput(
                          enabled: isMobileEdit,
                          context: context,
                          controller: _mobileController,
                          labelText: "Mobile",
                          hintText: "Mobile No",
                          prefixIcon: Icons.call,
                          keyboardType: TextInputType.number),
                      SizedBox(height: 30.0),
                      if (otpSend)
                        Inputfield().textFieldInput(
                          context: context,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          labelText: 'Enter OTP',
                          prefixIcon: Icons.lock,
                          hintText: "Enter OTP",
                        ),
                      SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                maximumSize: Size(170.0, 90.0),
                                backgroundColor: Colors.black,
                                minimumSize: Size(170.0, 60.0),
                                shape: StadiumBorder(),
                              ),
                              onPressed: () {
                                if (otpSend) {
                                  _verifyOtp();
                                } else {
                                  _submitMobile();
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          !otpSend ? 'Get OTP' : "Verify OTP",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                  Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                  ),
                                ],
                              )),
                        ],
                      ),
                      if (otpSend) SizedBox(height: 30.0),
                      if (otpSend)
                        Text(
                          'Time remaining: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_isResendVisible)
                            TextButton(
                              onPressed: () {
                                _resetTimer();
                              },
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          if (otpSend)
                            TextButton(
                              onPressed: () {
                                editNumber();
                              },
                              child: Text(
                                'Edit Number',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

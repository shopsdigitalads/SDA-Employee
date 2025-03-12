import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Home/start_point.dart';
import 'package:sdaemployee/Services/API/Setup/auth_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthApi authApi;
  bool _isLoading = false;
    bool otpSend = false; 
  bool isMobileEdit = true;
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
        authApi = AuthApi(_mobileController.text.trim());
        Map<String, dynamic> response = await authApi.sendOtp("Mobile");
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
        authApi.otp = int.parse(_otpController.text);
        Map<String, dynamic> response = await authApi.verifyOtp();
        if (response['status']) {
          setState(() {
            _isLoading = false;
          });

          ScreenRouter.replaceScreen(context, StartPoint());
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
            title: "Invalid OTP",
            message: "OTP should be of 6 digit only!");
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

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return; // Check if the widget is still mounted

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

   void editNumber(){
    setState(() {
      isMobileEdit = true;
      otpSend = false;
      _otpController.clear();
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
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/login.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 60.0,
                    ),
                    child: Text(
                      'SDA\n LOGIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.4,
                    left: 35,
                    right: 35,
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
            ],
          ),
        ),
      ),
    );
  }
}

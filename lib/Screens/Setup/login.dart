import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Home/start_point.dart';
import 'package:sdaemployee/Services/API/Setup/auth_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';
import 'dart:async';

import '../../Widgets/Buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      authApi = AuthApi(_mobileController.text.trim());
      Map<String, dynamic> response = await authApi.sendOtp("Mobile");
      if (response['status']) {
        setState(() {
          _isLoading = false;
          _isOTPVisible = true;
          _startTimer();
        });
      }else{
        setState(() {
          _isLoading = false;
        });
        DialogClass().showCustomDialog(context: context,icon:  Icons.error,title:  "Error Occured",message: 
          response['message']);
      }
    } else {
      DialogClass().showCustomDialog(context:context,icon:  Icons.error,title:  "Invalid Mobile",message: 
          "Enter Valid 10 Digit Mobile No!");
    }
    } catch (e) {
       setState(() {
          _isLoading = false;
        });
      DialogClass().showCustomDialog(context: context,icon:   Icons.error,title:  "Error Occured",message:"Something Went Wrong!");
    }
   
  }

  void _verifyOtp() async{
    try {
       if (_otpController.text.length == 6) {
      setState(() {
        _isLoading = true;
      });
      authApi.otp = int.parse(_otpController.text);
      Map<String, dynamic> response = await authApi.verifyOtp();
      print(response);
      if (response['status']) {
         setState(() {
          _isLoading = false;
        });
        if(response['user_exists']){
          if(!response['is_active']){
            DialogClass().showCustomDialog(context: context, icon: Icons.abc, title: "Active", message: "Employee is Active");  
            return ;
          }
          ScreenRouter.replaceScreen(context, StartPoint());
        }else{
          DialogClass().showCustomDialog(context: context, icon: Icons.error, title: "No User", message: "No user found with this mobile no");
          setState(() {
            _isOTPVisible = false;
          });
        }
       
      }else{
        setState(() {
          _isLoading = false;
        });
        DialogClass().showCustomDialog(context: context,icon:  Icons.error,title:  "Error Occured",message: 
          response['message']);
      }
    } else {
      DialogClass().showCustomDialog(context: context,icon:  Icons.error,title:  "Invalid OTP",message: 
          "OTP should be of 6 digit only!");
    }
    } catch (e) {
       setState(() {
          _isLoading = false;
        });
     DialogClass().showCustomDialog(context: context,icon:   Icons.error,title:  "Error Occured",message:"Something Went Wrong!");
    }
  }


  
 void _startTimer() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (!mounted) return;  // Check if the widget is still mounted
    
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
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Welcome Text
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 90.0),
                    child: Column(
                      children: [
                        Text(
                          '\nShop Digital\nAds',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Your one-stop solution\nfor digital advertising!',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Mobile Number and OTP fields
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: 35,
                    right: 35,
                  ),
                  child: Column(
                    children: [
                      // Mobile Number Field
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
                                  keyboardType:
                                      TextInputType.number,
                                  labelText: 'Enter OTP',
                                  prefixIcon: Icons.lock,
                                  hintText: "Enter OTP",
                                ),
                                SizedBox(height: 20.0),
                                SizedBox(
                                    width: double.infinity,
                                    child: Buttons().submitButton(
                                        onPressed:_verifyOtp,
                                        isLoading: _isLoading)),
                                Text(
                                  'Time remaining: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),

                      SizedBox(height: 10.0),

                      SizedBox(height: 30.0),
                      // Submit Button for Mobile Number
                      !_isOTPVisible
                          ? Buttons().submitButton(
                              onPressed: _submitMobile, isLoading: _isLoading)
                          : SizedBox.shrink(),
                      SizedBox(height: 1),
                      // Send Again button for OTP after timer expires
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
            ],
          ),
        ),
      ),
    );
  }
}

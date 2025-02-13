import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Screens/Setup/address.dart';
import 'package:sdaemployee/Services/API/Setup/register_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';
import 'package:sdaemployee/Services/validation.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';
import '../../Services/API/Setup/auth_api.dart';

// ignore: must_be_immutable
class DisplayOwnerRegistration extends StatefulWidget {
  String mobile_no;
  DisplayOwnerRegistration({required this.mobile_no, super.key});

  @override
  _DisplayOwnerRegistrationState createState() =>
      _DisplayOwnerRegistrationState();
}

class _DisplayOwnerRegistrationState extends State<DisplayOwnerRegistration> {
  late AuthApi authApi;
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _middleName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  bool isEmailEdit = true;
  bool _isEmailVerified = false;
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isResendVisible = false;
  int _timerSeconds = 120;
  late Timer _timer;

  Future<void> verfiyMail() async {
    try {
      if (Validation().validateEmail(_email.text.trim())) {
        setState(() {
          _isLoading = true;
        });
        Map<String, dynamic> response = await RegisterApi().sendOtp("Email",_email.text);
        if (response['status']) {
          setState(() {
            isEmailEdit = false;
            _isEmailVerified = true;
            _isLoading = false;
            _otpSent = true;
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
            title: "Invalid Email",
            message: "Enter Valid Email!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error Occured",
          message: "Something Went Wrong");
    }
  }

  void _verifyOtp() async {
    try {
      if (_otp.text.length == 6) {
        setState(() {
          _isLoading = true;
        });
        Map<String, dynamic> response = await RegisterApi().verifyOtp(_email.text,_otp.text);
        if (response['status']) {
          RegisterApi registerApi = RegisterApi(
             );
          Map<String, dynamic> user = await registerApi.register( _firstName.text.trim(),
              _lastName.text.trim(),
              _middleName.text.trim(),
              _email.text.trim(),
              widget.mobile_no);
          setState(() {
            _isLoading = false;
          });
          print(user);
          if (user['status']) {
            User user1 = await SharePrefs().getUser();
            user1.user_count = user1.user_count+1;
            await SharePrefs().storeUser(user1);
            DialogClass().showCustomDialog(
                context: context,
                icon: Icons.done,
                title: "Success",
                message: user['message'],
                onPressed: () {
                  ScreenRouter.replaceScreen(
                      context,
                      Address(
                        user_id:user['user_id'].toString(),
                        address_type: "Home",
                        isUpdate: false,
                        isBusiness: false,
                      ));
                });
          } else {
            DialogClass().showCustomDialog(
                context: context,
                icon: Icons.error,
                title: "Error Occured",
                message: response['message']);
          }
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
          message: "Something Went Wrong");
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
    verfiyMail();
    setState(() {
      _isResendVisible = false;
      _timerSeconds = 120;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppbarClass().buildSubScreenAppBar(context, "Register User"),
        backgroundColor: Colors.white,
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Register with \nShop Digital\nAds',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Your one-stop solution\nfor digital advertising!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Inputfield().textFieldInput(
                            enabled: isEmailEdit,
                            context: context,
                            controller: _firstName,
                            labelText: "First Name",
                            hintText: "First Name",
                            prefixIcon: Icons.person,
                            keyboardType: TextInputType.text),
                        SizedBox(height: 20.0),
                        Inputfield().textFieldInput(
                            enabled: isEmailEdit,
                            context: context,
                            controller: _middleName,
                            labelText: "Middle Name",
                            hintText: "Middle Name",
                            prefixIcon: Icons.edit,
                            keyboardType: TextInputType.text),
                        SizedBox(height: 20.0),
                        Inputfield().textFieldInput(
                            enabled: isEmailEdit,
                            context: context,
                            controller: _lastName,
                            labelText: "Last Name",
                            hintText: "Last Name",
                            prefixIcon: Icons.person,
                            keyboardType: TextInputType.text),
                        SizedBox(height: 20.0),
                        Inputfield().textFieldInput(
                            enabled: isEmailEdit,
                            context: context,
                            controller: _email,
                            labelText: "Email",
                            hintText: "Email",
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.text),
                        SizedBox(height: 20.0),
                        _otpSent
                            ? Column(
                                children: [
                                  Inputfield().textFieldInput(
                                      context: context,
                                      controller: _otp,
                                      labelText: "Enter OTP",
                                      hintText: "Enter OTP",
                                      prefixIcon: Icons.password,
                                      keyboardType: TextInputType.number),
                                  SizedBox(height: 15.0),
                                  Text(
                                    'Time remaining: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              )
                            : Container(),
                        _isEmailVerified
                            ? Buttons().submitButton(
                                onPressed: _verifyOtp, isLoading: _isLoading)
                            : Buttons().submitButton(
                                onPressed: verfiyMail,
                                isLoading: _isLoading,
                                buttonText: "Verify Email"),
                        SizedBox(height: 15.0),
                        _isResendVisible
                            ? Buttons().submitButton(
                                onPressed: _resetTimer,
                                isLoading: _isLoading,
                                buttonText: "Resend OTP")
                            : Container()
                      ],
                    ),
                  ],
                )))));
  }
}

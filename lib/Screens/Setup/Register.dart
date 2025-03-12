// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:sdaemployee/Screens/Setup/address.dart';
// import 'package:sdaemployee/Services/API/Setup/register_api.dart';
// import 'package:sdaemployee/Services/Routing/router.dart';
// import 'package:sdaemployee/Services/validation.dart';
// import 'package:sdaemployee/Widgets/Buttons.dart';
// import 'package:sdaemployee/Widgets/Dialog.dart';
// import 'package:sdaemployee/Widgets/InputField.dart';

// import '../../Services/API/Setup/auth_api.dart';
// // ignore: must_be_immutable
// class Register extends StatefulWidget {
//   String mobile;
//   Register({required this.mobile, super.key});

//   @override
//   _RegisterState createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   late AuthApi authApi;
//   final TextEditingController _firstName = TextEditingController();
//   final TextEditingController _lastName = TextEditingController();
//   final TextEditingController _middleName = TextEditingController();
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _otp = TextEditingController();
//   bool isEmailEdit = true;
//   bool _isEmailVerified = false;
//   bool _isLoading = false;
//   bool _otpSent = false;
//   bool _isResendVisible = false;
//   int _timerSeconds = 120;
//   late Timer _timer;

//   Future<void> verfiyMail() async {
//     try {
//       if (Validation().validateEmail(_email.text.trim())) {
//         setState(() {
//           _isLoading = true;
//         });
//         authApi = AuthApi(_email.text);
//         Map<String, dynamic> response = await authApi.sendOtp("Email");
//         if (response['status']) {
//           setState(() {
//             isEmailEdit = false;
//             _isEmailVerified = true;
//             _isLoading = false;
//             _otpSent = true;
//             _startTimer();
//           });
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//           DialogClass().showCustomDialog(
//               context: context,
//               icon: Icons.error,
//               title: "Error",
//               message: response['message']);
//         }
//       } else {
//         DialogClass().showCustomDialog(
//             context: context,
//             icon: Icons.error,
//             title: "Invalid Email",
//             message: "Enter Valid Email!");
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       DialogClass().showCustomDialog(
//           context: context,
//           icon: Icons.error,
//           title: "Error",
//           message: "Something Went Wrong");
//     }
//   }

//   void _verifyOtp() async {
//     try {
//       if (_otp.text.length == 6) {
//         setState(() {
//           _isLoading = true;
//         });
//         authApi.otp = int.parse(_otp.text);
//         Map<String, dynamic> response = await authApi.verifyOtp();
//         if (response['status']) {
//           RegisterApi registerApi = RegisterApi(_firstName.text.trim(), _lastName.text.trim(),
//               _middleName.text.trim(), _email.text.trim(), widget.mobile.trim());
//           Map<String, dynamic> user = await registerApi.register();
//           setState(() {
//             _isLoading = false;
//           });
//           print(user);
//           if (user['status']) {
//             DialogClass().showCustomDialog(
//                 context: context,
//                 icon: Icons.done,
//                 title: "Success",
//                 message: user['message'],
//                 onPressed: () {
//                   ScreenRouter.replaceScreen(
//                       context, Address(address_type: "Home",isUpdate: false,isBusiness: false,));
//                 });
//           } else {
//             DialogClass().showCustomDialog(
//                 context: context,
//                 icon: Icons.error,
//                 title: "Error",
//                 message: response['message']);
//           }
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//           DialogClass().showCustomDialog(
//               context: context,
//               icon: Icons.error,
//               title: "Error",
//               message: response['message']);
//         }
//       } else {
//         DialogClass().showCustomDialog(
//             context: context,
//             icon: Icons.error,
//             title: "Invalid OTP",
//             message: "OTP should be of 6 digit only!");
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       DialogClass().showCustomDialog(
//           context: context,
//           icon: Icons.error,
//           title: "Error",
//           message: "Something Went Wrong");
//     }
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (!mounted) return; // Check if the widget is still mounted

//       if (_timerSeconds > 0) {
//         setState(() {
//           _timerSeconds--;
//         });
//       } else {
//         setState(() {
//           _isResendVisible = true;
//         });
//         _timer.cancel();
//       }
//     });
//   }

//   void _resetTimer() {
//     verfiyMail();
//     setState(() {

//       _isResendVisible = false;
//       _timerSeconds = 120;
//       _startTimer();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/register.png'),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Stack(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Container(
//                   padding:
//                       EdgeInsets.symmetric(vertical: 50.0, horizontal: 90.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Register with \nShop Digital\nAds',
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 30.0,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.5,
//                         ),
//                       ),
//                       SizedBox(height: 10.0),
//                       Text(
//                         'Your one-stop solution\nfor digital advertising!',
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16.0,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SingleChildScrollView(
//               child: Container(
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).size.height * 0.3,
//                   left: 35,
//                   right: 35,
//                 ),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 20.0),
//                     Inputfield().textFieldInput(
//                       enabled: isEmailEdit,
//                       context: context,
//                         controller: _firstName,
//                         labelText: "First Name",
//                         hintText: "First Name",
//                         prefixIcon: Icons.person,
//                         keyboardType: TextInputType.text),
//                     SizedBox(height: 20.0),
//                     Inputfield().textFieldInput(
//                       enabled: isEmailEdit,
//                       context: context,
//                         controller: _middleName,
//                         labelText: "Middle Name",
//                         hintText: "Middle Name",
//                         prefixIcon: Icons.edit,
//                         keyboardType: TextInputType.text),
//                     SizedBox(height: 20.0),
//                     Inputfield().textFieldInput(
//                       enabled: isEmailEdit,
//                       context: context,
//                         controller: _lastName,
//                         labelText: "Last Name",
//                         hintText: "Last Name",
//                         prefixIcon: Icons.person,
//                         keyboardType: TextInputType.text),
//                     SizedBox(height: 20.0),
//                     Inputfield().textFieldInput(
//                       enabled: isEmailEdit,
//                       context: context,
//                         controller: _email,
//                         labelText: "Email",
//                         hintText: "Email",
//                         prefixIcon: Icons.email,
//                         keyboardType: TextInputType.text),
//                     SizedBox(height: 20.0),
//                     _otpSent
//                         ? Column(
//                             children: [
//                               Inputfield().textFieldInput(
//                                 context: context,
//                                   controller: _otp,
//                                   labelText: "Enter OTP",
//                                   hintText: "Enter OTP",
//                                   prefixIcon: Icons.password,
//                                   keyboardType: TextInputType.number),
//                               SizedBox(height: 15.0),
//                               Text(
//                                 'Time remaining: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
//                                 style: TextStyle(color: Colors.black),
//                               )
//                             ],
//                           )
//                         : Container(),
//                     _isEmailVerified
//                         ? Buttons().submitButton(
//                             onPressed: _verifyOtp, isLoading: _isLoading)
//                         : Buttons().submitButton(
//                             onPressed: verfiyMail,
//                             isLoading: _isLoading,
//                             buttonText: "Verify Email"),
//                     SizedBox(height: 15.0),
//                     _isResendVisible
//                         ? Buttons().submitButton(
//                             onPressed: _resetTimer,
//                             isLoading: _isLoading,
//                             buttonText: "Resend OTP")
//                         : Container()
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     ));
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Business/business_api.dart';
import 'package:sdaemployee/Services/API/Setup/address_api.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class BusinessAddress extends StatefulWidget {
  Map<String, dynamic> user;
  String client_business_name;
  String business_type_id;
  File interiorImage;
  File exteriorImage;

  BusinessAddress(
      {super.key,
      required this.user,
      required this.client_business_name,
      required this.business_type_id,
      required this.exteriorImage,
      required this.interiorImage});

  @override
  State<BusinessAddress> createState() => _BusinessAddressState();
}

class _BusinessAddressState extends State<BusinessAddress> {
  final TextEditingController _pinCode = TextEditingController();
  final TextEditingController _cluster = TextEditingController();
  final TextEditingController _district = TextEditingController();
  final TextEditingController _state = TextEditingController();
  TextEditingController _landmark = TextEditingController();
  TextEditingController _address_line = TextEditingController();

  List<dynamic> _areas = [];
  String? _selectedArea;
  bool _isLoading = false;
  bool _dialogLoading = false;

  void _onPinCodeChanged(String value) async {
    try {
      if (value.length == 6) {
        _areas = [];
        setState(() {
          _dialogLoading = true;
        });
        DialogClass()
            .showLoadingDialog(context: context, isLoading: _dialogLoading);
        final result = await AddressApi().getDataFromPinCode(value);
        setState(() {
          _dialogLoading = false;
        });
        DialogClass()
            .showLoadingDialog(context: context, isLoading: _dialogLoading);
        if (result["status"] == true) {
          setState(() {
            _areas = result["locations"];
            _district.text = _areas[0]["District"];
            _state.text = _areas[0]["State"];
            _cluster.text = _areas[0]["Taluk"];
          });
        } else {
          DialogClass().showCustomDialog(
              context: context,
              icon: Icons.error,
              title: "Error Occured",
              message: "Something Went Wrong");
        }
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Address",
          message: "Something Went Wrong!");
    }
  }

  void submitBusiness() async {
    try {
      if (_landmark.text.isEmpty) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Address",
            message: "Enter Landmark");
        return;
      } else if (_address_line.text.isEmpty) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Address",
            message: "Enter Address");
        return;
      } else if (_pinCode.text.isEmpty) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Address",
            message: "Enter Pin Code");
        return;
      } else if (_selectedArea == null) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Address",
            message: "Select Area");
        return;
      }
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> business = await BusinessApi().submitBusiness(
          widget.user,
          widget.client_business_name,
          widget.business_type_id,
          widget.interiorImage,
          widget.exteriorImage,
          _pinCode.text,
          _selectedArea!,
          _cluster.text,
          _district.text,
          _state.text,
          _landmark.text,
          _address_line.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppbarClass().buildSubScreenAppBar(context, 'Business Address'),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 10.0),
                  const Center(
                    child: Text(
                      'Business Address',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Inputfield().textFieldInput(
                    context: context,
                    controller: _landmark,
                    labelText: "Landmark",
                    hintText: "Near by location",
                    prefixIcon: Icons.mark_as_unread,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    onChanged: _onPinCodeChanged,
                    controller: _pinCode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Pin Code",
                      hintText: "Pin Code",
                      prefixIcon: Icon(Icons.numbers),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  if (_areas.isNotEmpty) ...[
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedArea,
                      items: _areas.map<DropdownMenuItem<String>>((area) {
                        return DropdownMenuItem<String>(
                          value: area['Name'],
                          child: Text(
                            area['Name'],
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value;
                        });
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled:
                            true, // Ensures the background is filled with white color
                        labelText: "Select Area",
                        labelStyle: TextStyle(
                            color:
                                Colors.black), // Label text color set to black
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: const Color.fromRGBO(255, 255, 255,
                          1), // Dropdown background color set to white
                      style: TextStyle(
                          color: Colors
                              .black), // Text color for the dropdown items
                    ),
                  ],
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                    context: context,
                    controller: _cluster,
                    labelText: "Cluster",
                    hintText: "Cluster (Taluk)",
                    prefixIcon: Icons.landscape,
                    keyboardType: TextInputType.text,
                    enabled: false,
                  ),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                    context: context,
                    controller: _district,
                    labelText: "District",
                    hintText: "District",
                    prefixIcon: Icons.location_city,
                    keyboardType: TextInputType.text,
                    enabled: false,
                  ),
                  SizedBox(height: 15),
                  Inputfield().textFieldInput(
                    context: context,
                    controller: _state,
                    labelText: "State",
                    hintText: "State",
                    prefixIcon: Icons.map,
                    keyboardType: TextInputType.text,
                    enabled: false,
                  ),
                  SizedBox(height: 15),
                    Inputfield().textFieldInput(
                  context: context,
                  controller: _address_line,
                  labelText: "Address Line 1",
                  hintText: "Near by location",
                  prefixIcon: Icons.circle,
                  keyboardType: TextInputType.text,
                  maxLines: 4
                ),
                SizedBox(height: 15),
                  Buttons().submitButton(
                      onPressed: submitBusiness, isLoading: _isLoading)
                ],
              ),
            ),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Home/start_point.dart';
import 'package:sdaemployee/Services/API/Setup/address_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class Address extends StatefulWidget {
  String user_id;
  String? pin_code;
  String? area;
  String? cluster;
  String? district;
  String? state;
  String? google_map_locatin;
  String? address_type;
  int? address_id;
  bool isUpdate;
  bool isBusiness;
  Address(
      {super.key,
      this.pin_code,
      this.area,
      this.cluster,
      this.district,
      this.state,
      this.google_map_locatin,
      this.address_type,
      this.address_id,
      required this.isUpdate,
      required this.isBusiness,
      required this.user_id});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  TextEditingController _pinCode = TextEditingController();
  TextEditingController _cluster = TextEditingController();
  TextEditingController _district = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _a = TextEditingController();

  List<dynamic> _areas = [];
  String? _selectedArea;
  bool _isLoading = false;
  bool _dialogLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pinCode = TextEditingController(text: widget.pin_code ?? "");
    _cluster = TextEditingController(text: widget.cluster ?? "");
    _district = TextEditingController(text: widget.district ?? "");
    _selectedArea = widget.area ?? "";
    _state = TextEditingController(text: widget.state ?? "");
    _a = TextEditingController(text: widget.area ?? '');
  }

  void _onPinCodeChanged(String value) async {
    try {
      _selectedArea = null;
      _areas = [];
      if (value.length == 6) {
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

  void submitAddress() async {
    try {
      setState(() {
        _isLoading = true;
      });
      AddressApi addressApi = AddressApi(
        user_id:widget.user_id,
          pin_code: _pinCode.text,
          area: _selectedArea,
          cluster: _cluster.text,
          district: _district.text,
          state: _state.text,
          address_type: widget.isBusiness?"Business":"Home");
      Map<String, dynamic> res;
      if (widget.isUpdate) {
        res = await addressApi.updateAdderss(widget.address_id!);
      } else {
        res = await addressApi.submitAddress();
      }
      print(res);
      bool condition;
      String message;
      if (widget.isUpdate) {
        condition = res['status'];
        message = res['message'];
      } else {
        condition = res['address']['status'];
        message = res['address']['message'];
      }

      if (condition) {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.done,
            title: "Address",
            message: message,
            onPressed: () {
              ScreenRouter.replaceScreen(context, StartPoint());
            });
      } else {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Address",
            message: res['address']['message']);
      }
    } catch (e) {
      print(e);
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Address",
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
      appBar: AppbarClass().buildSubScreenAppBar(context, "Address"),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  child: Text(
                    widget.isBusiness
                        ? "Update Business Address"
                        : 'Home Address',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 1,
                    ),
                  ),
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
                SizedBox(height: 10),
                if (_areas.isEmpty && widget.isUpdate)
                  Inputfield().textFieldInput(
                    context: context,
                    controller: _a,
                    labelText: "Area",
                    hintText: "Area",
                    prefixIcon: Icons.landscape,
                    keyboardType: TextInputType.text,
                    enabled: false,
                  ),
                if (_areas.isNotEmpty) ...[
                  SizedBox(height: 10),
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
                          color: Colors.black), // Label text color set to black
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: const Color.fromRGBO(255, 255, 255,
                        1), // Dropdown background color set to white
                    style: TextStyle(
                        color:
                            Colors.black), // Text color for the dropdown items
                  ),
                ],
                SizedBox(height: 10),
                Inputfield().textFieldInput(
                  context: context,
                  controller: _cluster,
                  labelText: "Cluster",
                  hintText: "Cluster (Taluk)",
                  prefixIcon: Icons.landscape,
                  keyboardType: TextInputType.text,
                  enabled: false,
                ),
                SizedBox(height: 10),
                Inputfield().textFieldInput(
                  context: context,
                  controller: _district,
                  labelText: "District",
                  hintText: "District",
                  prefixIcon: Icons.location_city,
                  keyboardType: TextInputType.text,
                  enabled: false,
                ),
                SizedBox(height: 10),
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
                Buttons().submitButton(
                    onPressed: submitAddress, isLoading: _isLoading)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

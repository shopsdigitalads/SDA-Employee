import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Ads/Upload%20Advertisement/advertisement_display.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/API/Setup/address_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/InputField.dart';

// ignore: must_be_immutable
class AdvertisementLocation extends StatefulWidget {
  int ad_id;
  int business_type_id;
  AdvertisementLocation(
      {required this.ad_id, required this.business_type_id, super.key});

  @override
  State<AdvertisementLocation> createState() => _AdvertisementLocationState();
}

class _AdvertisementLocationState extends State<AdvertisementLocation> {
  Map<String, dynamic> addresses = {};
  List<dynamic> states = [];
  List<dynamic> district = [];
  List<dynamic> cluster = [];
  List<dynamic> pincode = [];
  List<dynamic> area = [];
  List<dynamic> selectedAddressIds = [];

  List<Map<String, dynamic>> submittedAddresses = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedCluster;
  String? selectedPinCode;
  List<String> selectedAreas = [];
  bool isLoading = false;
  bool isSubmit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBusinessAddress();
    });
  }

  Future<void> fetchBusinessAddress() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res =
          await AddressApi().fetchBusinessAddress(widget.business_type_id);
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      if (res['status']) {
        setState(() {
          addresses = (res['data']);
          debugPrint(addresses.toString());
          states = addresses.keys.toList();
          states.insert(0, "All");
        });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Business Address",
          message: res['message'],
        );
      }
    } catch (e) {
      print(e);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void selectDistrict(String state) {
    try {
      area = [];
      pincode = [];
      cluster = [];
      district = [];
      selectedDistrict = null;
      selectedCluster = null;
      selectedPinCode = null;
      selectedAreas = [];
      print(state);
      if (state == "All") {
        debugPrint("States Called");
        selectAllStates();
      } else {
        Map<String, dynamic> d = addresses[state];
        district = d.keys.toList();
        district.insert(0, "All");
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
    }
  }

  void selectCluster(String district) {
    try {
      cluster = [];
      pincode = [];
      area = [];
      selectedCluster = null;
      selectedPinCode = null;
      selectedAreas = [];
      if (district == "All") {
        selectAllDistricts(selectedState!);
      } else {
        Map<String, dynamic> d = addresses[selectedState][district];
        cluster = d.keys.toList();
        cluster.insert(0, "All");
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
    }
  }

  void selectPinCode(String cluster) {
    try {
      pincode = [];
      area = [];
      selectedPinCode = null;
      selectedAreas = [];
      print("here");
      if (cluster == "All") {
        selectAllClusters(selectedState!, selectedDistrict!);
      } else {
        Map<String, dynamic> d =
            addresses[selectedState][selectedDistrict][cluster];
        print(d);
        pincode = d.keys.toList();
        pincode.insert(0, "All");
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
    }
  }

  void selectArea(String pincode) {
    try {
      area = [];

      selectedAreas = [];
      print(selectedCluster);
      if (pincode == "All") {
        selectAllPincodes(selectedState!, selectedDistrict!, selectedCluster!);
      } else {
        Map<String, dynamic> d = addresses[selectedState][selectedDistrict]
            [selectedCluster][pincode];
        area = d.keys.toList();
        selectedAreas.clear();
      }
      // Clear previous selections
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
    }
  }

  void selectAllStates() {
    setState(() {
      debugPrint("States Called");
      selectedAddressIds.clear();
      for (var state in addresses.keys) {
        selectAllDistricts(state);
      }
    });
  }

  void selectAllDistricts(String state) {
    debugPrint("District Called");
    for (var district in addresses[state].keys) {
      selectAllClusters(state, district);
    }
  }

  void selectAllClusters(String state, String district) {
    debugPrint("Cluster Called");
    for (var cluster in addresses[state][district].keys) {
      selectAllPincodes(state, district, cluster);
    }
  }

  void selectAllPincodes(String state, String district, String cluster) {
    debugPrint("PinCode Called");
    for (var pincode in addresses[state][district][cluster].keys) {
      selectAllAreas(state, district, cluster, pincode);
    }
  }

  void selectAllAreas(
      String state, String district, String cluster, String pincode) {
    if (addresses[state][district][cluster][pincode] is Map) {
      addresses[state][district][cluster][pincode].forEach((area, ids) {
        selectedAddressIds.addAll(ids);
        selectedAreas.add(area);
        Map<String, String> address = {
          "State": state,
          "District": district,
          "Cluster": cluster,
          "Pincode": pincode,
          "Area": area
        };
        submittedAddresses.add(address);
      });
    }
    updateSelectedAreasUI();
  }

  void updateSelectedAreasUI() {
    print(selectedAddressIds);
    setState(() {
      district = [];
      cluster = [];
      pincode = [];
      area = [];
      selectedDistrict = null;
      selectedCluster = null;
      selectedPinCode = null;
      selectedAreas = [];
      isSubmit = false;
    });
  }

  void handleSubmit() {
    try {
      if (selectedAreas.isNotEmpty) {
        for (String area in selectedAreas) {
          selectedAddressIds.addAll(addresses[selectedState][selectedDistrict]
              [selectedCluster][selectedPinCode][area]);
          print(addresses[selectedState][selectedDistrict][selectedCluster]
              [selectedPinCode][area]);
          if (addresses[selectedState]?[selectedDistrict]?[selectedCluster]
              ?[selectedPinCode] is Map) {
            Map? pinCodeMap = addresses[selectedState]?[selectedDistrict]
                ?[selectedCluster]?[selectedPinCode];
            pinCodeMap?.remove(area);
          }
        }
        Map<String, String> address = {
          "State": selectedState!,
          "District": selectedDistrict!,
          "Cluster": selectedCluster!,
          "Pincode": selectedPinCode!,
          "Area": selectedAreas.join(",")
        };
        submittedAddresses.add(address);

        setState(() {
          district = [];
          cluster = [];
          pincode = [];
          area = [];
          selectedDistrict = null;
          selectedCluster = null;
          selectedPinCode = null;
          selectedAreas = [];
          isSubmit = false;
        });
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.more,
            title: "Location",
            message: "You Can select More Locations");
      } else {
        DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Location",
            message: "Select Area");
      }
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Location",
          message: "Select Valid Location");
    }
  }

  void submitAdresss() async {
    try {
      print(isSubmit);
      if (!isSubmit) {
        if (selectedAddressIds.isEmpty) {
          DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Error",
            message: "No Location Selected",
          );
        } else {
          DialogClass().showLoadingDialog(context: context, isLoading: true);
          Map<String, dynamic> res = await AdvertisementApi()
              .submitAdvertisementLocation(selectedAddressIds, widget.ad_id);
          DialogClass().showLoadingDialog(context: context, isLoading: false);
          print(res);
          if (res['status']) {
            setState(() {
              isSubmit = true;
            });
            ScreenRouter.addScreen(
                context,
                AdvertisementDisplay(
                  address_ids: selectedAddressIds,
                  ad_id: widget.ad_id,
                ),
                slide: true);
            // DialogClass().showCustomDialog(
            //     context: context,
            //     icon: Icons.done,
            //     title: "Advertisement",
            //     message: res['message'],
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //       ScreenRouter.addScreen(
            //           context,
            //           AdvertisementDisplay(
            //             address_ids: selectedAddressIds,
            //             ad_id: widget.ad_id,
            //           ),
            //           slide: true);
            //     });
          } else {
            DialogClass().showCustomDialog(
              context: context,
              icon: Icons.error,
              title: "Business Address",
              message: res['message'],
            );
          }
        }
      } else {
        ScreenRouter.addScreen(
            context,
            AdvertisementDisplay(
              address_ids: selectedAddressIds,
              ad_id: widget.ad_id,
            ),
            slide: true);
      }
    } catch (e) {
      print(e);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Select Location"),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            children: [
              if (submittedAddresses.isEmpty)
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.all(12),
                      color: Colors.grey[200],
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "No address selected yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )),
              if (submittedAddresses.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: submittedAddresses.map((entry) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${entry['State']} > ${entry['District']} > ${entry['Cluster']} > ${entry['Pincode']}',
                          ),
                          subtitle: Text('Areas: ${entry['Area']}'),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 15),

              if (states.isNotEmpty)
                buildDropDown(
                  selectedValue: selectedState,
                  items: states,
                  labelText: "State",
                  select: (value) {
                    selectDistrict(value!);
                    setState(() {
                      selectedState = value;
                    });
                  },
                ),
              const SizedBox(height: 15),

              if (district.isNotEmpty)
                buildDropDown(
                  selectedValue: selectedDistrict,
                  items: district,
                  labelText: "District",
                  select: (value) {
                    selectCluster(value!);
                    setState(() {
                      selectedDistrict = value;
                    });
                  },
                ),
              const SizedBox(height: 15),

              if (cluster.isNotEmpty)
                buildDropDown(
                  selectedValue: selectedCluster,
                  items: cluster,
                  labelText: "Cluster",
                  select: (value) {
                    selectPinCode(value!);
                    setState(() {
                      selectedCluster = value;
                    });
                  },
                ),
              const SizedBox(height: 15),

              if (pincode.isNotEmpty)
                buildDropDown(
                  selectedValue: selectedPinCode,
                  items: pincode,
                  labelText: "Pin Code",
                  select: (value) {
                    selectArea(value!);
                    setState(() {
                      selectedPinCode = value;
                    });
                  },
                ),
              const SizedBox(height: 15),

              // Multiple Area Selection
              if (area.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Areas:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Select all areas
                            setState(() {
                              selectedAreas = List<String>.from(area);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text("Select All"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Deselect all areas
                            setState(() {
                              selectedAreas.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text("Deselect All"),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: area.length,
                      itemBuilder: (context, index) {
                        final currentArea = area[index];
                        return CheckboxListTile(
                          title: Text(currentArea),
                          value: selectedAreas.contains(currentArea),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                selectedAreas.add(currentArea);
                              } else {
                                selectedAreas.remove(currentArea);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey, // Text color
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 5, // Shadow effect
                  shadowColor: Colors.grey, // Shadow color
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 20), // Optional: Add an icon
                    SizedBox(width: 8),
                    Text("Submit Selected Areas",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: Buttons().submitButton(
            buttonText: "Next ->",
            onPressed: submitAdresss,
            isLoading: isLoading),
      ),
    );
  }

  Widget buildDropDown({
    required String? selectedValue,
    required List<dynamic> items,
    required String labelText,
    required void Function(String?) select,
  }) {
    return Row(
      children: [
        Expanded(
          // Prevent layout overflow
          child: Inputfield().buildDropdownFieldForAddress(
              context: context,
              selectedValue: selectedValue,
              items: items,
              labelText: labelText,
              onChanged: select),
        ),
      ],
    );
  }
}

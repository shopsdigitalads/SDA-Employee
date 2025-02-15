import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Setup/address.dart';
import 'package:sdaemployee/Services/API/Setup/address_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

// ignore: must_be_immutable
class ViewAddress extends StatefulWidget {
  String user_id;
  ViewAddress({required this.user_id, super.key});

  @override
  State<ViewAddress> createState() => _ViewAddressState();
}

class _ViewAddressState extends State<ViewAddress> {
  Map<String, dynamic> address = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAddressOfUser();
    });
  }

  void fetchAddressOfUser() async {
    try {
      Map<String, dynamic> res = await AddressApi().fetchAddressOfUser(widget.user_id);


      if (!mounted) return; // Check if widget is still mounted

      if (res['status']) {
        if (res['address'].isEmpty) {
          ScreenRouter.replaceScreen(context, Address(user_id:widget.user_id, isUpdate: false, isBusiness: false,address_type: "Home",));
        } else {
          setState(() {
            isLoading = false;
            address = res['address'][0]; 
          });
        }
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Address",
          message: res['message'],
        );
      }
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      print(e);
      DialogClass().showLoadingDialog(context: context, isLoading: false);
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something Went Wrong",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Address Details"),
      body: isLoading
          ? Section().buildShimmerList(70,40,2) // Show shimmer effect while loading
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Address Details
                  Section().builButtonCard(
                    [
                      Section().buildDetailRow("Pin Code", address['pin_code'],
                          Icons.location_on, Colors.teal),
                      Section().buildDetailRow("Area", address['area'],
                          Icons.place, Colors.orangeAccent),
                      Section().buildDetailRow("Taluka", address['cluster'],
                          Icons.map, Colors.blueAccent),
                      Section().buildDetailRow("District", address['district'],
                          Icons.location_city, Colors.green),
                      Section().buildDetailRow("State", address['state'],
                          Icons.flag, Colors.deepPurple),
                    ],
                  ),
                  const SizedBox(height: 20),

                  address['update_request'] == "Accepted"?Buttons().updateButton(
                    buttonText: "Update Address",
                    onPressed: () {
                      ScreenRouter.addScreen(
                        context,
                        Address(
                          user_id: widget.user_id,
                          isUpdate: true,
                          pin_code: address['pin_code'],
                          address_type: 'Home',
                          area: address['area'],
                          state: address['state'],
                          district: address['district'],
                          cluster: address['cluster'],
                          address_id: address['address_id'],
                          isBusiness: false,
                        ),
                      );
                    },
                  ):address['update_request'] == "Submitted"?Text(
                            "Update Request Submitted",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ):Buttons().actionButton(
                            title: "Request Update",
                            color: Colors.purpleAccent,
                            onPressed: () async {
                              await DialogClass().showFullScreenDialog(
                                  context: context,
                                  module: "Address",
                                  id:address['address_id'],);
                            }),
                ],
              ),
            ),
    );
  }
}

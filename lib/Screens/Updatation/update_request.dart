import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Updatation/business_update.dart';
import 'package:sdaemployee/Screens/Updatation/display_update.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';


// ignore: must_be_immutable
class UpdateRequest extends StatefulWidget {
    Map<String, dynamic> user;
   UpdateRequest({required this.user, super.key});

  @override
  State<UpdateRequest> createState() => _UpdateRequestState();
}

class _UpdateRequestState extends State<UpdateRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Request Update"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Request Update',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Section().builButtonCard([
            Buttons().buildListTile(
              icon: Icons.location_on,
              title: "Address",
              subtitle: "Personal Address",
              color: Colors.blueAccent,
               onTap: () async {
                await DialogClass().showFullScreenDialog(
                    context: context, module: "Address", id: widget.user['user_id']);
              },
            ),
            Buttons().buildListTile(
              icon: Icons.account_balance,
              title: "KYC",
              subtitle: "Bank Information",
              color: Colors.orangeAccent,
              onTap: () async {
                await DialogClass().showFullScreenDialog(
                    context: context, module: "KYC", id: widget.user['user_id']);
              },
            ),
            Buttons().buildListTile(
              icon: Icons.smart_display,
              title: "Display",
              subtitle: "Display Information",
              color: Colors.purpleAccent,
              onTap: () async {
               ScreenRouter.addScreen(context, DisplayUpdate(
                user: widget.user,
               ));
              },
            ),
            Buttons().buildListTile(
              icon: Icons.business,
              title: "Business",
              subtitle: "Business Information",
              color: Colors.greenAccent,
              onTap: () async {
               ScreenRouter.addScreen(context, BusinessUpdateRequest(
                user: widget.user,
               ));
              },
            ),
          ])
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Ads/Update%20Advertisement/update_advertistment.dart';
import 'package:sdaemployee/Screens/Ads/Upload%20Advertisement/advertisement_location.dart';
import 'package:sdaemployee/Screens/Ads/View%20Advertisement/view_ad_display.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

class AdDetailsScreen extends StatefulWidget {
  final dynamic adData;

  const AdDetailsScreen({required this.adData, Key? key}) : super(key: key);

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
  bool isLoading = false;
  Map<String, dynamic>? adDetails;
  late DateTime endDate;
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      endDate =
          DateTime.tryParse(widget.adData['end_date'] ?? "") ?? DateTime(0);
      fetchAdDetails();
    });
  }

  void fetchAdDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> res =
          await AdvertisementApi().fetchAdDetails(widget.adData['ads_id']);

      if (!mounted)
        return; // Check if the widget is still mounted before calling setState.

      setState(() {
        isLoading = false;
        adDetails = res['status'] ? res : null;
      });

      if (!res['status']) {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: res['message'],
        );
      }
    } catch (e) {
      if (!mounted)
        return; // Check if the widget is still mounted before calling setState.

      setState(() {
        isLoading = false;
      });
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something went wrong.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Ad Details"),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.6, // Adjust height as needed
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Section().buildShimmerList(100, 60, 5);
                  },
                ),
              )
            : adDetails != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Section().buildSectionTitle("Advertisement Info"),
                        Section().builButtonCard([
                          Section().buildDetailRow(
                              "Ad Type",
                              widget.adData['ad_type'] ?? "-",
                              Icons.type_specimen,
                              Colors.orangeAccent),
                          Section().buildDetailRow(
                              "Goal",
                              widget.adData['ad_goal'] ?? "-",
                              Icons.point_of_sale,
                              Colors.blueAccent),
                          Section().buildDetailRow(
                              "Start Date",
                              widget.adData['start_date'].substring(0, 10) ??
                                  "-",
                              Icons.calendar_month,
                              Colors.teal),
                          Section().buildDetailRow(
                              "End Date",
                              widget.adData['end_date'].substring(0, 10) ?? "-",
                              Icons.calendar_month,
                              Colors.teal),
                          Section().buildDetailRow(
                              "Status",
                              widget.adData['ad_status'] ?? "-",
                              Icons.card_travel,
                              Colors.deepPurple),
                          Section().buildDetailRow(
                              "Payment Status",
                              widget.adData['ad_bill_status'] ?? "-",
                              Icons.money,
                              Colors.greenAccent),
                        ]),
                        const SizedBox(height: 20.0),
                        if (currentDate.isBefore(endDate))
                          Buttons().updateButton(
                            buttonText: "Update Advertisement",
                            onPressed: () {
                              ScreenRouter.addScreen(
                                  context,
                                  UpdateAdvertistment(
                                      ad_action:
                                          widget.adData['ad_bill_status'] ==
                                                  "Unpaid" ||
                                              widget.adData['ad_bill_status'] ==
                                                  null,
                                      ad: widget.adData));
                            },
                          ),
                        const SizedBox(height: 20.0),
                        Divider(),
                        Section().buildSectionTitle("Ad Locations"),
                        ...buildAdLocations(adDetails!['ad_location']),
                        const SizedBox(height: 25.0),
                        Divider(),
                        Container(
                          margin: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Section().buildSectionTitle("Invoice Details"),
                              Section().buildDetailRow(
                                  "Total Cost",
                                  "₹${adDetails!['invoice']['total_cost'] ?? "-"}",
                                  Icons.money,
                                  Colors.greenAccent),
                              const SizedBox(height: 10.0),
                              Section().buildSectionTitle("Display Charges"),
                              Table(
                                border: TableBorder.all(
                                    color: Colors.grey, width: 0.5),
                                columnWidths: {
                                  0: FlexColumnWidth(screenWidth * 0.0029),
                                  1: FlexColumnWidth(screenWidth * 0.0027),
                                  2: FlexColumnWidth(screenWidth * 0.0024),
                                  3: FlexColumnWidth(screenWidth * 0.0022),
                                  4: FlexColumnWidth(1),
                                },
                                children: [
                                  // Table Header
                                  TableRow(
                                    decoration: const BoxDecoration(
                                        color: Colors.green),
                                    children: [
                                      buildTableCell("Display\nType",
                                          isHeader: true),
                                      buildTableCell("Charge", isHeader: true),
                                      buildTableCell("Count", isHeader: true),
                                      buildTableCell("Days", isHeader: true),
                                      buildTableCell("Cost", isHeader: true),
                                    ],
                                  ),
                                  // Table Rows for Each Display Charge
                                  ...adDetails!['invoice']['display_charge']
                                      .map<TableRow>((charge) {
                                    return TableRow(
                                      children: [
                                        buildTableCell(charge['display_type']),
                                        buildTableCell(
                                            "₹${charge['display_charge']}"),
                                        buildTableCell(
                                            charge['display_count'].toString()),
                                        buildTableCell(charge['no_of_days']),
                                        buildTableCell("₹${charge['cost']}"),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      "No details available.",
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ),
      ),
    );
  }

  Widget buildTableCell(String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 14.0,
          color: isHeader ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  List<Widget> buildAdLocations(Map<String, dynamic> locations) {
    List<Widget> widgets = [];
    locations.forEach((state, districts) {
      districts.forEach((district, talukas) {
        talukas.forEach((taluka, pinCodes) {
          pinCodes.forEach((pinCode, areas) {
            areas.forEach((area, boards) {
              widgets.add(Section().builButtonCard(
                [
                  Section().buildDetailRow(
                      "State", state, Icons.flag, Colors.deepPurple),
                  Section().buildDetailRow(
                      "District", district, Icons.location_city, Colors.green),
                  Section().buildDetailRow(
                      "Taluka", taluka, Icons.map, Colors.blueAccent),
                  Section().buildDetailRow(
                      "Pin Code", pinCode, Icons.location_on, Colors.teal),
                  Section().buildDetailRow(
                      "Area", area, Icons.place, Colors.orangeAccent),
                  Buttons().buildListTile(
                    icon: Icons.smart_display,
                    title: "Display",
                    subtitle: "View",
                    color: Colors.orangeAccent,
                    onTap: () {
                      ScreenRouter.addScreen(
                          context,
                          ViewAdDisplay(
                              ad_id: widget.adData['ads_id'],
                              address_ids: boards));

                      print(widget.adData['ads_id']);
                      print(boards);
                    },
                  ),
                ],
              ));
            });
          });
        });
      });
    });

    if (widgets.isEmpty) {
      widgets.add(
        Section().buildEmptyState("No Location Added", Icons.cloud_upload),
      );
      widgets.add(SizedBox(
        height: 10,
      ));
      widgets.add(Buttons().updateButton(
        buttonText: "Add Locations",
        onPressed: () {
          ScreenRouter.addScreen(
              context,
              AdvertisementLocation(
                  ad_id: widget.adData['ads_id'],
                  business_type_id: widget.adData['business_type_id']));
        },
      ));
    } else if (currentDate.isBefore(endDate) && (widget.adData['ad_bill_status'] == "Unpaid" || widget.adData['ad_bill_status'] == null)) {
      widgets.add(SizedBox(
        height: 10,
      ));
      widgets.add(Buttons().updateButton(
        buttonText: "Add More Locations",
        onPressed: () {
          ScreenRouter.addScreen(
              context,
              AdvertisementLocation(
                  ad_id: widget.adData['ads_id'],
                  business_type_id: widget.adData['business_type_id']));
        },
      ));
    }
    return widgets;
  }
}

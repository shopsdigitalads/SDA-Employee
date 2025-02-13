import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Ads/Upload%20Advertisement/advertisement_invoice.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';

// ignore: must_be_immutable
class AdvertisementDisplay extends StatefulWidget {
  final List<dynamic> address_ids;
  int ad_id;

  AdvertisementDisplay(
      {required this.ad_id, required this.address_ids, super.key});

  @override
  State<AdvertisementDisplay> createState() => _AdvertisementDisplayState();
}

class _AdvertisementDisplayState extends State<AdvertisementDisplay> {
  Map<String, dynamic> data = {};

  List<int> selectedDisplayIds = [];
  int total_cost = 0;
  bool isLoading = true;

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
          await AdvertisementApi().fetchDisplayWithAreas(widget.address_ids);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        setState(() {
          data = res['data'];
        });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Display",
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

  void updateTotalCost(int displayCharge, bool isSelected) {
    setState(() {
      if (isSelected) {
        total_cost += displayCharge;
      } else {
        total_cost -= displayCharge;
      }
    });
  }

  void submitDisplay() async {
    try {
      if (selectedDisplayIds.isEmpty) {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "No Display Selected",
        );
      } else {
        DialogClass().showLoadingDialog(context: context, isLoading: true);
        Map<String, dynamic> res = await AdvertisementApi()
            .submitDisplay(selectedDisplayIds, widget.ad_id);
        DialogClass().showLoadingDialog(context: context, isLoading: false);
        print(res);
        if (res['status']) {
          ScreenRouter.addScreen(
                    context,
                    AdvertisementInvoice(
                      calculationData: res['calculation'],
                      screen: 4,
                    ),slide: true);
          // DialogClass().showCustomDialog(
          //     context: context,
          //     icon: Icons.done,
          //     title: "Advertisement",
          //     message: res['message'],
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //       ScreenRouter.addScreen(
          //           context,
          //           AdvertisementInvoice(
          //             calculationData: res['calculation'],
          //             screen: 4,
          //           ));
          //     });
        } else {
          DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Advertisement Display",
            message: res['message'],
          );
        }
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Select Displays"),
      body: Stack(
        children: [
          !isLoading
              ? ListView(
                  children: data.entries.map((areaEntry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            areaEntry.key,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...areaEntry.value.entries.map((shopEntry) {
                          return Card(
                            margin: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ListTile(
                                    title: Text(
                                      shopEntry.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              for (var displayType
                                                  in shopEntry.value.values) {
                                                for (var display
                                                    in displayType) {
                                                  if (!selectedDisplayIds
                                                      .contains(display[
                                                          "display_id"])) {
                                                    selectedDisplayIds.add(
                                                        display["display_id"]);
                                                    updateTotalCost(
                                                        display[
                                                            "display_charge"],
                                                        true);
                                                  }
                                                }
                                              }
                                            });
                                          },
                                          child: const Text("Select All"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              for (var displayType
                                                  in shopEntry.value.values) {
                                                for (var display
                                                    in displayType) {
                                                  selectedDisplayIds.remove(
                                                      display["display_id"]);
                                                  updateTotalCost(
                                                      display["display_charge"],
                                                      false);
                                                }
                                              }
                                            });
                                          },
                                          child: const Text("Deselect All"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Table(
                                  columnWidths: {
                                    0: FixedColumnWidth(screenWidth * 0.18),
                                    1: FixedColumnWidth(screenWidth * 0.18),
                                    2: FixedColumnWidth(screenWidth * 0.18),
                                    3: FixedColumnWidth(screenWidth * 0.32),
                                  },
                                  border: TableBorder.all(
                                    color: Colors.black26,
                                    width: 1,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Display\nType',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Total',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Charge/Day',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Count',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    ...shopEntry.value.entries
                                        .map<TableRow>((typeEntry) {
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(typeEntry.key),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(typeEntry.value.length
                                                .toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                "₹ ${typeEntry.value[0]["display_charge"]}"
                                                    .toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: () {
                                                    setState(() {
                                                      for (var display
                                                          in typeEntry.value) {
                                                        if (selectedDisplayIds
                                                            .contains(display[
                                                                "display_id"])) {
                                                          selectedDisplayIds
                                                              .remove(display[
                                                                  "display_id"]);
                                                          updateTotalCost(
                                                              display[
                                                                  "display_charge"],
                                                              false);
                                                          break;
                                                        }
                                                      }
                                                    });
                                                  },
                                                ),
                                                Text(
                                                    "${typeEntry.value.where((display) => selectedDisplayIds.contains(display["display_id"])).length}"),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      for (var display
                                                          in typeEntry.value) {
                                                        if (!selectedDisplayIds
                                                            .contains(display[
                                                                "display_id"])) {
                                                          selectedDisplayIds
                                                              .add(display[
                                                                  "display_id"]);
                                                          updateTotalCost(
                                                              display[
                                                                  "display_charge"],
                                                              true);
                                                          break;
                                                        }
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                )
              : Container(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total/Day: ₹ ${total_cost}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.black), // Corrected here
                    ),
                    onPressed: () {
                      print(selectedDisplayIds);
                      submitDisplay();
                    },
                    child: const Text(
                      "Next ->",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

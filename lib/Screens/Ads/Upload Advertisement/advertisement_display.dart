import 'package:flutter/material.dart';
import 'package:sdaemployee/Screens/Ads/Upload%20Advertisement/advertisement_invoice.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'dart:math';

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
  double total_cost = 0;
  bool isLoading = true;
  bool isSelectedAll = false;
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

 void updateTotalCost(double? displayCharge, bool isSelected) {
  if (displayCharge == null) return;

  setState(() {
    if (isSelected) {
      total_cost += displayCharge;
    } else {
      total_cost = max(0.0, total_cost - displayCharge);
    }
  });
}

  void selectAllDisplayIds(Map<String, dynamic> data) {
    selectedDisplayIds.clear(); // clear existing selection
    total_cost = 0.0; // reset total cost

    data.forEach((location, clients) {
      clients.forEach((clientName, sections) {
        sections.forEach((sectionType, displayList) {
          for (var item in displayList) {
            selectedDisplayIds.add(item['display_id']);
            total_cost +=
                double.tryParse(item['display_charge'].toString()) ?? 0.0;
          }
        });
      });
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelectedAll,
                        onChanged: (bool? value) {
                          setState(() {
                            isSelectedAll = value ?? false;
                            if (isSelectedAll) {
                              selectAllDisplayIds(data);
                            } else {
                              selectedDisplayIds.clear();
                              total_cost = 0.0;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Select All Displays",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: !isLoading
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
                                                          display[
                                                              "display_id"]);
                                                      updateTotalCost(
                                                          double.tryParse(display[
                                                              'display_charge']),
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
                                                        double.tryParse(display[
                                                            "display_charge"]),
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
                                          tableHeaderCell('Display\nType'),
                                          tableHeaderCell('Total'),
                                          tableHeaderCell('Charge/Day'),
                                          tableHeaderCell('Count'),
                                        ],
                                      ),
                                      ...shopEntry.value.entries
                                          .map<TableRow>((typeEntry) {
                                        return TableRow(
                                          children: [
                                            tableCell(typeEntry.key),
                                            tableCell(typeEntry.value.length
                                                .toString()),
                                            tableCell(
                                                "₹ ${typeEntry.value[0]["display_charge"]}"),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        for (var display
                                                            in typeEntry
                                                                .value) {
                                                          if (selectedDisplayIds
                                                              .contains(display[
                                                                  "display_id"])) {
                                                            selectedDisplayIds
                                                                .remove(display[
                                                                    "display_id"]);
                                                            updateTotalCost(
                                                                double.tryParse(
                                                                    display[
                                                                        "display_charge"]),
                                                                false);
                                                            break;
                                                          }
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    "${typeEntry.value.where((display) => selectedDisplayIds.contains(display["display_id"])).length}",
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        for (var display
                                                            in typeEntry
                                                                .value) {
                                                          if (!selectedDisplayIds
                                                              .contains(display[
                                                                  "display_id"])) {
                                                            selectedDisplayIds
                                                                .add(display[
                                                                    "display_id"]);
                                                            updateTotalCost(
                                                                double.tryParse(
                                                                    display[
                                                                        "display_charge"]),
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
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total/Day: ₹ $total_cost",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.black),
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
        ],
      ),
    );
  }

  Widget tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }
}

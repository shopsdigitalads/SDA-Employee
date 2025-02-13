import 'package:flutter/material.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';

// ignore: must_be_immutable
class AdvertisementInvoice extends StatefulWidget {
  Map<String, dynamic> calculationData;
  int screen;

  AdvertisementInvoice(
      {required this.screen, required this.calculationData, super.key});

  @override
  State<AdvertisementInvoice> createState() => _AdvertisementInvoiceState();
}

class _AdvertisementInvoiceState extends State<AdvertisementInvoice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppbarClass().buildSubScreenAppBar(context,"Advertisement Invoice"),
      body: buildInvoiceContent(),
    );
  }

  Widget buildInvoiceContent() {
    final displayCharge = widget.calculationData["display_charge"] ?? [];
    final totalCost = widget.calculationData["total_cost"] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invoice Summary",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: displayCharge.length,
              itemBuilder: (context, index) {
                final item = displayCharge[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Display Type: ${item['display_type']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Charge Per Unit: ₹ ${item['display_charge']}"),
                        Text("Count: ${item['display_count']}"),
                        Text("Days: ${item['no_of_days']}"),
                        Text(
                          "Total Cost: ₹ ${item['cost']}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Text(
            "Total Cost: ₹ ${totalCost}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16),
          Buttons().submitButton(
            isLoading: false,
            onPressed: () {
              DialogClass().showCustomDialog(
                  context: context,
                  icon: Icons.done,
                  title: "Invoice",
                  message: "Advertisement Submited for Review",
                  onPressed: () {
                    if (widget.screen == 4) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  });
            },)
        ],
      ),
    );
  }
}

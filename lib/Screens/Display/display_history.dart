import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdaemployee/Services/API/Display/display_api.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

// ignore: must_be_immutable
class DisplayHistory extends StatefulWidget {
  int display_id;
  DisplayHistory({required this.display_id, super.key});

  @override
  State<DisplayHistory> createState() => _DisplayHistoryState();
}

class _DisplayHistoryState extends State<DisplayHistory> {
  List<dynamic> displayEarnings = [];
  double totalIncome = 0;
  double todayIncome = 0;
  bool isLoading = true;
  List<dynamic> adsList = [];
  bool _isMounted = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDisplayHistory();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void fetchDisplayHistory() async {
    try {
      if (!_isMounted) return;
      setState(() => isLoading = true);
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      Map<String, dynamic> res =
          await DisplayApi().fetchDisplayHistory(widget.display_id,formattedDate);

      if (_isMounted) {
        if (res['status']) {
          displayEarnings = res['display_earning'];
          adsList = res['ads_list'];
          calculateIncome();
        } else {
          DialogClass().showCustomDialog(
            context: context,
            icon: Icons.error,
            title: "Display History",
            message: res['message'],
          );
        }
      }
    } catch (e) {
      print(e);
      if (_isMounted) {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong",
        );
      }
    } finally {
      if (_isMounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void calculateIncome() {
    totalIncome = 0;
    todayIncome = 0;

    for (var earning in displayEarnings) {
      totalIncome += earning['total_earning'];
      todayIncome += earning['ad_count']??0;
    }

    if (_isMounted) {
      setState(() {});
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Display History"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIncomeCard("Total Ads", todayIncome, Icons.trending_up, Colors.green),
                _buildIncomeCard("Total Income", totalIncome, Icons.account_balance_wallet, Colors.blue),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            isLoading?CircularProgressIndicator():
            Buttons().updateButton(onPressed: fetchDisplayHistory,buttonText: "Fetch Details"),
            const SizedBox(height: 10),
            
            Expanded(
              child: isLoading
                  ? Section().buildShimmerList(30, 20, 6)
                  : displayEarnings.isEmpty && adsList.isEmpty
                      ? Section().buildEmptyState("No Data Available", Icons.hourglass_empty)
                      : ListView(
                         children: [
                        const SizedBox(height: 10),
                        Section().buildSectionTitle("Display Status"),
                        displayEarnings.isEmpty
                            ? Section().buildEmptyState("No Status Available", Icons.hourglass_empty)
                            : Column(
                                children: displayEarnings.map((earning) {
                                  String formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(DateTime.parse(earning['earning_date']));
                                  return _buildEarningCard(earning, formattedDate);
                                }).toList(),
                              ),
                        const SizedBox(height: 10),
                        Section().buildSectionTitle("Ads"),
                        adsList.isEmpty
                            ? Section().buildEmptyState("No Ads Available", Icons.hourglass_empty)
                            : Column(
                                children: adsList.map((ad) => _buildAdCard(ad)).toList(),
                              ),
                      ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard(Map ad) {
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(ad['start_date']));
  String endDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(ad['end_date']));

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 5,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade100,
        child: Icon(Icons.smart_display, color: Colors.orange),
      ),
      title: Text("Ad: ${ad['ad_campaign_name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Goal: ${ad['ad_goal']}"),
          Text("Start Date: $startDate"),
          Text("End Date: $endDate"),
          Text("Business Type : ${ad['business_type_name']}"),
          Text("Status: ${ad['ad_status']}"),
          if (ad['ad_description'] != null && ad['ad_description'].isNotEmpty)
            Text("Description: ${ad['ad_description']}"),
        ],
      ),
    ),
  );
}


  Widget _buildIncomeCard(
      String title, double amount, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text("₹$amount",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningCard(Map earning, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.monetization_on, color: Colors.blue),
        ),
        title: Text("Date: $date",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildInfoRow("Active Time:", "${earning['active_time']} mins",
                Icons.timer, Colors.green),
            _buildInfoRow("Inactive Time:", "${earning['inactive_time']} mins",
                Icons.timelapse, Colors.orange),
            _buildInfoRow("Ad Count:", "${earning['ad_count']} ",
                Icons.smart_display, Colors.purpleAccent),
            _buildInfoRow("Earnings:", "₹${earning['earning']}", Icons.money,
                Colors.green),
            _buildInfoRow(
                "Fine:", "₹${earning['fine']}", Icons.warning, Colors.red),
            _buildInfoRow("Total Earning:", "₹${earning['total_earning']}",
                Icons.calculate, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(label, style: TextStyle(fontWeight: FontWeight.w600))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

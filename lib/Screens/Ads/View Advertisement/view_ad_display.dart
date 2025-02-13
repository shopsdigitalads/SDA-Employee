import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';

class ViewAdDisplay extends StatefulWidget {
  final List<dynamic> address_ids;
  final int ad_id;

  const ViewAdDisplay(
      {required this.ad_id, required this.address_ids, Key? key})
      : super(key: key);

  @override
  State<ViewAdDisplay> createState() => _ViewAdDisplayState();
}

class _ViewAdDisplayState extends State<ViewAdDisplay> {
  Map<String, dynamic> displays = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDisplays();
    });
  }

  Future<void> fetchDisplays() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res = await AdvertisementApi()
          .fetchDisplayOfAds(widget.address_ids, widget.ad_id);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        setState(() {
          displays = res['displays'] ?? {};
        });
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: res['message'] ?? "Failed to fetch data.",
        );
      }
    } catch (e) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something went wrong.",
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
      appBar: AppbarClass().buildSubScreenAppBar(context, "Ad Displays"),
      body: isLoading
          ? Container()
          : displays.isNotEmpty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displays.entries.map((entry) {
                      final location = entry.key;
                      final types = entry.value as Map<String, dynamic>;
                      return buildLocationSection(location, types);
                    }).toList(),
                  ),
                )
              : const Center(
                  child: Text(
                    "No displays available.",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
    );
  }

  Widget buildLocationSection(String location, Map<String, dynamic> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Section().buildSectionTitle(location),
        ...types.entries.map((typeEntry) {
          final type = typeEntry.key;
          final displays = typeEntry.value as List<dynamic>;
          return buildDisplayTypeSection(type, displays);
        }).toList(),
        const Divider(height: 30, thickness: 1),
      ],
    );
  }

  Widget buildDisplayTypeSection(String type, List<dynamic> displays) {
    return Section().builButtonCard(
      [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            type,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
        ),
        ...displays.map((display) => buildDisplayCard(display)).toList(),
      ],
    );
  }

  Widget buildDisplayCard(Map<String, dynamic> display) {
    return  Section().buildDetailRow("Display ID", display['display_id'].toString(),
          Icons.smart_display_sharp, Colors.orangeAccent);
  }
}

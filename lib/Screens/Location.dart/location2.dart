import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Services/State/location_state.dart';

class LocationEmployee extends StatefulWidget {
  const LocationEmployee({super.key});

  @override
  State<LocationEmployee> createState() => _LocationEmployeeState();
}

class _LocationEmployeeState extends State<LocationEmployee> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!Provider.of<LocationProvider>(context, listen: false).isSetup) {
        Provider.of<LocationProvider>(context, listen: false).setup();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: !location.isSetup || location.currentLocation == null
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : FlutterMap(
              mapController: location.mapController,
              options: MapOptions(
                initialCenter: location.currentLocation!,
                initialZoom: 15,
                onMapReady: () {
                  location.mapInitialized = true;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location.currentLocation!,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    )
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () =>
                          debugPrint("OpenStreetMap attribution clicked"),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sdaemployee/Constant/constant.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LocationProvider with ChangeNotifier {
  LatLng? currentLocation;
  IO.Socket? socket;
  final MapController mapController = MapController();
  bool mapInitialized = false; // 🔴 Flag to track if map is built
  late User user;
  bool isSetup = false;

  Future<void> getUser() async {
    user = await SharePrefs().getUser();
  }

  Future<void> setup() async {
    try {
      await getUser();
      await _connectToSocket();
      await _getCurrentLocation();
      isSetup = true;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> _connectToSocket() async {
    try {
      await getUser();
      debugPrint("Connecting to Socket...");
      socket = IO.io(
          live_api_link,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setReconnectionAttempts(5) // Reconnect attempts
              .build());

      socket!.connect();
      socket!.onConnect((_) => debugPrint("Socket Connected!"));
      socket!.onDisconnect((_) => debugPrint("Socket Disconnected!"));
    } catch (e) {
      debugPrint("Socket connection error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      Geolocator.getPositionStream(
          locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update every 1 meter
      )).listen((Position position) {
        LatLng newLocation = LatLng(position.latitude, position.longitude);
        currentLocation = newLocation;
        notifyListeners();
        // 🔴 Ensure the map is initialized before moving it
        if (mapInitialized) {
          mapController.move(newLocation, mapController.camera.zoom);
        }
        socket!.emit('identify', 'employee');
        socket!.emit('updateLocation', {
          'employeeId': user.user_id, // Replace with actual employee ID
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }


   void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      debugPrint("Socket manually disconnected.");
    }
  }

  @override
  void dispose() {
    disconnectSocket(); // Disconnect when provider is disposed
    super.dispose();
  }
}

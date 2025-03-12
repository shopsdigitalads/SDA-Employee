import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LocationService {
  IO.Socket? socket;

  void initSocket() {
    socket = IO.io('http://your-server-ip:3000', 
      IO.OptionBuilder().setTransports(['websocket']).build());
      
    socket!.connect();
    socket!.onConnect((_) => print('Connected to server'));
  }

  Future<void> trackLocation(String employeeId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,  // Send update every 10 meters
      ),
    ).listen((Position position) {
      print("Location: ${position.latitude}, ${position.longitude}");

      // Send location to the backend
      socket!.emit('updateLocation', {
        'employeeId': employeeId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    });
  }
}

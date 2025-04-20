import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class GPSTrackingPage extends StatefulWidget {
  const GPSTrackingPage({super.key});

  @override
  State<GPSTrackingPage> createState() => _GPSTrackingPageState();
}

class _GPSTrackingPageState extends State<GPSTrackingPage> {
  BluetoothConnection? _connection;
  String status = 'Checking permissions...';

  Position? _phonePosition;
  Position? _carPosition;

  Timer? _timer;
  GoogleMapController? _mapController;
  final List<LatLng> _carPath = [];
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _carIcon;

  String _incomingBuffer = "";

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connection?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndStart() async {
    try {
      // Request location permission
      await Permission.locationWhenInUse.request();

      // Enable Bluetooth
      await FlutterBluetoothSerial.instance.requestEnable();
      bool isBluetoothEnabled =
          await FlutterBluetoothSerial.instance.isEnabled ?? false;
      if (!isBluetoothEnabled) {
        setState(() => status = '❌ Bluetooth is not enabled');
        return;
      }

      // Request precise location permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() => status = '❌ Location permission denied');
          return;
        }
      }

      await _loadCustomMarker();
      await _startTracking();
    } catch (e) {
      setState(() => status = '❌ Startup error: $e');
    }
  }

  Future<void> _loadCustomMarker() async {
    try {
      _carIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/car_icon.png',
      );
    } catch (e) {
      print("Error loading marker: $e");
    }
  }

  Future<void> _startTracking() async {
    try {
      final bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      final hcDevice = bondedDevices.firstWhere(
        (device) =>
            device.name != null &&
            device.name!.toUpperCase().contains('HC'),
        orElse: () => throw Exception('No HC device found.'),
      );

      _connection = await BluetoothConnection.toAddress(hcDevice.address);
      setState(() => status = '✅ Connected to ${hcDevice.name}');

      await Future.delayed(const Duration(seconds: 2));

      // Start sending data request
      _connection!.output.add(utf8.encode("start\n"));
      await _connection!.output.allSent;

      // Listen for data
      _connection!.input!.listen((Uint8List data) {
        try {
          _incomingBuffer += utf8.decode(data);
          while (_incomingBuffer.contains('\n')) {
            final index = _incomingBuffer.indexOf('\n');
            final line = _incomingBuffer.substring(0, index).trim();
            _incomingBuffer = _incomingBuffer.substring(index + 1);
            _handleCarData(line);
          }
        } catch (e) {
          print('Bluetooth decode error: $e');
        }
      }, onError: (error) {
        print('Bluetooth stream error: $error');
      });

      // Start updating phone location every second
      _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        await _updatePhoneLocation();
      });
    } catch (e) {
      setState(() => status = '❌ Error: $e');
    }
  }

  Future<void> _updatePhoneLocation() async {
    try {
      final phoneLoc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _phonePosition = phoneLoc;
      });
    } catch (e) {
      print("Error getting phone location: $e");
    }
  }

  void _handleCarData(String message) {
    if (!message.contains(',')) return;

    final parts = message.split(',');
    if (parts.length != 2) return;

    final lat = double.tryParse(parts[0]);
    final lon = double.tryParse(parts[1]);
    if (lat == null || lon == null) return;

    final newPos = Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    setState(() {
      _carPosition = newPos;
      final latLng = LatLng(lat, lon);
      _carPath.add(latLng);

      _polylines = {
        Polyline(
          polylineId: const PolylineId("car_path"),
          points: _carPath,
          color: Colors.blue,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lon)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Live Car Tracking'),
        backgroundColor: const Color.fromRGBO(50, 85, 131, 1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _connection?.isConnected == true
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: _connection?.isConnected == true
                      ? Colors.blue
                      : Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(20.5937, 78.9629), // Default view (India)
                  zoom: 4,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: {
                  if (_carPosition != null)
                    Marker(
                      markerId: const MarkerId('car'),
                      position: LatLng(
                          _carPosition!.latitude, _carPosition!.longitude),
                      icon: _carIcon ??
                          BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                      infoWindow: const InfoWindow(title: 'Car'),
                    ),
                  if (_phonePosition != null)
                    Marker(
                      markerId: const MarkerId('phone'),
                      position: LatLng(_phonePosition!.latitude,
                          _phonePosition!.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                      infoWindow: const InfoWindow(title: 'Phone'),
                    ),
                },
                polylines: _polylines,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

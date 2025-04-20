import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:arduino_app/tracking_page.dart';

class GPSServicePage extends StatefulWidget {
  const GPSServicePage({super.key});

  @override
  State<GPSServicePage> createState() => _GPSServicePageState();
}

class _GPSServicePageState extends State<GPSServicePage> {
  String statusMessage = 'Press the button to send location to car';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _handleInitialPermissions();
  }

  Future<void> _handleInitialPermissions() async {
    try {
      // Request location permission
      await Permission.locationWhenInUse.request();

      // Request Bluetooth permissions (Android 12+)
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      log('Permission request failed: $e');
    }
  }

  Future<Position> _safeGetCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _sendLocationToHCDevice() async {
    setState(() {
      isLoading = true;
      statusMessage = '🔄 Preparing to send location...';
    });

    BluetoothConnection? connection;

    try {
      final bluetoothState = await FlutterBluetoothSerial.instance.state;
      if (bluetoothState != BluetoothState.STATE_ON) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }

      final bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      final hcDevice = bondedDevices.firstWhere(
        (device) => device.name != null && device.name!.toUpperCase().contains('HC'),
        orElse: () => throw Exception('No paired HC-05 device found.'),
      );

      setState(() {
        statusMessage = '📡 Found: ${hcDevice.name}';
      });

      connection = await BluetoothConnection.toAddress(hcDevice.address);
      setState(() {
        statusMessage = '🔗 Connected to ${hcDevice.name}, getting location...';
      });

      Position position;
      try {
        position = await _safeGetCurrentPosition();
      } catch (e) {
        log('❌ Failed to get location: $e');
        setState(() {
          statusMessage = '❌ Location error: $e';
        });
        return;
      }

      final String message = '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}\n';
      log("Sending: $message");

      connection.output.add(Uint8List.fromList(utf8.encode(message)));
      await connection.output.allSent;

      setState(() {
        statusMessage = '✅ Location sent to ${hcDevice.name}';
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GPSTrackingPage()),
        );
      }
    } catch (e) {
      log('❌ Error: $e');
      setState(() {
        statusMessage = '❌ Error: $e';
      });
    } finally {
      connection?.finish();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Control'),
        backgroundColor: const Color.fromRGBO(50, 85, 131, 1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/car_location.png',
                height: 420,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : _sendLocationToHCDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(50, 85, 131, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Send Location to Car",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 40),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

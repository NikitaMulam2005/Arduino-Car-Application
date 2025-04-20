import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class HC05CarController extends StatefulWidget {
  const HC05CarController({super.key});

  @override
  State<HC05CarController> createState() => _HC05CarControllerState();
}

class _HC05CarControllerState extends State<HC05CarController> {
  BluetoothConnection? connection;
  bool isConnected = false;
  BluetoothDevice? device;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    requestPermissionsAndInit();
  }

  Future<void> requestPermissionsAndInit() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    await FlutterBluetoothSerial.instance.requestEnable();
  }

  Future<void> startScanAndConnect() async {
    setState(() => isConnecting = true);

    try {
      final bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

      if (bondedDevices.isEmpty) {
        throw Exception("No bonded devices found");
      }

      final hc05 = bondedDevices.firstWhere(
        (d) => d.name?.toUpperCase().contains('HC') ?? false,
        orElse: () => bondedDevices.first,
      );

      final conn = await BluetoothConnection.toAddress(hc05.address);
      setState(() {
        connection = conn;
        isConnected = true;
        device = hc05;
        isConnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${hc05.name}')),
      );
    } catch (e) {
      setState(() => isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    }
  }

  void sendCommand(String command) {
    if (connection != null && isConnected) {
      connection!.output.add(Uint8List.fromList(command.codeUnits));
    }
  }

  void disconnect() {
    connection?.dispose();
    setState(() {
      isConnected = false;
      device = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Smart Bluetooth Car Key",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text("Control at your fingertips", style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 20),

                // Keyring
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Center(
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Car Key Body
                Container(
                  width: 200,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isConnecting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : GestureDetector(
                              onTap: isConnected ? disconnect : startScanAndConnect,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isConnected ? Colors.green : Colors.grey,
                                ),
                                child: const Icon(Icons.bluetooth, color: Colors.white, size: 20),
                              ),
                            ),
                      const SizedBox(height: 20),
                      controlButton(Icons.arrow_upward, "F"),
                      const SizedBox(height: 10),
                      controlButton(Icons.arrow_downward, "B"),
                      const SizedBox(height: 10),
                      controlButton(Icons.arrow_back, "L"),
                      const SizedBox(height: 10),
                      controlButton(Icons.arrow_forward, "R"),
                      const SizedBox(height: 10),

                      // Power off button
                      GestureDetector(
                        onTap: disconnect,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(Icons.power_settings_new, color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back arrow
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

 Widget controlButton(IconData icon, String command) {
  return GestureDetector(
    onTapDown: (_) => sendCommand(command),
    onTapUp: (_) => sendCommand("S"),
    onTapCancel: () => sendCommand("S"),
    child: Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 30, color: Colors.black),
    ),
  );
}
}

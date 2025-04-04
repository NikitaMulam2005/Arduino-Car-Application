import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothCarController extends StatefulWidget {
  const BluetoothCarController({super.key});

  @override
  State<BluetoothCarController> createState() => _BluetoothCarControllerState();
}

class _BluetoothCarControllerState extends State<BluetoothCarController> {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void startScan() async {
    await requestPermissions();
    final isOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    if (!isOn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please turn on Bluetooth")),
      );
      return;
    }
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    showModalBottomSheet(
      context: context,
      builder: (context) => StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.scanResults,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No devices found"));
          }
          return ListView(
            children: snapshot.data!.map((result) {
              final name = result.device.platformName.isEmpty
                  ? "Unknown Device"
                  : result.device.platformName;
              return ListTile(
                title: Text(name),
                subtitle: Text(result.device.remoteId.toString()),
                onTap: () {
                  connectToDevice(result.device);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            characteristic = char;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        connectedDevice = device;
        isConnected = true;
      });

      FlutterBluePlus.stopScan();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    }
  }

  void sendCommand(String command) async {
    if (characteristic != null) {
      await characteristic!.write(command.codeUnits);
    }
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Control at your fingertips",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
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
                      // Bluetooth button
                      GestureDetector(
                        onTap: startScan,
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
                      GestureDetector(
                        onTap: () {
                          if (connectedDevice != null) {
                            connectedDevice!.disconnect();
                            setState(() {
                              connectedDevice = null;
                              isConnected = false;
                            });
                          }
                        },
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
      onTap: () => sendCommand(command),
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

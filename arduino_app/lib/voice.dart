import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:developer';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceControlPage extends StatefulWidget {
  final void Function(String) sendBluetoothData;
  final Function(BluetoothConnection?, bool)
  updateConnection; // Send connection + status

  const VoiceControlPage({
    super.key,
    required this.sendBluetoothData,
    required this.updateConnection,
  });

  @override
  State<VoiceControlPage> createState() => _VoiceControlPageState();
}

class _VoiceControlPageState extends State<VoiceControlPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _command = '';
  BluetoothConnection? connection;
  bool? _isBluetoothEnabled;
  bool _isConnected = false;
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkBluetoothPermissions();
  }

  Future<void> _checkBluetoothPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    await FlutterBluetoothSerial.instance.requestEnable();
    bool isBluetoothEnabled =
        await FlutterBluetoothSerial.instance.isEnabled ?? false;

    setState(() {
      _isBluetoothEnabled = isBluetoothEnabled;
    });

    if (_isBluetoothEnabled == true) {
      _connectToActiveBluetoothDevice();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth is not enabled')),
        );
      }
    }
  }

  Future<void> _connectToActiveBluetoothDevice() async {
    List<BluetoothDevice> pairedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    if (pairedDevices.isEmpty) {
      throw Exception("No bonded devices found");
    }

    final hc05 = pairedDevices.firstWhere(
      (d) => d.name?.toUpperCase().contains('HC') ?? false,
      orElse: () => pairedDevices.first,
    );
    try {
      connection = await BluetoothConnection.toAddress(hc05.address);
      setState(() {
        _connectedDevice = hc05;
        _isConnected = true;
      });

      // ✅ Notify ControlPage with connection and status
      widget.updateConnection(connection, true);
      return;
    } catch (e) {
      log('Failed to connect: $e');
      setState(() {
        _isConnected = false;
      });
      widget.updateConnection(null, false);
    }

   
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => log('onStatus: $val'),
        onError: (val) => log('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 2),
          onResult: (val) {
            setState(() {
              _command = val.recognizedWords;
              _isListening = false;
            });

            log('Recognized command: $_command');
            _executeCommand(_command.toLowerCase());
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _executeCommand(String command) {
    if (command.contains("forward")) {
      log("Moving forward");
      widget.sendBluetoothData("^");
    } else if (command.contains("back")) {
      log("Moving backward");
      widget.sendBluetoothData("-");
    } else if (command.contains("left")) {
      log("Turning left");
      widget.sendBluetoothData("<");
    } else if (command.contains("right")) {
      log("Turning right");
      widget.sendBluetoothData(">");
    } else if (command.contains("stop")) {
      log("Stopping");
      widget.sendBluetoothData("*");
    } else {
      log("Unrecognized command: '$command'");
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double circleSize = 150;
    final double animatedSize = _isListening ? circleSize + 30 : circleSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Control'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(50, 85, 131, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBluetoothEnabled != null && _isBluetoothEnabled!)
              Text(
                _isConnected
                    ? "Connected to ${_connectedDevice?.name ?? 'device'}"
                    : "Not connected to any device",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_isBluetoothEnabled == null || !_isBluetoothEnabled!)
              const Text(
                'Bluetooth is not enabled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _listen,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: animatedSize,
                    height: animatedSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withAlpha((0.6 * 255).toInt()),
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 50),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _command.isEmpty
                    ? "Tap the mic and speak a command"
                    : "You said: $_command",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

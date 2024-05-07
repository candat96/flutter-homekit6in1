import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_homekit6in1/flutter_homekit6in1.dart';

import '../components/scan_result_title.dart';
import 'device_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  bool _isScanning = false;
   @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterHomeKit.scanResults.listen((results) {
        List<ScanResult> response = results.where((element) => element.advertisementData.advName == 'Bluetooth BP').toList();
      _scanResults = response;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
    });

    _isScanningSubscription = FlutterHomeKit.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }
  Future onScanPressed() async {
    await FlutterHomeKit.systemDevices;
    await FlutterHomeKit.startScan(timeout: const Duration(seconds: 15));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterHomeKit.isScanningNow) {
      return FloatingActionButton(
        onPressed: () {
          FlutterHomeKit.stopScan();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
          onPressed: onScanPressed, child: const Text("SCAN"));
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connect();
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device));
    Navigator.of(context).push(route);
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          children: <Widget>[
            // ..._buildSystemDeviceTiles(context),
            ..._buildScanResultTiles(context),
          ],
        ),
      ),
      floatingActionButton: buildScanButton(context),
    );
  }
}

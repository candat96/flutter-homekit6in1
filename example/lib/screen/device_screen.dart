import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_homekit6in1/flutter_homekit6in1.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
    @override
  void initState() {
    super.initState();

    _connectionStateSubscription = widget.device.connectionState.listen((state) async {
      print(state);
      setState(() {
        _connectionState = state;
      });

    });

  }

   @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnect();
    } catch (e) {
      if (kDebugMode) {
        print('disconnect failed: ');
      }
    }
  }

   Future onConnectPressed() async {
    try {
      await widget.device.connect();
    } catch (e) {
      // if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
      //   // ignore connections canceled by the user
      // } else {
      //   Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
      // }
    }
  }

  Widget buildConnectButton(BuildContext context) {
      
    return Row(children: [
      TextButton(
          onPressed:  (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text(
             isConnected ? "DISCONNECT" : "CONNECT",
            style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.red),
          ))
    ]);
  }

  void handleOnMeasure (MeasurementType type) {
    FlutterHomeKitMeasure.onMeasurement(type, MeasurementGender.male, widget.device);
  }

  Widget buildMeasureButton(BuildContext context , MeasurementType type, String title) {
    return InkWell(
      onTap: () {
        handleOnMeasure(type);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: MediaQuery.of(context).size.width - 30,
        height: 50, 
        color: Colors.amber,
        child:  Center(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.advName),
        actions: [buildConnectButton(context)],
      ),
      body: Column(
        children: [
          buildMeasureButton(context, MeasurementType.sp02, 'SPO2'),
          buildMeasureButton(context, MeasurementType.temp, 'TEMP')
        ],
      ),
    );
  }
}
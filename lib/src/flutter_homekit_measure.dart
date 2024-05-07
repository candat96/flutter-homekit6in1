

part of flutter_homekit6in1;

class FlutterHomeKitMeasure {
  static List<int> createBluetoothPacket(List<int> data) {
    // Caculate checksum
    int checksum = data.reduce((value, element) => value + element) & 0xFF;
    // Length (not packhead, packtail và frame length)
    int frameLength = 1 + data.length + 1; // data type + data + checksum
    // create Bluetooth packet
    List<int> packet = [];
    // Packhead
    packet.addAll([0xA5, 0xA5]);
    // frame length
    packet.add(frameLength);

    packet.addAll(data);
    // checksum
    packet.add(checksum);
    // Packtail
    packet.addAll([0x5A, 0x5A]);
    return packet;
  }

  static onMeasurement(MeasurementType type,MeasurementGender gender, BluetoothDevice device) async {
    BluetoothCharacteristic? _characteristicWrite;
    List<BluetoothCharacteristic> _characteristicListen = [];
    final _services = await device.discoverServices();
    for (var service in _services) {
          for (var c in service.characteristics) {
              if (c.characteristicUuid.toString() == 'f000ffc1-0451-4000-b000-000000000000') {
                _characteristicWrite = c;
              }
              if (c.properties.write) {
                print('WRITE========: ${c.characteristicUuid}');
              }
              if (c.properties.notify) {
                _characteristicListen.add(c);
              }
          }
    }
    if (_characteristicWrite == null) {
      return;
    }
    handleSendData(type, gender, _characteristicWrite, _characteristicListen);
  }

  static List<String> convertToHex(List<int> inputList) {
    List<String> hexList = [];
    inputList.forEach((num) {
      hexList.add(num.toRadixString(16).toUpperCase().padLeft(2, '0'));
    });
    return hexList;
  }

  static handleSendData(MeasurementType type,MeasurementGender gender, BluetoothCharacteristic _characteristicWrite, List<BluetoothCharacteristic> _characteristicListen) async {
    final normalData = getDataSendByType(type, gender);
    if(normalData == null) return;
    final sendData = createBluetoothPacket(normalData);
    print(sendData);
    await _characteristicWrite.write(sendData);
    for (var element in _characteristicListen) {
        await element.setNotifyValue(true);
        element.onValueReceived.listen((value) {
            final result = convertToHex(value);
            print("VALUE=======>: ${element.characteristicUuid} : ${result}");
        });
    }
  }



  static List<int>? getDataSendByType(MeasurementType type, MeasurementGender gender) {
    int numberType = 0xB5;
    switch (type) {
      case MeasurementType.temp:
        numberType = 0xBF;
        break;
      case MeasurementType.sp02:
        numberType = 0xB5;
        break;
      default:
    }
    int genderValue = gender == MeasurementGender.male ? 0x01 : 0x00;
    return [numberType, genderValue];
  }

}
enum MeasurementType {
    temp,
    sp02, //sp02
    bloodPressure, // blood pressure
    bloodGlucose, // blood glucose
    acidUric // Acid Uric
}

enum MeasurementGender {
    male,
    female
}
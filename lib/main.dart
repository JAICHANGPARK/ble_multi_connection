import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Multi Connection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BLE Multi Connection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription scanStreamSubscription;

  StreamSubscription dataStreamSubscription0;
  StreamSubscription dataStreamSubscription1;

  BluetoothDevice _bluetoothDevice0;
  BluetoothDevice _bluetoothDevice1;

  BluetoothCharacteristic bluetoothCharacteristic0;
  BluetoothCharacteristic bluetoothCharacteristic1;

  List<String> data0 = [];
  List<String> data1 = [];

  ScrollController controller = new ScrollController();

  void _incrementCounter() {
    scanStreamSubscription = flutterBlue.scan(timeout: Duration(seconds: 15)).listen((event) {
      print("${event.device.name} / ${event.device.id}");
      //B4:E6:2D:C9:BD:37
      //84:0D:8E:D2:A5:6A
      if (event.device.id.id == "84:0D:8E:D2:A5:6A") {
        flutterBlue.stopScan().then((_) async {
          _bluetoothDevice0 = event.device;
          await _bluetoothDevice0.connect();
          print("Device Connected");
        });
      }
      // if(event.device.id.id == "B4:E6:2D:C9:BD:37"){
      //
      // }
    });
  }

  void _incrementCounter2() {
    scanStreamSubscription = flutterBlue.scan(timeout: Duration(seconds: 15)).listen((event) {
      print("${event.device.name} / ${event.device.id}");
      //B4:E6:2D:C9:BD:37
      //84:0D:8E:D2:A5:6A
      if (event.device.id.id == "B4:E6:2D:C9:BD:37") {
        flutterBlue.stopScan().then((_) async {
          _bluetoothDevice1 = event.device;
          await _bluetoothDevice1.connect();
          print("Device Connected");
        });
      }
      // if(event.device.id.id == "B4:E6:2D:C9:BD:37"){
      //
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MaterialButton(
              color: Colors.red,
              child: Text("Stop Scan"),
              onPressed: () {
                flutterBlue.stopScan();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  color: Colors.blue,
                  child: Text("Discover Service Device 1"),
                  onPressed: () {
                    _bluetoothDevice0.discoverServices().then((value) {
                      value.forEach((element) {
                        print("Service: ${element.uuid.toString()}");
                        if (element.uuid.toString() == "0000fff0-0000-1000-8000-00805f9b34fb") {
                          element.characteristics.forEach((element) {
                            if (element.uuid.toString() == "0000fff2-0000-1000-8000-00805f9b34fb") {
                              bluetoothCharacteristic0 = element;
                            }
                          });
                        }
                      });
                    });
                  },
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: Text("Discover Service Device 2"),
                  onPressed: () {
                    _bluetoothDevice1.discoverServices().then((value) {
                      value.forEach((element) {
                        print("Service: ${element.uuid.toString()}");
                        if (element.uuid.toString() == "0000ffe0-0000-1000-8000-00805f9b34fb") {
                          element.characteristics.forEach((element) {
                            print("Char : ${element.uuid.toString()}");
                            if (element.uuid.toString() == "0000ffe2-0000-1000-8000-00805f9b34fb") {
                              bluetoothCharacteristic1 = element;
                            }
                          });
                        }
                      });
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  color: Colors.blue,
                  child: Text("Listen Data Device 1"),
                  onPressed: () async {
                    if (bluetoothCharacteristic0 != null) {
                      await bluetoothCharacteristic0.setNotifyValue(true);
                      dataStreamSubscription0 = bluetoothCharacteristic0.value.listen((event) {
                        print("Data0 : ${event}");
                        if (event.length > 0) {
                          setState(() {
                            data0.add(event[0].toString());
                          });
                        }
                      });
                    }
                  },
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: Text("Listen Data Device 2"),
                  onPressed: () async {
                    if (bluetoothCharacteristic1 != null) {
                      await bluetoothCharacteristic1.setNotifyValue(true);
                      dataStreamSubscription1 = bluetoothCharacteristic1.value.listen((event) {
                        print("Data1 : ${event}");
                        if (event.length > 0) {
                          setState(() {
                            controller.jumpTo(controller.position.maxScrollExtent);
                            data1.add(event[0].toString());
                          });
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  child: Text("Disconnected Device 1"),
                  color: Colors.green,
                  onPressed: () async {
                    await _bluetoothDevice0.disconnect();
                    await dataStreamSubscription0?.cancel();
                    dataStreamSubscription0 = null;
                    setState(() {
                      data0.clear();
                    });

                  },
                ),
                MaterialButton(
                  child: Text("Disconnected Device 2"),
                  color: Colors.green,
                  onPressed: () async {
                    await _bluetoothDevice1.disconnect();
                    await dataStreamSubscription1?.cancel();
                    dataStreamSubscription1 = null;
                    setState(() {

                      data1.clear();
                    });
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 520,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: Text("Data0")),
                          Expanded(
                            child: ListView(
                              reverse: true,
                              children: [...data0.map((e) => Text(e))],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: Text("Data1")),
                          Expanded(
                            child: ListView(
                              controller: controller,
                              reverse: true,
                              children: [...data1.map((e) => Text(e))],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: Icon(Icons.search),
            ),
            SizedBox(
              width: 24,
            ),
            FloatingActionButton(
              onPressed: _incrementCounter2,
              tooltip: 'Increment',
              child: Icon(Icons.sanitizer),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scanStreamSubscription.cancel();
    dataStreamSubscription0.cancel();
    dataStreamSubscription1.cancel();
    super.dispose();
  }
}

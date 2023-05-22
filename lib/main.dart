import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barometer_plugin_n/barometer_plugin.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  double _reading = 0.0;
  double _reading2 = 0.0;
  double final_read = 0.0;
  double _buildingHeight = 0.0;
  double _bottomBuildingHeight = 0.0;
  double _topBuildingHeight = 0.0;
  double FciHeight = 150.0;
  double BuildingOfHeight = 0.0;
  static const double groundPressure = 1013.25;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      final reading = await BarometerPlugin.initialize();
    } on Exception {}
  }
  double calculateHeight(double final_read) {
    double pressureDiff = final_read - groundPressure;
    double BuildingOfHeight = pressureDiff * 8;
    return BuildingOfHeight.abs();
  }
  double calculateTopHeight(double _reading2) {
    double pressureDiff = groundPressure - _reading2;
    double topHeight = pressureDiff * 8.33;
    return topHeight;
  }
  double calculateBottomHeight(double _reading) {
    double pressureDiff = groundPressure - _reading;
    double bottomHeight = pressureDiff * 8.33;
    return bottomHeight;
  }

  double calculateBuildingHeight(double _reading, double _reading2) {
    double buildingHeight = _topBuildingHeight - _bottomBuildingHeight;
    return buildingHeight;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Barometer App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Bottom reading: $_reading'),
              ElevatedButton(
                child: Text("Get Barometer Bottom reading"),
                onPressed: () async {
                  final reading = await BarometerPlugin.reading;
                  setState(() {
                    _reading = reading;
                  });
                },
              ),
              SizedBox(height: 15),
              Text('Top reading: $_reading2'),
              ElevatedButton(
                child: Text("Get Barometer Top reading"),
                onPressed: () async {
                  final reading = await BarometerPlugin.reading;
                  setState(() {
                    _reading2 = reading;
                  });
                },
              ),
              SizedBox(height: 15),
              Text('BuildingHeight: $_buildingHeight'),
              ElevatedButton(
                child: Text("Get BuildingHeight"),
                onPressed: () {
                  setState(() {
                    _bottomBuildingHeight = calculateBottomHeight(_reading);
                    _topBuildingHeight = calculateTopHeight(_reading2);
                    _buildingHeight = calculateBuildingHeight(
                        _bottomBuildingHeight, _topBuildingHeight);
                  });
                },
              ),
              SizedBox(height: 15),
              Text('Building reading: $final_read'),
              ElevatedButton(
                child: Text("Get Barometer Any point reading"),
                onPressed: () async {
                  final reading = await BarometerPlugin.reading;
                  setState(() {
                    final_read = reading;
                  });
                },
              ),
              SizedBox(height: 15),
              Text(
                  'The height of the building above sea level: $BuildingOfHeight'),
              ElevatedButton(
                child: Text("Get BuildingHeight"),
                onPressed: () {
                  setState(() {
                    BuildingOfHeight = calculateHeight(final_read);
                  });
                },
              ),
              SizedBox(height: 15),
              ElevatedButton(
                child: Text("Compare FCI Height and Building Height"),
                onPressed: () {
                  String message = '';
                  if (_buildingHeight > FciHeight) {
                    message = 'The building is taller than the FCI height.';
                  } else if (_buildingHeight < FciHeight) {
                    message = 'The building is shorter than the FCI height.';
                  } else {
                    message =
                        'The building height is the same as the FCI height.';
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Comparison Result'),
                        content: Text(message),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

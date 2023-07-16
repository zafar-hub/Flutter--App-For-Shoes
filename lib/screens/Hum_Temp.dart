import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HumidityTemperaturePage extends StatefulWidget {
  @override
  _HumidityTemperaturePageState createState() => _HumidityTemperaturePageState();
}

class _HumidityTemperaturePageState extends State<HumidityTemperaturePage> {
  String humidity = 'Fetching...';
  String temperature = 'Fetching...';

  @override
  void initState() {
    super.initState();
    fetchData();
  }


  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.thingspeak.com/channels/2175581/feeds.json?api_key=1BPG3UAPL4BLEH2Y&results=2'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); ///made for debug

        final feeds = data['feeds'];
        print('Feeds: $feeds');

        if (feeds.isNotEmpty) {
          final latestFeed = feeds.last;
          print('Latest Feed: $latestFeed');/// made for debug ends

    setState(() {
    humidity = latestFeed['field2'].toString() + ' %';
    temperature = latestFeed['field1'].toString() + ' °C';
    });
    } else {
    // No data available
    setState(() {
    humidity = 'No Data';
    temperature = 'No Data';
    });
    }
    } else {
    // Error occurred while fetching data
    setState(() {
    humidity = 'Error';
    temperature = 'Error';
    });
    }
    } catch (e) {
    // Exception occurred while fetching data
    setState(() {
    humidity = 'Error';
    temperature = 'Error';
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Climate'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.purple[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleIndicator(
                label: 'Temperature',
                value: temperature,
              ),
              SizedBox(height: 20),
              CircleIndicator(
                label: 'Humidity',
                value: humidity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleIndicator extends StatelessWidget {
  final String label;
  final String value;

  const CircleIndicator({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 5.0,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

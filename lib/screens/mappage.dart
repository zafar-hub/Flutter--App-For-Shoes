import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 45;
const double CAMERA_BEARING = 30;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  bool noGPS = false;

  @override
  void initState() {
    super.initState();
    fetchCoordinates();
  }

  void fetchCoordinates() async {
    final url = 'https://api.thingspeak.com/channels/2175581/feeds.json?api_key=1BPG3UAPL4BLEH2Y&results=2';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feeds = data['feeds'];
        if (feeds.isNotEmpty) {
          final latestFeed = feeds.last;
          final field3 = latestFeed['field3'];
          final field5 = latestFeed['field5'];
          final field4 = latestFeed['field4'];

          if (field3 != null && field5 != null) {
            final latitude = double.tryParse(field5);
            final longitude = double.tryParse(field3);

            if (latitude != null && longitude != null) {
              setState(() {
                _markers.add(
                  Marker(
                    markerId: MarkerId('customMarker'),
                    position: LatLng(latitude, longitude),
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                );
              });
            }
          }

          if (field4 == '1') {
            setState(() {
              noGPS = true;
            });
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(30.268181, 66.94181), // Default target, will be updated with fetched coordinates
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            compassEnabled: false,
            tiltGesturesEnabled: false,
            markers: _markers,
            mapType: MapType.normal,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (noGPS)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.red,
                child: Text(
                  'NO GPS',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isLEDOn = false; // Track the state of LED
  bool isSoleOn = false; // Track the state of Sole

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to handle toggling the LED state
  void toggleLEDState(bool newValue) {
    setState(() {
      isLEDOn = newValue; // Update the LED state

      if (isLEDOn) {
        _animationController.forward(from: 0.0); // Start the animation
        _sendLEDRequest("on"); // Send request to Arduino
      } else {
        _animationController.reset(); // Reset the animation
        _sendLEDRequest("off"); // Send request to Arduino
      }
    });
  }

  // Function to handle toggling the Sole state
  void toggleSoleState(bool newValue) {
    setState(() {
      isSoleOn = newValue; // Update the Sole state

      if (isSoleOn) {
        _animationController.forward(from: 0.0); // Start the animation
        _sendSoleRequest("on"); // Send request to Arduino
      } else {
        _animationController.reset(); // Reset the animation
        _sendSoleRequest("off"); // Send request to Arduino
      }
    });
  }

  // Function to send LED control request to Arduino
  void _sendLEDRequest(String command) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.106.178/toggle_led1'));
      if (response.statusCode == 200) {
        print('LED control request sent!');
      } else {
        print('Error sending LED control request.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to send Sole control request to Arduino
  void _sendSoleRequest(String command) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.106.178/toggle_led2'));
      if (response.statusCode == 200) {
        print('Sole control request sent!');
      } else {
        print('Error sending Sole control request.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controls'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.purple[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LED image with animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoSwitch(
                  value: isLEDOn,
                  onChanged: toggleLEDState,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        isLEDOn
                            ? 'assets/images/led_image_on.png'
                            : 'assets/images/led_image_off.png',
                      ),
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        Colors.white, // Set the color to white
                        BlendMode.srcIn, // Apply the color to the image
                      ),
                    ),
                  ),
                  transform: Matrix4.rotationZ(
                      _animationController.value * 0.5 * 3.1415926535897932),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Sole image with animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoSwitch(
                  value: isSoleOn,
                  onChanged: toggleSoleState,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        isSoleOn
                            ? 'assets/images/sole_image_on.png'
                            : 'assets/images/sole_image_off.png',
                      ),
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        Colors.white, // Set the color to white
                        BlendMode.srcIn, // Apply the color to the image
                      ),
                    ),
                  ),
                  transform: Matrix4.rotationZ(
                      _animationController.value * 0.5 * 3.1415926535897932),
                ),
              ],
            ),
            SizedBox(height: 40),
            // LED status
            Text(
              'LED Status: ${isLEDOn ? 'ON' : 'OFF'}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // Set the text color to white
              ),
            ),
            SizedBox(height: 10),
            // Sole status
            Text(
              'Sole Status: ${isSoleOn ? 'ON' : 'OFF'}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // Set the text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}

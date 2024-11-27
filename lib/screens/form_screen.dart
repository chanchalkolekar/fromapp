import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async'; 
import 'package:flutter/services.dart';
import 'ema_watch_screen.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String _type = 'Buy';
  bool _isHovering = false;
  String? _selectedSymbol;
  String? _selectedName;

  final TextEditingController _lotController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

  late Timer _timer; // Timer for periodic updates
  bool _isLoading = false; // Loader state

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start timer for updating time
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  // Reset form fields
  void _resetForm() {
    setState(() {
      _lotController.clear();
      _selectedSymbol = null; // Reset to default
      _selectedName = null; // Reset to default
      _rateController.clear();
      _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _submitForm() async {
    // Validate if all fields are filled
    if (_selectedSymbol == null ||
        _selectedName == null ||
        _lotController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please fill all required fields!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red, // Red color for error
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return; // Stop further execution
    }

    // Start loader
    setState(() {
      _isLoading = true; // Show loader
    });

    final data = {
      'date': _currentDate,
      'time': _currentTime,
      'type': _type,
      'symbol': _selectedSymbol,
      'lot': _lotController.text,
      'name': _selectedName,
      'rate': _rateController.text,
    };

    final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbwOcq-KZATRGqLFw3dkerg_KCqgC7AK8uUxMDDMqfDwuYeFPoMZue8W7eqVxeWv0456oQ/exec');

    try {
      final httpClient = HttpClient();
      final request = await httpClient.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(data));

      final response = await request.close();

      // Hide loader
      setState(() {
        _isLoading = false;
      });

      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final responseData = jsonDecode(responseBody);

        print("Parsed Response: $responseData");

        if (responseData['status'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Data submitted successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm(); // Reset the form
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to submit data."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (response.statusCode == HttpStatus.movedTemporarily) {
        final redirectUrlList = response.headers['location'];
        if (redirectUrlList != null && redirectUrlList.isNotEmpty) {
          final redirectUrl = redirectUrlList.first;
          print("Redirected to: $redirectUrl");

          final redirectRequest = await httpClient.postUrl(
              Uri.parse(redirectUrl));
          redirectRequest.headers.set(
              HttpHeaders.contentTypeHeader, 'application/json');
          redirectRequest.write(jsonEncode(data));

          final redirectResponse = await redirectRequest.close();
          final redirectResponseBody = await redirectResponse.transform(
              utf8.decoder).join();
          print("Redirected Response Body: $redirectResponseBody");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Data submitted successfully after redirect!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm(); // Reset the form
        } else {
          print("No redirect URL found!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to handle redirection!")),
          );
        }
      }
    } catch (error) {
      // Hide loader
      setState(() {
        _isLoading = false;
      });
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("BUY / SELL RATE ENTRY"),
        backgroundColor: Colors.black, // Black AppBar background
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black, // Black background for the entire screen
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 350,
                  height: 600,
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(top: 7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Please fill all details carefully",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: "Date: $_currentDate"),
                                  decoration: InputDecoration(
                                    labelText: "Date",
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: "Time: $_currentTime"),
                                  decoration: InputDecoration(
                                    labelText: "Time",
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _type,
                                  decoration: InputDecoration(
                                    labelText: "Type",
                                    prefixIcon: Icon(Icons.swap_horiz),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: <String>['Buy', 'Sell']
                                      .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _type = value!;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedSymbol,
                                  decoration: InputDecoration(
                                    labelText: "Symbol",
                                    prefixIcon: Icon(Icons.account_balance),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: <String>[
                                    'MGOLD',
                                    'MSILVER',
                                    'CRUDEOIL',
                                    'NATURAL GAS',
                                    'MLEAD'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSymbol = value!;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedName,
                                  decoration: InputDecoration(
                                    labelText: "Name",
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: <String>[
                                    'SACHIN CODE',
                                    'ALEX CODE',
                                    'NS CODE',
                                    'NRJ11'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedName = value!;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _lotController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Lot",
                                    prefixIcon: Icon(Icons.layers),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _rateController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Rate",
                                    prefixIcon: Icon(Icons.attach_money),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                              (states) {
                                            if (_isHovering) {
                                              return Colors.lightGreen;
                                            }
                                            return Colors.white;
                                          }),
                                      foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                    ),
                                    onPressed: _submitForm,
                                    child: Text("Submit"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
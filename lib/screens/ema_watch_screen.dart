import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart'; // Import Workmanager

class EmaWatchScreen extends StatefulWidget {
  @override
  _EmaWatchScreenState createState() => _EmaWatchScreenState();
}

class _EmaWatchScreenState extends State<EmaWatchScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? htmlContent;
  bool isLoading = true;
  InAppWebViewController? webViewController;
  late Timer _timer; // Timer to periodically fetch data

  @override
  void initState() {
    super.initState();
    fetchHtmlData();
    initializeNotifications();

    // Call fetchHtmlData every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchHtmlData();
    });

    // Schedule the background task
    scheduleBackgroundTask();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void scheduleBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "checkTradeTask", // Unique task name
      "checkTrade", // Task identifier
      frequency: Duration(minutes: 15), // Adjust the interval
      initialDelay: Duration(seconds: 10), // Delay before the first execution
    );
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel name
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Trade Alert', // Title
      message, // Message body
      platformChannelSpecifics,
    );
  }

  Future<void> fetchHtmlData() async {
    try {
      final response = await http.get(Uri.parse(
          "https://docs.google.com/spreadsheets/d/e/2PACX-1vQneOq1zWiTY5E55y-loli-ybvuO9sH6sCJUj77u8kAWOUIGS3aC1F4updVqZrD8syi1KKwnA-2kFmo/pubhtml?gid=481559383&single=true"));
      if (response.statusCode == 200) {
        setState(() {
          // Add CSS to modify background and other styles
          htmlContent = """
          <!DOCTYPE html>
          <html>
            <head>
              <style>
                body {
                  background-color: black; /* Change background color */
                  color: white; /* Change text color */
                  margin: 5px;
                  padding: 0px;
                }
                table {
                  width: 60%; /* Adjust width */
                    min-height: 400px; /* Increase the table height */
          border-collapse: collapse; /* Ensure proper border display */
                }
                  td, th {
          border: 1px solid white; /* Border for table cells */
          padding: 8px; /* Padding inside cells */
          text-align: left; /* Align text to the left */
        }
        th {
          background-color: #333; /* Header background color */
          color: white; /* Header text color */
        }
              </style>
            </head>
            <body>
              ${response.body} <!-- Inject the API response here -->
            </body>
          </html>
        """;
          isLoading = false;

          // Reload WebView with updated data
          if (webViewController != null) {
            webViewController!.loadData(data: htmlContent!);
          }

          // Parse API response and check for "NO TRADE"
          if (response.body.contains("NO TRADE")) {
            // Do nothing
            showNotification("No trade is coming!");
          } else {
            showNotification("New trade data available!");
          }
        });
      } else {
        setState(() {
          htmlContent = "Error: Unable to fetch data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        htmlContent = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("EMA Watch"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : htmlContent != null
              ? InAppWebView(
                  initialData: InAppWebViewInitialData(data: htmlContent!),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),
                )
              : Center(child: Text("No content to display")),
    );
  }
}

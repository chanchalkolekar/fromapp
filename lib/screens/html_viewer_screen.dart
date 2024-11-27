import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HtmlViewerScreen extends StatelessWidget {
  final String htmlContent;

  HtmlViewerScreen({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EMA SHEET'),
      ),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(data: htmlContent),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
      ),
    );
  }
}

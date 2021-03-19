import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _signedTime = "-";
  String _unsignedTimeHttpClient = "-";
  String _unsignedTimeIOClient = "-";
  http.Client? client;

  void makeHttpsSigned() {
    setState(() {
      _signedTime = "-";
    });
    DateTime start = DateTime.now();
    HttpClient c =
        new HttpClient(context: SecurityContext(withTrustedRoots: true));
    c.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    c
        .getUrl(Uri.https("mariocsilva.tk", ""))
        .then((value) => value.close())
        .then((HttpClientResponse value) {
      setState(() {
        _signedTime =
            DateTime.now().difference(start).inMilliseconds.toString();
      });
    });
    //client!.get(Uri.https("mariocsilva.tk", "")).then((value) {
    //  setState(() {
    //    _signedTime = DateTime.now().difference(start).inMilliseconds.toString();
    //  });
    //});
  }

  void makeHttpsUnsignedWithHttpClient() {
    setState(() {
      _unsignedTimeHttpClient = "-";
    });
    DateTime start = DateTime.now();
    // This one is fast (300ms - 600ms)
    HttpClient c = new HttpClient();
    c.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    c
        .getUrl(Uri.https("easynet1.ecoforest.es:32268", ""))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      setState(() {
        _unsignedTimeHttpClient =
            DateTime.now().difference(start).inMilliseconds.toString();
      });
    });
  }

  void makeHttpsUnsignedWithIOClient() {
    setState(() {
      _unsignedTimeIOClient = "-";
    });
    DateTime start = DateTime.now();
    // This one takes 60 seconds to finish everytime
    Uri uri = Uri.https("easynet1.ecoforest.es:32268", "");
    client!.get(uri).then((value) {
      setState(() {
        _unsignedTimeIOClient =
            DateTime.now().difference(start).inMilliseconds.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    var ioClient = new HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    client = new IOClient(ioClient);
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
          children: <Widget>[
            Text(
              'HTTPS signed certificate duration: $_signedTime ms',
            ),
            Text(
              'HTTPS unsigned HttpClient duration: $_unsignedTimeHttpClient ms',
            ),
            Text(
              'HTTPS unsigned IOClient duration: $_unsignedTimeIOClient ms',
            ),
            SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
                onPressed: makeHttpsSigned,
                child: Text("Make HTTPS request to signed certificate")),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: ElevatedButton(
                  onPressed: makeHttpsUnsignedWithHttpClient,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Make HTTPS request to unsigned certificate with HttpClient",
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: ElevatedButton(
                  onPressed: makeHttpsUnsignedWithIOClient,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Make HTTPS request to unsigned certificate with IOClient",
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

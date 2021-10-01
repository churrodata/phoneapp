import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

//import 'package:http/http.dart' as http;
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'churro http POST Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'churro http POST Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _serviceEnabled = false;
  double? _logitude = 0.0;
  double? _latitude = 0.0;
  String _churroEndpoint = 'http://192.168.0.120:10000/extractsourcepost';
  String _activity = 'nothing at this point';


final myEmailController = TextEditingController();
final myActivityController = TextEditingController();
final myChurroURLController = TextEditingController();

  Location location = new Location();
  PermissionStatus _permissionGranted = PermissionStatus.granted;

  @override
  void initState() {
    _getThingsOnStartup().then((value){
      print('Async done');
    });
    super.initState();
  }

  Future _getThingsOnStartup() async {
    getLoc();
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myEmailController.dispose();
    myActivityController.dispose();
    super.dispose();
  }

  getLoc() async{
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

   _permissionGranted = await location.hasPermission();
   if (_permissionGranted == PermissionStatus.denied) {
     _permissionGranted = await location.requestPermission();
     if (_permissionGranted != PermissionStatus.granted) {
       return;
     }
   }

   _locationData = await location.getLocation();
   _logitude = _locationData.longitude;
   _latitude = _locationData.latitude;
 }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      getLoc();
	  
       logPhoneActivity(myChurroURLController.text, myActivityController.text, myEmailController.text, _logitude, _latitude);
    });
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _formKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
			  controller: myEmailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                return null;
              },
            ),
            TextFormField(
			  controller: myActivityController,
              decoration: const InputDecoration(
                hintText: 'Enter your activity status',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current activity status';
                }
                return null;
              },
            ),
            TextFormField(
			  //initialValue: 'something',
			  controller: myChurroURLController..text = _churroEndpoint,
              decoration: const InputDecoration(
                hintText: 'Enter your churro endpoint URL',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your churro endpoint URL';
                }
                return null;
              },
            ),
            Text(
              'You have sent messages this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'logitude/latitude',
            ),
            Text(
              '$_logitude/$_latitude',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

//Future<http.Response> logPhoneActivity(String activity, String email, String timevalue,  double longitude, double latitude) async {
 logPhoneActivity(String churroURL, String activity, String email, double? longitude, double? latitude) async {

  DateTime now = DateTime.now();
String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);
//String formattedDate = DateFormat.yMEd().add_jms().format(DateTime.now());

 final url = Uri.parse(churroURL);
  final headers = {"Content-type": "application/json", "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Credentials": "true", "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale", "Access-Control-Allow-Methods": "POST, OPTIONS"};
//'{"longitude": longitude, "latitude": latitude, "email": email, "activity": activity, "time": timevalue}';
  final json = jsonEncode(<String, String>{
'longitude': longitude.toString(), 
'latitude': latitude.toString(), 
'email': email, 
'activity': activity, 
'time': formattedDate,
  });
  final response = await post(url, headers: headers, body: json);
  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
  //print('activity=$activity');
}


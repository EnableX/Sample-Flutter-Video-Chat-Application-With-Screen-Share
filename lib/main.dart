import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screen_share_sample/video_call.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/Conference': (context) => MyConfApp(
          token: _MyHomePageState.token,
        )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});





  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*Your webservice host URL, Keet the defined host when kTry = true */
  static const String kBaseURL = "https://demo.enablex.io/";
  /* To try the app with Enablex hosted service you need to set the kTry = true */
  static bool kTry = true;
  /*Use enablec portal to create your app and get these following credentials*/

  static const String kAppId = "app_id";
  static const String kAppkey = "app_key";

  var header = (kTry)
      ? {
    "x-app-id": kAppId,
    "x-app-key": kAppkey,
    "Content-Type": "application/json"
  }
      : {"Content-Type": "application/json"};

  TextEditingController nameController = TextEditingController();
  TextEditingController roomIdController = TextEditingController();
  static String token = "";
  Future<void> _handleCameraAndMic() async {



// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();

  }
  Future<void> createRoomvalidations() async {
    if (nameController.text.isEmpty) {
      isValidated = false;
      Fluttertoast.showToast(
          msg: "This is Center Short Toast",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Fluttertoast.showToast(
          msg: "Please Enter your name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      isValidated = true;
    }
  }
  Future<void> joinRoomValidations() async {
    // await _handleCameraAndMic();
    if (permissionError) {
      Fluttertoast.showToast(
          msg: "Plermission denied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (nameController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter your name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      isValidated = false;
    } else if (roomIdController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter your roomId",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      isValidated = false;
    } else {
      isValidated = true;
    }
  }

  Future<String> createRoom() async {
    var response = await http.post(
        Uri.parse(
            "${kBaseURL}createRoom"), // replace FQDN with Your Server API URL
        headers: header);
    if (response.statusCode == 200) {
      Map<String, dynamic> user = jsonDecode(response.body);
      Map<String, dynamic> room = user['room'];

      setState(() => roomIdController.text = room['room_id'].toString());
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }
  Future<String> createToken() async {
    var value = {
      'user_ref': "2236",
      "roomId": roomIdController.text,
      "role": "participant",
      "name": nameController.text
    };
    print(jsonEncode(value));
    var response = await http.post(
        Uri.parse(
            "${kBaseURL}createToken"), // replace FQDN with Your Server API URL
        headers: header,
        body: jsonEncode(value));

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> user = jsonDecode(response.body);
      setState(() => token = user['token'].toString());
      print(token);
      Navigator.pushNamed(context, '/Conference');
      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  bool isValidated = false;
  bool permissionError = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleCameraAndMic();
  }
  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
      obscureText: false,
      style: style,
      controller: nameController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final roomIdField = TextField(
      obscureText: false,
      controller: roomIdController,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Room Id",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final createRoomButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        // minWidth: MediaQuery.of(context).size.width / 2,
        minWidth: 100,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          createRoomvalidations();
          if (isValidated) {
            createRoom();
          }
        },
        child: Text("Create Room",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );

    final joinButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        minWidth: 100,
        // minWidth: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {

          joinRoomValidations();
          if (isValidated) {
            createToken();
          }
        },
        child: Text("Join",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Sample App'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Enablex',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Welcome !',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: usernameField,
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: roomIdField),
                Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 100,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: createRoomButon)),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.all(10), child: joinButon)),
                      ],
                    ))
              ],
            )));
  }
}



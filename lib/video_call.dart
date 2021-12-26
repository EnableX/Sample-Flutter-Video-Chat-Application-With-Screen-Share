import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:enx_flutter_plugin/enx_player_widget.dart';

import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/android_notification_options.dart';

import 'package:flutter_foreground_task/models/notification_button.dart';
import 'package:flutter_foreground_task/models/notification_channel_importance.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

class MyConfApp extends StatefulWidget {
  MyConfApp({this.token});
  final String token;

  @override
  Conference createState() => Conference();
}

class Conference extends State<MyConfApp> {
  static const platformChannel = const MethodChannel('screen_share_data');
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  bool isScreenShare=false;
  String streamId,roomId;
   String roomID;
   String clientID;
  @override
  void initState() {
    super.initState();
    print('here 1');
    initEnxRtc();
    _initForegroundTask();

    _addEnxrtcEventHandlers();
  }

  Future<void> initEnxRtc() async {
    Map<String, dynamic> map2 = {
      'minWidth': 320,
      'minHeight': 180,
      'maxWidth': 1280,
      'maxHeight': 720
    };
    Map<String, dynamic> map1 = {
      'audio': true,
      'video': true,
      'data': true,
      'framerate': 30,
      'maxVideoBW': 1500,
      'minVideoBW': 150,
      'audioMuted': false,
      'videoMuted': false,
      'name': 'flutter',
      'videoSize': map2
    };
    print('here 2');
    await EnxRtc.joinRoom(widget.token, map1, null, null);
    print('here 3');
  }

  void _addEnxrtcEventHandlers() {
    print('here 4');
    EnxRtc.onRoomConnected = (Map<dynamic, dynamic> map)  {
      roomID =  map['id'];
      clientID = map["clientId"];
      print('RoomConnected ++++');
      EnxRtc.publish();

    };
    print('here 5');
   EnxRtc.OnCapturedView=(String bitmap){
     setState(() {
       print('OnCapturedView' + bitmap);
     });
    };
    EnxRtc.onPublishedStream = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onPublishedStream' + jsonEncode(map));
        EnxRtc.setupVideo(0, 0, true, 300, 200);
        platformChannel.invokeMethod('screen_share', {
          'streamId': map['streamId'],
          'roomId': 1234,

        });
      });
    };
    print('here 6');
    EnxRtc.onStreamAdded = (Map<dynamic, dynamic> map) {
      print('onStreamAdded' + jsonEncode(map));
      print('onStreamAdded Id' + map['streamId']);

      setState(() {
        streamId = map['streamId'];
      });
      EnxRtc.subscribe(streamId);
    };
    print('here 7');
    EnxRtc.onRoomError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomError' + jsonEncode(map));
      });
    };
    EnxRtc.onNotifyDeviceUpdate = (String deviceName) {
      print('onNotifyDeviceUpdate' + deviceName);
    };
    print('here 8');
    EnxRtc.onActiveTalkerList = (Map<dynamic, dynamic> map) {
      print('onActiveTalkerList ' + map.toString());
      print('here 9');
      final items = (map['activeList'] as List)
          .map((i) => new ActiveListModel.fromJson(i));
      if (items.length > 0) {
        print('here 10');
        setState(() {
          for (final item in items) {
            if(!_remoteUsers.contains(item.streamId)){
              print('_remoteUsers ' + map.toString());
              _remoteUsers.add(item.streamId);
            }
          }
        });
      }
    };
    print('here 11');
    EnxRtc.onEventError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventError' + jsonEncode(map));
      });
    };
    print('here 12');
    EnxRtc.onEventInfo = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventInfo' + jsonEncode(map));
      });
    };
    print('here 13');
    EnxRtc.onUserConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserConnected' + jsonEncode(map));
      });
    };
    EnxRtc.onUserDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserDisConnected' + jsonEncode(map));
      });
    };
    print('here 14');
    EnxRtc.onRoomDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomDisConnected' + jsonEncode(map));
        Navigator.pop(context, '/Conference');
      });
    };
    print('here 15');
    EnxRtc.onAudioEvent = (Map<dynamic, dynamic> map) {
      print('onAudioEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Audio Off") {
          isAudioMuted = true;
        } else {
          isAudioMuted = false;
        }
      });
    };
    print('here 16');
    EnxRtc.onVideoEvent = (Map<dynamic, dynamic> map) {
      print('onVideoEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Video Off") {
          isVideoMuted = true;
        } else {
          isVideoMuted = false;
        }
      });
    };
    //
    EnxRtc.onStartScreenShareACK=(Map<dynamic, dynamic> map){
      isScreenShare=true;
      Fluttertoast.showToast(
          msg: "onStartScreenShareACK+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onStoppedScreenShareACK=(Map<dynamic, dynamic> map){
      isScreenShare=false;
      Fluttertoast.showToast(
          msg: "onStoppedScreenShareACK+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onScreenSharedStarted=(Map<dynamic, dynamic> map){

      Fluttertoast.showToast(
          msg: "onScreenSharedStarted+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onScreenSharedStopped=(Map<dynamic, dynamic> map){

      Fluttertoast.showToast(
          msg: "onScreenSharedStopped+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    print('here 17');
  }

  void _setMediaDevice(String value) {
    Navigator.of(context, rootNavigator: true).pop();
    EnxRtc.switchMediaDevice(value);
  }

  createDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Media Devices'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: deviceList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(deviceList[index].toString()),
                          onTap: () =>
                              _setMediaDevice(deviceList[index].toString()),
                        );
                      },
                    ),
                  )
                ],
              ));
        });
  }

  void _disconnectRoom() {
    EnxRtc.disconnect();
    Navigator.pop(context);
  }

  void _toggleAudio() {
   // EnxRtc.captureScreenShot(streamId);
    if (isAudioMuted) {
      EnxRtc.muteSelfAudio(false);
    } else {
      EnxRtc.muteSelfAudio(true);
    }
  }

  void _toggleVideo() {
    if (isVideoMuted) {
      EnxRtc.muteSelfVideo(false);
    } else {
      EnxRtc.muteSelfVideo(true);
    }
  }
  //For Android Screen share need foreground service
  ReceivePort _receivePort;

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
        'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),

      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    ReceivePort receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',

      );
    }
    if (receivePort != null) {
      _receivePort = receivePort;

      return true;
    }

    return false;
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }


  void _toggleScreenShare() async{

    if (Platform.isAndroid) {
      if(isScreenShare){
        EnxRtc.stopScreenShare();
       _stopForegroundTask();
      }else{
       _startForegroundTask();
        EnxRtc.startScreenShare();

      }



    } else if (Platform.isIOS) {
      await SharedPreferenceAppGroup.setAppGroup('group.vcxsample');
      await SharedPreferenceAppGroup.setString('clientID', clientID);
      await SharedPreferenceAppGroup.setString('RoomID', roomID);
      print('Screen shared Clicked');
      ReplayKitLauncher.launchReplayKitBroadcast('BroadCastExtension');
    }

  }
  void _toggleSpeaker() async {
    List<dynamic> list = await EnxRtc.getDevices();
    setState(() {
      deviceList = list;
    });
    print('deviceList');
    print(deviceList);
    createDialog();
  }

  void _toggleCamera() {
    EnxRtc.switchCamera();
  }

  int remoteView = -1;
  List<dynamic> deviceList;

  Widget _viewRows() {
    return Column(
      children: <Widget>[
        for (final widget in _renderWidget)
          Expanded(
            child: Container(
              child: widget,
            ),
          )
      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    for (final streamId in _remoteUsers) {
      double width = MediaQuery.of(context).size.width;
      yield EnxPlayerWidget(streamId, local: false,width:width.toInt(),height:380);
    }
  }

  final _remoteUsers = List<int>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Container(
                alignment: Alignment.topRight,
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.black,
                  height: 100,
                  width: 100,
                  child: EnxPlayerWidget(0, local: true,width: 100, height: 100),
                )),
            Stack(
              children: <Widget>[
                Card(
                  color: Colors.black,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: MediaQuery.of(context).size.height - 200,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                              child: _viewRows()
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    color: Colors.white,
                    // height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 7,
                          child: MaterialButton(
                            child: isAudioMuted
                                ? Image.asset(
                              'assets/mute_audio.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            )
                                : Image.asset(
                              'assets/unmute_audio.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            ),
                            onPressed: _toggleAudio,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 7,
                          child: MaterialButton(
                            child: Image.asset(
                              'assets/camera_switch.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            ),
                            onPressed: _toggleCamera,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 7,
                          child: MaterialButton(
                            child: isVideoMuted
                                ? Image.asset(
                              'assets/mute_video.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            )
                                : Image.asset(
                              'assets/unmute_video.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            ),
                            onPressed: _toggleVideo,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 7,
                          child: MaterialButton(
                            child: Image.asset(
                              'assets/unmute_speaker.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            ),
                            onPressed: _toggleSpeaker,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 7,
                          child: MaterialButton(
                            child: Image.asset(
                              'assets/screenShare.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            ),
                            onPressed: _toggleScreenShare,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 7,
                          child: MaterialButton(
                            child: Image.asset(
                              'assets/disconnect.png',
                              fit: BoxFit.cover,
                              height: 25,
                              width: 25,
                            ),
                            onPressed: _disconnectRoom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ActiveList {
  bool active;
  List<ActiveListModel> activeList = [];
  String event;

  ActiveList(this.active, this.activeList, this.event);

  factory ActiveList.fromJson(Map<dynamic, dynamic> json) {
    return ActiveList(
      json['active'] as bool,
      (json['activeList'] as List).map((i) {
        return ActiveListModel.fromJson(i);
      }).toList(),
      json['event'] as String,
    );
  }
}

class ActiveListModel {
  String name;
  int streamId;
  String clientId;
  String videoaspectratio;
  String mediatype;
  bool videomuted;
  String reason;

  ActiveListModel(this.name, this.streamId, this.clientId,
      this.videoaspectratio, this.mediatype, this.videomuted, this.reason);

  // convert Json to an exercise object
  factory ActiveListModel.fromJson(Map<dynamic, dynamic> json) {
    int sId = int.parse(json['streamId'].toString());
    return ActiveListModel(
      json['name'] as String,
      sId,
//      json['streamId'] as int,
      json['clientId'] as String,
      json['videoaspectratio'] as String,
      json['mediatype'] as String,
      json['videomuted'] as bool,
      json['reason'] as String,
    );
  }
}

 # ScreenShare_FlutterToolKit

The sample Flutter App demonstrates the use of [EnableX platform Server APIs](https://www.enablex.io/developer/video-api/server-api) and [Flutter Toolkit](https://www.enablex.io/developer/video-api/client-api/flutter-toolkit/) to build 1-to-1 RTC (Real-Time Communication) Application. It allows developers to ramp up on app development by hosting on their own devices.

This App creates a virtual Room on the fly hosted on the Enablex platform using REST calls and uses the Room credentials (i.e. Room Id) to connect to the virtual Room as a Moderator or Participant using a mobile client. The same Room credentials can be shared with others to join the same virtual Room to carry out an RTC (Real-Time Communication) session.

EnableX Developer Center: https://developer.enablex.io/

## 1. How to get started

### 1.1 Prerequisites

#### 1.1.1 App Id and App Key

* Register with EnableX [https://portal.enablex.io/cpaas/trial-sign-up/] 
* Create your Application
* Get your App ID and App Key delivered to your email



#### 1.1.2 Sample Flutter Client

* [Clone or download this Repository](https://github.com/EnableX/Sample-Flutter-Video-Chat-Application-With-Screen-Share.git)

#### 1.1.3 Test Application Server

You need to setup an Application Server to provision Web Service API for your Flutter Application to enable Video Session.

To help you to try our Flutter Application quickly, without having to set up Application Server, this Application is shipped pre-configured to work in a "try" mode with EnableX hosted Application Server i.e. https://demo.enablex.io.

Our Application Server restricts a single Session Duations to 10 minutes, and allows 1 moderator and not more than 1 participant in a Session.

Once you tried EnableX flutter Sample Application, you may need to set up your own  Application Server and verify your Application to work with your Application Server.  Refer to point 2 for more details on this.


#### 1.1.4 Configure Flutter Client


* Open the App
* Go to main.dart and change the following:
``` 
 /* To try the app with Enablex hosted service you need to set the kTry = true 
  When you setup your own Application Service, set kTry = false */*/
 /* Your Web Service Host URL. Keet the defined host when kTry = true */
 static final String kBaseURL = "https://demo.enablex.io/";
 
  static bool kTry = true;
  /*Use enablec portal to create your app and get these following credentials*/

  static final String kAppId = "App-Id";
  static final String kAppkey = "App-key";
 ```

Note: The distributable comes with demo username and password for the Service. 

### 1.2 Test

#### 1.2.1 Open the App

* Open the App in your Device. You get a form to enter Credentials i.e. Name & Room Id.
* You need to create a Room by clicking the "Create Room" button.
* Once the Room Id is created, you can use it and share with others to connect to the Virtual Room to carry out an RTC Session either as a Moderator or a Participant (Choose applicable Role in the Form).

Note: Only one user with Moderator Role allowed to connect to a Virtual Room while trying with EnableX Hosted Service. Your Own Application Server can allow upto 5 Moderators.

Note:- In case of emulator/simulator your local stream will not create. It will create only on real device.

## 2. Set up Your Own Application Server

You may need to setup your own Application Server after you tried the Sample Application with EnableX hosted Server. We have differnt variants of Application Server Sample Code. Pick the one in your preferred language and follow instructions given in respective README.md file.

* NodeJS: [https://github.com/EnableX/Video-Conferencing-Open-Source-Web-Application-Sample.git]
* PHP: [https://github.com/EnableX/Group-Video-Call-Conferencing-Sample-Application-in-PHP]

Note the following:

* You need to use App ID and App Key to run this Service.
* Your Flutter Client EndPoint needs to connect to this Service to create Virtual Room and Create Token to join the session.
* Application Server is created using EnableX Server API while Rest API Service helps in provisioning, session access and post-session reporting.

To know more about Server API, go to:
https://www.enablex.io/developer/video-api/server-api



## 3. Flutter Toolkit
https://www.enablex.io/developer/video-api/client-api/flutter-toolkit/
   

## 4. Application Walk-through

### 4.1 Create Token

We create a Token for a Room Id to get connected to EnableX Platform to connect to the Virtual Room to carry out a RTC Session.

To create Token, we make use of Server API. Refer following documentation:
https://www.enablex.io/developer/video-api/server-api/rooms-route/#create-token


### 4.2 Connect to a Room, Initiate & Publish Stream

We use the Token to get connected to the Virtual Room. Once connected, we initiate local stream and publish into the room. Refer following documentation for this process:
https://www.enablex.io/developer/video-api/client-api/flutter-toolkit/room-connection/

### 4.3 To start screen share with enableX flutter plugin in flutter  IOS and android App 
  user need to add some required dependency in pubspec.yaml

   enx_flutter_plugin
   replay_kit_launcher
   shared_preference_app_group
   flutter_foreground_task
   ![GitHub Logo](/images/pubspec.png)
   
# For IOS


replay_kit_launcher will help to open RPSystemBroadcastPickerView in flutter iOS app.

ReplayKitLauncher.launchReplayKitBroadcast('BroadCastExtension');

Here 'BroadCastExtension' is the name of extension which user will add through xcode.



How to add BroadcastExtenssion

Open your flutter project's iOS native workspace (Runner.xcworkspace),
select Xcode -> File -> New -> Target and create a new Broadcast Upload Extension target.
![GitHub Logo](/images/broadcast.png)
![GitHub Logo](/images/broadcastDetails.png)

[After adding broadcast extension make sure you have added a correct bundle id for your broadcast extension and your app.]

After adding the broadcast extension, your broadcast will be open and you will start receiving sample buffer (buffer Frame of your image) in broadcast class Sample Handler through delegate method.

Sample Handler is the default class for broadcast extension, who are responsible for updating the state of current activity to extension target.



//To start getting sample buffer frame of screen.

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType; get buffer frame



There are some more broadcast delegate method as below

If broadcast stopped/finished

- (void)broadcastFinished;

If broadcast pause

- (void)broadcastPaused

If broadcast resume

- (void)broadcastResumed





shared_preference_app_group will help to share data from one target to another target.
How to add App Group :- App Target -> Signing & Capabilities -> Click + icon on Capability -> App Groups

![GitHub Logo](/images/appgroup.png)
After adding app group you need to set a common name for app-group.

[App Group should be add in bother app target as well as extension target and name of app group should be same on both target]



After adding the shared_preference_app_group user need to shared the roomId and clientID to broadcast extension through app group so that broadcast extenssion also join the same room and published the screen frame

Sample code to share data from flutter app to iOS native app.

await SharedPreferenceAppGroup.setAppGroup('group.vcxsample');
await SharedPreferenceAppGroup.setString('clientID', clientID);
await SharedPreferenceAppGroup.setString('RoomID', roomID);



How to get shared data in shared_preference_app_group to native app.



NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"appGroup_Name"];

NSString *roomID  [userDefault objectForKey:@" roomID"];

NSString *roomID  = [userDefault objectForKey:@" clientID"];



Here after getting roomID and clientID user need to pass same client id to sdk through below APIs from broadcast extension target.



[[EnxUtilityManager shareInstance] setAppGroupsName:@"group.vcxsample" withUserKey:@"clientID"];



And use this roomId to create new token from broadcast and EnableX on going session through broadcast extension.



To join the room through Broadcast extension, User need to add new Broadcast target in Pod file and below EnableX iOS sdks.



target 'BroadCastExtension' do

use_frameworks!

pod 'EnxRTCiOS'

pod 'Socket.IO-Client-Swift', '~> 15.0.0'

# Pods for BroadCastExtension

end

Also in Pod file add this



post_install do |installer|

installer.pods_project.targets.each do |target|

flutter_additional_ios_build_settings(target)|

installer.pods_project.build_configurations.each 	do |config|

config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'

config.build_settings['ENABLE_BITCODE'] = 'NO'

config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'

    end 

end

end



After joining room success through broadcast extension. Broadcast target will start getting callback from EnableX iOS sdk.



Connection Success

-(void)broadCastConnected

Connection Failed

-(void)failedToConnectWithBroadCast:(NSArray *)reason

Once Broadcast Started Success

-(void)didStartBroadCast:(NSArray *)data

Once Broadcast Stopped Success

-(void)didStoppedBroadCast:(NSArray *)data

Once user from main app will stop the screen shared

-(void)didRequestedExitRoom:(NSArray *_Nullable)Data



Once Broadcast user disconnect through Room

-(void)broadCastDisconnected



Once Owner of screen share disconnected from room.

-(void)disconnectedByOwner



Once Broadcast connected start sending from to EnableX room

-(void)sendVideoBuffer:(CVPixelBufferRef _Nonnull )sampleBuffer withTimeStamp:(int64_t)timeStampNs 


# For Android
 Add permission and register  foreground service
 ![GitHub Logo](/images/forgroundpermission.png)
 ![GitHub Logo](/images/registerservice.png)



When Screen share start then also need to start foreground service and when stop need to stop foreground service.

![GitHub Logo](/images/initservice.png)
![GitHub Logo](/images/startservice.png)


## 5 Demo

EnableX provides hosted Demo Application of different use-case for you to try out.

1. Try a quick Video Call: https://try.enablex.io
2. Sign up for a free trial https://portal.enablex.io/cpaas/trial-sign-up/

 

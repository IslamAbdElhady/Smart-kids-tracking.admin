import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kinder_garten/Screens/Chat/MultiReciver.dart';
import 'package:kinder_garten/Screens/Home_screen.dart';
import 'package:kinder_garten/Screens/LogIn_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './Chat_Screen.dart';
import './const.dart';
import './SettingsUnUsedYet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';


class MainScreen extends StatefulWidget {
  final String currentUserId;

  MainScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {

  MainScreenState({Key key, @required this.currentUserId});

  TextEditingController textEditingController = TextEditingController();

  final String currentUserId;
  //final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
//    firebaseMessaging.requestNotificationPermissions();
//
//    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
//      print('onMessage: $message');
//      showNotification(message['notification']);
//      return;
//    }, onResume: (Map<String, dynamic> message) {
//      print('onResume: $message');
//      return;
//    }, onLaunch: (Map<String, dynamic> message) {
//      print('onLaunch: $message');
//      return;
//    });
//
//    firebaseMessaging.getToken().then((token) {
//      print('token: $token');
//      Firestore.instance.collection('users').document(currentUserId).updateData({'pushToken': token});
//    }).catchError((err) {
//      Fluttertoast.showToast(msg: err.message.toString());
//    });
  }

  void configLocalNotification() {
//    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = new IOSInitializationSettings();
//    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
//    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//      Platform.isAndroid ? 'com.dfa.flutterchatdemo': 'com.duytq.flutterchatdemo',
//      'Flutter chat demo',
//      'your channel description',
//      playSound: true,
//      enableVibration: true,
//      importance: Importance.Max,
//      priority: Priority.High,
//    );
//    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//    var platformChannelSpecifics =
//        new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.show(
//        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
//        payload: json.encode(message));
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<Null> handleSignOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });

    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        LogInScreen(title: "KinderGarten",)),
            (Route<dynamic> route) => false);
  }

  List<DocumentSnapshot> selectUsers;
  List<bool> selectedValues;
  bool selectAll = false;


  _senMessages(){
    for(int i=0; i<selectedValues.length; i++){
      if(selectedValues[i]){
        MultiReceiver(peerId: selectUsers[i]["id"],id: currentUserId).
        onSendMessage(textEditingController.text, 0);
      }
    }
    textEditingController.clear();
    selectAll = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: (){
              handleSignOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context)=> LogInScreen(title: "KinderGarten",)));
            },
            icon: Icon(Icons.exit_to_app),
          ),
          IconButton(
            onPressed: (){
              showDialog(barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context){
                    return StatefulBuilder(

                      builder:(context,setState)=> Container(
                        child: AlertDialog(
                          backgroundColor: Colors.white,
                          title: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.topCenter,
                            child: CheckboxListTile(
                              value: selectAll,
                              onChanged: (value){
                                setState(() {
                                  selectAll = value;
                                  for(int i=0; i<selectedValues.length; i++){
                                    selectedValues[i] = value;
                                  }
                                });
                              },
                              title: Text("select all",style:
                              TextStyle(color: Colors.teal,fontSize: 20,fontWeight: FontWeight.w600),),
                            ),
                          ),
                          content: new Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                   // height: MediaQuery.of(context).size.height*0.6,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView(
                                      children: selectUsers.map((selectUser){
                                        int index = selectUsers.indexOf(selectUser);
                                        return selectUserWidget(
                                          index: index,
                                          userName: selectUser["nickname"],
                                          onChange: (v){
                                            setState(() {
                                              selectedValues[index] = v;
                                            });
                                          }
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.all(Radius.circular(7)),
                                  ),
                                  child: TextField(
                                    style: TextStyle(color: primaryColor, fontSize: 15.0),
                                    controller: textEditingController,
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Type your message...',
                                      hintStyle: TextStyle(color: greyColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            new IconButton(
                                onPressed:(){
                                  Navigator.pop(context);
                                  // send all messages
                                  _senMessages();
                                },
                                icon: new Icon(Icons.send,color: Colors.blue,),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              );
            },
            icon: Icon(Icons.group),
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    selectUsers = [];
                    snapshot.data.documents.forEach((user){
                      if(user['chattingWith'] == currentUserId){
                        selectUsers.add(user);
                      }
                    });


                    selectedValues = [];
                    selectUsers.forEach((f){
                      if(f['chattingWith'] == currentUserId){
                        selectedValues.add(false);
                      }
                    });

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['chattingWith'] != currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About me: ${document['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document.documentID,
                          peerAvatar: document['photoUrl'],
                        )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Widget selectUserWidget ({String userName,int index,Function onChange}){
    return CheckboxListTile(
      title: Text(userName),
      value: selectedValues[index],
      onChanged: onChange,
    );
  }
}

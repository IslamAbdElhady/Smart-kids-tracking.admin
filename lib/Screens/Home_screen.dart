import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kinder_garten/Screens/Chat/Chat_Screen.dart';
import 'package:kinder_garten/Screens/Map/Map_screen.dart';
import 'package:kinder_garten/Screens/LogIn_Screen.dart';
import 'package:kinder_garten/Widgets/CustomButton.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageScreen extends StatefulWidget {
  String currentUserId;

  HomePageScreen({this.currentUserId});
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  double latitude=0.0;
  double longitude=0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  LocationData  currentLocation;
  var location = new Location();

  Future<Map<String,double>> getCurrentLocation()async{
    Map<String,double> result={
      "latitude":0.0,
      "longitude":0.0
    };
    try {
      currentLocation = await location.getLocation();
      result = {
        "latitude":currentLocation.latitude,
        "longitude":currentLocation.longitude
      };
      setState(() {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
      });
    }catch (e) {
      currentLocation = null;
    }
    return result;
  }

  void _signOut()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context)=> LogInScreen(title: "KinderGarten",)));
    print("log out");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("KinderGarten",style: TextStyle(color: Colors.white,fontSize: 18),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.exit_to_app,color: Colors.white,),
          ),
        ],
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomButtonWidget(
                        title: "Track My Baby!",
                        onPressed: ()async{
                          await getCurrentLocation().then((result){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  ShowMap(result["longitude"],result["latitude"])),
                            );
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomButtonWidget(
                        title: "chat with admin",
                        onPressed: ()async{
                          print(">>>>>>>>>>>>>>>>>: ${widget.currentUserId}");
                          await Future.delayed(Duration(seconds: 3));
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=>
                                //MainScreen(currentUserId: widget.currentUserId,)
                            Chat(
                              //todo peerId is the static admin id
                              peerId: "SugcJJCtvuTC7y09GJZFyGX2CRB2",

                              // todo peerAvatar is the static admin avatar
                              peerAvatar: "https://www.w3schools.com/howto/img_avatar.png",
                            )
                            )
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

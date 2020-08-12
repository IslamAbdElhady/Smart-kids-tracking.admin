import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/distance.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/geolocation.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/timezone.dart';

class ShowMap extends StatefulWidget {

  double latitude;
  double longitude;
  ShowMap(this.longitude,this.latitude);
  @override
  _ShowMapState createState() => _ShowMapState(this.longitude,this.latitude);
}

class _ShowMapState extends State<ShowMap> {


  double latitude;
  double longitude;
  _ShowMapState(this.longitude,this.latitude);

  GoogleMapController _controller;
  static String _mapApiKey = "AIzaSyC_2Bl7U94OAHmQWVuYRhLjaWJdKJqH_-0";
  BitmapDescriptor customHomeIcon;
  BitmapDescriptor customChildIcon;
  Set<Marker> markers;

  createHomeMarker(context) {
    if (customHomeIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/home.png')
          .then((icon) {
        setState(() {
          customHomeIcon = icon;
        });
      });
    }
  }
  createChildMarker(context) {
    if (customChildIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/child.png')
          .then((icon) {
        setState(() {
          customChildIcon = icon;
        });
      });
    }
  }

  addOldMark()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getDouble("home_lat")!=null){
      print(LatLng(prefs.getDouble("home_lat"),prefs.getDouble("home_lng")).toString());
      Marker m = Marker(
          markerId: MarkerId('markHomeId'),
          icon: customHomeIcon,
          position: LatLng(prefs.getDouble("home_lat"),prefs.getDouble("home_lng"))
      );
      setState(() {
        markers.add(m);
      });
    }
    if(prefs.getDouble("kinder_lat")!=null){
      Marker m = Marker(
          markerId: MarkerId('markKinderId'),
          icon: customChildIcon,
          position: LatLng(prefs.getDouble("kinder_lat"),prefs.getDouble("kinder_lng"))
      );
      setState(() {
        markers.add(m);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    markers = Set.from([]);
  }

  @override
  Widget build(BuildContext context) {
    createChildMarker(context);
    createHomeMarker(context);

    return Scaffold(
      appBar: null,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: GoogleMap(
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                addOldMark();
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(latitude, longitude), zoom: 16),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              trafficEnabled: true,
              indoorViewEnabled: true,
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.easeInCirc,
        overlayColor: Colors.black,
        overlayOpacity: 0.2,
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
          child: Icon(Icons.pin_drop,color: Colors.cyan,),
          backgroundColor: Colors.white,
          label: 'Mark Kinder',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: ()=> showPlacePicker(isHome: false),

          ),
          SpeedDialChild(
              child: Icon(Icons.home,color: Colors.cyan,),
              backgroundColor: Colors.white,
              label: 'Mark Home',
              labelStyle: TextStyle(fontSize: 18.0),
            onTap: ()=> showPlacePicker(isHome: true),
          ),
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset("assets/images/route.png"),
            ),
            backgroundColor: Colors.white,
            label: 'Start Route',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: getMapRoute,
          ),
        ],
      ),
    );
  }

  void showPlacePicker({@required bool isHome}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    LocationResult result = await LocationPicker.pickLocation(
      context,
        _mapApiKey,
      initialCenter: LatLng(latitude, longitude),
      requiredGPS: true
    );
    Marker m = Marker(
        markerId: MarkerId(isHome?"markHomeId":'markKinderId'),
        icon: isHome?customHomeIcon:customChildIcon,
        position: result.latLng);

    setState(() {
      markers.add(m);
    });

    if(isHome){
      prefs.setDouble('home_lat', result.latLng.latitude);
      prefs.setDouble('home_lng', result.latLng.longitude);
    }else{
      prefs.setDouble('kinder_lat', result.latLng.latitude);
      prefs.setDouble('kinder_lng', result.latLng.longitude);
    }

  }

  getMapRoute()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DirectionsResponse x = await GoogleMapsDirections(apiKey: _mapApiKey).directions(
      Location(prefs.getDouble("kinder_lat"),prefs.getDouble("kinder_lng")),
      Location(prefs.getDouble("home_lat"),prefs.getDouble("home_lng")),
    );
    print(x.errorMessage);
    print(">>>>>>>>>>>>>>>>>>>>>>");

    setState(() {});
  }

}
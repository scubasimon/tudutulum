import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locationLib;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../viewmodels/map_viewmodel.dart';

class MapView extends StatefulWidget {
  final bool isGotoCurrent;

  const MapView({
    Key? key,
    required this.isGotoCurrent,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapView();
}

class _MapView extends State<MapView> {
  MapViewModel _mapViewModel = MapViewModel();

  locationLib.Location location = locationLib.Location();
  late StreamSubscription<locationLib.LocationData> locationStream;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? mapController; //controller for Google map

  CameraPosition initCameraPosition = CameraPosition(target: LatLng(21.0278, 105.8342), zoom: 15.0);

  bool isMapCreated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //init listen network connection
      await _mapViewModel.checkLocationEnable(context);
      if (widget.isGotoCurrent)  {
        await _mapViewModel.getCurrentPosition();
        goToCurrentPosition();
      } else {
        goToDestinationPosition();
      }
      locationStream = location.onLocationChanged.listen((locationLib.LocationData position) {
        _addMarker();
        reloadView();
      });
    });
  }

  @override
  void dispose() {
    locationStream.cancel();
    super.dispose();
  }

  void reloadView() {
    setState(() {});
  }

  void goToCurrentPosition() {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(
          _mapViewModel.currentPosition?.latitude ?? 21,
          _mapViewModel.currentPosition?.longitude ?? 105),
      12.0,
    ));
  }

  void goToDestinationPosition() {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(
          _mapViewModel.destinationPosition?.latitude ?? 21,
          _mapViewModel.destinationPosition?.longitude ?? 105),
      12.0,
    ));
  }

  Future<void> _addMarker() async {
    // if (basicModeViewModel.missionInfo.listPosition.length >= 2) {
    //
    //   markers.add(markerStart);
    //   markers.add(markerEnd);
    // } else {
    //   final Marker markerStart = Marker(
    //     markerId: MarkerId("start"),
    //     position: LatLng(basicModeViewModel.currentPosition?.latitude ?? MapConst.defaultLatLon.latitude,
    //         basicModeViewModel.currentPosition?.longitude ?? MapConst.defaultLatLon.longitude),
    //     infoWindow: InfoWindow(title: 'start', snippet: '*'),
    //     icon: markerStartBitmap,
    //     onTap: () {},
    //   );
    //   markers.add(markerStart);
    // }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        key: _scaffoldKey,
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
            zoomGesturesEnabled: true,
            //enable Zoom in, out on map
            zoomControlsEnabled: false,
            initialCameraPosition: initCameraPosition,
            // polylines: polyline,
            mapType: MapType.normal,
            //map type
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
                isMapCreated = true;
                _addMarker();
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // markers: markers,
          ),
        ],
      ),
    );
  }
}

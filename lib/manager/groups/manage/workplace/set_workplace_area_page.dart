import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SetWorkplaceAreaPage extends StatefulWidget {
  @override
  _SetWorkplaceAreaPageState createState() => _SetWorkplaceAreaPageState();
}

class _SetWorkplaceAreaPageState extends State<SetWorkplaceAreaPage> {
  CameraPosition _cameraPosition = new CameraPosition(target: LatLng(51.9189046, 19.1343786));
  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  double _distance = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        markers: _markersList.toSet(),
        onMapCreated: (controller) {
          this._controller = controller;
        },
        circles: _circles,
        onTap: (coordinates) {
          _controller.animateCamera(CameraUpdate.newLatLng(coordinates));
          _markersList.clear();
          _markersList.add(
            new Marker(
              position: coordinates,
              markerId: MarkerId('${coordinates.latitude}-${coordinates.longitude}'),
            ),
          );
          _circles.clear();
          _circles.add(
            new Circle(
              circleId: CircleId('${51.9189046}-${19.1343786}'),
              center: LatLng(coordinates.latitude, coordinates.longitude),
              radius: _distance * 1000,
            ),
          );
          setState(() {});
        },
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: SfSlider(
          min: 0.0,
          max: 20.0,
          value: _distance,
          interval: 4,
          showTicks: true,
          showLabels: true,
          showTooltip: true,
          minorTicksPerInterval: 1,
          onChanged: (dynamic value) {
            Circle circle = _circles.elementAt(0);
            _circles.clear();
            _circles.add(
              new Circle(
                circleId: CircleId('${circle.circleId}'),
                center: circle.center,
                radius: _distance * 1000,
              ),
            );
            setState(() => _distance = value);
          },
        ),
      ),
    );
  }
}

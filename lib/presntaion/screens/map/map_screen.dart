// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:map_graduation_project/map_utils.dart';

class MapScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  const MapScreen({Key? key, this.startPosition, this.endPosition})
      : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition _initialPosition;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  final Set<Marker> _markers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<Map<String, dynamic>> data = [
    {
      'src_name': 'SOURCE',
      'src_town': 'DESTINATION',
      'des_name': 'BTTC Standard Bus Stand',
      'des_town': 'General Bus Stand',
      'distance': 100,
      'inter_towns': 'Intermediate Towns 1',
      'brand': 'Brand 1',
      'chair_count': 40,
      'ac': 1,
      'start_time': '10:00 AM',
      'duration': '2 hours',
    },


  ];
  int selectedCarId = 1;
  bool backButtonVisible = true;
  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!),
      zoom: 14.4746,
    );
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 1);
    polylines[id] = polyline;
    setState(() {});
  }
  Future<double> calculateDistance(LatLng start, LatLng end) async {
    double distance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distance;
  }


  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCp_L1077gb21quhvorGdeVGyO_7bpnsgE',
      PointLatLng(widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!),
      PointLatLng(widget.endPosition!.geometry!.location!.lat!,
          widget.endPosition!.geometry!.location!.lng!),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      // Calculate distance between start and end points
      double calculatedDistance = _distance(
        widget.startPosition!.geometry!.location!.lat!,
        widget.startPosition!.geometry!.location!.lng!,
        widget.endPosition!.geometry!.location!.lat!,
        widget.endPosition!.geometry!.location!.lng!,
      );

      // Print the calculated distance
      if (kDebugMode) {
        print('Calculated Distance: ${calculatedDistance.toStringAsFixed(2)} km');
      }

      // Update markers with custom info window including distance
      Marker startMarker = Marker(
        markerId: MarkerId('start'),
        position: LatLng(widget.startPosition!.geometry!.location!.lat!,
            widget.startPosition!.geometry!.location!.lng!),
        infoWindow: InfoWindow(
          title: 'Start',
          snippet: 'Distance: ${calculatedDistance.toStringAsFixed(2)} km',
        ),
      );

      Marker endMarker = Marker(
        markerId: MarkerId('end'),
        position: LatLng(widget.endPosition!.geometry!.location!.lat!,
            widget.endPosition!.geometry!.location!.lng!),
        infoWindow: InfoWindow(
          title: 'End',
          snippet: 'Distance: ${calculatedDistance.toStringAsFixed(2)} km',
        ),
      );

      _markers.removeWhere(
              (marker) => marker.markerId.value == 'start' || marker.markerId.value == 'end');
      _markers.add(startMarker);
      _markers.add(endMarker);

      _addPolyLine();
      setState(() {});
    }
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6372.8; // Earth radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final lat1Radians = _toRadians(lat1);
    final lat2Radians = _toRadians(lat2);

    final a = _haversin(dLat) +
        cos(lat1Radians) * cos(lat2Radians) * _haversin(dLon);
    final c = 2 * asin(sqrt(a));

    return r * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  num _haversin(double radians) => pow(sin(radians / 2), 2);

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
          markerId: MarkerId('start'),
          position: LatLng(widget.startPosition!.geometry!.location!.lat!,
              widget.startPosition!.geometry!.location!.lng!)),
      Marker(
          markerId: MarkerId('end'),
          position: LatLng(widget.endPosition!.geometry!.location!.lat!,
              widget.endPosition!.geometry!.location!.lng!)),
    };

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: backButtonVisible
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              )
            : null,
      ),
      body: Stack(children: [
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            height: constraints.maxHeight / 1.5,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              trafficEnabled: true,
              indoorViewEnabled: true,
              compassEnabled: true,
              myLocationEnabled: true,
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: _initialPosition,
              markers: Set.from(markers),
              onMapCreated: (GoogleMapController controller) {
                Future.delayed(Duration(milliseconds: 2000), () {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      MapUtils.boundsFromLatLngList(
                          markers.map((loc) => loc.position).toList()),
                      1));
                  _getPolyline();
                });
              },
            ),
          );
        }),


        DraggableScrollableSheet(
            initialChildSize: 0.3,
            // minChildSize: 0.5,
            // maxChildSize: 1,
            // snapSizes: [0.5, 1],
            // snap: true,
            builder: (BuildContext context, scrollSheetController) {
              return BusCard(data: data,);
            }),
      ]),
    );
  }
}

class BusCard extends StatelessWidget {

   final List<Map<String, dynamic>>?data;

   const BusCard({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blue[700], borderRadius: BorderRadius.circular(15)),
        width: double.infinity,
        child:  ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(height: 1,color: Colors.black,);
          },
            itemCount: data!.length,
            itemBuilder: (context, i) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.blue[700], borderRadius: BorderRadius.circular(12)),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SOURCE',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          Text(
                            data![i]['src_name']!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data![i]['src_town']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '→',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'DESTINATION',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          Text(
                            data![i]['des_name']!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data![i]['des_town']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          '${data![i]['distance'].toString()} KM, via ${data![i]['inter_towns']!}',
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data![i]['brand']! +
                            ', ' +
                            data![i]['chair_count'].toString() +
                            ' seater, ' +
                            ['Non-AC', 'AC'][data![i]['ac']!],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data![i]['start_time'].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      const Icon(
                        Icons.timelapse_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data![i]['duration'].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
        ),
    );

  }
}
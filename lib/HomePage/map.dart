import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyMap extends StatefulWidget {
  final String category;
  const MyMap({super.key, required this.category});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  String? _selectedTitle = null;
  String? _selectedLocation = null;

  Future<void> _fetchLocationsFromFirebase() async {
    try {
      final collection = FirebaseFirestore.instance.collection(widget.category);
      final querySnapshot = await collection.get();

      final Set<Marker> markers = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final GeoPoint? location = data['location'];
            if (location != null) {
              return Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(
                  title: data['title'] ?? '제목 없음',
                  snippet: data['memo'] ?? '설명 없음',
                ),
              );
            }
            return null;
          })
          .whereType<Marker>()
          .toSet();

      setState(() {
        _markers.addAll(markers);
      });
    } catch (e) {
      print("Firebase에서 데이터를 가져오는 데 실패했습니다: $e");
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 14.0,
        ),
      ));
    } catch (e) {
      print("현재 위치를 가져오는 데 실패했습니다: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocationsFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng initialLocation = LatLng(37.574464609563755, 126.978468954584);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('내 주변 메이트'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: initialLocation,
              zoom: 14.0,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

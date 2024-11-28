import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Movelocation extends StatefulWidget {
  const Movelocation({Key? key}) : super(key: key);

  @override
  State<Movelocation> createState() => _MovelocationState();
}

class _MovelocationState extends State<Movelocation> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentPosition = LatLng(37.574464609563755, 126.978468954584);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 위치 설정'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId('current_location'),
                position: _currentPosition,
                draggable: true,
                onDragEnd: (LatLng newPosition) {
                  setState(() {
                    _currentPosition = newPosition;
                  });
                },
                infoWindow: const InfoWindow(title: '현재 위치를 드래그하세요'),
              ),
            },
            onTap: (LatLng newPosition) {
              setState(() {
                _currentPosition = newPosition;
              });
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.newLatLng(_currentPosition),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, _currentPosition);
              },
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

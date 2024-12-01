import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mymate/HomePage/chat.dart';

class MyMap extends StatefulWidget {
  final String category;
  const MyMap({super.key, required this.category});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  String? _selectedTitle;
  String? _selectedAddress;
  String? _selectedId;

  static const String _apiKey = 'AIzaSyCUuLRJo0rGLrzlpvkKCq0JGsPDWZ_WloQ';

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
                onTap: () async {
                  final address = await _getAddressFromLatLng(
                      location.latitude, location.longitude);
                  setState(() {
                    _selectedId = doc.id;
                    _selectedTitle = data['title'];
                    _selectedAddress = address;
                  });
                },
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

  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results']?.isNotEmpty ?? false) {
        final results = data['results'] as List;
        String? streetAddress;
        String? locality;

        for (final result in results) {
          final types = result['types'] as List;
          if (types.contains('locality')) {
            streetAddress = result['formatted_address'];
          } else if (types.contains('street_address')) {
            locality = result['formatted_address'];
          }
          if (streetAddress != null && locality != null) break;
        }

        if (streetAddress != null && locality != null) {
          return "$streetAddress, $locality";
        } else if (streetAddress != null) {
          return streetAddress;
        } else if (locality != null) {
          return locality;
        } else {
          return "주소 정보를 찾을 수 없습니다.";
        }
      } else {
        return "주소를 찾을 수 없습니다.";
      }
    } else {
      return "주소 변환 실패";
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

  Future<void> _incrementCurrentCount(String documentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(widget.category)
          .doc(documentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("문서가 존재하지 않습니다.");
        }

        final currentCount = snapshot.data()?['currentCount'] ?? 0;
        transaction.update(docRef, {'currentCount': currentCount + 1});
      });
    } catch (e) {
      print("currentCount 증가 중 오류 발생: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocationsFromFirebase();
  }

  Widget _buildDebugInfo() {
    return Positioned(
      top: 0.0,
      left: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "채팅방: ${_selectedTitle ?? '마커를 눌러'}",
              style: const TextStyle(fontSize: 16.0),
            ),
            Text(
              "주소: ${_selectedAddress ?? '주소를 불러오는 중...'}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16.0),
            ),
            TextButton(
              onPressed: () {
                if (_selectedId != null) {
                  _incrementCurrentCount(_selectedId!); // currentCount 증가 호출
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        id: _selectedId!,
                        category: widget.category,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('채팅방을 선택해주세요.')),
                  );
                }
              },
              child: const Text('채팅방 들어가기'),
            ),
          ],
        ),
      ),
    );
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
          _buildDebugInfo(),
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

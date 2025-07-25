import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_services.dart';

class TripTrackerScreen extends StatefulWidget {
  const TripTrackerScreen({super.key});

  @override
  _TripTrackerScreenState createState() => _TripTrackerScreenState();
}

class _TripTrackerScreenState extends State<TripTrackerScreen> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool isTracking = false;
  Set<Marker> _markers = {};
  final List<LatLng> _routePoints = [];
  Set<Polyline> _polylines = {};
  final LocationServices _locationServices = LocationServices();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // Check and request location permissions
      Position? position = await _locationServices.getCurrentLocation();

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });

      // Move camera to current location
      mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    } catch (e) {
      print('Location error: $e');
      _showErrorSnackBar('Error getting location: $e');
    }
  }

  void _updateMarkers() {
    if (_currentPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Current Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isTracking ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
            ),
          ),
        };
      });
    }
  }

  void _updateRoute() {
    if (_routePoints.length > 1) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints,
            color: Colors.blue,
            width: 4,
            patterns: [],
          ),
        };
      });
    }
  }

  void _toggleTrip() {
    if (isTracking) {
      _stopTrip();
    } else {
      _startTrip();
    }
  }

  void _startTrip() {
    if (_currentPosition == null) {
      _showErrorSnackBar('Location not available');
      return;
    }

    // Clear previous route
    _routePoints.clear();
    _routePoints.add(_currentPosition!);

    // Start location tracking using Geolocator directly since LocationServices doesn't have getLocationStream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _updateMarkers();
          _routePoints.add(_currentPosition!);
          _updateRoute();
        });

        // Move camera to current location
        mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      },
      onError: (error) {
        print('Location stream error: $error');
        _showErrorSnackBar('Location tracking error: $error');
        _stopTrip();
      },
    );

    setState(() {
      isTracking = true;
    });

    _showSuccessSnackBar("Trip Started - Tracking your route");
  }


  void _stopTrip() {
    _positionStream?.cancel();

    setState(() {
      isTracking = false;
    });

    _updateMarkers();
    _showSuccessSnackBar("Trip Ended - Route saved");
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trip Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: _currentPosition == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 16,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: false, // We're using custom markers
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Status indicator
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isTracking
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isTracking ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTracking ? 'Tracking Active' : 'Tracking Inactive',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isTracking ? Colors.green : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (_routePoints.isNotEmpty)
                          Text(
                            '${_routePoints.length} points',
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _currentPosition == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _toggleTrip,
              label: Text(
                isTracking ? 'End Trip' : 'Start Trip',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
              backgroundColor: isTracking ? Colors.red : Colors.green,
              elevation: 4,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

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
      mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
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
    _positionStream =
        Geolocator.getPositionStream(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trip Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade600,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: _currentPosition == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.white : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Getting your location...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    // Apply dark mode style to map if needed
                    if (isDarkMode) {
                      _setMapStyle(controller);
                    }
                  },
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

                // Status indicator with dark mode support
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF2C2C2C).withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDarkMode ? 0.4 : 0.1,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: isDarkMode
                          ? Border.all(color: Colors.grey.shade700, width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isTracking
                                ? Colors.green.shade100
                                : (isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isTracking
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isTracking
                                ? Colors.green.shade600
                                : (isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isTracking
                                  ? 'Tracking Active'
                                  : 'Tracking Inactive',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isTracking
                                    ? Colors.green.shade600
                                    : (isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700),
                              ),
                            ),
                            if (_routePoints.isNotEmpty)
                              Text(
                                '${_routePoints.length} tracking points',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (isTracking)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Route info card (if tracking)
                if (isTracking && _routePoints.length > 1)
                  Positioned(
                    bottom: 100,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2C2C2C).withOpacity(0.95)
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.4 : 0.1,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isDarkMode
                            ? Border.all(color: Colors.grey.shade700, width: 1)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRouteInfo(
                            'Distance',
                            '${(_calculateDistance() / 1000).toStringAsFixed(2)} km',
                            Icons.straighten,
                            isDarkMode,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          _buildRouteInfo(
                            'Points',
                            '${_routePoints.length}',
                            Icons.location_on,
                            isDarkMode,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          _buildRouteInfo(
                            'Status',
                            'Active',
                            Icons.circle,
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _currentPosition == null
          ? null
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: (isTracking ? Colors.red : Colors.green).withOpacity(
                      0.3,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _toggleTrip,
                label: Text(
                  isTracking ? 'End Trip' : 'Start Trip',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                icon: Icon(
                  isTracking ? Icons.stop : Icons.play_arrow,
                  size: 24,
                ),
                backgroundColor: isTracking
                    ? Colors.red.shade600
                    : Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRouteInfo(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  double _calculateDistance() {
    if (_routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  void _setMapStyle(GoogleMapController controller) {
    // Dark map style JSON
    const String darkMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [{"color": "#212121"}]
      },
      {
        "elementType": "labels.icon",
        "stylers": [{"visibility": "off"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#757575"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#212121"}]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [{"color": "#757575"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [{"color": "#2c2c2c"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#8a8a8a"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#000000"}]
      }
    ]
    ''';

    controller.setMapStyle(darkMapStyle);
  }
}

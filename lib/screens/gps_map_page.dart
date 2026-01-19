import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';
import 'gps_statistics_page.dart';

class GpsMapPage extends StatefulWidget {
  final PetService petService;
  const GpsMapPage({Key? key, required this.petService}) : super(key: key);

  @override
  State<GpsMapPage> createState() => _GpsMapPageState();
}

class _GpsMapPageState extends State<GpsMapPage> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  bool _followMode = true;
  
  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onLocationChanged);
    _locationService.startTracking();
    _locationService.fetchLocationHistory(results: 100);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    _locationService.stopTracking();
    _pulseController.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    setState(() {});
    
    // Auto-move map to new location if follow mode is enabled
    if (_followMode && _locationService.currentLocation != null) {
      final loc = _locationService.currentLocation!;
      try {
        _mapController.move(
          LatLng(loc.latitude, loc.longitude),
          _mapController.camera.zoom,
        );
      } catch (_) {}
    }
  }

  void _centerOnLocation() {
    if (_locationService.currentLocation != null) {
      final loc = _locationService.currentLocation!;
      _mapController.move(
        LatLng(loc.latitude, loc.longitude),
        16.0,
      );
      setState(() => _followMode = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = _locationService.currentLocation;
    final history = _locationService.locationHistory;
    final selectedPet = widget.petService.pets.isNotEmpty 
        ? widget.petService.selectedPet 
        : null;

    // Default location (Jakarta) if no data
    final currentLatLng = location != null
        ? LatLng(location.latitude, location.longitude)
        : const LatLng(-6.2088, 106.8456);

    return Scaffold(
      body: Stack(
        children: [
          // Real Map with OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLatLng,
              initialZoom: 16.0,
              minZoom: 3.0,
              maxZoom: 19.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _followMode = false);
                }
              },
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pet_tracker_app',
              ),
              
              // History Trail (Polyline)
              if (history.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: history
                          .where((h) => h.latitude != 0 && h.longitude != 0)
                          .map((h) => LatLng(h.latitude, h.longitude))
                          .toList(),
                      color: Colors.blue.withOpacity(0.7),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              
              // History Points (small circles)
              if (history.isNotEmpty)
                CircleLayer(
                  circles: history
                      .where((h) => h.latitude != 0 && h.longitude != 0)
                      .map((h) => CircleMarker(
                            point: LatLng(h.latitude, h.longitude),
                            radius: 5,
                            color: Colors.blue.withOpacity(0.5),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 1,
                          ))
                      .toList(),
                ),
              
              // Current Location Marker
              if (location != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLatLng,
                      width: 80,
                      height: 80,
                      child: _buildAnimatedMarker(selectedPet),
                    ),
                  ],
                ),
            ],
          ),
          
          // Header with GPS info
          _buildHeader(location),
          
          // Control buttons (right side)
          Positioned(
            top: 120,
            right: 20,
            child: Column(
              children: [
                _buildStatusBadge(),
                const SizedBox(height: 8),
                // Refresh button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'refresh',
                  onPressed: () {
                    _locationService.fetchLatestLocation();
                    _locationService.fetchLocationHistory(results: 100);
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  child: _locationService.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 8),
                // Center on location button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'center',
                  onPressed: _centerOnLocation,
                  backgroundColor: _followMode 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).cardColor,
                  child: Icon(
                    Icons.my_location,
                    color: _followMode 
                        ? Colors.white 
                        : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Statistics button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'stats',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GpsStatisticsPage(),
                      ),
                    );
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
          
          // Info card at bottom
          if (location != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildLocationCard(location, selectedPet, history.length),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(LocationData? location) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt, color: Colors.greenAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GPS Pet Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location != null
                      ? 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}'
                      : 'Menunggu data dari ThingSpeak...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMarker(Pet? pet) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.3);
        final opacity = 1.0 - _pulseController.value;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            Transform.scale(
              scale: scale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent.withOpacity(opacity * 0.3),
                ),
              ),
            ),
            // Main marker
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: pet != null
                  ? ClipOval(
                      child: Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  : const Icon(Icons.pets, color: Colors.white, size: 20),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    final isConnected = _locationService.currentLocation != null;
    final hasError = _locationService.error != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.withOpacity(0.9)
            : isConnected
                ? Colors.green.withOpacity(0.9)
                : Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError
                ? Icons.error_outline
                : isConnected
                    ? Icons.check_circle
                    : Icons.sync,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            hasError
                ? 'Error'
                : isConnected
                    ? 'Live'
                    : 'Connecting',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationData location, Pet? pet, int historyCount) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Pet avatar
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: pet != null
                        ? ClipOval(
                            child: Image.network(
                              pet.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.pets, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet?.name ?? 'Pet Tracker',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.speed, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${location.speed.toStringAsFixed(1)} km/h',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.timeline, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$historyCount titik',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Battery
                  Column(
                    children: [
                      Icon(
                        _getBatteryIcon(location.battery),
                        color: _getBatteryColor(location.battery),
                        size: 24,
                      ),
                      Text(
                        '${location.battery.toInt()}%',
                        style: TextStyle(
                          color: _getBatteryColor(location.battery),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Coordinates
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCoordItem('LAT', location.latitude.toStringAsFixed(6)),
                    Container(width: 1, height: 25, color: Colors.white24),
                    _buildCoordItem('LNG', location.longitude.toStringAsFixed(6)),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Last update
              Text(
                'Update: ${_formatTimestamp(location.timestamp)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  IconData _getBatteryIcon(double level) {
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(double level) {
    if (level > 60) return Colors.greenAccent;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'N/A';
    }
  }
}

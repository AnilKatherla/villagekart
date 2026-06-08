import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_utils.dart';

/// Production-ready route map widget
/// - Accept either precomputed `routePoints` or an encoded polyline string
/// - Draws polyline (smoothed) and start/end custom markers
/// - Supports animated moving vehicle marker
class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    this.encodedPolyline,
    this.routePoints,
    this.startLabel = 'Start',
    this.endLabel = 'Drop',
    this.initialZoom = 14.0,
  }) : assert(encodedPolyline != null || routePoints != null, 'Either encodedPolyline or routePoints must be provided');

  final String? encodedPolyline;
  final List<LatLng>? routePoints;
  final String startLabel;
  final String endLabel;
  final double initialZoom;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _c = Completer();

  // Map objects
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  Marker? _movingMarker;

  // animation
  AnimationController? _vehicleAnimController;
  Timer? _vehicleTimer;
  int _currentVehicleIndex = 0;
  List<LatLng> _points = [];

  // caching bitmap descriptors
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  BitmapDescriptor? _vehicleIcon;

  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _prepareIcons();
    _loadRoute();
  }

  @override
  void dispose() {
    _vehicleAnimController?.dispose();
    _vehicleTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _prepareIcons() async {
    _startIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(60, 60)),
      'assets/icons/shop_marker.png',
    );

    _endIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(60, 60)),
      'assets/icons/user_marker.png',
    );

    _vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(60, 60)),
      'assets/icons/vehicle_marker.png',
    );
  }


  Future<void> _loadRoute() async {
    // 1. decode polyline or use provided points
    List<LatLng> pts;
    if (widget.encodedPolyline != null) {
      // offload decode to compute if it's heavy
      pts = await compute(decodeEncodedPolyline, widget.encodedPolyline!);
    } else {
      pts = widget.routePoints!;
    }

    // 2. simplify / reduce points for performance
    final simplified = simplifyPoints(pts, toleranceMeters: 6.0);

    setState(() {
      _points = simplified;
    });

    // once icons prepared, add map overlays
    await Future.delayed(const Duration(milliseconds: 80));
    _addPolyline();
    _addMarkers();
    _startVehicleAnimation();
    _isReady = true;
  }

  void _addPolyline() {
    const id = PolylineId('route_poly');
    final polyline = Polyline(
      polylineId: id,
      points: _points,
      width: 6,
      color: Colors.deepOrange,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      geodesic: true,
    );
    setState(() => _polylines.add(polyline));
  }

  void _addMarkers() {
    if (_points.isEmpty) return;

    final start = _points.first;   // Shop
    final end = _points.last;      // User

    final shopMarker = Marker(
      markerId: const MarkerId('start'),
      position: start,
      icon: _startIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: widget.startLabel),
      anchor: const Offset(0.5, 1.0),
    );

    final userMarker = Marker(
      markerId: const MarkerId('end'),
      position: end,
      icon: _endIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: widget.endLabel),
      anchor: const Offset(0.5, 1.0),
    );

    final vehicleMarker = Marker(
      markerId: const MarkerId('vehicle'),
      position: start,
      icon: _vehicleIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
      zIndex: 3,
    );

    setState(() {
      _markers
        ..removeWhere((m) =>
        m.markerId.value == 'start' ||
            m.markerId.value == 'end' ||
            m.markerId.value == 'vehicle')
        ..addAll([shopMarker, userMarker, vehicleMarker]);

      _movingMarker = vehicleMarker;
    });
  }

  void _startVehicleAnimation() {
    if (_points.length < 2) return;

    // stop any running timer
    _vehicleTimer?.cancel();

    _vehicleAnimController?.dispose();
    _vehicleAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 10));

    // move the marker step by step along the poly points using a Timer
    _currentVehicleIndex = 0;
    _vehicleTimer = Timer.periodic(const Duration(seconds: 20), (t) async {
      if (!mounted) return;
      final nextIndex = _currentVehicleIndex + 1;
      if (nextIndex >= _points.length) {
        t.cancel();
        return;
      }

      final from = _points[_currentVehicleIndex];
      final to = _points[nextIndex];

      // animate position using lerp
      final animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _vehicleAnimController!, curve: Curves.easeInOut));
      _vehicleAnimController!.reset();
      _vehicleAnimController!.forward();

      animation.addListener(() {
        final v = animation.value;
        final lat = _lerp(from.latitude, to.latitude, v);
        final lng = _lerp(from.longitude, to.longitude, v);
        _updateVehiclePosition(LatLng(lat, lng));
      });

      // animate camera to follow
      try {
        await _mapController.animateCamera(CameraUpdate.newLatLng(to));
      } catch (_) {}

      _currentVehicleIndex = nextIndex;
    });
  }

  void _updateVehiclePosition(LatLng pos) {
    final vehicle = Marker(
      markerId: const MarkerId('vehicle'),
      position: pos,
      icon: _vehicleIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
      zIndex: 3,
    );

    setState(() {
      _markers..removeWhere((m) => m.markerId.value == 'vehicle')
      ..add(vehicle);
      _movingMarker = vehicle;
    });
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    // If route not ready, show a loader over map
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _points.isNotEmpty ? _points.first : const LatLng(17.445, 78.391), zoom: widget.initialZoom),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _c.complete(controller);
            _mapController = controller;
            // optionally set map style here using controller.setMapStyle(...)
            if (_points.isNotEmpty) {
              // fit bounds to route
              WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToBounds());
            }
          },
          polylines: _polylines,
          markers: _markers,
          compassEnabled: false,
          tiltGesturesEnabled: false,
        ),

        // optional loading indicator
        if (!_isReady)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Future<void> _fitMapToBounds() async {
    if (_points.length < 2) return;

    final latitudes = _points.map((p) => p.latitude).toList();
    final longitudes = _points.map((p) => p.longitude).toList();
    final sw = LatLng(latitudes.reduce(min), longitudes.reduce(min));
    final ne = LatLng(latitudes.reduce(max), longitudes.reduce(max));
    final bounds = LatLngBounds(southwest: sw, northeast: ne);

    try {
      await _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    } catch (_) {
      // ignore if map not ready
    }
  }
}
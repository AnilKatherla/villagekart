import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Decode an encoded polyline (Google Directions) into a List<LatLng>.
/// If you already have raw points, you can skip this.
List<LatLng> decodeEncodedPolyline(String encoded) {
  final List<LatLng> points = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}

/// Simple smoothing: remove near-duplicate points to reduce polyline size
List<LatLng> simplifyPoints(List<LatLng> pts, {double toleranceMeters = 5}) {
  if (pts.length < 3) {
    return pts;
  }
  final res = <LatLng>[];
  LatLng last = pts.first;
  res.add(last);

  for (int i = 1; i < pts.length; i++) {
    final p = pts[i];
    final dx = _distanceMeters(last.latitude, last.longitude, p.latitude, p.longitude);
    if (dx >= toleranceMeters) {
      res.add(p);
      last = p;
    }
  }
  if (res.last != pts.last) {
    res.add(pts.last);
  }
  return res;
}

/// Haversine distance approx (meters)
double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000; // m
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
          cos(_toRad(lat1)) * cos(_toRad(lat2)) * (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _toRad(double deg) => deg * (pi / 180);

/// Convert a Flutter widget to a BitmapDescriptor (for custom markers).
/// Use caching in production to avoid repeated conversions.
Future<Uint8List> widgetToBytes(GlobalKey key, {double pixelRatio = 2.0}) async {
  final renderObject = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (renderObject == null) {
    throw Exception('RenderRepaintBoundary null for key');
  }
  final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// Convenience: build a simple circular marker bitmap on the fly
Future<Uint8List> createCircleBitmapBytes({
  required int diameter,
  required Color fillColor,
  Color? borderColor,
  String? text,
  double textSize = 14,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = fillColor;
  final center = Offset(diameter / 2, diameter / 2);
  canvas.drawCircle(center, diameter / 2.0, paint);

  if (borderColor != null) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, diameter / 2.0 - 1.0, borderPaint);
  }

  if (text != null && text.isNotEmpty) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: textSize, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(diameter, diameter);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}
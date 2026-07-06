import 'package:latlong2/latlong.dart';

/// Approximate center points for Bangladesh's 8 divisions (heat-map plotting).
abstract final class BangladeshDivisions {
  static const unknownLabel = 'অজানা এলাকা';

  static const List<String> names = [
    'ঢাকা',
    'চট্টগ্রাম',
    'রাজশাহী',
    'খুলনা',
    'বরিশাল',
    'সিলেট',
    'রংপুর',
    'ময়মনসিংহ',
  ];

  static const Map<String, LatLng> centers = {
    'ঢাকা': LatLng(23.8103, 90.4125),
    'চট্টগ্রাম': LatLng(22.3569, 91.7832),
    'রাজশাহী': LatLng(24.3745, 88.6042),
    'খুলনা': LatLng(22.8456, 89.5403),
    'বরিশাল': LatLng(22.7010, 90.3535),
    'সিলেট': LatLng(24.8949, 91.8687),
    'রংপুর': LatLng(25.7439, 89.2752),
    'ময়মনসিংহ': LatLng(24.7471, 90.4203),
  };

  static LatLng? resolveCenter(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    return centers[label.trim()];
  }
}

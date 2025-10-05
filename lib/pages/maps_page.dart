import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapsPage extends StatefulWidget {
  final bool findNearestOnOpen;
  const MapsPage({super.key, this.findNearestOnOpen = false});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  Marker? _hospitalMarker;
  List<LatLng> _routePoints = [];
  bool _isFindingHospital = false; // 🔹 indikator loading
  bool _triggeredFindOnOpen = false;

  Future<void> _getCurrentLocation({bool moveMap = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GPS tidak aktif")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (moveMap && _currentPosition != null) {
      _mapController.move(_currentPosition!, 16);
      _mapController.rotate(0);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.findNearestOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _getCurrentLocation(moveMap: true);
        if (!mounted) return;
        await _findNearestHospital();
      });
    } else {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If requested to find nearest on open, trigger once when position is available
    if (widget.findNearestOnOpen && !_triggeredFindOnOpen && _currentPosition != null) {
      _triggeredFindOnOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _findNearestHospital();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 🔹 Map full screen (put in RepaintBoundary to avoid repainting when other widgets change)
                RepaintBoundary(
                  child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 16,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.artificial_intelegence',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        if (_hospitalMarker != null) _hospitalMarker!,
                      ],
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blueAccent,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                  ],
                  ),
                ),

                // 🔹 Lat & Lng di pojok bawah
                Positioned(
                  left: 10,
                  bottom: 90,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),

                // 🔹 FAB lokasi
                Positioned(
                  bottom: 90,
                  right: 10,
                  child: FloatingActionButton(
                    heroTag: "btnMyLocation", // 🔹 tambahkan tag unik
                    onPressed: () => _getCurrentLocation(moveMap: true),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.purple),
                  ),
                ),

                // 🔹 FAB cari rumah sakit
                Positioned(
                  bottom: 160,
                  right: 10,
                  child: FloatingActionButton(
                    heroTag: "btnFindHospital", // 🔹 tag berbeda
                    backgroundColor: Colors.white,
                    onPressed: _isFindingHospital ? null : _findNearestHospital,
                    tooltip: 'Cari rumah sakit terdekat',
                    child: _isFindingHospital
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.redAccent,
                            ),
                          )
                        : const Icon(Icons.local_hospital, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _findNearestHospital() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi belum tersedia')));
      return;
    }

    setState(() => _isFindingHospital = true); // 🔹 tampilkan loading

    final lat = _currentPosition!.latitude;
    final lon = _currentPosition!.longitude;

    final overpass = '''[out:json];
      (
        node[amenity=hospital](around:5000,$lat,$lon);
        way[amenity=hospital](around:5000,$lat,$lon);
        relation[amenity=hospital](around:5000,$lat,$lon);
      );
      out center;''';

    try {
      final resp = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': overpass},
      );

      if (resp.statusCode != 200) throw Exception('Overpass error');

      final data = json.decode(resp.body);
      if (data['elements'] == null || (data['elements'] as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ditemukan rumah sakit di sekitar')),
        );
        setState(() => _isFindingHospital = false);
        return;
      }

      double bestDist = double.infinity;
      LatLng? bestPt;
      String name = 'Rumah Sakit';

      for (final el in data['elements']) {
        double elLat;
        double elLon;
        if (el['type'] == 'node') {
          elLat = el['lat'] + 0.0;
          elLon = el['lon'] + 0.0;
        } else if (el['center'] != null) {
          elLat = el['center']['lat'] + 0.0;
          elLon = el['center']['lon'] + 0.0;
        } else {
          continue;
        }

        final d = Distance().as(
            LengthUnit.Meter, _currentPosition!, LatLng(elLat, elLon));
        if (d < bestDist) {
          bestDist = d;
          bestPt = LatLng(elLat, elLon);
          if (el['tags'] != null && el['tags']['name'] != null) {
            name = el['tags']['name'];
          }
        }
      }

      if (bestPt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ditemukan rumah sakit di sekitar')),
        );
        setState(() => _isFindingHospital = false);
        return;
      }

      final chosen = bestPt;

      setState(() {
        _hospitalMarker = Marker(
          point: chosen,
          width: 120,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital,
                  color: Colors.redAccent, size: 36),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      });

      // 🔹 Ambil rute via OSRM
      final coords =
          '${lon.toString()},${lat.toString()};${chosen.longitude.toString()},${chosen.latitude.toString()}';
      final osrmUrl =
          'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
      final r = await http.get(Uri.parse(osrmUrl));

      if (r.statusCode == 200) {
        final jr = json.decode(r.body);
        if (jr['routes'] != null && (jr['routes'] as List).isNotEmpty) {
          final geom = jr['routes'][0]['geometry'];
          if (geom != null && geom['coordinates'] != null) {
            final coordsList = geom['coordinates'] as List;
            final pts = coordsList
                .map<LatLng>((c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
                .toList();
            setState(() {
              _routePoints = pts;
            });

            // 🔹 geser map biar kelihatan dua titik
            final midLat =
                (_currentPosition!.latitude + bestPt.latitude) / 2;
            final midLon =
                (_currentPosition!.longitude + bestPt.longitude) / 2;
            _mapController.move(LatLng(midLat, midLon), 13);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isFindingHospital = false); // 🔹 matikan loading
    }
  }
}

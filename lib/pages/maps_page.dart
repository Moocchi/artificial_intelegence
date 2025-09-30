import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  Future<void> _getCurrentLocation({bool moveMap = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 🔹 Cek GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GPS tidak aktif")),
      );
      return;
    }

    // 🔹 Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // 🔹 Ambil lokasi sekarang
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // 🔹 Geser map + reset rotasi (hanya jika moveMap = true)
    if (moveMap && _currentPosition != null) {
      _mapController.move(_currentPosition!, 16);
      _mapController.rotate(0);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // langsung ambil lokasi saat load (tanpa move map)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 🔹 Map full screen
                FlutterMap(
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
                      ],
                    ),
                  ],
                ),

                // 🔹 Lat & Lng pojok kiri bawah
                Positioned(
                  left: 10,
                  bottom: 90, // biar ga ketutup FAB
                  child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
              ),
            ),
                // 🔹 FAB custom position (misal pojok kanan atas)
                Positioned(
                  bottom: 90, // Ubah sesuai kebutuhan
                  right: 10, // Ubah sesuai kebutuhan
                  child: FloatingActionButton(
                    onPressed: () => _getCurrentLocation(moveMap: true),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.purple),
                  ),
                ),
              ],
            ),
    );
  }
}

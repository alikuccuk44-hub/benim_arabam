import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMsg = '';
  List<Map<String, dynamic>> _places = [];
  String _filter = 'fuel'; // 'fuel' or 'service'

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _errorMsg = 'Konum hizmetleri kapalı. Lütfen açın.'; _isLoading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _errorMsg = 'Konum izni reddedildi.'; _isLoading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _errorMsg = 'Konum izni kalıcı olarak reddedildi. Ayarlardan açın.'; _isLoading = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = pos);
      await _fetchNearby();
    } catch (e) {
      setState(() { _errorMsg = 'Konum alınamadı: $e'; _isLoading = false; });
    }
  }

  Future<void> _fetchNearby() async {
    if (_currentPosition == null) return;
    setState(() { _isLoading = true; _places = []; });

    final lat = _currentPosition!.latitude;
    final lon = _currentPosition!.longitude;
    final radius = 3000; // 3 km

    late String amenity;
    if (_filter == 'fuel') {
      amenity = 'fuel';
    } else {
      amenity = 'car_repair';
    }

    final query = '[out:json];node["amenity"="$amenity"](around:$radius,$lat,$lon);out body;';
    final url = 'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        setState(() {
          _places = elements.take(30).map<Map<String, dynamic>>((e) => {
            'id': e['id'],
            'lat': e['lat'],
            'lon': e['lon'],
            'name': e['tags']?['name'] ?? (_filter == 'fuel' ? 'Benzinlik' : 'Oto Servis'),
            'brand': e['tags']?['brand'] ?? '',
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() { _errorMsg = 'Veri alınamadı.'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMsg = 'İnternet bağlantısı gerekli.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakınımdaki Servis & Benzinlik'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _initLocation),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Row(children: [Icon(Icons.local_gas_station, size: 18), SizedBox(width: 6), Text('Benzinlik')]),
                    selected: _filter == 'fuel',
                    onSelected: (_) { setState(() => _filter = 'fuel'); _fetchNearby(); },
                    selectedColor: const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Row(children: [Icon(Icons.build, size: 18), SizedBox(width: 6), Text('Oto Servis')]),
                    selected: _filter == 'service',
                    onSelected: (_) { setState(() => _filter = 'service'); _fetchNearby(); },
                    selectedColor: const Color(0xFF818CF8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _errorMsg.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(_errorMsg, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _initLocation, child: const Text('Tekrar Dene')),
                ],
              ),
            )
          : _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          initialZoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.benim_arabam',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                              ),
                              ..._places.map((p) => Marker(
                                point: LatLng(p['lat'], p['lon']),
                                width: 36,
                                height: 36,
                                child: Icon(
                                  _filter == 'fuel' ? Icons.local_gas_station : Icons.build_circle,
                                  color: _filter == 'fuel' ? Colors.green : Colors.purple,
                                  size: 36,
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _isLoading
                          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Yakındakiler aranıyor...')]))
                          : _places.isEmpty
                              ? const Center(child: Text('Yakınlarda sonuç bulunamadı.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _places.length,
                                  itemBuilder: (ctx, i) {
                                    final p = _places[i];
                                    final distance = Geolocator.distanceBetween(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      p['lat'],
                                      p['lon'],
                                    );
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _filter == 'fuel' ? Colors.green.withAlpha(40) : Colors.purple.withAlpha(40),
                                        child: Icon(_filter == 'fuel' ? Icons.local_gas_station : Icons.build, color: _filter == 'fuel' ? Colors.green : Colors.purple, size: 20),
                                      ),
                                      title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Text(p['brand'].isNotEmpty ? p['brand'] : (_filter == 'fuel' ? 'Akaryakıt İstasyonu' : 'Oto Servis')),
                                      trailing: Text(
                                        distance < 1000 ? '${distance.toStringAsFixed(0)} m' : '${(distance / 1000).toStringAsFixed(1)} km',
                                        style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () {
                                        _mapController.move(LatLng(p['lat'], p['lon']), 16);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
    );
  }
}

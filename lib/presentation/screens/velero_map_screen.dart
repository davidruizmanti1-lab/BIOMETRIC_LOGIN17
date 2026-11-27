import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/velero_theme.dart';

class VeleroMapScreen extends StatefulWidget {
  const VeleroMapScreen({super.key});
  @override
  State<VeleroMapScreen> createState() => _VeleroMapScreenState();
}

class _VeleroMapScreenState extends State<VeleroMapScreen> {
  static const _points = <(String, LatLng)>[
    ('Centro de Santa Marta', LatLng(11.2408, -74.1990)),
    ('El Rodadero · zona', LatLng(11.2034, -74.2264)),
    ('Aeropuerto Simón Bolívar', LatLng(11.1196, -74.2306)),
  ];
  final _map = MapController();
  LatLng? _position;
  int _point = 0;
  bool _busy = false;
  String _status = 'Mapa en línea · puntos turísticos aproximados.';
  @override
  void dispose() { _map.dispose(); super.dispose(); }

  Future<void> _gps() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw StateError('Activa la ubicación del teléfono.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw StateError('Permiso de ubicación no concedido.');
      }
      final p = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)));
      if (!mounted) return;
      setState(() { _position = LatLng(p.latitude, p.longitude); _status = 'Ubicación mostrada en el mapa; no guardada por Velero2H.'; });
      _map.move(_position!, 14);
    } catch (error) {
      if (mounted) setState(() => _status = error is StateError ? error.message.toString() : 'GPS no disponible. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _route() async {
    final point = _points[_point].$2;
    try {
      if (await launchUrl(Uri.https('www.google.com', '/maps/dir/', {'api':'1','destination':point.latitude.toString()+','+point.longitude.toString()}), mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (mounted) setState(() => _status = 'No fue posible abrir la ruta.');
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(24), child: FlutterMap(
      mapController: _map,
      options: MapOptions(initialCenter: _points.first.$2, initialZoom: 12),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.biometric_login'),
        MarkerLayer(markers: [
          for (final point in _points) Marker(point: point.$2, width: 42, height: 42, child: const Icon(Icons.location_on, color: VeleroTheme.teal, size: 36)),
          if (_position != null) Marker(point: _position!, width: 36, height: 36, child: const Icon(Icons.my_location, color: Colors.blue)),
        ]),
        const SimpleAttributionWidget(source: Text('© OpenStreetMap contributors')),
      ],
    ))),
    const SizedBox(height: 8),
    DropdownButton<int>(isExpanded: true, value: _point, items: [for (int i = 0; i < _points.length; i++) DropdownMenuItem(value: i, child: Text(_points[i].$1))], onChanged: (i) { if (i != null) { setState(() => _point = i); _map.move(_points[i].$2, 13); } }),
    Text(_status, style: const TextStyle(fontSize: 12)),
    Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : _gps, icon: const Icon(Icons.my_location), label: const Text('Mi GPS'))),
      const SizedBox(width: 8),
      Expanded(child: FilledButton.icon(onPressed: _route, icon: const Icon(Icons.directions), label: const Text('Ruta'))),
    ]),
    const Text('La ubicación y la ruta pueden compartirse con el proveedor de mapas.', style: TextStyle(fontSize: 11)),
  ]);
}

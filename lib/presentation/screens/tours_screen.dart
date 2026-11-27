import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/velero_theme.dart';
import '../../domain/services/tour_catalog.dart';

class ToursScreen extends StatefulWidget {
  final ValueChanged<String> onBrisa;
  const ToursScreen({super.key, required this.onBrisa});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  Set<String> _assets = {};

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (mounted) setState(() => _assets = manifest.listAssets().toSet());
    } catch (_) {
      // El catálogo de texto funciona aun sin carteles instalados.
    }
  }

  Widget _poster(VeleroTour tour, {bool full = false}) {
    if (!_assets.contains(tour.asset)) {
      return const ColoredBox(
        color: VeleroTheme.water,
        child: Center(child: Icon(Icons.sailing_outlined, color: VeleroTheme.teal, size: 32)),
      );
    }
    return Image.asset(tour.asset, fit: full ? BoxFit.contain : BoxFit.cover,
      cacheWidth: full ? 1000 : 240,
      semanticLabel: 'Anuncio de ${tour.title}',
      errorBuilder: (_, error, stack) => const Center(child: Icon(Icons.image_not_supported_outlined)));
  }

  void _details(VeleroTour tour) {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true,
      showDragHandle: true, backgroundColor: VeleroTheme.ivory,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .92,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
          Text(tour.category.toUpperCase(), style: const TextStyle(color: VeleroTheme.teal, letterSpacing: 1.4)),
          const SizedBox(height: 6),
          Text(tour.title, style: Theme.of(sheetContext).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(tour.rate, style: const TextStyle(color: VeleroTheme.ocean, fontSize: 19, fontWeight: FontWeight.bold)),
          Text('Horario anunciado: ${tour.hours}'),
          const SizedBox(height: 16),
          const Text('Qué incluye', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          for (final item in tour.includes) Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_outline, size: 20, color: VeleroTheme.teal),
              const SizedBox(width: 8), Expanded(child: Text(item)),
            ]),
          ),
          if (tour.optional != null) ...[
            const SizedBox(height: 12), Text('Opcional: ${tour.optional}'),
          ],
          const SizedBox(height: 12),
          const Text(TourCatalog.confirmation, style: TextStyle(fontSize: 13)),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () { Navigator.pop(sheetContext); widget.onBrisa('¿Qué incluye ${tour.title}?'); },
            icon: const Icon(Icons.waves), label: const Text('Consultar con BRISA')),
          if (_assets.contains(tour.asset)) ...[
            const SizedBox(height: 18),
            ClipRRect(borderRadius: BorderRadius.circular(20), child: _poster(tour, full: true)),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.only(bottom: 12),
    itemCount: TourCatalog.all.length + 1,
    itemBuilder: (context, index) {
      if (index == 0) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [VeleroTheme.ocean, VeleroTheme.teal])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EXPERIENCIAS DEL CARIBE', style: TextStyle(color: VeleroTheme.champagne, letterSpacing: 1.5, fontSize: 11)),
            SizedBox(height: 8),
            Text('Más allá del resort', style: TextStyle(color: Colors.white, fontSize: 27, fontFamily: 'serif')),
            SizedBox(height: 6),
            Text('Descubre cuatro planes. Tarifas anunciadas, sujetas a confirmación.', style: TextStyle(color: Colors.white)),
          ]),
        );
      }
      final tour = TourCatalog.all[index - 1];
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 76, height: 100, child: ClipRRect(
                borderRadius: BorderRadius.circular(14), child: _poster(tour))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tour.category.toUpperCase(), style: const TextStyle(color: VeleroTheme.teal, fontSize: 11, letterSpacing: .9)),
                const SizedBox(height: 4),
                Text(tour.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: VeleroTheme.ocean)),
                const SizedBox(height: 6),
                Text(tour.rate, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(tour.hours, style: const TextStyle(fontSize: 13)),
              ])),
            ]),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => _details(tour), child: const Text('Ver experiencia')),
          ]),
        ),
      );
    },
  );
}

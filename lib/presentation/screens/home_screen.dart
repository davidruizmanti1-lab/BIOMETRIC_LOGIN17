import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/velero_theme.dart';
import '../../domain/services/velero_gallery.dart';
import '../controllers/auth_controller.dart';
import 'travel_screens.dart';
import 'velero_map_screen.dart';
import 'brisa_screen.dart';
import '../widgets/velero_brand.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      appBar: AppBar(title: Row(children: [
        const VeleroBrand(size: 44),
        const SizedBox(width: 8),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Velero2H', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'serif', fontSize: 22)),
          Text('AGENCIA DE TURISMO', style: TextStyle(color: VeleroTheme.teal, fontSize: 9, letterSpacing: 1.3)),
        ])),
      ]), actions: [
        IconButton(tooltip: 'Cerrar sesión', onPressed: context.read<AuthController>().logout, icon: const Icon(Icons.logout)),
      ]),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: LayoutBuilder(builder: (context, size) => Stack(fit: StackFit.expand, children: [
          _pane(0, CatalogScreen(onBrisa: () => setState(() => _tab = 4)), size.maxHeight),
          if (_tab == 1) const VeleroMapScreen() else const SizedBox.shrink(),
          _pane(2, const TripScreen(), size.maxHeight),
          _pane(3, const BudgetScreen(), size.maxHeight),
          _pane(4, const BrisaScreen(), size.maxHeight),
        ])),
      )),
      bottomNavigationBar: keyboard ? null : NavigationBar(
        selectedIndex: _tab, height: 72,
        onDestinationSelected: (i) { FocusScope.of(context).unfocus(); setState(() => _tab = i); },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.hotel_outlined), label: 'Estadía'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Viaje'),
          NavigationDestination(icon: Icon(Icons.wallet_outlined), label: 'Gastos'),
          NavigationDestination(icon: Icon(Icons.waves), label: 'BRISA'),
        ],
      ),
    );
  }

  // Las herramientas mantienen su estado dentro de la sesión.
  Widget _pane(int index, Widget child, double height) => Offstage(
    offstage: _tab != index,
    child: ExcludeFocus(excluding: _tab != index, child: TickerMode(enabled: _tab == index, child: OverflowBox(
      minHeight: _tab == index ? height : 650,
      maxHeight: _tab == index ? height : 650,
      alignment: Alignment.topCenter, child: child,
    ))),
  );
}

class CatalogScreen extends StatefulWidget {
  final VoidCallback onBrisa;
  const CatalogScreen({super.key, required this.onBrisa});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  PhotoCategory _category = PhotoCategory.all;
  int _index = 0;
  Set<String> _assets = VeleroGallery.website.map((p) => p.asset).toSet();
  static const _labels = ['Todas las fotos', 'Habitaciones', 'Baños', 'Cocinas', 'Otros espacios'];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (mounted) setState(() { _assets = manifest.listAssets().toSet(); _index = 0; });
    } catch (_) { /* Las fotos de la web siguen disponibles. */ }
  }

  void _viewPhoto(VeleroPhoto photo) {
    showDialog<void>(context: context, builder: (context) => Dialog.fullscreen(
      backgroundColor: VeleroTheme.ocean,
      child: SafeArea(child: Column(children: [
        Row(children: [
          IconButton(color: Colors.white, tooltip: 'Cerrar foto', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          Expanded(child: Text(photo.caption, style: const TextStyle(color: Colors.white), maxLines: 2)),
        ]),
        Expanded(child: InteractiveViewer(
          minScale: 1, maxScale: 3,
          child: Center(child: Image.asset(photo.asset, fit: BoxFit.contain,
            errorBuilder: (_, error, stack) => const Text('Foto no disponible', style: TextStyle(color: Colors.white)))),
        )),
        const Padding(padding: EdgeInsets.all(12), child: Text('Foto real · acerca con dos dedos', style: TextStyle(color: Colors.white70))),
      ])),
    ));
  }

  Future<void> _open() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await launchUrl(Uri.https('velero2h.lat', '/alojamientos'), mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (mounted) messenger.showSnackBar(const SnackBar(content: Text('No se pudo abrir el sitio. Revisa tu conexión.')));
  }

  @override
  Widget build(BuildContext context) {
    final categories = VeleroGallery.categories(_assets);
    final category = categories.contains(_category) ? _category : PhotoCategory.all;
    final photos = VeleroGallery.available(_assets, category);
    final photo = photos.isEmpty ? null : photos[_index % photos.length];
    return LayoutBuilder(builder: (context, box) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (box.maxHeight > 435) Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [VeleroTheme.ocean, VeleroTheme.teal],
        )),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SANTA MARTA  /  COLOMBIA', style: TextStyle(color: VeleroTheme.lightAqua, fontSize: 10, letterSpacing: 2)),
          SizedBox(height: 4),
          Text('Tu escape al Caribe', style: TextStyle(fontSize: 26, color: Colors.white, fontFamily: 'serif', height: 1.05)),
          SizedBox(height: 8),
          Text('Estadías y experiencias a tu ritmo.', style: TextStyle(color: Colors.white, fontSize: 12)),
          SizedBox(height: 9),
          SizedBox(width: 42, height: 2, child: ColoredBox(color: VeleroTheme.gold)),
        ]),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<PhotoCategory>(
        key: ValueKey(categories.map((item) => item.name).join(',')),
        initialValue: category, isExpanded: true,
        decoration: const InputDecoration(labelText: 'Explorar espacios', isDense: true),
        items: [for (final item in categories) DropdownMenuItem(value: item, child: Text(_labels[item.index]))],
        onChanged: (value) { if(value != null) setState(() { _category = value; _index = 0; }); },
      ),
      const SizedBox(height: 8),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(color: VeleroTheme.ocean, child: photo == null
          ? const Center(child: Text('No hay fotos de esta categoría instaladas.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))
          : Stack(fit: StackFit.expand, children: [
            Image.asset(photo.asset, fit: BoxFit.contain, semanticLabel: photo.caption,
              cacheWidth: (box.maxWidth * MediaQuery.devicePixelRatioOf(context)).round().clamp(320, 1200).toInt(),
              errorBuilder: (_, error, stack) => const Center(child: Text('Foto no disponible', style: TextStyle(color: Colors.white)))),
            Positioned(top: 8, left: 8, child: IconButton.filledTonal(
              tooltip: 'Ampliar fotografía', onPressed: () => _viewPhoto(photo), icon: const Icon(Icons.fullscreen))),
            Align(alignment: Alignment.centerLeft, child: IconButton.filledTonal(tooltip: 'Foto anterior', onPressed: () => setState(() => _index = (_index + photos.length - 1) % photos.length), icon: const Icon(Icons.chevron_left))),
            Align(alignment: Alignment.centerRight, child: IconButton.filledTonal(tooltip: 'Foto siguiente', onPressed: () => setState(() => _index = (_index + 1) % photos.length), icon: const Icon(Icons.chevron_right))),
            Positioned(top: 8, right: 8, child: DecoratedBox(decoration: BoxDecoration(color: VeleroTheme.ocean, borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(8), child: Text('${_index + 1}/${photos.length}', style: const TextStyle(color: Colors.white))))),
            Positioned(bottom: 0, left: 0, right: 0, child: ColoredBox(color: VeleroTheme.ocean.withValues(alpha: .9), child: Padding(padding: const EdgeInsets.all(10), child: Text(photo.caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white))))),
          ]),
        ),
      )),
      const SizedBox(height: 6),
      const Text('Fotografías reales · fechas por confirmar', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
      FilledButton.icon(onPressed: _open, icon: const Icon(Icons.calendar_month), label: const Text('Consultar alojamiento y fechas')),
      OutlinedButton.icon(onPressed: widget.onBrisa, icon: const Icon(Icons.waves), label: const Text('Preguntar a BRISA')),
    ]));
  }
}

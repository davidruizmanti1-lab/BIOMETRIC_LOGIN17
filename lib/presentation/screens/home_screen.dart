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
import 'tours_screen.dart';
import '../widgets/velero_brand.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _visited = <int>{0};
  String? _brisaPrompt;
  int _brisaRevision = 0;

  void _select(int i) {
    FocusScope.of(context).unfocus();
    setState(() { _tab = i; _visited.add(i); });
  }

  void _askBrisa(String prompt) {
    FocusScope.of(context).unfocus();
    setState(() {
      _brisaPrompt = prompt;
      _brisaRevision++;
      _tab = 4;
      _visited.add(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      appBar: AppBar(title: Row(children: [
        const VeleroBrand(size: 44),
        const SizedBox(width: 8),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Velero2H', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'serif', fontSize: 22)),
          Text('RESORT · EXPERIENCIAS', style: TextStyle(color: VeleroTheme.teal, fontSize: 9, letterSpacing: 1.1)),
        ])),
      ]), actions: [
        IconButton(tooltip: 'Cerrar sesión', onPressed: context.read<AuthController>().logout, icon: const Icon(Icons.logout)),
      ]),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: LayoutBuilder(builder: (context, size) => Stack(fit: StackFit.expand, children: [
          _pane(0, CatalogScreen(onBrisa: () => _askBrisa('¿Qué alojamientos ofrecen?')), size.maxHeight),
          _pane(1, ToursScreen(onBrisa: _askBrisa), size.maxHeight),
          _pane(2, const TravelHub(), size.maxHeight),
          if (_tab == 3) const VeleroMapScreen() else const SizedBox.shrink(),
          _pane(4, BrisaScreen(suggestedQuestion: _brisaPrompt, suggestionRevision: _brisaRevision), size.maxHeight),
        ])),
      )),
      bottomNavigationBar: keyboard ? null : NavigationBar(
        selectedIndex: _tab, height: 72, onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.hotel_outlined), label: 'Estadía'),
          NavigationDestination(icon: Icon(Icons.sailing_outlined), label: 'Tours'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Viaje'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.waves), label: 'BRISA'),
        ],
      ),
    );
  }

  // Solo se montan los módulos visitados; el mapa se libera al salir.
  Widget _pane(int index, Widget child, double height) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    final active = _tab == index;
    return Offstage(
      offstage: !active,
      child: ExcludeFocus(excluding: !active, child: TickerMode(enabled: active, child: OverflowBox(
        minHeight: active ? height : 650,
        maxHeight: active ? height : 650,
        alignment: Alignment.topCenter, child: child,
      ))),
    );
  }
}

class TravelHub extends StatefulWidget {
  const TravelHub({super.key});
  @override
  State<TravelHub> createState() => _TravelHubState();
}

class _TravelHubState extends State<TravelHub> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(children: [
      if (!keyboard) ...[
        SizedBox(width: double.infinity, child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, icon: Icon(Icons.event_note_outlined), label: Text('Itinerario')),
            ButtonSegment(value: 1, icon: Icon(Icons.wallet_outlined), label: Text('Gastos')),
          ],
          selected: {_index},
          onSelectionChanged: (value) => setState(() => _index = value.first),
        )),
        const SizedBox(height: 8),
      ],
      Expanded(child: LayoutBuilder(builder: (context, box) => Stack(fit: StackFit.expand, children: [
        for (final entry in const [(0, TripScreen()), (1, BudgetScreen())])
          Offstage(offstage: _index != entry.$1,
            child: ExcludeFocus(excluding: _index != entry.$1,
              child: OverflowBox(
                minHeight: _index == entry.$1 ? box.maxHeight : 650,
                maxHeight: _index == entry.$1 ? box.maxHeight : 650,
                alignment: Alignment.topCenter, child: entry.$2))),
      ]))),
    ]);
  }
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
  static const _labels = ['Todos los espacios', 'Habitaciones', 'Baños', 'Cocinas', 'Salas', 'Balcones y vistas', 'Piscinas'];

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
      if (box.maxHeight > 540) Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [VeleroTheme.ocean, VeleroTheme.teal],
        )),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SANTA MARTA  /  COLOMBIA', style: TextStyle(color: VeleroTheme.lightAqua, fontSize: 10, letterSpacing: 2)),
          SizedBox(height: 4),
          Text('Tu refugio frente al mar', style: TextStyle(fontSize: 26, color: Colors.white, fontFamily: 'serif', height: 1.05)),
          SizedBox(height: 8),
          Text('Descubre cada espacio a tu ritmo.', style: TextStyle(color: Colors.white, fontSize: 12)),
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
      if (box.maxHeight > 520 && photos.length > 1) ...[
        const SizedBox(height: 8),
        SizedBox(height: 56, child: ListView.builder(
          scrollDirection: Axis.horizontal, itemCount: photos.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _index = i),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 68, padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: i == _index ? VeleroTheme.teal : VeleroTheme.water, width: 2)),
                child: ClipRRect(borderRadius: BorderRadius.circular(7),
                  child: Image.asset(photos[i].asset, fit: BoxFit.cover, cacheWidth: 180,
                    semanticLabel: photos[i].caption,
                    errorBuilder: (_, error, stack) => const Icon(Icons.image_not_supported_outlined))),
              ),
            ),
          ),
        )),
      ],
      const SizedBox(height: 6),
      const Text('Fotografías reales · fechas por confirmar', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
      FilledButton.icon(onPressed: _open, icon: const Icon(Icons.calendar_month), label: const Text('Consultar alojamiento y fechas')),
      OutlinedButton.icon(onPressed: widget.onBrisa, icon: const Icon(Icons.waves), label: const Text('Preguntar a BRISA')),
    ]));
  }
}

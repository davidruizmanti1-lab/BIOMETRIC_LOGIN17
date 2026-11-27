import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/velero_theme.dart';
import '../../domain/services/brisa_faq.dart';
import '../../domain/services/tour_catalog.dart';
import '../controllers/auth_controller.dart';
import '../widgets/velero_brand.dart';

class BrisaScreen extends StatefulWidget {
  final String? suggestedQuestion;
  final int suggestionRevision;
  const BrisaScreen({super.key, this.suggestedQuestion, this.suggestionRevision = 0});

  @override
  State<BrisaScreen> createState() => _BrisaScreenState();
}

class _BrisaScreenState extends State<BrisaScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _history = <(String, String, String)>[];
  bool _online = false;
  bool _busy = false;
  String? _notice;

  static const _suggestions = [
    '¿Qué alojamientos ofrecen?',
    '¿Qué tours ofrecen y cuánto cuestan?',
    '¿Qué incluye Bahía Concha?',
    '¿Cómo reservo?',
  ];

  @override
  void initState() {
    super.initState();
    _input.text = widget.suggestedQuestion ?? '';
  }

  @override
  void didUpdateWidget(covariant BrisaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestionRevision != widget.suggestionRevision) {
      _input.text = widget.suggestedQuestion ?? '';
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _latest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _ask(String question) async {
    if (_busy) return;
    final q = question.trim();
    FocusScope.of(context).unfocus();
    if (!BrisaFaq.safe(q)) {
      setState(() => _notice = BrisaFaq.privacy);
      return;
    }
    final auth = context.read<AuthController>();
    final fromCatalog = TourCatalog.matching(q).isNotEmpty || BrisaFaq.localTopics(q).contains('tours');
    final useOnline = _online && auth.brisaAvailable && !fromCatalog;
    setState(() {
      _notice = null;
      _busy = useOnline;
      if (_history.length >= 12) _history.removeAt(0);
      _history.add((q, BrisaFaq.answer(q),
        fromCatalog ? 'Catálogo de tours · local' : useOnline ? 'Guía local · consultando IA' : 'Guía local'));
    });
    _input.clear();
    _latest();
    if (!useOnline) return;

    String? topic;
    try { topic = await auth.askBrisa(q); } catch (_) { topic = null; }
    if (!mounted) return;
    final confirmed = BrisaFaq.validTopics(topic).isNotEmpty;
    setState(() {
      _history[_history.length - 1] = (
        q, BrisaFaq.answer(q, topic: confirmed ? topic : null),
        confirmed ? 'IA en línea · guía autorizada' : 'Guía local · IA no disponible',
      );
      _busy = false;
    });
    _latest();
  }

  Widget _welcome(bool available) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [VeleroTheme.ocean, VeleroTheme.teal])),
      child: const Row(children: [
        VeleroBrand(size: 48), SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BRISA', style: TextStyle(color: Colors.white, fontFamily: 'serif', fontSize: 27)),
          Text('Tu concierge del Caribe', style: TextStyle(color: VeleroTheme.champagne, fontSize: 13)),
        ])),
      ]),
    ),
    if (available) SwitchListTile(
      contentPadding: EdgeInsets.zero, dense: true,
      title: const Text('IA en línea'),
      subtitle: const Text('Solo preguntas generales; catálogo local primero.'),
      value: _online, onChanged: _busy ? null : (v) => setState(() => _online = v),
    ) else const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text('Guía local disponible sin conexión al proveedor de IA.', style: TextStyle(fontSize: 12)),
    ),
    if (_history.isEmpty) ...[
      const SizedBox(height: 8),
      const Text('Hola. ¿En qué puedo ayudarte?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      for (final q in _suggestions) Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: OutlinedButton(onPressed: () => _ask(q), child: Text(q, textAlign: TextAlign.center))),
    ],
  ]);

  Widget _message((String, String, String) item) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Align(alignment: Alignment.centerRight, child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.only(left: 28),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: VeleroTheme.ocean,
          borderRadius: BorderRadius.circular(18)),
        child: Text(item.$1, style: const TextStyle(color: Colors.white, height: 1.4)),
      )),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.white, VeleroTheme.water]),
          border: Border.all(color: VeleroTheme.water),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.waves, size: 20, color: VeleroTheme.teal),
            const SizedBox(width: 6),
            Expanded(child: Text(item.$3, style: const TextStyle(color: VeleroTheme.teal, fontWeight: FontWeight.w600, fontSize: 12))),
          ]),
          const SizedBox(height: 10),
          SelectableText(item.$2, style: const TextStyle(color: VeleroTheme.ink, fontSize: 15, height: 1.5)),
        ]),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final available = context.watch<AuthController>().brisaAvailable;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(child: ListView.builder(
        controller: _scroll, padding: const EdgeInsets.only(bottom: 8),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        itemCount: _history.length + 1,
        itemBuilder: (context, index) => index == 0 ? _welcome(available) : _message(_history[index - 1]),
      )),
      if (_busy) const LinearProgressIndicator(),
      if (_notice != null) Text(_notice!, style: TextStyle(color: Theme.of(context).colorScheme.error), maxLines: 2),
      const SizedBox(height: 6),
      TextField(
        controller: _input, enabled: !_busy, maxLength: 300,
        textInputAction: TextInputAction.send, onSubmitted: _ask,
        decoration: InputDecoration(hintText: 'Pregúntale a BRISA', counterText: '',
          suffixIcon: IconButton(tooltip: 'Enviar pregunta', onPressed: _busy ? null : () => _ask(_input.text),
            icon: const Icon(Icons.send_rounded))),
      ),
    ]);
  }
}

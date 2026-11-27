import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../core/velero_theme.dart';
import '../../domain/services/brisa_faq.dart';

class BrisaScreen extends StatefulWidget {
  const BrisaScreen({super.key});
  @override
  State<BrisaScreen> createState() => _BrisaScreenState();
}

class _BrisaScreenState extends State<BrisaScreen> {
  final _input = TextEditingController();
  String _answer = 'Hola, soy BRISA. Pregúntame por estadías, reservas o planes en Santa Marta.';
  int _page = 0;
  bool _online = false, _busy = false;
  String _source = 'Guía local · sin internet';
  static const _questions = ['¿Qué alojamientos ofrecen?', '¿Cuánto cuesta?', '¿Cómo reservo?', '¿Hay disponibilidad?', '¿Ofrecen tours?'];
  @override
  void dispose() { _input.dispose(); super.dispose(); }

  Future<void> _ask(String q) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (!BrisaFaq.safe(q)) {
      setState(() { _answer = BrisaFaq.answer(q); _source = 'Privacidad'; });
      return;
    }
    final auth = context.read<AuthController>();
    setState(() => _busy = true);
    _input.clear();
    String? topic;
    if (_online) {
      try { topic = await auth.askBrisa(q.trim()); } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _answer = BrisaFaq.answer(q, topic: topic);
      _source = topic == null ? 'Guía local · sin internet' : 'IA semántica · respuestas verificadas';
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, size) {
    final compact = size.maxHeight < 390;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!compact) const ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: VeleroTheme.teal, foregroundColor: Colors.white, child: Icon(Icons.waves)), title: Text('BRISA', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Tu concierge de viaje')),
      Expanded(child: Container(
        decoration: BoxDecoration(color: VeleroTheme.water, borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.all(16),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_source, textAlign: TextAlign.center, style: const TextStyle(color: VeleroTheme.teal, fontSize: 12)),
          const SizedBox(height: 8),
          Flexible(child: Text(_answer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.35))),
        ])),
      )),
      if (!compact && context.watch<AuthController>().brisaAvailable)
        SwitchListTile(dense: true, contentPadding: EdgeInsets.zero, title: const Text('IA en línea (opcional)'), subtitle: const Text('Envía únicamente preguntas generales.'), value: _online, onChanged: _busy ? null : (v) => setState(() => _online = v)),
      if (!compact) Row(children: [
        IconButton(tooltip: 'Anterior', onPressed: () => setState(() => _page = (_page + _questions.length - 1) % _questions.length), icon: const Icon(Icons.chevron_left)),
        Expanded(child: TextButton(onPressed: () => _ask(_questions[_page]), child: Text(_questions[_page]))),
        IconButton(tooltip: 'Siguiente', onPressed: () => setState(() => _page = (_page + 1) % _questions.length), icon: const Icon(Icons.chevron_right)),
      ]),
      const SizedBox(height: 8),
      TextField(controller: _input, enabled: !_busy, maxLength: 300, textInputAction: TextInputAction.send, onSubmitted: _ask,
        decoration: InputDecoration(hintText: 'Pregúntale a BRISA', counterText: '', suffixIcon: IconButton(tooltip: 'Enviar', onPressed: _busy ? null : () => _ask(_input.text), icon: const Icon(Icons.send_rounded)))),
      if (_busy) const LinearProgressIndicator(),
    ]);
  });
}

import 'package:flutter/material.dart';
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
  static const _questions = ['¿Qué alojamientos ofrecen?', '¿Cuánto cuesta?', '¿Cómo reservo?', '¿Hay disponibilidad?', '¿Ofrecen tours?'];
  @override
  void dispose() { _input.dispose(); super.dispose(); }

  void _ask(String q) {
    FocusScope.of(context).unfocus();
    setState(() => _answer = BrisaFaq.answer(q));
    _input.clear();
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
          const Text('Guía local · sin internet', textAlign: TextAlign.center, style: TextStyle(color: VeleroTheme.teal, fontSize: 12)),
          const SizedBox(height: 8),
          Flexible(child: Text(_answer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.35))),
        ])),
      )),
      if (!compact) Row(children: [
        IconButton(tooltip: 'Anterior', onPressed: () => setState(() => _page = (_page + _questions.length - 1) % _questions.length), icon: const Icon(Icons.chevron_left)),
        Expanded(child: TextButton(onPressed: () => _ask(_questions[_page]), child: Text(_questions[_page]))),
        IconButton(tooltip: 'Siguiente', onPressed: () => setState(() => _page = (_page + 1) % _questions.length), icon: const Icon(Icons.chevron_right)),
      ]),
      const SizedBox(height: 8),
      TextField(controller: _input, maxLength: 300, textInputAction: TextInputAction.send, onSubmitted: _ask,
        decoration: InputDecoration(hintText: 'Pregúntale a BRISA', counterText: '', suffixIcon: IconButton(tooltip: 'Enviar', onPressed: () => _ask(_input.text), icon: const Icon(Icons.send_rounded)))),
    ]);
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/velero_theme.dart';
import '../../domain/services/brisa_faq.dart';
import '../controllers/auth_controller.dart';
import '../widgets/velero_brand.dart';

class BrisaScreen extends StatefulWidget {
  const BrisaScreen({super.key});

  @override
  State<BrisaScreen> createState() => _BrisaScreenState();
}

class _BrisaScreenState extends State<BrisaScreen> {
  final _input = TextEditingController();
  final _history = <(String, String, String)>[];
  int _page = 0;
  bool _online = false;
  bool _busy = false;
  String? _notice;

  static const _suggestions = [
    '¿Qué alojamientos ofrecen?',
    '¿Tienen cocina y aire acondicionado?',
    '¿Cuánto cuesta y cómo reservo?',
    '¿Hay disponibilidad?',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
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
    final useOnline = _online && auth.brisaAvailable;
    setState(() {
      _notice = null;
      _busy = useOnline;
      if (_history.length >= 12) _history.removeAt(0);
      _history.add((q, BrisaFaq.answer(q), useOnline ? 'Guía local · consultando IA' : 'Guía local'));
      _page = _history.length - 1;
    });
    _input.clear();
    if (!useOnline) return;

    // La respuesta local permanece visible si el servidor no responde.
    String? topic;
    try {
      topic = await auth.askBrisa(q);
    } catch (_) {
      topic = null;
    }
    if (!mounted) return;
    final confirmed = BrisaFaq.validTopics(topic).isNotEmpty;
    setState(() {
      _history[_history.length - 1] = (
        q,
        BrisaFaq.answer(q, topic: confirmed ? topic : null),
        confirmed ? 'IA en línea · guía autorizada' : 'Guía local · revisa conexión, sesión o configuración del servidor',
      );
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = context.watch<AuthController>().brisaAvailable;
    final latest = _history.isEmpty ? null : _history[_page];
    return LayoutBuilder(builder: (context, size) {
      final compact = size.maxHeight < 400;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!compact) ...[
          Row(children: [
            const VeleroBrand(size: 50),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BRISA', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700, color: VeleroTheme.ocean)),
              const Text('Concierge privado · Velero2H', style: TextStyle(color: VeleroTheme.teal, fontSize: 12)),
            ])),
          ]),
          const SizedBox(height: 10),
          if (available)
            SwitchListTile(
              dense: true, contentPadding: EdgeInsets.zero,
              title: const Text('IA en línea'),
              subtitle: const Text('Envía solo preguntas generales al proveedor.'),
              value: _online,
              onChanged: _busy ? null : (value) => setState(() => _online = value),
            )
          else const Text('Modo local · activa BRISA en la configuración de compilación y vuelve a iniciar sesión.', style: TextStyle(fontSize: 12)),
        ],
        if (_busy) const LinearProgressIndicator(),
        const SizedBox(height: 6),
        Expanded(child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(latest?.$3 ?? 'BIENVENIDO A BORDO', style: const TextStyle(
                color: VeleroTheme.teal, fontWeight: FontWeight.w600, fontSize: 12)),
              if (latest != null && !compact) ...[
                const SizedBox(height: 6),
                Text(latest.$1, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 8),
              Expanded(child: Center(child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: (size.maxWidth - 36).clamp(120.0, 600.0).toDouble(),
                  child: Text(latest?.$2 ?? 'Hola, soy BRISA. Puedo orientarte sobre alojamientos, servicios, reservas y turismo en Santa Marta.',
                    style: const TextStyle(fontSize: 16, height: 1.35), textAlign: TextAlign.center),
                ),
              ))),
            ]),
          ),
        )),
        if (!compact && _history.length > 1) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(tooltip: 'Consulta anterior', onPressed: _page > 0 ? () => setState(() => _page--) : null, icon: const Icon(Icons.chevron_left)),
          Text((_page + 1).toString() + '/' + _history.length.toString()),
          IconButton(tooltip: 'Consulta siguiente', onPressed: _page + 1 < _history.length ? () => setState(() => _page++) : null, icon: const Icon(Icons.chevron_right)),
        ]),
        if (!compact && _history.isEmpty) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Preguntas frecuentes', isDense: true),
            items: [for (final q in _suggestions) DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis))],
            onChanged: (q) { if (q != null) _ask(q); },
          ),
        ),
        if (_notice != null) Text(_notice!, style: TextStyle(color: Theme.of(context).colorScheme.error), maxLines: 2),
        const SizedBox(height: 8),
        TextField(
          controller: _input, enabled: !_busy, maxLength: 300,
          textInputAction: TextInputAction.send, onSubmitted: _ask,
          decoration: InputDecoration(hintText: 'Pregúntale a BRISA', counterText: '',
            suffixIcon: IconButton(tooltip: 'Enviar pregunta', onPressed: _busy ? null : () => _ask(_input.text), icon: const Icon(Icons.send_rounded))),
        ),
      ]);
    });
  }
}

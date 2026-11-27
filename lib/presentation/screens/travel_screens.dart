import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/velero_theme.dart';
import '../../domain/services/travel_tools.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});
  @override
  State<TripScreen> createState() => _TripScreenState();
}
class _TripScreenState extends State<TripScreen> {
  final _budget = TextEditingController();
  TravelInterest _interest = TravelInterest.playa;
  int _days = 3, _page = 0, _total = 0;
  List<TravelDay> _plan = [];
  String? _error;
  @override
  void dispose() { _budget.dispose(); super.dispose(); }
  void _generate() {
    final total = int.tryParse(_budget.text);
    if (total == null || total < 0 || total > 100000000) {
      setState(() => _error = 'Ingresa un presupuesto válido en COP.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _plan = TravelTools.plan(_interest, _days); _page = 0; _total = total; _error = null; });
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final compact = box.maxHeight < 400;
    if (_plan.isNotEmpty) {
      final day = _plan[_page];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Día ${_page + 1} de ${_plan.length}', style: Theme.of(context).textTheme.titleLarge),
        Text('Presupuesto diario: ${TravelTools.cop(TravelTools.split(_total, _days)[_page])}'),
        const SizedBox(height: 8),
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!compact) const Icon(Icons.explore_outlined, size: 44, color: VeleroTheme.teal),
          Text(day.title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text('MAÑANA', style: TextStyle(color: VeleroTheme.teal, fontWeight: FontWeight.bold)),
          Text(day.morning, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('TARDE', style: TextStyle(color: VeleroTheme.teal, fontWeight: FontWeight.bold)),
          Text(day.afternoon, textAlign: TextAlign.center),
        ]))))),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _page > 0 ? () => setState(() => _page--) : null, child: const Text('Anterior'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: _page + 1 < _plan.length ? () => setState(() => _page++) : null, child: const Text('Siguiente'))),
        ]),
        TextButton(onPressed: () => setState(() => _plan = []), child: const Text('Editar viaje')),
        const Text('Sugerencia por reglas · no es una reserva ni cotización.', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
      ]);
    }
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!compact) ...[Text('Diseña tu viaje', style: Theme.of(context).textTheme.headlineMedium), const Text('Tu itinerario, a tu ritmo y presupuesto.'), const SizedBox(height: 12)],
      if (!keyboard) ...[
        DropdownButtonFormField<TravelInterest>(initialValue: _interest, decoration: const InputDecoration(labelText: 'Qué te gusta'), items: [for (final i in TravelInterest.values) DropdownMenuItem(value: i, child: Text(i.name))], onChanged: (v) { if (v != null) setState(() => _interest = v); }),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(initialValue: _days, decoration: const InputDecoration(labelText: 'Duración'), items: [for (int i = 1; i <= 5; i++) DropdownMenuItem(value: i, child: Text('$i día(s)'))], onChanged: (v) { if (v != null) setState(() => _days = v); }),
        const SizedBox(height: 8),
      ],
      TextField(controller: _budget, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)], decoration: const InputDecoration(labelText: 'Presupuesto total COP'), onSubmitted: (_) => _generate()),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      const Spacer(),
      FilledButton.icon(onPressed: _generate, icon: const Icon(Icons.auto_awesome), label: const Text('Crear itinerario')),
    ]);
  });
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}
class _BudgetScreenState extends State<BudgetScreen> {
  final _amount = TextEditingController();
  final _expenses = <(String, int)>[];
  static const _categories = ['Alojamiento', 'Transporte', 'Comida', 'Actividad', 'Otro'];
  String _category = _categories.first;
  int _people = 2, _page = 0;
  String? _error;
  @override
  void dispose() { _amount.dispose(); super.dispose(); }
  void _add() {
    final value = int.tryParse(_amount.text);
    if (value == null || value <= 0 || value > 100000000 || _expenses.length >= 100) {
      setState(() => _error = 'Monto inválido o límite de gastos alcanzado.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _expenses.add((_category, value)); _page = _expenses.length - 1; _amount.clear(); _error = null; });
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final compact = box.maxHeight < 400;
    final total = _expenses.fold(0, (sum, item) => sum + item.$2);
    final split = TravelTools.split(total, _people);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!compact) ...[
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: VeleroTheme.ocean, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PRESUPUESTO DE VIAJE', style: TextStyle(color: VeleroTheme.lightAqua, letterSpacing: 1, fontSize: 11)),
          Text(TravelTools.cop(total), style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
          Text('Por persona: ${TravelTools.cop(split.last)}${split.first != split.last ? ' – ${TravelTools.cop(split.first)}' : ''}', style: const TextStyle(color: Colors.white)),
        ])),
        Row(children: [const Text('Viajeros'), const Spacer(),
          IconButton(tooltip: 'Quitar viajero', onPressed: _people > 1 ? () => setState(() => _people--) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$_people'),
          IconButton(tooltip: 'Añadir viajero', onPressed: _people < 20 ? () => setState(() => _people++) : null, icon: const Icon(Icons.add_circle_outline)),
        ]),
      ],
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(initialValue: _category, isExpanded: true, decoration: const InputDecoration(labelText: 'Concepto'), items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))], onChanged: (v) { if (v != null) setState(() => _category = v); })),
        const SizedBox(width: 6),
        Expanded(child: TextField(controller: _amount, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)], decoration: const InputDecoration(labelText: 'Monto COP'), onSubmitted: (_) => _add())),
      ]),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Registrar gasto')),
      if (keyboard) const Spacer() else Expanded(child: Card(child: Center(child: _expenses.isEmpty
        ? const Text('Aún no has registrado gastos.')
        : Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${_page + 1}/${_expenses.length} · ${_expenses[_page].$1}'),
          Text(TravelTools.cop(_expenses[_page].$2), style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(tooltip: 'Anterior', onPressed: _page > 0 ? () => setState(() => _page--) : null, icon: const Icon(Icons.chevron_left)),
            IconButton(tooltip: 'Eliminar', onPressed: () => setState(() { _expenses.removeAt(_page); _page = _expenses.isEmpty ? 0 : _page.clamp(0, _expenses.length - 1).toInt(); }), icon: const Icon(Icons.delete_outline)),
            IconButton(tooltip: 'Siguiente', onPressed: _page + 1 < _expenses.length ? () => setState(() => _page++) : null, icon: const Icon(Icons.chevron_right)),
          ]),
        ]),
      ))),
      if (!compact) const Text('Registro temporal privado. No realiza cobros. Se borra al cerrar sesión.', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
    ]);
  });
}

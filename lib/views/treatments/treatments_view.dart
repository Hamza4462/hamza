import 'package:flutter/material.dart';
import '../../models/treatment.dart';
import '../../services/treatment_service.dart';

class TreatmentsView extends StatefulWidget {
  const TreatmentsView({super.key});

  @override
  State<TreatmentsView> createState() => _TreatmentsViewState();
}

class _TreatmentsViewState extends State<TreatmentsView> {
  final TreatmentService _service = TreatmentService();
  List<Treatment> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _service.getAll();
    if (!mounted) return;
    setState(() { _list = items; _loading = false; });
  }

  Future<void> _showAddEdit([Treatment? t]) async {
    final nameCtrl = TextEditingController(text: t?.name ?? '');
    final descCtrl = TextEditingController(text: t?.description ?? '');
    final priceCtrl = TextEditingController(text: t?.price.toString() ?? '0.0');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t == null ? 'Add Treatment' : 'Edit Treatment'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;

    final newT = Treatment(
      id: t?.id,
      name: nameCtrl.text,
      description: descCtrl.text,
      price: double.tryParse(priceCtrl.text) ?? 0.0,
    );

    if (t == null) await _service.create(newT);
    else await _service.update(newT);

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treatments')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('No treatments yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final tr = _list[i];
                    return ListTile(
                      title: Text(tr.name),
                      subtitle: Text(tr.description ?? ''),
                      trailing: Text('PKR ${tr.price.toStringAsFixed(2)}'),
                      onTap: () => _showAddEdit(tr),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

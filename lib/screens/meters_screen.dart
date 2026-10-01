import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/saved_meter.dart';
import '../services/meter_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MetersScreen extends StatefulWidget {
  const MetersScreen({super.key});

  @override
  State<MetersScreen> createState() => _MetersScreenState();
}

class _MetersScreenState extends State<MetersScreen> {
  final _service = MeterService();
  List<SavedMeter> _meters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meters = await _service.load();
    if (!mounted) return;
    setState(() {
      _meters = meters;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await _service.delete(id);
    _load();
  }

  Future<void> _addMeter() async {
    final labelController = TextEditingController();
    final meterController = TextEditingController();
    final splitController = TextEditingController();
    bool isSplit = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Meter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (e.g. Home)'),
              ),
              TextField(
                controller: meterController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Meter number'),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isSplit,
                    onChanged: (v) => setDialogState(() => isSplit = v ?? false),
                  ),
                  const Text('Split meter'),
                ],
              ),
              if (isSplit)
                TextField(
                  controller: splitController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Split meter number'),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved == true &&
        labelController.text.trim().isNotEmpty &&
        meterController.text.trim().isNotEmpty) {
      await _service.add(
        SavedMeter(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          label: labelController.text.trim(),
          meterNumber: meterController.text.trim(),
          isSplit: isSplit,
          splitMeterNumber: isSplit && splitController.text.trim().isNotEmpty
              ? splitController.text.trim()
              : null,
        ),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backdrop),
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  GlassIconButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Meters',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  GlassIconButton(icon: Icons.add, onTap: _addMeter),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _meters.isEmpty
                      ? const Center(
                          child: Text('No saved meters yet.', style: TextStyle(color: Colors.white70)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          itemCount: _meters.length,
                          itemBuilder: (context, index) {
                            final m = _meters[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: AppColors.meterOrangeBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.speed_outlined, color: AppColors.meterOrange),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(m.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          Text(
                                            m.isSplit
                                                ? '${m.meterNumber} • Split: ${m.splitMeterNumber}'
                                                : m.meterNumber,
                                            style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed),
                                      onPressed: () => _delete(m.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

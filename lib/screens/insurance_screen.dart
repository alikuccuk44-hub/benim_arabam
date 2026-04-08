import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(int days) {
    if (days < 0) return Colors.red;
    if (days <= 30) return Colors.orange;
    return Colors.green;
  }

  IconData _statusIcon(int days) {
    if (days < 0) return Icons.error;
    if (days <= 30) return Icons.warning;
    return Icons.check_circle;
  }

  String _statusText(int days) {
    if (days < 0) return 'Süresi Doldu!';
    if (days == 0) return 'Bugün bitiyor!';
    return '$days gün kaldı';
  }

  void _showAddInsuranceDialog(BuildContext context, int carId) {
    final companyCtrl = TextEditingController();
    final policyCtrl = TextEditingController();
    final premiumCtrl = TextEditingController();
    String selectedType = 'Trafik Sigortası';
    String startDate = '';
    String endDate = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Sigorta Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: ['Trafik Sigortası', 'Kasko'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setS(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Sigorta Türü'),
                ),
                const SizedBox(height: 8),
                TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Sigorta Şirketi')),
                const SizedBox(height: 8),
                TextField(controller: policyCtrl, decoration: const InputDecoration(labelText: 'Poliçe No')),
                const SizedBox(height: 8),
                TextField(controller: premiumCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prim Tutarı (₺)')),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(startDate.isEmpty ? 'Başlangıç Tarihi Seç' : 'Başlangıç: $startDate'),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2035));
                    if (picked != null) setS(() => startDate = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(endDate.isEmpty ? 'Bitiş Tarihi Seç' : 'Bitiş: $endDate'),
                  leading: const Icon(Icons.calendar_today, color: Colors.orange),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2040));
                    if (picked != null) setS(() => endDate = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (companyCtrl.text.isEmpty || startDate.isEmpty || endDate.isEmpty) return;
                await context.read<AppProvider>().addInsurance(Insurance(
                  carId: carId,
                  type: selectedType,
                  company: companyCtrl.text,
                  policyNo: policyCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  premium: double.tryParse(premiumCtrl.text) ?? 0,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInspectionDialog(BuildContext context, int carId) {
    final stationCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String inspectionDate = '';
    String expiryDate = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Muayene Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(inspectionDate.isEmpty ? 'Muayene Tarihi Seç' : 'Muayene: $inspectionDate'),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2035));
                    if (picked != null) setS(() => inspectionDate = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(expiryDate.isEmpty ? 'Geçerlilik Tarihi Seç' : 'Bitiş: $expiryDate'),
                  leading: const Icon(Icons.calendar_today, color: Colors.orange),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2040));
                    if (picked != null) setS(() => expiryDate = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}');
                  },
                ),
                const SizedBox(height: 8),
                TextField(controller: stationCtrl, decoration: const InputDecoration(labelText: 'İstasyon Adı (İsteğe Bağlı)')),
                const SizedBox(height: 8),
                TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ücret (₺) (İsteğe Bağlı)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (inspectionDate.isEmpty || expiryDate.isEmpty) return;
                await context.read<AppProvider>().addInspection(Inspection(
                  carId: carId,
                  inspectionDate: inspectionDate,
                  expiryDate: expiryDate,
                  station: stationCtrl.text.isEmpty ? null : stationCtrl.text,
                  cost: double.tryParse(costCtrl.text),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.selectedCar == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sigorta & Muayene')),
            body: const Center(child: Text('Önce bir araç seçin.')),
          );
        }

        final carId = provider.selectedCar!.id!;
        final insurances = provider.insurances;
        final inspections = provider.inspections;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sigorta & Muayene'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.shield), text: 'Sigorta'),
                Tab(icon: Icon(Icons.fact_check), text: 'Muayene'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddInsuranceDialog(context, carId);
              } else {
                _showAddInspectionDialog(context, carId);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Ekle'),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Sigorta Tab
              insurances.isEmpty
                  ? const Center(child: Text('Henüz sigorta kaydı yok.\nEklemek için + butonuna basın.', textAlign: TextAlign.center))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: insurances.length,
                      itemBuilder: (ctx, i) {
                        final ins = insurances[i];
                        final days = ins.daysRemaining();
                        final color = _statusColor(days);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withAlpha(40),
                              child: Icon(_statusIcon(days), color: color),
                            ),
                            title: Text('${ins.type} - ${ins.company}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Poliçe: ${ins.policyNo}'),
                                Text('${ins.startDate} → ${ins.endDate}'),
                                if (ins.premium > 0) Text('Prim: ₺${ins.premium.toStringAsFixed(0)}'),
                                Text(_statusText(days), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => provider.deleteInsurance(ins.id!),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
              // Muayene Tab
              inspections.isEmpty
                  ? const Center(child: Text('Henüz muayene kaydı yok.\nEklemek için + butonuna basın.', textAlign: TextAlign.center))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: inspections.length,
                      itemBuilder: (ctx, i) {
                        final ins = inspections[i];
                        final days = ins.daysRemaining();
                        final color = _statusColor(days);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withAlpha(40),
                              child: Icon(_statusIcon(days), color: color),
                            ),
                            title: Text('Muayene', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Muayene Tarihi: ${ins.inspectionDate}'),
                                Text('Geçerlilik: ${ins.expiryDate}'),
                                if (ins.station != null) Text('İstasyon: ${ins.station}'),
                                if (ins.cost != null) Text('Ücret: ₺${ins.cost!.toStringAsFixed(0)}'),
                                Text(_statusText(days), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => provider.deleteInspection(ins.id!),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}

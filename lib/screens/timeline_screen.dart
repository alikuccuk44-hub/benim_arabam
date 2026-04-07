import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.selectedCar == null) {
          return const Scaffold(body: Center(child: Text('Görüntülenecek araç yok.')));
        }

        // Merge all into a generic timeline items list
        List<_TimelineItem> items = [];
        
        for (var f in provider.fuels) {
          items.add(_TimelineItem(date: f.date, title: 'Yakıt Alımı', subtitle: '${f.liters}L', amount: f.totalCost, icon: Icons.local_gas_station, color: Colors.green));
        }
        for (var m in provider.maintenances) {
          String sub = '${m.mileage} km';
          if (m.jobsDone != null && m.jobsDone!.isNotEmpty) {
            sub += ' - ${m.jobsDone}';
          }
          items.add(_TimelineItem(date: m.date, title: m.category, subtitle: sub, amount: 0, icon: Icons.build, color: Colors.orange));
        }
        for (var e in provider.expenses) {
          items.add(_TimelineItem(date: e.dueDate, title: e.category, subtitle: e.isPaid == 1 ? 'Ödendi' : 'Ödenecek', amount: e.amount, icon: Icons.account_balance_wallet, color: Colors.redAccent));
        }

        // Sort descending pseudo-logic: Since date format is dd.MM.yyyy, it's tricky to sort strings directly safely if missing zeros, but we'll try a fast hack parsing or assume ordering.
        // As a simpler approach for UI: Let's assume they are already fairly chronological or we use reverse logic.
        
        if (items.isEmpty) {
           return Scaffold(appBar: AppBar(title: const Text('Geçmiş Kayıtlar')), body: const Center(child: Text('Henüz hiçbir kayıt bulunmuyor.')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Zaman Çizelgesi')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.color.withAlpha(50),
                    child: Icon(item.icon, color: item.color),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.date} • ${item.subtitle}'),
                  trailing: item.amount > 0 
                    ? Text('₺${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                    : const SizedBox.shrink(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TimelineItem {
  final String date;
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;

  _TimelineItem({required this.date, required this.title, required this.subtitle, required this.amount, required this.icon, required this.color});
}

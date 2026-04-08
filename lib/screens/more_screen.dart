import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'documents_screen.dart';
import 'drivers_screen.dart';
import 'insurance_screen.dart';
import 'nearby_screen.dart';
import '../providers/app_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    final provider = context.read<AppProvider>();
    final db = provider;

    try {
      final fuels = db.fuels;
      final maintenances = db.maintenances;
      final expenses = db.expenses;

      final StringBuffer csv = StringBuffer();
      csv.writeln('=== YAKIT KAYITLARI ===');
      csv.writeln('Tarih,Kilometre,Litre,Litre Fiyatı,Toplam Maliyet');
      for (final f in fuels) {
        csv.writeln('${f.date},${f.mileage},${f.liters},${f.literPrice},${f.totalCost}');
      }
      csv.writeln('');
      csv.writeln('=== BAKIM KAYITLARI ===');
      csv.writeln('Tarih,Kategori,Kilometre,Sonraki Tarih,Yapılanlar');
      for (final m in maintenances) {
        csv.writeln('${m.date},${m.category},${m.mileage},${m.nextDate},${m.jobsDone ?? ''}');
      }
      csv.writeln('');
      csv.writeln('=== GİDER KAYITLARI ===');
      csv.writeln('Tarih,Kategori,Tutar,Ödendi mi');
      for (final e in expenses) {
        csv.writeln('${e.dueDate},${e.category},${e.amount},${e.isPaid == 1 ? 'Evet' : 'Hayır'}');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/benim_arabam_yedek.csv');
      await file.writeAsString(csv.toString());

      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Benim Arabam - Araç Verileri Yedeği',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Daha Fazla')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context,
            'Sigorta & Muayene',
            'Poliçe takibi, muayene tarihleri ve kalan gün sayacı.',
            Icons.shield_outlined,
            Colors.green,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceScreen())),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            'Dijital Cüzdan',
            'Ruhsat, sigorta ve ehliyet fotoğraflarınızı güvenle saklayın.',
            Icons.wallet,
            const Color(0xFF38BDF8),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            'Yakınımdaki Servis & Benzinlik',
            'GPS konumunuza göre yak\u0131ndaki benzinlik ve oto servisleri bulun.',
            Icons.map_outlined,
            Colors.teal,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyScreen())),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            'Sürücüler',
            'Aracı kullanan sürücülerin kayıtlarını ve iletişim bilgilerini tutun.',
            Icons.people,
            Colors.purpleAccent,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriversScreen())),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            'Verileri Dışa Aktar (CSV)',
            'Tüm yakıt, bakım ve gider kayıtlarını CSV olarak paylaşın veya yedekleyin.',
            Icons.download,
            Colors.greenAccent,
            () => _exportData(context),
          ),
          const SizedBox(height: 16),
          // Theme toggle card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withAlpha(50), width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withAlpha(30),
                  radius: 30,
                  child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.orange, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(isDark ? 'Karanlık mod aktif' : 'Aydınlık mod aktif', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: !isDark,
                  activeColor: Colors.orange,
                  onChanged: (_) => context.read<AppProvider>().toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.directions_car, size: 32, color: Color(0xFF38BDF8)),
                SizedBox(height: 8),
                Text('Benim Arabam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Versiyon 2.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50), width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(30),
              radius: 30,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

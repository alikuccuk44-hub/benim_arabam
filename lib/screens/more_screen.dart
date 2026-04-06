import 'package:flutter/material.dart';
import 'documents_screen.dart';
import 'drivers_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _showExportSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verileriniz başarıyla dışa aktarıldı (CSV)! (Simülasyon)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daha Fazla')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            'Sürücüler', 
            'Aracı kullanan sürücülerin kayıtlarını ve iletişim bilgilerini tutun.', 
            Icons.people, 
            Colors.purpleAccent,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriversScreen())),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context, 
            'Verileri Dışa Aktar (Yedekle)', 
            'Tüm yakıt ve bakım masraflarınızı CSV formatında Excel için dışa aktarın.', 
            Icons.download, 
            Colors.greenAccent,
            () => _showExportSuccess(context),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context, 
            'Bildirim Ayarları', 
            'Yaklaşan bakımlarınız ve vergi ödemeleriniz için alarm tercihleri.', 
            Icons.notifications_active, 
            Colors.orangeAccent,
            () {}, 
          ),
        ],
      )
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
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

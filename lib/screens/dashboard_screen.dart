import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showAddCarDialog() {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final plateController = TextEditingController();
    final yearController = TextEditingController();
    final mileageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Araç Ekle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Marka')),
              TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Model')),
              TextField(controller: plateController, decoration: const InputDecoration(labelText: 'Plaka')),
              TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Yıl'), keyboardType: TextInputType.number),
              TextField(controller: mileageController, decoration: const InputDecoration(labelText: 'Kilometre'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final newCar = Car(
                brand: brandController.text,
                model: modelController.text,
                plate: plateController.text,
                year: int.tryParse(yearController.text) ?? 2000,
                mileage: int.tryParse(mileageController.text) ?? 0,
              );
              Provider.of<AppProvider>(context, listen: false).addCar(newCar);
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(AppProvider provider) async {
    if (provider.selectedCar == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final updatedCar = Car(
        id: provider.selectedCar!.id,
        brand: provider.selectedCar!.brand,
        model: provider.selectedCar!.model,
        plate: provider.selectedCar!.plate,
        year: provider.selectedCar!.year,
        mileage: provider.selectedCar!.mileage,
        photoPath: image.path,
      );
      // NOTE: Here we should just update DB via a helper.
      // For now, we update it via AppProvider.
      // We will need an updateCar method in AppProvider.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            children: [
              // Araç Seçici
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Car>(
                          isExpanded: true,
                          value: provider.selectedCar,
                          hint: const Text('Araç Seçiniz'),
                          items: provider.cars.map((car) {
                            return DropdownMenuItem<Car>(
                              value: car,
                              child: Text('${car.brand} ${car.model} (${car.plate})', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) provider.selectCar(val);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF38BDF8)),
                      onPressed: _showAddCarDialog,
                    ),
                    if (provider.selectedCar != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Aracı Sil'),
                              content: const Text('Bu aracı ve araca ait tüm verileri tamamen silmek istediğinize emin misiniz?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    provider.deleteCar(provider.selectedCar!.id!);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Sil'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              if (provider.selectedCar == null)
                const Expanded(child: Center(child: Text('Lütfen bir araç ekleyin.')))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      // Araç Fotoğrafı ve Bilgileri
                      GestureDetector(
                        onTap: () => _pickImage(provider),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF1E293B),
                            image: provider.selectedCar!.photoPath != null
                                ? DecorationImage(
                                    image: FileImage(File(provider.selectedCar!.photoPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: provider.selectedCar!.photoPath == null
                              ? const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                                            // Odometer (Kilometre Sayacı)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                          boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withAlpha(50), blurRadius: 10, spreadRadius: 2)]
                        ),
                        child: Column(
                          children: [
                            const Text('TOTAL KİLOMETRE', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.selectedCar!.mileage.toString().replaceAll(RegExp(r"\\B(?=(\\d{3})+(?!\\d))"), ".")} KM',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
                            ),
                          ],
                        ),
                      ),
                      // Özet Kartlar
                      Row(
                        children: [
                          _buildSummaryCard('Toplam Gider', '₺${_calculateTotal(provider.expenses)}', Icons.account_balance_wallet, Colors.redAccent),
                          const SizedBox(width: 16),
                          _buildSummaryCard('Yaklaşan Bakım', '${provider.maintenances.length} Adet', Icons.build, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotal(List<Expense> exps) {
    return exps.fold(0, (sum, e) => sum + e.amount);
  }

  Widget _buildSummaryCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

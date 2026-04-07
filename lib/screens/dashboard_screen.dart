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

  static const Map<String, List<String>> _carData = {
    'Fiat': ['Egea', 'Fiorino', 'Linea', 'Doblo', 'Punto'],
    'Renault': ['Clio', 'Megane', 'Symbol', 'Fluence', 'Captur'],
    'Volkswagen': ['Polo', 'Golf', 'Passat', 'Tiguan', 'Jetta'],
    'Ford': ['Focus', 'Fiesta', 'Courier', 'Transit', 'Mondeo'],
    'Toyota': ['Corolla', 'Yaris', 'Auris', 'C-HR', 'Hilux'],
    'Hyundai': ['i20', 'Tucson', 'Accent Blue', 'Elantra', 'i10'],
    'Honda': ['Civic', 'CR-V', 'City', 'Accord', 'Jazz'],
    'Peugeot': ['3008', '208', '508', '2008', '308'],
    'Dacia': ['Duster', 'Sandero', 'Logan', 'Lodgy'],
    'Opel': ['Astra', 'Corsa', 'Insignia', 'Crossland', 'Mokka'],
  };

  void _showAddCarDialog() {
    final yearController = TextEditingController();
    final mileageController = TextEditingController();
    final plateController = TextEditingController();
    
    String selectedBrand = '';
    String selectedModel = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          List<String> availableModels = selectedBrand.isNotEmpty && _carData.containsKey(selectedBrand) 
              ? _carData[selectedBrand]! 
              : [];

          return AlertDialog(
            title: const Text('Yeni Araç Ekle'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return _carData.keys.toList();
                      }
                      return _carData.keys.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedBrand = selection;
                        selectedModel = '';
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      controller.addListener(() {
                        selectedBrand = controller.text;
                      });
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Marka (Örn: Fiat)'),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return availableModels;
                      }
                      return availableModels.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      selectedModel = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      controller.addListener(() {
                        selectedModel = controller.text;
                      });
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Model (Örn: Egea)'),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
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
                    brand: selectedBrand.isEmpty ? 'Bilinmiyor' : selectedBrand,
                    model: selectedModel.isEmpty ? 'Bilinmiyor' : selectedModel,
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
          );
        }
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
      provider.updateCar(updatedCar);
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
                      const SizedBox(height: 16),
                      // Yaklaşan Bakımlar Listesi
                      if (provider.maintenances.isNotEmpty) ...[
                        const Text('Yaklaşan Bakımlar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 8),
                        ...provider.maintenances.map((m) {
                          return Card(
                            color: const Color(0xFF1E293B),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.build, color: Colors.orange),
                              title: Text(m.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Tahmini Tarih: ${m.nextDate} • ${m.nextMileage} km'),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 16),
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

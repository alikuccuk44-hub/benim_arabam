import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../database/car_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showCarDialog({Car? carToEdit}) {
    final yearController = TextEditingController(text: carToEdit?.year.toString());
    final mileageController = TextEditingController(text: carToEdit?.mileage.toString());
    final plateController = TextEditingController(text: carToEdit?.plate);
    
    String selectedBrand = carToEdit?.brand ?? '';
    String selectedModel = carToEdit?.model ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          List<String> availableModels = selectedBrand.isNotEmpty && CarData.brands.containsKey(selectedBrand) 
              ? CarData.brands[selectedBrand]! 
              : [];

          return AlertDialog(
            title: Text(carToEdit == null ? 'Yeni Araç Ekle' : 'Aracı Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: selectedBrand),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return CarData.brands.keys.toList();
                      }
                      return CarData.brands.keys.where((String option) {
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
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Marka (Örn: Fiat)'),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: selectedModel),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return availableModels;
                      }
                      return availableModels.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedModel = selection;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
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
                  final car = Car(
                    id: carToEdit?.id,
                    brand: selectedBrand.isEmpty ? 'Bilinmiyor' : selectedBrand,
                    model: selectedModel.isEmpty ? 'Bilinmiyor' : selectedModel,
                    plate: plateController.text,
                    year: int.tryParse(yearController.text) ?? carToEdit?.year ?? 2000,
                    mileage: int.tryParse(mileageController.text) ?? carToEdit?.mileage ?? 0,
                    photoPath: carToEdit?.photoPath,
                    photoBytes: carToEdit?.photoBytes,
                  );
                  if (carToEdit == null) {
                    Provider.of<AppProvider>(context, listen: false).addCar(car);
                  } else {
                    Provider.of<AppProvider>(context, listen: false).updateCar(car);
                  }
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
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      final updatedCar = Car(
        id: provider.selectedCar!.id,
        brand: provider.selectedCar!.brand,
        model: provider.selectedCar!.model,
        plate: provider.selectedCar!.plate,
        year: provider.selectedCar!.year,
        mileage: provider.selectedCar!.mileage,
        photoPath: kIsWeb ? null : image.path,
        photoBytes: bytes,
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
                      onPressed: () => _showCarDialog(),
                    ),
                    if (provider.selectedCar != null) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showCarDialog(carToEdit: provider.selectedCar),
                      ),
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
                      // Araç Fotoğrafı
                      GestureDetector(
                        onTap: () => _pickImage(provider),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF1E293B),
                            image: provider.selectedCar!.photoBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(provider.selectedCar!.photoBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : (provider.selectedCar!.photoPath != null && !kIsWeb
                                    ? DecorationImage(
                                        image: FileImage(File(provider.selectedCar!.photoPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: (provider.selectedCar!.photoBytes == null && provider.selectedCar!.photoPath == null)
                              ? const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Odometer (Kilometre Sayacı)
                      GestureDetector(
                        onTap: () {
                          // Show km history
                          final sorted = List.from(provider.fuels)..sort((a, b) => a.mileage.compareTo(b.mileage));
                          final avgKm = provider.avgMonthlyKm;
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Kilometre Geçmişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  if (avgKm > 0) Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text('Ort. Aylık: ${avgKm.toStringAsFixed(0)} km/ay', style: const TextStyle(color: Color(0xFF38BDF8))),
                                  ),
                                  const Divider(),
                                  Expanded(
                                    child: sorted.isEmpty
                                        ? const Center(child: Text('Henüz km verisi yok.'))
                                        : ListView.builder(
                                            itemCount: sorted.length,
                                            itemBuilder: (_, i) {
                                              final f = sorted[i];
                                              return ListTile(
                                                leading: const Icon(Icons.local_gas_station, color: Color(0xFF38BDF8)),
                                                title: Text('${f.mileage} km'),
                                                subtitle: Text(f.date),
                                                trailing: Text('${f.liters} L', style: const TextStyle(color: Colors.grey)),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
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
                                '${provider.selectedCar!.mileage.toString().replaceAll(RegExp(r"\B(?=(\d{3})+(?!\d))"), ".")} KM',
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.avgMonthlyKm > 0 ? 'Ort. ${provider.avgMonthlyKm.toStringAsFixed(0)} km/ay · Geçmiş için dokun' : 'Geçmiş için dokun',
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
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

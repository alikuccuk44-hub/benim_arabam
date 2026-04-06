import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});
  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showAddDriverDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String? photoPath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Yeni Sürücü Ekle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setStateDialog(() { photoPath = image.path; });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF1E293B),
                    backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                    child: photoPath == null ? const Icon(Icons.person, color: Colors.grey, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Ad Soyad')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefon Numarası')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                final d = Driver(name: nameController.text, phone: phoneController.text, photoPath: photoPath);
                provider.addDriver(d);
                Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sürücüler')),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF38BDF8),
            onPressed: () => _showAddDriverDialog(context, provider),
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
          body: provider.drivers.isEmpty
              ? const Center(child: Text('Henüz ekli bir sürücü bulunmuyor.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.drivers.length,
                  itemBuilder: (ctx, i) {
                    final d = provider.drivers[i];
                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: d.photoPath != null ? FileImage(File(d.photoPath!)) : null,
                          child: d.photoPath == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(d.phone, style: TextStyle(color: Colors.grey[400])),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => provider.deleteDriver(d.id!),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

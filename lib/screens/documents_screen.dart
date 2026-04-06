import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addDocument(AppProvider provider) async {
    if (provider.selectedCar == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    String? selectedCategory = 'Ruhsat';

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Kategori Seçin'),
          content: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            items: ['Ruhsat', 'Sigorta', 'Kasko', 'Ehliyet', 'Diğer'].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (val) {
              setStateDialog(() { selectedCategory = val; });
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                final doc = Document(
                   carId: provider.selectedCar!.id!,
                   category: selectedCategory ?? 'Diğer',
                   photoPath: image.path,
                );
                provider.addDocument(doc);
                Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Dijital Cüzdan')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addDocument(provider),
            backgroundColor: const Color(0xFF38BDF8),
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            label: const Text('Belge Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: provider.documents.isEmpty
            ? const Center(child: Text('Buraya kasko, sigorta veya ruhsat fotoğraflarınızı ekleyebilirsiniz.'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8
                ),
                itemCount: provider.documents.length,
                itemBuilder: (ctx, i) {
                  final doc = provider.documents[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                         image: FileImage(File(doc.photoPath)),
                         fit: BoxFit.cover,
                         colorFilter: ColorFilter.mode(Colors.black.withAlpha(100), BlendMode.darken)
                      )
                    ),
                    child: Center(
                      child: Text(doc.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    ),
                  );
                },
            ),
        );
      }
    );
  }
}

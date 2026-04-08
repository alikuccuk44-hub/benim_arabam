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

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
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
            items: ['Ruhsat', 'Trafik Sigortası', 'Kasko', 'Muayene Kartı', 'Ehliyet', 'Diğer']
                .map((val) => DropdownMenuItem<String>(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) => setStateDialog(() => selectedCategory = val),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                provider.addDocument(Document(
                  carId: provider.selectedCar!.id!,
                  category: selectedCategory ?? 'Diğer',
                  photoPath: image.path,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, Document doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(doc.category),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Belgeyi Sil'),
                      content: const Text('Bu belgeyi silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AppProvider>().deleteDocument(doc.id!);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: Hero(
              tag: 'doc_${doc.id}',
              child: InteractiveViewer(
                child: Image.file(File(doc.photoPath), fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Ruhsat': return const Color(0xFF38BDF8);
      case 'Trafik Sigortası': return Colors.green;
      case 'Kasko': return Colors.teal;
      case 'Muayene Kartı': return Colors.orange;
      case 'Ehliyet': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Dijital Cüzdan')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addDocument(provider),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Belge Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: provider.documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wallet, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      const Text('Dijital cüzdanınız boş.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Ruhsat, sigorta poliçesi veya\nmuayene kartı ekleyebilirsiniz.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: provider.documents.length,
                  itemBuilder: (ctx, i) {
                    final doc = provider.documents[i];
                    final color = _categoryColor(doc.category);
                    return GestureDetector(
                      onTap: () => _openFullscreen(context, doc),
                      child: Hero(
                        tag: 'doc_${doc.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withAlpha(120), width: 2),
                            image: File(doc.photoPath).existsSync()
                                ? DecorationImage(
                                    image: FileImage(File(doc.photoPath)),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.black.withAlpha(120), BlendMode.darken),
                                  )
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(160),
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                  ),
                                  child: Text(doc.category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color), textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
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

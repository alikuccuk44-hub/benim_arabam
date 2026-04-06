import 'dart:io';

void main() {
   File f1 = File('lib/screens/dashboard_screen.dart');
   String s1 = f1.readAsStringSync();
   // Replace only the first occurrence to avoid duplicate injections if run twice
   if (!s1.contains('TOTAL MILEAGE')) {
       s1 = s1.replaceAll('// Özet Kartlar', '''
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
                              '\${provider.selectedCar!.mileage.toString().replaceAll(RegExp(r"\\\\B(?=(\\\\d{3})+(?!\\\\d))"), ".")} KM',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
                            ),
                          ],
                        ),
                      ),
                      // Özet Kartlar''');
       f1.writeAsStringSync(s1);
   }

   File f2 = File('lib/providers/app_provider.dart');
   String s2 = f2.readAsStringSync();
   if (!s2.contains('fuel.mileage > selectedCar!.mileage')) {
       s2 = s2.replaceAll('await _dbHelper.insertFuel(fuel);', '''await _dbHelper.insertFuel(fuel);
    if (selectedCar != null && fuel.mileage > selectedCar!.mileage) {
       selectedCar = Car(id: selectedCar!.id, brand: selectedCar!.brand, model: selectedCar!.model, plate: selectedCar!.plate, year: selectedCar!.year, mileage: fuel.mileage, photoPath: selectedCar!.photoPath);
       await _dbHelper.updateCar(selectedCar!);
    }''');
       s2 = s2.replaceAll('await _dbHelper.insertMaintenance(maintenance);', '''await _dbHelper.insertMaintenance(maintenance);
    if (selectedCar != null && maintenance.mileage > selectedCar!.mileage) {
       selectedCar = Car(id: selectedCar!.id, brand: selectedCar!.brand, model: selectedCar!.model, plate: selectedCar!.plate, year: selectedCar!.year, mileage: maintenance.mileage, photoPath: selectedCar!.photoPath);
       await _dbHelper.updateCar(selectedCar!);
    }''');
       f2.writeAsStringSync(s2);
   }
}

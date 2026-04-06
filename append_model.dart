import 'dart:io';
void main() {
   File f = File('lib/models/models.dart');
   if(!f.readAsStringSync().contains('class Driver')) {
       f.writeAsStringSync('\nclass Driver {\n  final int? id;\n  final String name;\n  final String phone;\n  final String? photoPath;\n\n  Driver({this.id, required this.name, required this.phone, this.photoPath});\n\n  Map<String, dynamic> toMap() => {"id": id, "name": name, "phone": phone, "photoPath": photoPath};\n\n  factory Driver.fromMap(Map<String, dynamic> m) => Driver(id: m["id"], name: m["name"], phone: m["phone"], photoPath: m["photoPath"]);\n}\n', mode: FileMode.append);
   }
}

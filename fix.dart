import 'dart:io';
void main() {
  var files = ['lib/providers/app_provider.dart', 'lib/screens/dashboard_screen.dart'];
  for (var p in files) {
    var f = File(p);
    if (!f.existsSync()) continue;
    var c = f.readAsStringSync().replaceAll(r'\${', r'${').replaceAll(r'\₺', '₺');
    f.writeAsStringSync(c);
  }
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  sqfliteFfiInit();
  var dbFactory = databaseFactoryFfi;
  String path = join(await dbFactory.getDatabasesPath(), 'benim_arabam.db');
  print('DB Path: ' + path);
  var db = await dbFactory.openDatabase(path);
  var cars = await db.query('cars');
  print('CARS COUNT: ' + cars.length.toString());
  for (var c in cars) {
    print('CAR: ' + c.toString());
  }
  await db.close();
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'benim_arabam.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT,
        model TEXT,
        plate TEXT,
        year INTEGER,
        mileage INTEGER,
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE fuels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER,
        date TEXT,
        mileage INTEGER,
        liters REAL,
        literPrice REAL,
        totalCost REAL,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER,
        category TEXT,
        date TEXT,
        mileage INTEGER,
        nextDate TEXT,
        nextMileage INTEGER,
        jobsDone TEXT,
        upcomingJobs TEXT,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER,
        category TEXT,
        amount REAL,
        dueDate TEXT,
        isPaid INTEGER,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER,
        category TEXT,
        photoPath TEXT,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE drivers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE insurance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER,
        type TEXT,
        company TEXT,
        policyNo TEXT,
        startDate TEXT,
        endDate TEXT,
        premium REAL,
        notes TEXT,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE inspection(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER,
        inspectionDate TEXT,
        expiryDate TEXT,
        station TEXT,
        cost REAL,
        FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE drivers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone TEXT,
          photoPath TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE maintenance ADD COLUMN jobsDone TEXT');
      await db.execute('ALTER TABLE maintenance ADD COLUMN upcomingJobs TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS insurance(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          carId INTEGER,
          type TEXT,
          company TEXT,
          policyNo TEXT,
          startDate TEXT,
          endDate TEXT,
          premium REAL,
          notes TEXT,
          FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS inspection(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          carId INTEGER,
          inspectionDate TEXT,
          expiryDate TEXT,
          station TEXT,
          cost REAL,
          FOREIGN KEY (carId) REFERENCES cars (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // CAR CRUD
  Future<int> insertCar(Car car) async {
    Database db = await database;
    return await db.insert('cars', car.toMap());
  }

  Future<List<Car>> getCars() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('cars');
    return List.generate(maps.length, (i) => Car.fromMap(maps[i]));
  }
  
  Future<int> updateCar(Car car) async {
    Database db = await database;
    return await db.update('cars', car.toMap(), where: 'id = ?', whereArgs: [car.id]);
  }

  Future<int> deleteCar(int id) async {
    Database db = await database;
    return await db.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  // FUEL CRUD
  Future<int> insertFuel(Fuel fuel) async {
    Database db = await database;
    return await db.insert('fuels', fuel.toMap());
  }

  Future<List<Fuel>> getFuelsForCar(int carId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('fuels', where: 'carId = ?', whereArgs: [carId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Fuel.fromMap(maps[i]));
  }

  // MAINTENANCE CRUD
  Future<int> insertMaintenance(Maintenance maintenance) async {
    Database db = await database;
    return await db.insert('maintenance', maintenance.toMap());
  }

  Future<List<Maintenance>> getMaintenanceForCar(int carId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('maintenance', where: 'carId = ?', whereArgs: [carId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Maintenance.fromMap(maps[i]));
  }

  // EXPENSE CRUD
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpensesForCar(int carId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('expenses', where: 'carId = ?', whereArgs: [carId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }
  
  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  // DOCUMENT CRUD
  Future<int> insertDocument(Document doc) async {
    Database db = await database;
    return await db.insert('documents', doc.toMap());
  }

  Future<List<Document>> getDocumentsForCar(int carId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('documents', where: 'carId = ?', whereArgs: [carId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  Future<int> deleteDocument(int id) async {
    Database db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  // DRIVER CRUD
  Future<int> insertDriver(Driver driver) async {
    Database db = await database;
    return await db.insert('drivers', driver.toMap());
  }

  Future<List<Driver>> getDrivers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('drivers', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Driver.fromMap(maps[i]));
  }

  Future<int> deleteDriver(int id) async {
    Database db = await database;
    return await db.delete('drivers', where: 'id = ?', whereArgs: [id]);
  }

  // INSURANCE CRUD
  Future<int> insertInsurance(Insurance ins) async {
    Database db = await database;
    return await db.insert('insurance', ins.toMap());
  }

  Future<List<Insurance>> getInsuranceForCar(int carId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('insurance', where: 'carId = ?', whereArgs: [carId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Insurance.fromMap(maps[i]));
  }

  Future<int> deleteInsurance(int id) async {
    Database db = await database;
    return await db.delete('insurance', where: 'id = ?', whereArgs: [id]);
  }

  // INSPECTION CRUD
  Future<int> insertInspection(Inspection ins) async {
    Database db = await database;
    return await db.insert('inspection', ins.toMap());
  }

  Future<List<Inspection>> getInspectionsForCar(int carId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('inspection', where: 'carId = ?', whereArgs: [carId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Inspection.fromMap(maps[i]));
  }

  Future<int> deleteInspection(int id) async {
    Database db = await database;
    return await db.delete('inspection', where: 'id = ?', whereArgs: [id]);
  }

  // All data for export
  Future<List<Map<String, dynamic>>> getAllFuels() async {
    Database db = await database;
    return await db.query('fuels');
  }

  Future<List<Map<String, dynamic>>> getAllMaintenances() async {
    Database db = await database;
    return await db.query('maintenance');
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    Database db = await database;
    return await db.query('expenses');
  }
}

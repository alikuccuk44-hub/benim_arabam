import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  List<Car> cars = [];
  Car? selectedCar;

  List<Fuel> fuels = [];
  List<Maintenance> maintenances = [];
  List<Expense> expenses = [];
  List<Document> documents = [];
  List<Driver> drivers = [];
  List<Insurance> insurances = [];
  List<Inspection> inspections = [];

  bool isLoading = false;
  ThemeMode themeMode = ThemeMode.dark;

  AppProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    drivers = await _dbHelper.getDrivers();
    cars = await _dbHelper.getCars();

    if (cars.isNotEmpty && selectedCar == null) {
      selectedCar = cars.first;
    }

    if (selectedCar != null) {
      await _loadCarData(selectedCar!.id!);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCarData(int carId) async {
    fuels = await _dbHelper.getFuelsForCar(carId);
    maintenances = await _dbHelper.getMaintenanceForCar(carId);
    expenses = await _dbHelper.getExpensesForCar(carId);
    documents = await _dbHelper.getDocumentsForCar(carId);
    insurances = await _dbHelper.getInsuranceForCar(carId);
    inspections = await _dbHelper.getInspectionsForCar(carId);
  }

  void selectCar(Car car) {
    selectedCar = car;
    _loadCarData(car.id!).then((_) => notifyListeners());
  }

  Future<void> addCar(Car car) async {
    int insertedId = await _dbHelper.insertCar(car);
    await loadData();
    try {
      selectedCar = cars.firstWhere((c) => c.id == insertedId);
      await _loadCarData(insertedId);
    } catch (e) {}
    notifyListeners();
  }

  Future<void> updateCar(Car car) async {
    await _dbHelper.updateCar(car);
    if (selectedCar != null && selectedCar!.id == car.id) {
      selectedCar = car;
    }
    await loadData();
  }

  Future<void> deleteCar(int id) async {
    await _dbHelper.deleteCar(id);
    if (selectedCar != null && selectedCar!.id == id) {
      selectedCar = null;
    }
    await loadData();
  }

  Future<void> addFuel(Fuel fuel) async {
    await _dbHelper.insertFuel(fuel);
    if (selectedCar != null && fuel.mileage > selectedCar!.mileage) {
       selectedCar = Car(
         id: selectedCar!.id,
         brand: selectedCar!.brand,
         model: selectedCar!.model,
         plate: selectedCar!.plate,
         year: selectedCar!.year,
         mileage: fuel.mileage,
         photoPath: selectedCar!.photoPath,
         photoBytes: selectedCar!.photoBytes,
       );
       await _dbHelper.updateCar(selectedCar!);
    }
    await loadData();
  }

  Future<void> addMaintenance(Maintenance m) async {
    int id = await _dbHelper.insertMaintenance(m);
    if (selectedCar != null && m.mileage > selectedCar!.mileage) {
       selectedCar = Car(
         id: selectedCar!.id,
         brand: selectedCar!.brand,
         model: selectedCar!.model,
         plate: selectedCar!.plate,
         year: selectedCar!.year,
         mileage: m.mileage,
         photoPath: selectedCar!.photoPath,
         photoBytes: selectedCar!.photoBytes,
       );
       await _dbHelper.updateCar(selectedCar!);
    }
    await loadData();
    try {
      DateTime next = DateFormat('dd.MM.yyyy').parse(m.nextDate);
      for (int days in [7, 3, 1]) {
        DateTime notifyDate = next.subtract(Duration(days: days));
        if (notifyDate.isAfter(DateTime.now())) {
          _notificationService.scheduleNotification(
            id: id * 10 + days,
            title: 'Yaklasan Bakim ($days gun kaldi)',
            body: '${m.category} bakimi icin ${m.nextDate} tarihi yaklasıyor.',
            scheduledDate: notifyDate,
          );
        }
      }
    } catch(e) {}
  }

  Future<void> addExpense(Expense e) async {
    int id = await _dbHelper.insertExpense(e);
    await loadData();
    try {
      DateTime due = DateFormat('dd.MM.yyyy').parse(e.dueDate);
      for (int days in [7, 3, 1]) {
        DateTime notifyDate = due.subtract(Duration(days: days));
        if (notifyDate.isAfter(DateTime.now())) {
          _notificationService.scheduleNotification(
            id: id + 10000 + days,
            title: 'Yaklasan Odeme ($days gun kaldi)',
            body: '${e.category} son odeme tarihi yaklasıyor.',
            scheduledDate: notifyDate,
          );
        }
      }
    } catch(e) {}
  }

  Future<void> addDocument(Document d) async {
    await _dbHelper.insertDocument(d);
    await loadData();
  }

  Future<void> deleteDocument(int id) async {
    await _dbHelper.deleteDocument(id);
    await loadData();
  }

  Future<void> addDriver(Driver d) async {
    await _dbHelper.insertDriver(d);
    await loadData();
  }

  Future<void> deleteDriver(int id) async {
    await _dbHelper.deleteDriver(id);
    await loadData();
  }

  Future<void> addInsurance(Insurance ins) async {
    int id = await _dbHelper.insertInsurance(ins);
    await loadData();
    try {
      DateTime end = DateFormat('dd.MM.yyyy').parse(ins.endDate);
      for (int days in [30, 7, 1]) {
        DateTime notifyDate = end.subtract(Duration(days: days));
        if (notifyDate.isAfter(DateTime.now())) {
          _notificationService.scheduleNotification(
            id: id + 20000 + days,
            title: '${ins.type} Sigortasi Bitiyor ($days gun)',
            body: '${ins.company} sigortanizin bitis tarihi: ${ins.endDate}',
            scheduledDate: notifyDate,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> deleteInsurance(int id) async {
    await _dbHelper.deleteInsurance(id);
    await loadData();
  }

  Future<void> addInspection(Inspection ins) async {
    int id = await _dbHelper.insertInspection(ins);
    await loadData();
    try {
      DateTime end = DateFormat('dd.MM.yyyy').parse(ins.expiryDate);
      for (int days in [30, 7, 1]) {
        DateTime notifyDate = end.subtract(Duration(days: days));
        if (notifyDate.isAfter(DateTime.now())) {
          _notificationService.scheduleNotification(
            id: id + 30000 + days,
            title: 'Muayene Bitiyor ($days gun)',
            body: 'Arac muayenenizin bitis tarihi: ${ins.expiryDate}',
            scheduledDate: notifyDate,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> deleteInspection(int id) async {
    await _dbHelper.deleteInspection(id);
    await loadData();
  }

  // Average monthly km
  double get avgMonthlyKm {
    if (fuels.length < 2) return 0;
    final sorted = List<Fuel>.from(fuels)..sort((a, b) => a.mileage.compareTo(b.mileage));
    final kmDiff = sorted.last.mileage - sorted.first.mileage;
    try {
      final first = DateFormat('dd.MM.yyyy').parse(sorted.first.date);
      final last = DateFormat('dd.MM.yyyy').parse(sorted.last.date);
      final months = last.difference(first).inDays / 30.0;
      if (months < 0.1) return 0;
      return kmDiff / months;
    } catch (_) {
      return 0;
    }
  }
}

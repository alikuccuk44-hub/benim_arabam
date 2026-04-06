import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  bool isLoading = false;

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
       selectedCar = Car(id: selectedCar!.id, brand: selectedCar!.brand, model: selectedCar!.model, plate: selectedCar!.plate, year: selectedCar!.year, mileage: fuel.mileage, photoPath: selectedCar!.photoPath);
       await _dbHelper.updateCar(selectedCar!);
    }
    await loadData();
  }

  Future<void> addMaintenance(Maintenance m) async {
    int id = await _dbHelper.insertMaintenance(m);
    if (selectedCar != null && m.mileage > selectedCar!.mileage) {
       selectedCar = Car(id: selectedCar!.id, brand: selectedCar!.brand, model: selectedCar!.model, plate: selectedCar!.plate, year: selectedCar!.year, mileage: m.mileage, photoPath: selectedCar!.photoPath);
       await _dbHelper.updateCar(selectedCar!);
    }
    await loadData();
    try {
      DateTime next = DateFormat('dd.MM.yyyy').parse(m.nextDate);
      DateTime notifyDate = next.subtract(const Duration(days: 7));
      if (notifyDate.isAfter(DateTime.now())) {
        _notificationService.scheduleNotification(id: id, title: 'Yaklaşan Bakım', body: '${m.category} bakımı yaklaşıyor.', scheduledDate: notifyDate);
      }
    } catch(e) {}
  }

  Future<void> addExpense(Expense e) async {
    int id = await _dbHelper.insertExpense(e);
    await loadData();
    try {
      DateTime due = DateFormat('dd.MM.yyyy').parse(e.dueDate);
      DateTime notifyDate = due.subtract(const Duration(days: 7));
      if (notifyDate.isAfter(DateTime.now())) {
         _notificationService.scheduleNotification(id: id + 10000, title: 'Yaklaşan Ödeme', body: '${e.category} son ödeme tarihi yaklaşıyor.', scheduledDate: notifyDate);
      }
    } catch(e) {}
  }

  Future<void> addDocument(Document d) async {
    await _dbHelper.insertDocument(d);
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
}

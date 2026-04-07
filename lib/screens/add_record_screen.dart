import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ekle'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF38BDF8),
          tabs: const [
            Tab(text: 'Yakıt', icon: Icon(Icons.local_gas_station)),
            Tab(text: 'Bakım', icon: Icon(Icons.build)),
            Tab(text: 'Gider', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FuelForm(),
          _MaintenanceForm(),
          _ExpenseForm(),
        ],
      ),
    );
  }
}

// YAKIT FORMU
class _FuelForm extends StatefulWidget {
  const _FuelForm();
  @override
  State<_FuelForm> createState() => _FuelFormState();
}

class _FuelFormState extends State<_FuelForm> {
  final _mileageController = TextEditingController();
  final _litersController = TextEditingController();
  final _literPriceController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd.MM.yyyy').format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _save(AppProvider provider) {
    if (provider.selectedCar == null) return;
    
    double liters = double.tryParse(_litersController.text.replaceAll(',', '.')) ?? 0;
    double price = double.tryParse(_literPriceController.text.replaceAll(',', '.')) ?? 0;

    final fuel = Fuel(
      carId: provider.selectedCar!.id!,
      date: _dateController.text,
      mileage: int.tryParse(_mileageController.text) ?? 0,
      liters: liters,
      literPrice: price,
      totalCost: liters * price,
    );
    provider.addFuel(fuel);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(controller: _dateController, readOnly: true, onTap: () => _selectDate(context), decoration: const InputDecoration(labelText: 'Tarih', suffixIcon: Icon(Icons.calendar_today))),
          const SizedBox(height: 16),
          TextField(controller: _mileageController, decoration: const InputDecoration(labelText: 'Mevcut Kilometre'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          TextField(controller: _litersController, decoration: const InputDecoration(labelText: 'Alınan Litre'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          TextField(controller: _literPriceController, decoration: const InputDecoration(labelText: 'Litre Fiyatı (₺)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () => _save(provider),
            child: const Text('Yakıt Fişini Kaydet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// BAKIM FORMU
class _MaintenanceForm extends StatefulWidget {
  const _MaintenanceForm();
  @override
  State<_MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<_MaintenanceForm> {
  final _categoryController = TextEditingController();
  final _mileageController = TextEditingController();
  final _nextDateController = TextEditingController();
  final _jobsDoneController = TextEditingController();
  final _upcomingJobsController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd.MM.yyyy').format(DateTime.now());
    _nextDateController.text = DateFormat('dd.MM.yyyy').format(DateTime.now().add(const Duration(days: 365)));
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _save(AppProvider provider) {
    if (provider.selectedCar == null) return;

    final maint = Maintenance(
      carId: provider.selectedCar!.id!,
      category: _categoryController.text.isEmpty ? 'Genel Bakım' : _categoryController.text,
      date: _dateController.text,
      mileage: int.tryParse(_mileageController.text) ?? 0,
      nextDate: _nextDateController.text,
      nextMileage: (int.tryParse(_mileageController.text) ?? 0) + 10000,
      jobsDone: _jobsDoneController.text,
      upcomingJobs: _upcomingJobsController.text,
    );
    provider.addMaintenance(maint);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(controller: _dateController, readOnly: true, onTap: () => _selectDate(context, _dateController), decoration: const InputDecoration(labelText: 'Bakım Tarihi', suffixIcon: Icon(Icons.calendar_today))),
          const SizedBox(height: 16),
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Bakım Türü (Örn: Periyodik, Fren)')),
          const SizedBox(height: 16),
          TextField(controller: _mileageController, decoration: const InputDecoration(labelText: 'Mevcut Kilometre'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          TextField(controller: _jobsDoneController, decoration: const InputDecoration(labelText: 'Yapılan İşlemler (İsteğe Bağlı)'), maxLines: 2),
          const SizedBox(height: 16),
          TextField(controller: _nextDateController, readOnly: true, onTap: () => _selectDate(context, _nextDateController), decoration: const InputDecoration(labelText: 'Sonraki Bakım Tarihi', suffixIcon: Icon(Icons.calendar_today))),
          const SizedBox(height: 16),
          TextField(controller: _upcomingJobsController, decoration: const InputDecoration(labelText: 'Gelecek Bakımda Yapılacaklar (İsteğe Bağlı)'), maxLines: 2),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () => _save(provider),
            child: const Text('Bakım Kaydet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// GIDER FORMU
class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm();
  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dueDateController.text = DateFormat('dd.MM.yyyy').format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _save(AppProvider provider) {
    if (provider.selectedCar == null) return;

    final expense = Expense(
      carId: provider.selectedCar!.id!,
      category: _categoryController.text.isEmpty ? 'Genel Gider' : _categoryController.text,
      amount: double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
      dueDate: _dueDateController.text,
      isPaid: 1, // Default to paid
    );
    provider.addExpense(expense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori (Örn: MTV, Sigorta, Kasko)')),
          const SizedBox(height: 16),
          TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Tutar (₺)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          TextField(controller: _dueDateController, readOnly: true, onTap: () => _selectDate(context), decoration: const InputDecoration(labelText: 'Tarih / Son Ödeme Günü', suffixIcon: Icon(Icons.calendar_today))),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () => _save(provider),
            child: const Text('Gideri Kaydet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

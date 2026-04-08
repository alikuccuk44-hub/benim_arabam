import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  double _calculateAvgConsumption(List<Fuel> fuels) {
    if (fuels.length < 2) return 0.0;
    final sorted = List<Fuel>.from(fuels)..sort((a, b) => a.mileage.compareTo(b.mileage));
    double totalLitres = 0;
    for (int i = 1; i < sorted.length; i++) {
      totalLitres += sorted[i].liters;
    }
    int distance = sorted.last.mileage - sorted.first.mileage;
    if (distance <= 0) return 0.0;
    return (totalLitres / distance) * 100;
  }

  // Per-fill consumption list for chart
  List<double> _getConsumptionHistory(List<Fuel> fuels) {
    if (fuels.length < 2) return [];
    final sorted = List<Fuel>.from(fuels)..sort((a, b) => a.mileage.compareTo(b.mileage));
    List<double> rates = [];
    for (int i = 1; i < sorted.length; i++) {
      int dist = sorted[i].mileage - sorted[i - 1].mileage;
      if (dist > 0) {
        rates.add((sorted[i].liters / dist) * 100);
      }
    }
    return rates;
  }

  List<Fuel> _filterFuels(List<Fuel> fuels) {
    return fuels.where((f) {
      try {
        final parts = f.date.split('.');
        final year = int.parse(parts[2]);
        final month = int.parse(parts[1]);
        if (year != _selectedYear) return false;
        if (_selectedMonth != null && month != _selectedMonth) return false;
        return true;
      } catch (_) { return false; }
    }).toList();
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses.where((e) {
      try {
        final parts = e.dueDate.split('.');
        final year = int.parse(parts[2]);
        final month = int.parse(parts[1]);
        if (year != _selectedYear) return false;
        if (_selectedMonth != null && month != _selectedMonth) return false;
        return true;
      } catch (_) { return false; }
    }).toList();
  }

  List<Maintenance> _filterMaintenances(List<Maintenance> ms) {
    return ms.where((m) {
      try {
        final parts = m.date.split('.');
        final year = int.parse(parts[2]);
        final month = int.parse(parts[1]);
        if (year != _selectedYear) return false;
        if (_selectedMonth != null && month != _selectedMonth) return false;
        return true;
      } catch (_) { return false; }
    }).toList();
  }

  // Monthly totals for bar chart (12 months)
  List<double> _monthlyTotals(AppProvider provider) {
    List<double> totals = List.filled(12, 0.0);
    for (final f in provider.fuels) {
      try {
        final parts = f.date.split('.');
        final year = int.parse(parts[2]);
        final month = int.parse(parts[1]);
        if (year == _selectedYear) totals[month - 1] += f.totalCost;
      } catch (_) {}
    }
    for (final e in provider.expenses) {
      try {
        final parts = e.dueDate.split('.');
        final year = int.parse(parts[2]);
        final month = int.parse(parts[1]);
        if (year == _selectedYear) totals[month - 1] += e.amount;
      } catch (_) {}
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.selectedCar == null) {
          return const Scaffold(body: Center(child: Text('Görüntülenecek araç yok.')));
        }

        final filteredFuels = _filterFuels(provider.fuels);
        final filteredExpenses = _filterExpenses(provider.expenses);
        final filteredMaintenances = _filterMaintenances(provider.maintenances);

        double periodFuelCost = filteredFuels.fold(0, (s, f) => s + f.totalCost);
        double periodExpenseCost = filteredExpenses.fold(0, (s, e) => s + e.amount);
        double periodMaintenanceCost = filteredMaintenances.length.toDouble();
        double periodTotal = periodFuelCost + periodExpenseCost;

        double totalFuel = provider.fuels.fold(0, (sum, f) => sum + f.totalCost);
        double totalExpense = provider.expenses.fold(0, (sum, e) => sum + e.amount);
        double avgConsumption = _calculateAvgConsumption(List.from(provider.fuels));
        List<double> consumptionHistory = _getConsumptionHistory(List.from(provider.fuels));
        List<double> monthly = _monthlyTotals(provider);

        final monthNames = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

        return Scaffold(
          appBar: AppBar(title: const Text('Analiz ve Raporlar')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Date filter row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: 'Yıl', border: OutlineInputBorder()),
                      items: List.generate(6, (i) => DateTime.now().year - i)
                          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (v) => setState(() { _selectedYear = v!; _selectedMonth = null; }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Ay', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Tüm Yıl')),
                        ...List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(monthNames[i]))),
                      ],
                      onChanged: (v) => setState(() => _selectedMonth = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Period Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8).withAlpha(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMonth != null ? '${monthNames[_selectedMonth! - 1]} $_selectedYear Özeti' : '$_selectedYear Yılı Özeti',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _summaryTile('Yakıt', '₺${periodFuelCost.toStringAsFixed(0)}', Colors.green)),
                        Expanded(child: _summaryTile('Gider', '₺${periodExpenseCost.toStringAsFixed(0)}', Colors.redAccent)),
                        Expanded(child: _summaryTile('Bakım', '${filteredMaintenances.length} adet', Colors.orange)),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toplam Harcama', style: TextStyle(color: Colors.white70)),
                        Text('₺${periodTotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Avg consumption card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF818CF8)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Ortalama Yakıt Tüketimi', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      avgConsumption > 0 ? '${avgConsumption.toStringAsFixed(1)} L / 100km' : 'Yetersiz Veri',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
                    ),
                    if (consumptionHistory.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('En İyi: ${consumptionHistory.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)} L/100', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('En Kötü: ${consumptionHistory.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} L/100', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Consumption history chart
              if (consumptionHistory.length >= 2) ...[
                const Text('Tüketim Geçmişi (L/100km)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: consumptionHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: const Color(0xFF38BDF8),
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: const Color(0xFF38BDF8).withAlpha(40)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Monthly bar chart for selected year
              const Text('Aylık Harcama Dağılımı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                child: monthly.every((v) => v == 0)
                    ? const Center(child: Text('Bu yıl için veri yok.'))
                    : BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => Text(
                                  monthNames[value.toInt()],
                                  style: const TextStyle(fontSize: 9, color: Colors.white54),
                                ),
                              ),
                            ),
                          ),
                          barGroups: monthly.asMap().entries.map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [BarChartRodData(
                              toY: e.value,
                              color: e.value > 0 ? const Color(0xFF38BDF8) : Colors.transparent,
                              width: 14,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            )],
                          )).toList(),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Expense pie chart (all time)
              const Text('Toplam Harcama Dağılımı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                child: totalFuel == 0 && totalExpense == 0
                    ? const Center(child: Text('Veri yok'))
                    : Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 40,
                                sections: [
                                  if (totalFuel > 0) PieChartSectionData(color: Colors.green, value: totalFuel, title: '${((totalFuel / (totalFuel + totalExpense)) * 100).toStringAsFixed(0)}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  if (totalExpense > 0) PieChartSectionData(color: Colors.redAccent, value: totalExpense, title: '${((totalExpense / (totalFuel + totalExpense)) * 100).toStringAsFixed(0)}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Container(width: 12, height: 12, color: Colors.green), const SizedBox(width: 8), Text('Yakıt\n₺${totalFuel.toStringAsFixed(0)}')]),
                                const SizedBox(height: 12),
                                Row(children: [Container(width: 12, height: 12, color: Colors.redAccent), const SizedBox(width: 8), Text('Giderler\n₺${totalExpense.toStringAsFixed(0)}')]),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Multi-car comparison
              if (provider.cars.length > 1) ...[
                const Text('Araç Karşılaştırması', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: provider.cars.map((car) {
                      return FutureBuilder(
                        future: Future.value(car),
                        builder: (ctx, snap) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text('${car.brand} ${car.model}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                Expanded(flex: 2, child: Text('₺ —', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey[400]))),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

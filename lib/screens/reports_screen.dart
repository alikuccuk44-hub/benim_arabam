import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  double _calculateAvgConsumption(List<Fuel> fuels) {
    if (fuels.length < 2) return 0.0;
    // Sort logic to find max and min mileage
    fuels.sort((a,b) => a.mileage.compareTo(b.mileage));
    double totalLitres = 0;
    for (int i = 1; i < fuels.length; i++) {
       totalLitres += fuels[i].liters;
    }
    int distance = fuels.last.mileage - fuels.first.mileage;
    if (distance <= 0) return 0.0;
    return (totalLitres / distance) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.selectedCar == null) {
          return const Scaffold(body: Center(child: Text('Görüntülenecek araç yok.')));
        }

        double totalFuel = provider.fuels.fold(0, (sum, f) => sum + f.totalCost);
        double totalExpense = provider.expenses.fold(0, (sum, e) => sum + e.amount);
        double avgConsumption = _calculateAvgConsumption(List.from(provider.fuels));

        List<FlSpot> mileageSpots = [];
        if (provider.fuels.isNotEmpty) {
           var fSorted = List<Fuel>.from(provider.fuels)..sort((a,b) => a.mileage.compareTo(b.mileage));
           for(int i=0; i<fSorted.length; i++) {
             mileageSpots.add(FlSpot(i.toDouble(), fSorted[i].mileage.toDouble()));
           }
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Analiz ve Raporlar')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // yakit tuketimi (Drivvo/Fuelio synthesization)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF818CF8)]),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Column(
                  children: [
                    const Text('Ortalama Yakıt Tüketimi', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      avgConsumption > 0 ? '${avgConsumption.toStringAsFixed(1)} L / 100km' : 'Yetersiz Veri', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)
                    ),
                    const SizedBox(height: 8),
                    const Text('En az 2 yakıt alımı gereklidir', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Gider Dagilimi
              const Text('Harcama Dağılımı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                if (totalFuel > 0) PieChartSectionData(color: Colors.green, value: totalFuel, title: '${((totalFuel/(totalFuel+totalExpense))*100).toStringAsFixed(0)}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                if (totalExpense > 0) PieChartSectionData(color: Colors.redAccent, value: totalExpense, title: '${((totalExpense/(totalFuel+totalExpense))*100).toStringAsFixed(0)}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                              Row(children: [Container(width: 12, height: 12, color: Colors.green), const SizedBox(width: 8), const Text('Yakıt')]),
                              const SizedBox(height: 8),
                              Row(children: [Container(width: 12, height: 12, color: Colors.redAccent), const SizedBox(width: 8), const Text('Giderler')]),
                            ],
                          ),
                        )
                      ],
                    ),
              ),
              const SizedBox(height: 24),

              // Odometer Tracking Chart
              const Text('Kilometre Gelişimi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                child: mileageSpots.length >= 2 
                  ? LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: mileageSpots,
                            isCurved: true,
                            color: const Color(0xFF38BDF8),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFF38BDF8).withAlpha(50)),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('Grafik için yeterli kilometre verisi yok (Yakıt kayıtlarından alınır).')),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

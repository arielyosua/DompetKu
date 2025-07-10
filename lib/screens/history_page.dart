// lib/screens/history_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/transaction_form.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedRange = '7 Hari';
  final List<String> _chartRanges = ['7 Hari', '30 Hari'];

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> transactionsStream = FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Riwayat & Analisis'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactionsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('Tidak ada riwayat transaksi.'));

          int daysToDisplay = _selectedRange == '30 Hari' ? 30 : 7;
          final List<double> dailyIncome = List.filled(daysToDisplay, 0.0);
          final List<double> dailyExpense = List.filled(daysToDisplay, 0.0);
          final now = DateTime.now();

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final transactionDate = (data['timestamp'] as Timestamp).toDate();
            final differenceInDays = now.difference(transactionDate).inDays;
            if (differenceInDays >= 0 && differenceInDays < daysToDisplay) {
              final index = (daysToDisplay - 1) - differenceInDays;
              if (data['type'] == 'PEMASUKAN') {
                dailyIncome[index] += (data['amount'] as num).toDouble();
              } else {
                dailyExpense[index] += (data['amount'] as num).toDouble();
              }
            }
          }

          final List<FlSpot> incomeSpots = List.generate(dailyIncome.length, (i) => FlSpot(i.toDouble(), dailyIncome[i]));
          final List<FlSpot> expenseSpots = List.generate(dailyExpense.length, (i) => FlSpot(i.toDouble(), dailyExpense[i]));

          Map<String, List<DocumentSnapshot>> groupedTransactions = {};
          for (var doc in snapshot.data!.docs) {
            DateTime date = (doc['timestamp'] as Timestamp).toDate();
            // ===================================================================
            // PERBAIKAN UTAMA DI SINI
            // ===================================================================
            String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
            if (groupedTransactions[formattedDate] == null) groupedTransactions[formattedDate] = [];
            groupedTransactions[formattedDate]!.add(doc);
          }
          List<String> sortedDates = groupedTransactions.keys.toList();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.blue.shade800], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tren Keuangan", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(
                          height: 40,
                          child: DropdownButton<String>(
                            value: _selectedRange,
                            dropdownColor: Colors.indigo.shade600,
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            items: _chartRanges.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                            onChanged: (String? newValue) => setState(() => _selectedRange = newValue!),
                            underline: Container(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 1.8,
                      child: LineChart(_mainChartData(incomeSpots, expenseSpots, daysToDisplay)),
                    ),
                  ],
                ),
              ),

              const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: Align(alignment: Alignment.centerLeft, child: Text("Detail Transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    String date = sortedDates[index];
                    List<DocumentSnapshot> transactions = groupedTransactions[date]!;
                    return DailySummaryCard(date: date, transactions: transactions);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Semua fungsi helper untuk chart tidak berubah
  LineChartData _mainChartData(List<FlSpot> incomeSpots, List<FlSpot> expenseSpots, int daysToDisplay) { /* ... (Tidak ada perubahan) ... */ return LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 1, dashArray: [8, 4])), titlesData: FlTitlesData(show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: _bottomTitles(daysToDisplay)), leftTitles: AxisTitles(sideTitles: _leftTitles())), borderData: FlBorderData(show: false), minX: 0, maxX: (daysToDisplay - 1).toDouble(), minY: 0, lineBarsData: [_buildLineChartBarData(incomeSpots, Colors.greenAccent), _buildLineChartBarData(expenseSpots, Colors.redAccent)], lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipItems: (touchedSpots) { final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0); return touchedSpots.map((spot) => LineTooltipItem(currencyFormatter.format(spot.y), TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList(); }))); }
  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) { /* ... (Tidak ada perubahan) ... */ return LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: color.withOpacity(0.3))); }
  SideTitles _bottomTitles(int daysToDisplay) { /* ... (Tidak ada perubahan) ... */ return SideTitles(showTitles: true, reservedSize: 30, interval: daysToDisplay == 7 ? 1 : 5, getTitlesWidget: (value, meta) { final now = DateTime.now(); String text = ''; if (daysToDisplay == 7) { final day = now.subtract(Duration(days: (daysToDisplay - 1) - value.toInt())); text = DateFormat('E', 'id_ID').format(day); } else { if (value.toInt() % 5 == 0) { final day = now.subtract(Duration(days: (daysToDisplay - 1) - value.toInt())); text = DateFormat('d/M').format(day); } } return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70))); }); }
  SideTitles _leftTitles() { /* ... (Tidak ada perubahan) ... */ return SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (value, meta) { if (value == meta.max || value == meta.min) return Container(); String text; if (value >= 1000000) text = '${(value / 1000000).toStringAsFixed(1)}M'; else if (value >= 1000) text = '${(value / 1000).toStringAsFixed(0)}K'; else return Container(); return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70))); }); }
}
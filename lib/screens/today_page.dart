// lib/screens/today_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/transaction_form.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});
  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final Map<String, IconData> categoryIcons = {
    'Makanan': Icons.fastfood_outlined, 'Minuman': Icons.local_cafe_outlined, 'Transportasi': Icons.directions_bus_outlined,
    'Belanja': Icons.shopping_bag_outlined, 'Tagihan': Icons.receipt_long_outlined, 'Hiburan': Icons.movie_outlined,
    'Transfer': Icons.swap_horiz_outlined, 'Lainnya...': Icons.more_horiz_outlined,
  };

  Future<double> _getTotalBalance() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transactions').get();
    double totalPemasukan = 0, totalPengeluaran = 0;
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['type'] == 'PEMASUKAN') totalPemasukan += (data['amount'] as num);
      else totalPengeluaran += (data['amount'] as num);
    }
    return totalPemasukan - totalPengeluaran;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final Stream<QuerySnapshot> transactionsStream = FirebaseFirestore.instance
        .collection('transactions')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots();

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Ringkasan Keuangan'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================================================================
          // KARTU RINGKASAN DENGAN DESAIN BARU
          // ===================================================================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                // --- Saldo Total ---
                const Text('Sisa Uang Total', style: TextStyle(color: Colors.white70, fontSize: 16)),
                FutureBuilder<double>(
                  future: _getTotalBalance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: SizedBox(height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)));
                    }
                    double totalBalance = snapshot.data ?? 0;
                    return Text(
                      currencyFormatter.format(totalBalance),
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    );
                  },
                ),
                const Divider(height: 32, thickness: 0.5, color: Colors.white24),

                // --- Aktivitas Harian ---
                StreamBuilder<QuerySnapshot>(
                  stream: transactionsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();

                    double dailyIncome = 0, dailyExpense = 0;
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      if (data['type'] == 'PEMASUKAN') dailyIncome += (data['amount'] as num);
                      else dailyExpense += (data['amount'] as num);
                    }
                    double dailyBalance = dailyIncome - dailyExpense;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kolom Pemasukan
                            _buildDailyActivityColumn(
                              icon: Icons.arrow_circle_up_rounded,
                              label: 'Pemasukan Hari Ini',
                              amount: dailyIncome,
                              color: Colors.greenAccent, // WARNA BARU
                              formatter: currencyFormatter,
                            ),
                            // Kolom Pengeluaran
                            _buildDailyActivityColumn(
                              icon: Icons.arrow_circle_down_rounded,
                              label: 'Pengeluaran Hari Ini',
                              amount: dailyExpense,
                              color: Colors.redAccent, // WARNA BARU
                              formatter: currencyFormatter,
                              isRightAligned: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Saldo Hari Ini
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Perubahan Hari Ini: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text(
                              currencyFormatter.format(dailyBalance),
                              style: TextStyle(
                                color: dailyBalance == 0 ? Colors.white : (dailyBalance < 0 ? Colors.redAccent : Colors.greenAccent),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text('Detail Transaksi Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // --- DAFTAR TRANSAKSI HARI INI ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text('Belum ada transaksi hari ini.'));
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    bool isPengeluaran = data['type'] == 'PENGELUARAN';
                    IconData icon = categoryIcons[data['category']] ?? Icons.more_horiz_outlined;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        onTap: () => showTransactionFormSheet(context, document: document),
                        leading: Icon(icon, color: Colors.grey[600], size: 30),
                        title: Text(data['description'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(currencyFormatter.format(data['amount']), style: TextStyle(fontWeight: FontWeight.bold, color: isPengeluaran ? Colors.red : Colors.green)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTransactionFormSheet(context),
        tooltip: 'Tambah Transaksi',
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget helper baru untuk kolom aktivitas harian
  Widget _buildDailyActivityColumn({required IconData icon, required String label, required double amount, required Color color, required NumberFormat formatter, bool isRightAligned = false}) {
    return Column(
      crossAxisAlignment: isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Text(formatter.format(amount), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
// lib/widgets/daily_summary_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dompetku/widgets/transaction_form.dart';

class DailySummaryCard extends StatefulWidget {
  final String date;
  final List<DocumentSnapshot> transactions;

  const DailySummaryCard({
    super.key,
    required this.date,
    required this.transactions,
  });

  @override
  State<DailySummaryCard> createState() => _DailySummaryCardState();
}

class _DailySummaryCardState extends State<DailySummaryCard> {
  bool _isExpanded = false;

  final Map<String, IconData> categoryIcons = {
    'Makanan': Icons.fastfood_outlined, 'Minuman': Icons.local_cafe_outlined, 'Transportasi': Icons.directions_bus_outlined,
    'Belanja': Icons.shopping_bag_outlined, 'Tagihan': Icons.receipt_long_outlined, 'Hiburan': Icons.movie_outlined,
    'Transfer': Icons.swap_horiz_outlined, 'Lainnya...': Icons.more_horiz_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double dailyIncome = 0;
    double dailyExpense = 0;
    for (var doc in widget.transactions) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['type'] == 'PEMASUKAN') dailyIncome += (data['amount'] as num);
      else dailyExpense += (data['amount'] as num);
    }
    double dailyBalance = dailyIncome - dailyExpense;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ===================================================================
          // BAGIAN HEADER BARU YANG LEBIH INFORMATIF
          // ===================================================================
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.expand_more, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Pemasukan', dailyIncome, Colors.green, currencyFormatter),
                  const SizedBox(height: 4),
                  _buildSummaryRow('Pengeluaran', dailyExpense, Colors.red, currencyFormatter),
                  const Divider(height: 20, thickness: 1),
                  _buildSummaryRow('Saldo Hari Ini', dailyBalance, dailyBalance < 0 ? Colors.red : Colors.black87, currencyFormatter, isBold: true),
                ],
              ),
            ),
          ),

          // BAGIAN DETAIL (TIDAK BERUBAH)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              height: _isExpanded ? null : 0,
              color: Colors.black.withOpacity(0.03),
              child: Column(
                children: widget.transactions.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  bool isPengeluaran = data['type'] == 'PENGELUARAN';
                  IconData icon = categoryIcons[data['category']] ?? Icons.more_horiz_outlined;

                  return Dismissible(
                    key: Key(document.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      document.reference.delete();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data['description']} dihapus')));
                    },
                    background: Container(color: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 20), alignment: Alignment.centerRight, child: const Icon(Icons.delete, color: Colors.white)),
                    child: ListTile(
                      onTap: () => showTransactionFormSheet(context, document: document),
                      leading: Icon(icon, color: Colors.grey[600]),
                      title: Text(data['description']),
                      trailing: Text(
                        currencyFormatter.format(data['amount']),
                        style: TextStyle(fontWeight: FontWeight.bold, color: isPengeluaran ? Colors.red : Colors.green),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk membuat baris ringkasan
  Widget _buildSummaryRow(String label, double amount, Color color, NumberFormat formatter, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
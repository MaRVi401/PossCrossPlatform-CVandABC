import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../../../app/di/injection.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../stores/sales_report_store.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final _store = sl<SalesReportStore>();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _store.fetchSalesReport();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _store.startDate, end: _store.endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E1B4B),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _store.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: () => _store.fetchSalesReport(),
          ),
        ],
      ),
      drawer: const MainDrawer(currentRoute: 'sales_report'),
      body: Column(
        children: [
          // Filter Tanggal & Action Export
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: const Color(0xFF1E1B4B),
            child: Column(
              children: [
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 10),
                            Text(
                              'Filter Periode:',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        Observer(
                          builder: (_) => Text(
                            '${_store.formattedStartDate}  s/d  ${_store.formattedEndDate}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tombol Export PDF & Excel
                Observer(
                  builder: (_) => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _store.isExportingPdf
                              ? null
                              : () async {
                                  final success = await _store.exportPdf();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success ? 'Berhasil mengunduh PDF!' : 'Gagal mengunduh PDF.',
                                      ),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          icon: _store.isExportingPdf
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: Text(_store.isExportingPdf ? 'Mengunduh...' : 'Export PDF'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _store.isExportingExcel
                              ? null
                              : () async {
                                  final success = await _store.exportExcel();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success ? 'Berhasil mengunduh Excel!' : 'Gagal mengunduh Excel.',
                                      ),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          icon: _store.isExportingExcel
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.table_chart_rounded, size: 18),
                          label: Text(_store.isExportingExcel ? 'Mengunduh...' : 'Export Excel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Body (KPI Summary & Transaction List)
          Expanded(
            child: Observer(
              builder: (_) {
                if (_store.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Memuat laporan penjualan...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (_store.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(_store.errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _store.fetchSalesReport(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final summary = _store.summary;
                final transactions = _store.transactions;

                return RefreshIndicator(
                  onRefresh: () => _store.fetchSalesReport(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Grid KPI Ringkasan
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _buildSummaryCard(
                            title: 'Total Omzet',
                            value: _currencyFormat.format(summary['total_sales'] ?? 0),
                            icon: Icons.payments_rounded,
                            color: const Color(0xFF10B981),
                          ),
                          _buildSummaryCard(
                            title: 'Total Transaksi',
                            value: '${summary['total_count'] ?? 0} Trx',
                            icon: Icons.receipt_long_rounded,
                            color: Colors.indigo,
                          ),
                          _buildSummaryCard(
                            title: 'Item Terjual',
                            value: '${summary['total_items_sold'] ?? 0} Qty',
                            icon: Icons.shopping_bag_rounded,
                            color: Colors.amber.shade800,
                          ),
                          _buildSummaryCard(
                            title: 'Total Diskon',
                            value: _currencyFormat.format(summary['total_discount'] ?? 0),
                            icon: Icons.discount_rounded,
                            color: const Color(0xFFF43F5E),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rincian Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${transactions.length} Data',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (transactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('Tidak ada transaksi pada periode ini.'),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final trx = transactions[index];
                            final items = (trx['items'] as List?) ?? [];
                            final itemListText = items
                                .map((i) => '${i['product']?['product_name'] ?? 'Produk'} (${i['quantity']}x)')
                                .join(', ');

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: const Icon(Icons.receipt_rounded, color: Colors.indigo),
                                ),
                                title: Text(
                                  trx['invoice_number'] ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tgl: ${trx['transaction_date'] ?? '-'} • Kasir: ${trx['admin']?['name'] ?? 'Admin'}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      itemListText.isNotEmpty ? itemListText : 'Tidak ada detail barang',
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currencyFormat.format(double.tryParse(trx['final_amount'].toString()) ?? 0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                        fontSize: 13,
                                      ),
                                    ),
                                    if ((double.tryParse(trx['discount_amount'].toString()) ?? 0) > 0)
                                      Text(
                                        'Disc: ${_currencyFormat.format(double.parse(trx['discount_amount'].toString()))}',
                                        style: const TextStyle(fontSize: 10, color: Colors.red),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
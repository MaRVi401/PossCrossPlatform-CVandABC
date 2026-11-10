import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../stores/sales_report_store.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final _store = sl<SalesReportStore>();

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
      initialDateRange: DateTimeRange(
        start: _store.startDate,
        end: _store.endDate,
      ),
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

  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    // Memastikan waktu terkonversi ke waktu lokal perangkat (WIB/WITA/WIT)
    return DateFormat('dd MMM yyyy, HH:mm').format(parsed.toLocal());
  }

  void _showTransactionDetailModal(Map<String, dynamic> trx) {
    final items = (trx['items'] as List?) ?? [];
    final discountAmount =
        double.tryParse(trx['discount_amount']?.toString() ?? '0') ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle & Title
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trx['invoice_number'] ?? 'Rincian Transaksi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Info Meta Transaksi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Waktu Transaksi',
                      _formatDateTime(trx['transaction_date']?.toString()),
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      'Kasir',
                      trx['admin']?['name']?.toString() ?? 'Admin',
                    ),
                    if (trx['payment_method'] != null) ...[
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        'Metode Bayar',
                        trx['payment_method'].toString().toUpperCase(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Item Barang
              const Text(
                'Item Dibeli',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Tidak ada detail barang.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final name = item['product']?['product_name'] ??
                              item['product_name'] ??
                              'Produk';
                          final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

                          double price = double.tryParse(
                                (item['unit_price'] ?? item['price'])?.toString() ?? '0',
                              ) ??
                              0;

                          double subtotal = double.tryParse(
                                (item['subtotal'] ?? item['total_price'])?.toString() ?? '0',
                              ) ??
                              0;

                          if (price == 0 && subtotal > 0 && qty > 0) {
                            price = subtotal / qty;
                          } else if (subtotal == 0 && price > 0) {
                            subtotal = price * qty;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${CurrencyFormatter.format(price)} x $qty',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const Divider(height: 24),

              // Ringkasan Pembayaran Modal
              if (discountAmount > 0) ...[
                _buildSummaryRow(
                  'Diskon',
                  '- ${CurrencyFormatter.format(discountAmount)}',
                  valueColor: Colors.red,
                ),
                const SizedBox(height: 6),
              ],
              _buildSummaryRow(
                'Total Akhir',
                CurrencyFormatter.format(trx['final_amount']),
                isTotal: true,
                valueColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF0F172A) : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Filter Periode:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _store.isExportingPdf
                              ? null
                              : () async {
                                  final success = await _store.exportPdf();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Berhasil mengunduh PDF!'
                                            : 'Gagal mengunduh PDF.',
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                },
                          icon: _store.isExportingPdf
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            _store.isExportingPdf
                                ? 'Mengunduh...'
                                : 'Export PDF',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _store.isExportingExcel
                              ? null
                              : () async {
                                  final success = await _store.exportExcel();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Berhasil mengunduh Excel!'
                                            : 'Gagal mengunduh Excel.',
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                },
                          icon: _store.isExportingExcel
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.table_chart_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            _store.isExportingExcel
                                ? 'Mengunduh...'
                                : 'Export Excel',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Body (KPI Summary, Sales Chart & Transaction List)
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
                        Text(
                          'Memuat laporan penjualan...',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _store.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
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
                            value: CurrencyFormatter.format(
                              summary['total_sales'],
                            ),
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
                            value: CurrencyFormatter.format(
                              summary['total_discount'],
                            ),
                            icon: Icons.discount_rounded,
                            color: const Color(0xFFF43F5E),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section & Card Grafik Tren Penjualan
                      const Row(
                        children: [
                          Icon(
                            Icons.show_chart_rounded,
                            color: Color(0xFF1E1B4B),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Grafik Tren Penjualan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSalesChartCard(transactions),
                      const SizedBox(height: 24),

                      // Rincian Transaksi
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
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
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
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tidak ada transaksi pada periode ini.',
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final trx = transactions[index];

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
                                onTap: () => _showTransactionDetailModal(trx),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: const Icon(
                                    Icons.receipt_rounded,
                                    color: Colors.indigo,
                                  ),
                                ),
                                title: Text(
                                  trx['invoice_number'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  'Tgl: ${_formatDateTime(trx['transaction_date']?.toString())}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(
                                        trx['final_amount'],
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.grey.shade400,
                                      size: 20,
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
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
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

  Widget _buildSalesChartCard(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Belum ada tren data transaksi.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      );
    }

    final sortedTxs = List<dynamic>.from(transactions);
    sortedTxs.sort((a, b) {
      final dateA = DateTime.tryParse(a['transaction_date']?.toString() ?? '') ??
          DateTime(1970);
      final dateB = DateTime.tryParse(b['transaction_date']?.toString() ?? '') ??
          DateTime(1970);
      return dateA.compareTo(dateB);
    });

    List<FlSpot> spots = [];
    double maxY = 0;

    for (int i = 0; i < sortedTxs.length; i++) {
      final amount =
          (double.tryParse(sortedTxs[i]['final_amount']?.toString() ?? '0') ??
              0.0);
      spots.add(FlSpot(i.toDouble(), amount));
      if (amount > maxY) maxY = amount;
    }

    if (maxY == 0) maxY = 100000;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade100,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    String formatted;
                    if (value >= 1000000) {
                      formatted = '${(value / 1000000).toStringAsFixed(1)}Jt';
                    } else if (value >= 1000) {
                      formatted = '${(value / 1000).toStringAsFixed(0)}K';
                    } else {
                      formatted = value.toInt().toString();
                    }
                    return Text(
                      formatted,
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index < 0 || index >= sortedTxs.length) {
                      return const SizedBox.shrink();
                    }
                    final dateStr =
                        sortedTxs[index]['transaction_date']?.toString();
                    final dt =
                        dateStr != null ? DateTime.tryParse(dateStr)?.toLocal() : null;
                    final label =
                        dt != null ? DateFormat('HH:mm').format(dt) : '#${index + 1}';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (spots.length - 1).toDouble() < 1
                ? 1
                : (spots.length - 1).toDouble(),
            minY: 0,
            maxY: maxY * 1.15,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      CurrencyFormatter.format(spot.y),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: const Color(0xFF1E1B4B),
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF10B981),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF1E1B4B).withAlpha(25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
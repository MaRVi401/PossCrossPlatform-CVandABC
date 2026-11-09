import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/network/api_client.dart';

part 'sales_report_store.g.dart';

// ignore: library_private_types_in_public_api
class SalesReportStore = _SalesReportStoreBase with _$SalesReportStore;

abstract class _SalesReportStoreBase with Store {
  final ApiClient _apiClient = sl<ApiClient>();

  @observable
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @observable
  DateTime endDate = DateTime.now();

  @observable
  bool isLoading = false;

  @observable
  bool isExportingPdf = false;

  @observable
  bool isExportingExcel = false;

  @observable
  String? errorMessage;

  @observable
  Map<String, dynamic> summary = {};

  @observable
  ObservableList<dynamic> transactions = ObservableList<dynamic>();

  @computed
  String get formattedStartDate => DateFormat('yyyy-MM-dd').format(startDate);

  @computed
  String get formattedEndDate => DateFormat('yyyy-MM-dd').format(endDate);

  @action
  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    fetchSalesReport();
  }

  /// Helper untuk mendapatkan folder penyimpanan publik (Download) di Android
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }
    }
    return await getApplicationDocumentsDirectory();
  }

  @action
  Future<void> fetchSalesReport() async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await _apiClient.client.get(
        '/reports/sales',
        queryParameters: {
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        summary = Map<String, dynamic>.from(response.data['summary'] ?? {});
        transactions = ObservableList<dynamic>.of(response.data['data'] ?? []);
      } else {
        errorMessage = 'Gagal memuat data laporan.';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> exportPdf() async {
    isExportingPdf = true;
    errorMessage = null;

    try {
      final response = await _apiClient.client.get(
        '/reports/sales/export-pdf',
        queryParameters: {
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      if (response.statusCode == 200) {
        final Uint8List bytes = Uint8List.fromList(response.data);
        final saveDir = await _getDownloadDirectory();
        final fileName = "Laporan_Penjualan_${formattedStartDate}_sd_$formattedEndDate.pdf";
        final filePath = "${saveDir.path}/$fileName";

        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        debugPrint('File PDF berhasil tersimpan di: $filePath');

        // Buka file PDF secara native
        final result = await OpenFilex.open(filePath);
        return result.type == ResultType.done || result.type == ResultType.noAppToOpen;
      }
      return false;
    } catch (e) {
      debugPrint('Error Export PDF: $e');
      errorMessage = 'Gagal mendownload PDF: $e';
      return false;
    } finally {
      isExportingPdf = false;
    }
  }

  @action
  Future<bool> exportExcel() async {
    isExportingExcel = true;
    errorMessage = null;

    try {
      final response = await _apiClient.client.get(
        '/reports/sales/export-excel',
        queryParameters: {
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'},
        ),
      );

      if (response.statusCode == 200) {
        final Uint8List bytes = Uint8List.fromList(response.data);
        final saveDir = await _getDownloadDirectory();
        final fileName = "Laporan_Penjualan_${formattedStartDate}_sd_$formattedEndDate.xlsx";
        final filePath = "${saveDir.path}/$fileName";

        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        debugPrint('File Excel berhasil tersimpan di: $filePath');

        // Buka file Excel secara native
        final result = await OpenFilex.open(filePath);
        return result.type == ResultType.done || result.type == ResultType.noAppToOpen;
      }
      return false;
    } catch (e) {
      debugPrint('Error Export Excel: $e');
      errorMessage = 'Gagal mendownload Excel: $e';
      return false;
    } finally {
      isExportingExcel = false;
    }
  }
}
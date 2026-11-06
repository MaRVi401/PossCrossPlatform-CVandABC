import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/network/api_client.dart';

class ReportService {
  final ApiClient _apiClient = sl<ApiClient>();

  Future<bool> downloadAndOpenSalesPdf({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiClient.client.get(
        '/api/v1/reports/sales/export-pdf',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Uint8List pdfBytes = Uint8List.fromList(response.data);

        final outputDir = await getTemporaryDirectory();
        final fileName = "Laporan_Penjualan_${startDate}_sd_$endDate.pdf";
        final filePath = "${outputDir.path}/$fileName";

        final file = File(filePath);
        await file.writeAsBytes(pdfBytes, flush: true);

        final result = await OpenFilex.open(filePath);
        
        if (result.type != ResultType.done) {
          debugPrint('Gagal membuka file PDF: ${result.message}');
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return false;
    }
  }
}
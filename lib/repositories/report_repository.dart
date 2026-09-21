import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/proposal_report.dart';

class ReportRepository {
  final ApiClient _client = ApiClient();

  Future<List<ProposalReport>> getReports({String? farmId, String? type}) async {
    final queryParams = <String, dynamic>{};
    if (farmId != null && farmId.isNotEmpty && farmId != 'draft') {
      queryParams['farmId'] = farmId;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }

    final response = await _client.get('/api/reports', queryParams: queryParams);
    List rawList = [];
    if (response is List) {
      rawList = response;
    } else if (response is Map && response['reports'] is List) {
      rawList = response['reports'] as List;
    }
    return rawList.map((r) => ProposalReport.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<ProposalReport> generateReport({
    required String farmId,
    required String designId,
    String type = 'proposal',
  }) async {
    final response = await _client.post(
      '/api/reports/generate',
      body: {
        'farmId': farmId,
        'designId': designId,
        'type': type,
      },
    );
    final data = (response is Map && response['report'] is Map)
        ? response['report'] as Map<String, dynamic>
        : (response as Map<String, dynamic>);
    return ProposalReport.fromJson(data);
  }

  Future<String> downloadReportPdf(
    String reportId,
    String filename, {
    String? downloadUrl,
    List<int>? fallbackBytes,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final candidateUrls = <Uri>[];
    if (downloadUrl != null && downloadUrl.isNotEmpty) {
      final fullUrl = downloadUrl.startsWith('http')
          ? downloadUrl
          : '${AppConfig.baseUrl}${downloadUrl.startsWith('/') ? '' : '/'}$downloadUrl';
      candidateUrls.add(Uri.parse(fullUrl));
    }
    candidateUrls.add(Uri.parse('${AppConfig.baseUrl}/api/reports/$reportId/download'));

    for (final url in candidateUrls) {
      try {
        final response = await http.get(
          url,
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final dir = await getApplicationDocumentsDirectory();
          final sanitizedFilename = filename.replaceAll(RegExp(r'[^\w\.\-]'), '_');
          final cleanName = sanitizedFilename.endsWith('.pdf') ? sanitizedFilename : '$sanitizedFilename.pdf';
          final file = File('${dir.path}/$cleanName');
          await file.writeAsBytes(response.bodyBytes);
          return file.path;
        }
      } catch (_) {
        // Try next candidate
      }
    }

    if (fallbackBytes != null && fallbackBytes.isNotEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedFilename = filename.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final cleanName = sanitizedFilename.endsWith('.pdf') ? sanitizedFilename : '$sanitizedFilename.pdf';
      final file = File('${dir.path}/$cleanName');
      await file.writeAsBytes(fallbackBytes);
      return file.path;
    }

    throw Exception('Failed to download report PDF');
  }

  Future<void> deleteReport(String id) async {
    await _client.delete('/api/reports/$id');
  }
}

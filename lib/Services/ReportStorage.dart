import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ReportItem.dart';

class ReportStorage {
  static Future<String> saveImagePermanently(String temPath) async {
    final docs = await getApplicationDocumentsDirectory();
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${docs.path}/$fileName';

    await File(temPath).copy(newPath);
    return newPath;
  }
  static Future<void> saveReport(List<ReportItem> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reports.map((r)=> r.toJson()).toList());
    await prefs.setString('saved_reports', encoded);
  }
    static Future<List<ReportItem>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_reports');
    if (raw == null) return [];

    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => ReportItem.fromJson(e)).toList();
 }
   static Future<void> deleteReport(int index) async {
    final reports = await loadReports();
    if (index >= 0 && index < reports.length) {
      reports.removeAt(index);
      await saveReport(reports);
    }
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sv_vehicle_license_plate_detection/model/ReportItem.dart';

class MaintenanceVehicle {
  final String plate;
  final ReportStatus status;

  MaintenanceVehicle({required this.plate, required this.status});


Map<String, dynamic> toJson()=> {
  'plate' : plate,
  'status' : status.name,
};

factory MaintenanceVehicle.fromJson(Map<String, dynamic> json) => MaintenanceVehicle(
  plate : json['plate'],
  status : ReportStatus.values.byName(json['status']),
);
}
class MaintenanceStorage{
  static const String _key = 'maintenance_list';

  static Future<List<MaintenanceVehicle>>loadlist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw ==  null || raw.isEmpty){
      return[];
    }
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => MaintenanceVehicle.fromJson(e)).toList();
    }
      static Future<void> saveList(List<MaintenanceVehicle> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((v) => v.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
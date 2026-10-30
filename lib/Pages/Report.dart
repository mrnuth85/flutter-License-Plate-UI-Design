import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/ReportDetail.dart';
import '../model/ReportItem.dart';
import '../Services/ReportStorage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ReportPage extends StatefulWidget {
  final String? capturedImagePath;
  final String? capturedDate;
  final int initialStatusIndex;

  const ReportPage({
    super.key,
    this.capturedImagePath,
    this.capturedDate,
    this.initialStatusIndex = 0,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // ---------- FILTERS ----------
  // Row 1: time
  int selectedTimeIndex = 0;
  final List<String> timeFilters = ["All", "Today", "This week", "This month"];

  // Row 2: status
  late int selectedStatusIndex;
  final List<String> statusFilters = ["All", "Safe", "Alert"];

  // ---------- DATA ----------
  List<ReportItem> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    selectedStatusIndex = widget.initialStatusIndex;
    _loadReports();
  }

  // Load all reports from persistent storage
  Future<void> _loadReports() async {
    final data = await ReportStorage.loadReports();
    if (!mounted) return;
    setState(() {
      _reports = data;
      _loading = false;
    });
  }

  // ---------- FILTERING ----------
  List<ReportItem> get _filteredReports {
    return _reports.where((r) {
    final now = DateTime.now();

    // --- Time filter ---
    bool timeMatch;
    final reportDate = _parseDate(r.date);   // DateTime? from "2026-10-05 14:30"

    switch (selectedTimeIndex) {
      case 1: // Today
        timeMatch = reportDate != null &&
            reportDate.year == now.year &&
            reportDate.month == now.month &&
            reportDate.day == now.day;
        break;

      case 2: // This week (last 7 days)
        final weekAgo = now.subtract(const Duration(days: 7));
        timeMatch = reportDate != null && reportDate.isAfter(weekAgo);
        break;

      case 3: // This month
        timeMatch = reportDate != null &&
            reportDate.year == now.year &&
            reportDate.month == now.month;
        break;

      default: // All
        timeMatch = true;
    }

      // --- Status filter ---
      bool statusMatch;
      switch (selectedStatusIndex) {
        case 1: // Safe
          statusMatch = r.status == ReportStatus.safe;
          break;
        case 2: // Alert
          statusMatch = r.status == ReportStatus.alert;
          break;
        default: // All
          statusMatch = true;
      }

      return timeMatch && statusMatch;
    }).toList();
  }

  Future<void> _confirmAndDelete(BuildContext context, ReportItem r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report?'),
        content: Text('Are you sure you want to delete this report ${r.plate}?'),
        actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey),),  
        ),
         TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete',style: TextStyle(color: Colors.red),),
         )
        ],
      ),
    );
    if (confirm == true) {
      final originalIndex = _reports.indexOf(r);
      if (originalIndex != -1) {
        setState((){
          _reports.removeAt(originalIndex);
        });
        await ReportStorage.deleteReport(originalIndex);

        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Delete ${r.plate}'),
            duration: const Duration(seconds: 2), 
            )
          );
        }
      }
    }
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C12F3),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Pop back to the first page in the stack (Home)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Column(
        children: [
          // ---------- ROW 1: TIME ----------
          _buildFilterRow(
            labels: timeFilters,
            selectedIndex: selectedTimeIndex,
            onSelected: (i) => setState(() => selectedTimeIndex = i),
          ),

          // ---------- ROW 2: STATUS ----------
          _buildFilterRow(
            labels: statusFilters,
            selectedIndex: selectedStatusIndex,
            onSelected: (i) => setState(() => selectedStatusIndex = i),
            topPadding: 8,
          ),

          const SizedBox(height: 12),

          // ---------- LIST ----------
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReports.isEmpty
                    ? const Center(
                        child: Text(
                          "No reports yet.\nCapture a vehicle to get started.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final r = _filteredReports[index];
                          return Slidable(
                            key: ValueKey(r.date + r.plate + index.toString()),
                            startActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (context) => _confirmAndDelete(context, r),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),
                            child: _buildReportCard(
                              context,
                              date: r.date,
                              plate: r.plate,
                              imagePath: r.imagePath,
                              plateImagePath: r.plateImagePath,
                              status: r.status,
                            )
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ---------- FILTER CHIP ROW ----------
  Widget _buildFilterRow({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
    double topPadding = 20,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (index) {
            final isSelected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labels[index]),
                selected: isSelected,
                onSelected: (_) => onSelected(index),
                showCheckmark: false,
                selectedColor: const Color(0xFF2C12F3),
                backgroundColor: const Color(0xFFE0E0E0),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------- REPORT CARD ----------
  Widget _buildReportCard(
    BuildContext context, {
    required String date,
    required String plate,
    String? imagePath,
    String? plateImagePath,
    required ReportStatus status,
  }) {
    final isSafe = status == ReportStatus.safe;
    final badgeColor = isSafe ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 125, 125, 125),
            spreadRadius: 0.2,
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePath != null
                  ? Image.file(
                      File(imagePath),
                      width: 70,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 50,
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.car_rental, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        plate,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSafe ? "Safe" : "Alert",
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => ReportDetailPage(
                      imagePath: imagePath,
                      plateImagePath: plateImagePath,
                      date: date,
                      plate: plate,
                      status: status,
                    ),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
DateTime? _parseDate(String s) {
  try {
    final parts = s.split(' ');           // ["2026-10-05", "14:30"]
    final dateParts = parts[0].split('-');// ["2026", "10", "05"]
    final timeParts = parts.length > 1
        ? parts[1].split(':')             // ["14", "30"]
        : ['0', '0'];

    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  } catch (_) {
    return null;  // bad format → filter treats it as "not matching"
  }
}
}

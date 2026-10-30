import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sv_vehicle_license_plate_detection/model/ReportItem.dart';

class ReportDetailPage extends StatefulWidget {
  final String? imagePath;
  final String? date;
  final String? plate;
  final String? plateImagePath;
  final ReportStatus? status;

  const ReportDetailPage({super.key, this.imagePath, this.date, this.plate, this.plateImagePath, this.status});
  
  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  String? get imagePath => widget.imagePath;
  String? get date => widget.date;
  String? get plateImagePath => widget.plateImagePath;
  String? get plate => widget.plate;
  ReportStatus? get status => widget.status;

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF2C12F3);
    final bool isSafe = status?.name.toLowerCase() == 'safe';
    final Color badgeColor = isSafe ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Detail',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: brandBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 90, 22, 30),
        child: Column(
          children: [
            // Box 1 (Main Image)
            GestureDetector(
              onTap: (){
                if (imagePath != null) _showFullImage(context, imagePath!);
              },
              child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagePath != null
                    ? Image.file(
                        File(imagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.car_rental),
                      ),
              ),
            ),
        ),
            const SizedBox(height: 20),

            // Box 2 (License Plate Image)
            GestureDetector(
              onTap: (){
                if (plateImagePath != null) _showFullImage(context, plateImagePath!);
              },
            
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: plateImagePath != null
                    ? Image.file(
                        File(plateImagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.car_rental),
                      ),
              ),
            ),
            ),
            const SizedBox(height: 20),

            // Detail Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Date and Time
                  _buildDetail(
                    label: "Date and Time",
                    value: date ?? "Unknown time",
                  ),
                  const Divider(height: 1),

                  // License Plate
                  _buildDetail(
                    label: "License plate",
                    value: plate ?? " ",
                  ),
                  const Divider(height: 1),

                  // Image Row
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Image",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 60,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: imagePath != null
                                ? Image.file(File(imagePath!), fit: BoxFit.cover)
                                : const Icon(Icons.image),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Status
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isSafe ? "Safe" : "Alert",
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      /*bottomNavigationBar: BottomAppBar(
        color: brandBlue,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.assignment, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),*/
    );
  }

  
  Widget _buildDetail({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.all(12), // Fixed the EdgeInsetsGeometry
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, // Fixed typo
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  void _showFullImage(BuildContext context, String path){
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                icon: const Icon(Icons.close, 
                color: Colors.white,
                size: 35,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              )
            ],
          ),
        );
      },
    );
  }
}
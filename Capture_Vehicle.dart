  import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sv_vehicle_license_plate_detection/Pages/Report.dart';
import 'package:sv_vehicle_license_plate_detection/model/ReportItem.dart';
import 'package:sv_vehicle_license_plate_detection/Services/ReportStorage.dart';

  class CaptureVehiclePage extends StatelessWidget {
    final String imagePath;

    const CaptureVehiclePage({
      super.key,
      required this.imagePath,
      });

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Capture Vehicle',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2C12F3),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 90, 22, 30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black,
                width: 2,),
                borderRadius: BorderRadius.circular(18),
              ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,  
                ),
              ),
            ),
          const SizedBox(height: 50,),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () async {
                final DateTime now = DateTime.now();
                final String formattedDate = _formatDate(now);
                final permanentPath =
                  await ReportStorage.saveImagePermanently(imagePath);
                final existing = await ReportStorage.loadReports();
                existing.insert(
                  0, ReportItem(
                    date: formattedDate,
                    plate: 'PL8 REC',
                    imagePath: permanentPath,
                    status: ReportStatus.safe,
                  )
                );
                await ReportStorage.saveReport(existing);

                if (!context.mounted) return;


                Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) =>
                 ReportPage(
                  capturedImagePath: imagePath,
                  capturedDate: formattedDate,
                )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C12F3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Confirm",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),
            ),
          ],
        ),
        ),
      );
    }
    String _formatDate(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return "$y-$m-$d $h:$min";
    }
  }
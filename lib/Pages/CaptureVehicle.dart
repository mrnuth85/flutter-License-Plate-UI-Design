import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sv_vehicle_license_plate_detection/Pages/Report.dart';
import 'package:sv_vehicle_license_plate_detection/model/ReportItem.dart';
import 'package:sv_vehicle_license_plate_detection/Services/ReportStorage.dart';
import 'package:sv_vehicle_license_plate_detection/Services/LicensePlateDetection.dart';
import 'package:sv_vehicle_license_plate_detection/model/MaintenanceVehicle.dart';

  class CaptureVehiclePage extends StatefulWidget {
    final String imagePath;

    const CaptureVehiclePage({
      super.key,
      required this.imagePath,
      });

    @override
    State<CaptureVehiclePage> createState() => _CaptureVehiclePageState();
  }

  class _CaptureVehiclePageState extends State<CaptureVehiclePage> {

    bool _detecting = true;
    String? _plateText;
    String? _plateCropPath;
    ReportStatus? _maintenanceStatus;

    @override
      void initState() {
        super.initState();
        _runDetection();
      }
      
      Future<void> _runDetection() async {
        try{
          final result = await PlateDetector.detect(widget.imagePath);
          if(!mounted) return;
          
          // ADD THIS LINE:
          final savedList = await MaintenanceStorage.loadlist(); 

          setState(() {
            _plateText = result.plateText;
            _plateCropPath = result.croppedImagePath;
            if (_plateText != null){
              // CHANGE 'maintenanceList' to 'savedList' here:
              final match = savedList.firstWhere( 
                (v) => v.plate == _plateText,
                orElse: () => MaintenanceVehicle(plate: '', status: ReportStatus.safe),
              );
              if (match.plate.isNotEmpty){
                _maintenanceStatus = match.status;
              } else {
                _maintenanceStatus = null;
              }
            }
            _detecting = false;
          });
        }
        catch(e) {
          debugPrint('Detection failed: $e');
          if(!mounted) return;
          setState(() => _detecting = false);
        }
      }

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
            //original image
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Original-Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ),

            GestureDetector(
              onTap: () => _showFullImage(context, widget.imagePath),
            child: Container(
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
                  File(widget.imagePath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ),
          const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'License Plate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            GestureDetector(
              onTap: () {
                if (_plateCropPath != null) _showFullImage(context, _plateCropPath!);
              },
            
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black,
                width: 2,),
                borderRadius: BorderRadius.circular(18),
              ),
                child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _detecting
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Detecting plate...'),
                  ],
                ),
              )
              : (_plateCropPath != null)
              ?Image.file(
                File(_plateCropPath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.contain,
              )
              : const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                  size: 48, color: Colors.grey),
                  SizedBox(height:8),
                  Text('No license plate detected',
                  style: TextStyle(color: Colors.grey),
                  ),
                 ],
                ),
               ),
              ),
            ),
            ),
            const SizedBox(height: 16),
            if (!_detecting)
              Column(
                children: [
                  Text(
                    _plateText != null ? 'Plate: $_plateText' : 'Plate: unknown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _plateText != null ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_plateText != null) ...[
                    if (_maintenanceStatus == null)
                      const Text(
                        'Vehicle not found in Maintenance List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )
                    else
                      Text(
                        'Status: ${_maintenanceStatus == ReportStatus.safe ? "Safe" : "Alert"}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _maintenanceStatus == ReportStatus.safe ? Colors.green : Colors.red,
                        ),
                      ),
                  ]
                ],
              ),

          const SizedBox(height: 30,),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _detecting ? null : _onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C12F3),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                disabledForegroundColor: Colors.white70,
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
  Future<void> _onConfirm() async {
     if (_maintenanceStatus == null && _plateText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save: Vehicle not found in Maintenance List'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final formattedDate = _formatDate(DateTime.now());
    final permanetPath = await ReportStorage.saveImagePermanently(widget.imagePath);
    final existing = await ReportStorage.loadReports();
    String? permanentPlatePath;
    if (_plateCropPath != null) {
      permanentPlatePath = await ReportStorage.saveImagePermanently(_plateCropPath!);
    }
    existing.insert(
      0,
      ReportItem(
        date: formattedDate,
        plate: _plateText ?? 'UNKNOW',
        imagePath: permanetPath,
        plateImagePath: permanentPlatePath,
        status:  _maintenanceStatus ?? ReportStatus.safe, 
      ),
    );
    await ReportStorage.saveReport(existing);
    if(!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ReportPage(
        capturedImagePath: permanetPath,
        capturedDate: formattedDate,))
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
      void _showFullImage(BuildContext context, String path) {
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
                  icon: const Icon(Icons.close, color: Colors.white, size: 35),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  }
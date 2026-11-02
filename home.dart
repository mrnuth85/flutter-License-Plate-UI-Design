import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/CaptureVehicle.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/Notifications.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/Report.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/Setting.dart';
import 'package:sv_vehicle_license_plate_detection/model/ReportItem.dart';
import 'package:sv_vehicle_license_plate_detection/services/ReportStorage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalCarCapture = 0;
  int totalAlert = 0;
  int totalSafe = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final reports = await ReportStorage.loadReports();
    if (!mounted) return;
    setState(() {
      totalCarCapture = reports.length;
      totalAlert =
          reports.where((r) => r.status == ReportStatus.alert).length;
      totalSafe =
          reports.where((r) => r.status == ReportStatus.safe).length;
      isLoading = false;
    });
  }

  // Navigate somewhere, then reload counts when we come back
  Future<void> _refreshAfter(Future<void> Function() action) async {
    await action();
    await _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SV Detection',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C12F3),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications,
                color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Padding(
              padding: EdgeInsets.all(0),
              child: Icon(Icons.settings, color: Colors.white, size: 24),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 15),
        child: SizedBox(
          width: 330,
          height: 360,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              dashboardBox(
                Icons.directions_car,
                "Total car capture",
                isLoading ? "…" : "$totalCarCapture",
              ),
              dashboardBox(
                Icons.warning,
                "Alert",
                isLoading ? "…" : "$totalAlert",
                () {
                  _refreshAfter(() async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ReportPage(initialStatusIndex: 2),
                      ),
                    );
                  });
                },
              ),
              dashboardBox(
                Icons.assignment,
                "Report",
                null,
                () {
                  _refreshAfter(() async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportPage(),
                      ),
                    );
                  });
                },
              ),
              dashboardBox(
                Icons.health_and_safety,
                "safe",
                isLoading ? "…" : "$totalSafe",
                () {
                  _refreshAfter(() async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ReportPage(initialStatusIndex: 1),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),

      // Bottom Bar
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2864E8),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              const SizedBox(width: 70),
              IconButton(
                icon: const Icon(Icons.assignment,
                    color: Colors.white, size: 30),
                onPressed: () {
                  _refreshAfter(() async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportPage(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),

      // Camera FAB
      floatingActionButton: SizedBox(
        height: 100,
        width: 100,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF2C12F3),
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 5),
          ),
          child: const Icon(Icons.camera_alt,
              color: Colors.white, size: 35),
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.camera,
            );
            if (image != null && mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CaptureVehiclePage(imagePath: image.path),
                ),
              );
              // Reload counts after coming back from the capture flow
              _loadCounts();
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget dashboardBox(
    IconData icon,
    String title,
    String? value, [
    VoidCallback? onTap,
  ]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              child: Icon(icon, color: const Color(0xFF2C12F3), size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            if (value != null) ...[
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
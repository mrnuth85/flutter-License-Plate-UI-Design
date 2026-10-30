import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/CaptureVehicle.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/Notifications.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/Report.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/Setting.dart';
import '../model/ReportItem.dart';
import '../Services/ReportStorage.dart';
import 'package:sv_vehicle_license_plate_detection/model/MaintenanceVehicle.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  List<MaintenanceVehicle> maintenanceList = [];

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final reports = await ReportStorage.loadReports();
    final savedMaintenance = await MaintenanceStorage.loadlist();
    if (!mounted) return;
    setState(() {
      totalCarCapture = reports.length;
      totalAlert = reports.where((r) => r.status == ReportStatus.alert).length;
      totalSafe = reports.where((r) => r.status == ReportStatus.safe).length;
      maintenanceList = savedMaintenance;
      isLoading = false;
    });
  }

  Future<void> _refreshAfter(Future<void> Function() action) async {
    await action();
    await _loadCounts();
  }

  // Function to handle deletion
  Future<void> _confirmAndDelete(BuildContext context, MaintenanceVehicle v) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Vehicle?"),
        content: Text("Are you sure you want to remove ${v.plate} from the maintenance list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final newList = maintenanceList.where((item) => item != v).toList();
      await MaintenanceStorage.saveList(newList);
      _loadCounts();
    }
  }

  void _showAddVehicleDialog() {
    final plateController = TextEditingController();
    ReportStatus selectedStatus = ReportStatus.safe;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add to maintenance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: plateController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Status:'),
                      const SizedBox(width: 10),
                      DropdownButton<ReportStatus>(
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(
                            value: ReportStatus.safe,
                            child: Text('Safe', style: TextStyle(color: Colors.green)),
                          ),
                          DropdownMenuItem(
                            value: ReportStatus.alert,
                            child: Text('Alert', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    final newPlate = plateController.text.trim().toUpperCase();
                    if (newPlate.isNotEmpty) {
                      final newList = [
                        ...maintenanceList, 
                        MaintenanceVehicle(plate: newPlate, status: selectedStatus)
                      ];
                      await MaintenanceStorage.saveList(newList);
                      if (context.mounted) Navigator.pop(context);
                      _loadCounts();
                    }
                  },
                  child: const Text('Add'),
                )
              ],
            );
          }
        );
      }
    );
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
            icon: const Icon(Icons.notifications, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 38),
            child: SizedBox(
              width: 280,
              height: 280,
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
                            builder: (context) => const ReportPage(initialStatusIndex: 2),
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
                            builder: (context) => const ReportPage(initialStatusIndex: 1),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maintenance List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C12F3),
                  ),
                ),
                IconButton(
                  onPressed: _showAddVehicleDialog, 
                  icon: const Icon(Icons.add_circle, color: Color(0xFF2C12F3), size: 30),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: maintenanceList.isEmpty
                    ? const Center(
                        child: Text(
                          'Maintenance list is Empty',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: maintenanceList.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final v = maintenanceList[index];
                          final isSafe = v.status == ReportStatus.safe;
                          return Slidable(
                            key: ValueKey(v.plate),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (context) => _confirmAndDelete(context, v),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.directions_car, color: Color(0xFF2C12F3)),
                              title: Text(
                                v.plate,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: const Text("Registered Vehicle"),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSafe ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isSafe ? "Safe" : "Alert",
                                  style: TextStyle(
                                    color: isSafe ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
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
                icon: const Icon(Icons.assignment, color: Colors.white, size: 30),
                onPressed: () {
                  _refreshAfter(() async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportPage()),
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
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 35),
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.camera,
            );
            if (image != null && mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaptureVehiclePage(imagePath: image.path),
                ),
              );
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
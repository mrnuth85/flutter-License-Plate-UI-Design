import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C12F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Text(
              'System',
              style: TextStyle(
                color: Color.fromARGB(255, 74, 74, 74),
                fontSize: 16,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildSetting(
                  icon: Icons.build,
                  label: 'Maintenance Mode',
                  value: 'Enable to play sound alert when vehicle is captured.',
                ),
                const Divider(height: 1),
                _buildSetting(
                  icon: Icons.volume_up,
                  label: 'Sound',
                  value: 'Test sound or adjust volume.',
                ),
              ],
            ),
          ),
          const Text('Language',
          style: TextStyle(
            color: Color.fromARGB(255, 74, 74, 74),
            fontSize: 16,
          ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300,),
            ),
            child: Column(
              children: [
                //Language
                _buildSetting(
                  icon: Icons.language, 
                  label: "Language", 
                  value: "Select language"),
              ],
            ),
          ),
        const Text('Information',
        style: TextStyle(
          color: Color.fromARGB(255, 74, 74, 74),
          fontSize: 16,
        ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              //Information
              _buildSetting(
                icon: Icons.info, 
                label: "About", 
                value: "App version 1.00")
            ],
          ),
        ),
         const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add your logout logic here
                    // Example: Navigator.pushReplacementNamed(context, '/login');
                    print("Log out pressed");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background
                    foregroundColor: Colors.white, // White text
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded pill shape
                    ),
                  ),
                  child: const Text(
                    "Log out",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetting({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2C12F3), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 102, 102, 102),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
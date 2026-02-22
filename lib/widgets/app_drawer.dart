import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_report_screen.dart';
import '../screens/edit_report_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 122, 70, 245),
            ),
            child: Text(
              'Incident Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home Screen'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard Screen'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Add Report Screen'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddReportScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Report Screen (Demo)'),
            onTap: () {
              Navigator.pop(context); 
      
              final demoIncident = Incident(
                stationId: '000',
                stationName: 'Demo Station',
                zone: 'เขต 1',
                province: 'กรุงเทพมหานคร',
                typeId: 1, 
                severity: 'Low',
                reporterName: 'Demo Reporter',
                description: 'Demo for navigation linking',
                timestamp: DateTime.now().toString(),
                syncStatus: 0,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditReportScreen(incident: demoIncident),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

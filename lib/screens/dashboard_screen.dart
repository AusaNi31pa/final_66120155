import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/db_service.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int offlineCount = 0;
  List<Map<String, dynamic>> topStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final dbService = DBService.instance;
    final count = await dbService.getOfflineIncidentsCount();
    final stations = await dbService.getTop3ComplainedStations();

    setState(() {
      offlineCount = count;
      topStations = stations;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Card(
                    color: const Color.fromARGB(255, 239, 222, 255),
                    child: ListTile(
                      leading: const Icon(
                        Icons.cloud_off,
                        size: 40,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Offline Incidents Count',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          const Text('Total reports waiting to sync'),
                      trailing: Text(
                        '$offlineCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Top 3 Most Complained Stations",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  if (topStations.isEmpty)
                    const Text("No incident data available.")
                  else
                    ...topStations.map((station) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.how_to_vote,
                            color: Colors.indigo,
                          ),
                          title: Text(
                            station['station_name'] ?? '',
                          ),
                          trailing: Text(
                            "${station['report_count']} Reports",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
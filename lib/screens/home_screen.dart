import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/sync_service.dart';
import '../models/incident.dart';
import '../widgets/report_card.dart';
import 'add_report_screen.dart';
import 'edit_report_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DBService db = DBService.instance;   
  final SyncService sync = SyncService();

  List<Incident> list = [];
  List<Incident> filteredList = []; 
  String searchQuery = "";          

  Future<void> loadData() async {
    final data = await db.getIncidents();

    if (!mounted) return;   

    setState(() {
      list = data;
      filteredList = data; 
    });
  }

  void _search(String query) {  
    setState(() {
      searchQuery = query;

      filteredList = list.where((incident) {
        return incident.description
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            incident.stationName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            incident.reporterName
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Incident Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await sync.syncData();
              await loadData();

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sync Completed")),
              );
            },
          )
        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Search reports...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No Reports Found"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      return ReportCard(
                        incident: item,

                        onDelete: () async {
                          if (item.reportId == null) return;

                          await sync.deleteIncident(item);
                          await loadData();
                        },

                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditReportScreen(incident: item),
                            ),
                          );

                          await loadData();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddReportScreen(),
            ),
          );

          await loadData();
        },
      ),
    );
  }
}
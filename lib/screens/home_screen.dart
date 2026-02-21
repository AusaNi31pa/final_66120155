import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/sync_service.dart';
import '../models/incident.dart';
import '../widgets/report_card.dart';
import 'add_report_screen.dart';
import 'edit_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DBService db = DBService.instance;   
  final SyncService sync = SyncService();
  List<Incident> list = [];

  // โหลดข้อมูลจาก SQLite
  Future<void> loadData() async {
    final data = await db.getIncidents();
    setState(() {
      list = data;
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
      appBar: AppBar(
        title: const Text("Incident Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await sync.syncData();
              await loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sync Completed")),
              );
            },
          )
        ],
      ),

      body: list.isEmpty
          ? const Center(child: Text("No Reports Found"))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];

                return ReportCard(
                  incident: item,

                  onDelete: () async {
                    await db.deleteIncident(item.reportId!);
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

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReportScreen(),
            ),
          );
          await loadData();
        },
      ),
    );
  }
}
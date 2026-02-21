import 'package:flutter/material.dart';
import '../models/incident.dart';

class ReportCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  ReportCard({
    required this.incident,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(incident.description),
        subtitle: Text("Sync: ${incident.syncStatus}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
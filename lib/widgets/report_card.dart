import 'dart:io';
import 'package:flutter/material.dart';
import '../models/incident.dart';

class ReportCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReportCard({
    super.key,
    required this.incident,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: incident.evidencePhoto != null &&
                incident.evidencePhoto!.isNotEmpty &&
                File(incident.evidencePhoto!).existsSync()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(incident.evidencePhoto!),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),

        title: Text(
          incident.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text("Reported by: ${incident.reporterName}"),

            Text("Station Name: ${incident.stationName}"),

            Text("Violation Type: ${incident.typeId}"),

            Text("Sync: ${incident.syncStatus}"),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
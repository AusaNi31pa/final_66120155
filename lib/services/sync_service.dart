import 'package:flutter/foundation.dart';
import 'db_service.dart';
import 'firebase_service.dart';
import '../models/incident.dart';

class SyncService {
  final DBService db = DBService.instance;
  final FirebaseService firebase = FirebaseService();

  Future<void> syncData() async {
    try {
      final List<Incident> localList = await db.getIncidents();

      for (var incident in localList) {
        if (incident.syncStatus == 0) {
          await firebase.uploadIncident(incident);

          incident.syncStatus = 1;
          await db.updateIncident(incident);
        }
      }

      final List<Incident> remoteList = await firebase.getIncidents();

      for (var remoteIncident in remoteList) {
        final localExists = localList.any(
            (local) => local.reportId == remoteIncident.reportId);

        if (!localExists) {
          remoteIncident.syncStatus = 1;
          await db.insertIncident(remoteIncident);
        } else {
          await db.updateIncident(remoteIncident);
        }
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  Future<void> deleteIncident(Incident incident) async {
    try {
      if (incident.reportId == null) return;
      await firebase.deleteIncident(incident.reportId.toString());
      await db.deleteIncident(incident.reportId!);

    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }
}
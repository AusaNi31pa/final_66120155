import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadIncident(Incident incident) async {
    if (incident.reportId == null) return;

    String docId = incident.reportId.toString();

    await _firestore
        .collection("incident_reports")
        .doc(docId)
        .set(incident.toMap(), SetOptions(merge: true));
  }

  Future<List<Incident>> getIncidents() async {
    final snapshot =
        await _firestore.collection("incident_reports").get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      data['syncStatus'] = 1;

      return Incident.fromMap(data);
    }).toList();
  }

  Future<void> deleteIncident(String reportId) async {
    await _firestore
        .collection("incident_reports")
        .doc(reportId)
        .delete();
  }
}
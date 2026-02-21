import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadIncident(Incident incident) async {
    String docId = incident.reportId.toString();
    await _firestore
        .collection("incident_reports")
        .doc(docId)
        .set(incident.toMap(), SetOptions(merge: true));
  }

  Future<List<Incident>> getIncidents() async {
    final snapshot = await _firestore.collection("incident_reports").get();
    return snapshot.docs.map((doc) => Incident.fromMap(doc.data())).toList();
  }
}
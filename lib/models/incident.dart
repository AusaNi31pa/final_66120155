class Incident {
  int? reportId;
  String stationId;     
  String stationName;   
  String zone;          
  String province;      
  int typeId;           
  String severity;      
  String reporterName;
  String description;
  String? evidencePhoto;
  String timestamp;
  String? aiResult;
  double? aiConfidence;
  int syncStatus;

  Incident({
    this.reportId,
    required this.stationId,
    required this.stationName,
    required this.zone,
    required this.province,
    required this.typeId,
    required this.severity,
    required this.reporterName,
    required this.description,
    this.evidencePhoto,
    required this.timestamp,
    this.aiResult,
    this.aiConfidence,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "report_id": reportId,
      "station_id": stationId,
      "station_name": stationName,
      "zone": zone,
      "province": province,
      "type_id": typeId,
      "severity": severity,
      "reporter_name": reporterName,
      "description": description,
      "evidence_photo": evidencePhoto,
      "timestamp": timestamp,
      "ai_result": aiResult,
      "ai_confidence": aiConfidence,
      "syncStatus": syncStatus,
    };
  }

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      reportId: map["report_id"],
      stationId: map["station_id"].toString(),
      stationName: map["station_name"] ?? "",
      zone: map["zone"] ?? "",
      province: map["province"] ?? "",
      typeId: map["type_id"],
      severity: map["severity"] ?? "Low",
      reporterName: map["reporter_name"],
      description: map["description"],
      evidencePhoto: map["evidence_photo"],
      timestamp: map["timestamp"],
      aiResult: map["ai_result"],
      aiConfidence: map["ai_confidence"] != null
          ? map["ai_confidence"].toDouble()
          : null,
      syncStatus: map["syncStatus"] ?? 0,
    );
  }
}
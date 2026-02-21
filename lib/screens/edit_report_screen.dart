import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/db_service.dart';
import '../services/sync_service.dart';

class EditReportScreen extends StatefulWidget {
  final Incident incident;

  const EditReportScreen({Key? key, required this.incident})
      : super(key: key);

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController descriptionController;
  late TextEditingController stationIdController;
  late TextEditingController stationNameController;
  late TextEditingController reporterNameController;
  late TextEditingController evidencePhotoController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  
  final DBService db = DBService.instance;

  List<Map<String, dynamic>> violationTypes = [];
  int? selectedTypeId;
  
  String? selectedZone;
  final List<String> zones = ['เขต 1', 'เขต 2', 'เขต 3', 'เขต 4', 'เขต 5'];

  String? selectedProvince;
  final List<String> provinces = [
    'กรุงเทพมหานคร', 'กระบี่', 'กาญจนบุรี', 'กาฬสินธุ์', 'กำแพงเพชร', 'ขอนแก่น', 'จันทบุรี', 'ฉะเชิงเทรา', 'ชลบุรี', 'ชัยนาท', 'ชัยภูมิ', 'ชุมพร', 'เชียงราย', 
    'เชียงใหม่', 'ตรัง', 'ตราด', 'ตาก', 'นครนายก', 'นครปฐม', 'นครพนม', 'นครราชสีมา', 'นครศรีธรรมราช', 'นครสวรรค์', 'นนทบุรี', 'นราธิวาส', 'น่าน', 'บึงกาฬ', 'บุรีรัมย์', 'ปทุมธานี', 
    'ประจวบคีรีขันธ์', 'ปราจีนบุรี', 'ปัตตานี', 'พระนครศรีอยุธยา', 'พะเยา', 'พังงา', 'พัทลุง', 'พิจิตร', 'พิษณุโลก', 'เพชรบุรี', 'เพชรบูรณ์', 'แพร่', 'ภูเก็ต', 'มหาสารคาม', 'มุกดาหาร', 'แม่ฮ่องสอน', 
    'ยโสธร', 'ยะลา', 'ร้อยเอ็ด', 'ระนอง', 'ระยอง', 'ราชบุรี', 'ลพบุรี', 'ลำปาง', 'ลำพูน', 'เลย', 'ศรีสะเกษ', 'สกลนคร', 'สงขลา', 'สตูล', 'สมุทรปราการ', 'สมุทรสงคราม', 'สมุทรสาคร', 'สระแก้ว', 
    'สระบุรี', 'สิงห์บุรี', 'สุโขทัย', 'สุพรรณบุรี', 'สุราษฎร์ธานี', 'สุรินทร์', 'หนองคาย', 'หนองบัวลำภู', 'อ่างทอง', 'อำนาจเจริญ', 'อุดรธานี', 'อุตรดิตถ์', 'อุทัยธานี', 'อุบลราชธานี'
  ];

  String? selectedSeverity;
  final List<String> severities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.incident.description);
    stationIdController = TextEditingController(text: widget.incident.stationId);
    stationNameController = TextEditingController(text: widget.incident.stationName);
    reporterNameController = TextEditingController(text: widget.incident.reporterName);
    evidencePhotoController = TextEditingController(text: widget.incident.evidencePhoto ?? "");
    
    String ts = widget.incident.timestamp;
    List<String> parts = ts.split(' ');
    String datePart = parts.isNotEmpty ? parts[0] : '';
    String timePart = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    dateController = TextEditingController(text: datePart);
    timeController = TextEditingController(text: timePart);
    
    selectedZone = widget.incident.zone.isNotEmpty ? widget.incident.zone : null;
    selectedProvince = widget.incident.province.isNotEmpty ? widget.incident.province : null;
    selectedTypeId = widget.incident.typeId;
    selectedSeverity = widget.incident.severity.isNotEmpty ? widget.incident.severity : null;

    if (selectedZone != null && !zones.contains(selectedZone)) {
       selectedZone = null;
    }
    if (selectedProvince != null && !provinces.contains(selectedProvince)) {
       selectedProvince = null;
    }

    loadDropdownData();
  }

  Future<void> loadDropdownData() async {
    final v = await db.getViolationTypes();
    setState(() {
      violationTypes = v;
      if (violationTypes.isNotEmpty && !violationTypes.any((vt) => vt['type_id'] == selectedTypeId)) {
        selectedTypeId = violationTypes.first['type_id'] as int;
      }
    });
  }

  Future<void> update() async {
    if (descriptionController.text.trim().isEmpty) return;
    if (stationIdController.text.trim().isEmpty) return;
    if (stationNameController.text.trim().isEmpty) return;
    if (reporterNameController.text.trim().isEmpty) return;
    if (selectedZone == null) return;
    if (selectedProvince == null) return;
    if (selectedTypeId == null) return;
    if (selectedSeverity == null) return;

    String reporterName = reporterNameController.text.trim();
    String? evidencePhoto = evidencePhotoController.text.trim().isEmpty ? null : evidencePhotoController.text.trim();
    String newTimestamp = "${dateController.text.trim()} ${timeController.text.trim()}";

    widget.incident.description = descriptionController.text.trim();
    widget.incident.stationId = stationIdController.text.trim();
    widget.incident.stationName = stationNameController.text.trim();
    widget.incident.reporterName = reporterName;
    widget.incident.evidencePhoto = evidencePhoto;
    widget.incident.timestamp = newTimestamp;
    widget.incident.zone = selectedZone!;
    widget.incident.province = selectedProvince!;
    widget.incident.typeId = selectedTypeId!;
    widget.incident.severity = selectedSeverity!;
    
    widget.incident.syncStatus = 0;

    await db.updateIncident(widget.incident);
    SyncService().syncData(); 
    
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    stationIdController.dispose();
    stationNameController.dispose();
    reporterNameController.dispose();
    evidencePhotoController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Report"),
      ),
      body: violationTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: stationIdController,
                    decoration: const InputDecoration(
                      labelText: "Station ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: stationNameController,
                    decoration: const InputDecoration(
                      labelText: "Station Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedZone,
                    decoration: const InputDecoration(
                      labelText: "Zone",
                      border: OutlineInputBorder(),
                    ),
                    items: zones.map((z) {
                      return DropdownMenuItem<String>(
                        value: z,
                        child: Text(z),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedZone = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedProvince,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Province",
                      border: OutlineInputBorder(),
                    ),
                    items: provinces.map((p) {
                      return DropdownMenuItem<String>(
                        value: p,
                        child: Text(p),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedProvince = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Violation Type",
                      border: OutlineInputBorder(),
                    ),
                    items: violationTypes.map((v) {
                      return DropdownMenuItem<int>(
                        value: v['type_id'] as int,
                        child: Text(v['type_name'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTypeId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: "Severity",
                      border: OutlineInputBorder(),
                    ),
                    items: severities.map((s) {
                      return DropdownMenuItem<String>(
                        value: s,
                        child: Text(s),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSeverity = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reporterNameController,
                    decoration: const InputDecoration(
                      labelText: "Reporter Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: evidencePhotoController,
                    decoration: const InputDecoration(
                      labelText: "Evidence Photo Path (Optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateController,
                          decoration: const InputDecoration(
                            labelText: "วัน/เดือน/ปี (YYYY-MM-DD)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            labelText: "เวลา (HH:MM:SS)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: update,
                      child: const Text("Update"),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
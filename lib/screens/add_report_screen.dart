import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/db_service.dart';
import '../services/sync_service.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({Key? key}) : super(key: key);

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stationIdController = TextEditingController();
  final TextEditingController stationNameController = TextEditingController();
  final TextEditingController reporterNameController = TextEditingController();
  final TextEditingController evidencePhotoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  
  final DBService db = DBService.instance;

  List<Map<String, dynamic>> violationTypes = [];
  int? selectedTypeId;
  
  String? selectedZone;
  final List<String> zones = ['เขต 1', 'เขต 2', 'เขต 3', 'เขต 4', 'เขต 5'];

  String? selectedProvince;
  final List<String> provinces = [
    'กรุงเทพมหานคร', 'กระบี่', 'กาญจนบุรี', 'กาฬสินธุ์', 'กำแพงเพชร', 'ขอนแก่น', 'จันทบุรี', 'ฉะเชิงเทรา', 'ชลบุรี', 'ชัยนาท', 'ชัยภูมิ', 'ชุมพร', 'เชียงราย', 
    'เชียงใหม่', 'ตรัง', 'ตราด', 'ตาก', 'นครนายก', 'นครปฐม', 'นครพนม', 'นครราชสีมา', 'นครศรีธรรมราช', 'นครสวรรค์', 'นนทบุรี', 'นราธิวาส', 'น่าน', 'บึงกาฬ', 
    'บุรีรัมย์', 'ปทุมธานี', 'ประจวบคีรีขันธ์', 'ปราจีนบุรี', 'ปัตตานี', 'พระนครศรีอยุธยา', 'พะเยา', 'พังงา', 'พัทลุง', 'พิจิตร', 'พิษณุโลก', 'เพชรบุรี', 'เพชรบูรณ์', 'แพร่', 'ภูเก็ต', 'มหาสารคาม', 
    'มุกดาหาร', 'แม่ฮ่องสอน', 'ยโสธร', 'ยะลา', 'ร้อยเอ็ด', 'ระนอง', 'ระยอง', 'ราชบุรี', 'ลพบุรี', 'ลำปาง', 'ลำพูน', 'เลย', 'ศรีสะเกษ', 'สกลนคร', 'สงขลา', 'สตูล', 'สมุทรปราการ', 'สมุทรสงคราม', 
    'สมุทรสาคร', 'สระแก้ว', 'สระบุรี', 'สิงห์บุรี', 'สุโขทัย', 'สุพรรณบุรี', 'สุราษฎร์ธานี', 'สุรินทร์', 'หนองคาย', 'หนองบัวลำภู', 'อ่างทอง', 'อำนาจเจริญ', 'อุดรธานี', 'อุตรดิตถ์', 'อุทัยธานี', 'อุบลราชธานี'
  ];

  String? selectedSeverity;
  final List<String> severities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    String currentDateTime = DateTime.now().toString().split('.')[0];
    List<String> parts = currentDateTime.split(' ');
    dateController.text = parts[0];
    timeController.text = parts.length > 1 ? parts[1] : '';
    loadDropdownData();
  }

  Future<void> loadDropdownData() async {
    final v = await db.getViolationTypes();
    setState(() {
      violationTypes = v;
      if (violationTypes.isNotEmpty) {
        selectedTypeId = violationTypes.first['type_id'] as int;
      }
    });
  }

  Future<void> save() async {
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
    String timestamp = "${dateController.text.trim()} ${timeController.text.trim()}";

    Incident incident = Incident(
      stationId: stationIdController.text.trim(),
      stationName: stationNameController.text.trim(),
      zone: selectedZone!,
      province: selectedProvince!,
      typeId: selectedTypeId!,
      severity: selectedSeverity!,
      reporterName: reporterName,
      evidencePhoto: evidencePhoto,
      description: descriptionController.text.trim(),
      timestamp: timestamp,
      syncStatus: 0,
    );

    await db.insertIncident(incident);
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
        title: const Text("Add Report"),
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
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => save(),
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
                      onPressed: save,
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
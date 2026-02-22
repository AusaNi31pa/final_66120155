import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/incident.dart';
import '../services/db_service.dart';
import '../services/sync_service.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';

class EditReportScreen extends StatefulWidget {
  final Incident incident;

  const EditReportScreen({super.key, required this.incident});

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
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isPickingImage = false;

  List<Map<String, dynamic>> violationTypes = [];
  int? selectedTypeId;

  String? selectedZone;
  final List<String> zones = ['เขต 1', 'เขต 2', 'เขต 3', 'เขต 4', 'เขต 5'];

  String? selectedProvince;
  final List<String> provinces = [
    'กรุงเทพมหานคร','กระบี่','กาญจนบุรี','กาฬสินธุ์','กำแพงเพชร','ขอนแก่น','จันทบุรี','ฉะเชิงเทรา','ชลบุรี','ชัยนาท','ชัยภูมิ','ชุมพร','เชียงราย',
    'เชียงใหม่','ตรัง','ตราด','ตาก','นครนายก','นครปฐม','นครพนม','นครราชสีมา','นครศรีธรรมราช','นครสวรรค์','นนทบุรี','นราธิวาส',
    'น่าน','บึงกาฬ','บุรีรัมย์','ปทุมธานี','ประจวบคีรีขันธ์','ปราจีนบุรี','ปัตตานี','พระนครศรีอยุธยา','พะเยา','พังงา','พัทลุง','พิจิตร',
    'พิษณุโลก','เพชรบุรี','เพชรบูรณ์','แพร่','ภูเก็ต','มหาสารคาม','มุกดาหาร','แม่ฮ่องสอน','ยโสธร','ยะลา','ร้อยเอ็ด','ระนอง',
    'ระยอง','ราชบุรี','ลพบุรี','ลำปาง','ลำพูน','เลย','ศรีสะเกษ','สกลนคร','สงขลา','สตูล','สมุทรปราการ','สมุทรสงคราม',
    'สมุทรสาคร','สระแก้ว','สระบุรี','สิงห์บุรี','สุโขทัย','สุพรรณบุรี','สุราษฎร์ธานี','สุรินทร์','หนองคาย','หนองบัวลำภู','อ่างทอง',
    'อำนาจเจริญ','อุดรธานี','อุตรดิตถ์','อุทัยธานี','อุบลราชธานี'
  ];

  String? selectedSeverity;
  final List<String> severities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();

    descriptionController =
        TextEditingController(text: widget.incident.description);
    stationIdController =
        TextEditingController(text: widget.incident.stationId);
    stationNameController =
        TextEditingController(text: widget.incident.stationName);
    reporterNameController =
        TextEditingController(text: widget.incident.reporterName);
    evidencePhotoController =
        TextEditingController(text: widget.incident.evidencePhoto ?? "");

    if (widget.incident.evidencePhoto != null &&
        widget.incident.evidencePhoto!.isNotEmpty &&
        File(widget.incident.evidencePhoto!).existsSync()) {
      _selectedImage = File(widget.incident.evidencePhoto!);
    }

    String ts = widget.incident.timestamp;
    List<String> parts = ts.split(' ');
    dateController =
        TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    timeController =
        TextEditingController(text: parts.length > 1 ? parts[1] : '');

    selectedZone = widget.incident.zone;
    selectedProvince = widget.incident.province;
    selectedTypeId = widget.incident.typeId;
    selectedSeverity = widget.incident.severity;

    loadDropdownData();
  }

  Future<void> loadDropdownData() async {
    final v = await db.getViolationTypes();
    setState(() {
      violationTypes = v;
    });
  }

  Future<void> _pickImageFromGallery() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          evidencePhotoController.text = picked.path;
        });
      }
    } finally {
      _isPickingImage = false;
    }
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

    widget.incident.description = descriptionController.text.trim();
    widget.incident.stationId = stationIdController.text.trim();
    widget.incident.stationName = stationNameController.text.trim();
    widget.incident.reporterName = reporterNameController.text.trim();
    widget.incident.evidencePhoto =
        evidencePhotoController.text.trim().isEmpty
            ? null
            : evidencePhotoController.text.trim();
    widget.incident.timestamp =
        "${dateController.text.trim()} ${timeController.text.trim()}";
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
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Edit Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
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
                    initialValue: selectedZone,
                    decoration: const InputDecoration(
                      labelText: "Zone",
                      border: OutlineInputBorder(),
                    ),
                    items: zones
                        .map((z) =>
                            DropdownMenuItem(value: z, child: Text(z)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedZone = val),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedProvince,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Province",
                      border: OutlineInputBorder(),
                    ),
                    items: provinces
                        .map((p) =>
                            DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedProvince = val),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    initialValue: selectedTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Violation Type",
                      border: OutlineInputBorder(),
                    ),
                    items: violationTypes
                        .map((v) => DropdownMenuItem(
                              value: v['type_id'] as int,
                              child: Text(v['type_name'].toString()),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedTypeId = val),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: "Severity",
                      border: OutlineInputBorder(),
                    ),
                    items: severities
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedSeverity = val),
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

                  const Text("Evidence Photo (Optional)",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_photo_alternate,
                                    size: 40, color: Colors.black54),
                                SizedBox(height: 8),
                                Text("Tap to select image",
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateController,
                          decoration: const InputDecoration(
                            labelText: "YYYY-MM-DD",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            labelText: "HH:MM:SS",
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
                  ),
                ],
              ),
            ),
    );
  }
}
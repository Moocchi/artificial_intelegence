// ignore: file_names
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'maps_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<String> selectedSymptoms = [];
  String? predictedDisease;
  double? confidence;
  // keep a single search controller for the symptoms picker to avoid
  // disposing it while the modal still has active widgets listening to it
  final TextEditingController _searchController = TextEditingController();

  final symptoms = [
  'Abdominal Pain',
  'Abnormal Menstruation',
  'Acidity',
  'Acute Liver Failure',
  'Altered Sensorium',
  'Anxiety',
  'Back Pain',
  'Belly Pain',
  'Blackheads',
  'Bladder Discomfort',
  'Blister',
  'Blood In Sputum',
  'Bloody Stool',
  'Blurred And Distorted Vision',
  'Breathlessness',
  'Brittle Nails',
  'Bruising',
  'Burning Micturition',
  'Chest Pain',
  'Chills',
  'Cold Hands And Feets',
  'Coma',
  'Congestion',
  'Constipation',
  'Continuous Feel Of Urine',
  'Continuous Sneezing',
  'Cough',
  'Cramps',
  'Dark Urine',
  'Dehydration',
  'Depression',
  'Diarrhoea',
  'Dischromic Patches',
  'Distention Of Abdomen',
  'Dizziness',
  'Drying And Tingling Lips',
  'Enlarged Thyroid',
  'Excessive Hunger',
  'Extra Marital Contacts',
  'Family History',
  'Fast Heart Rate',
  'Fatigue',
  'Fluid Overload',
  'Foul Smell Of Urine',
  'Headache',
  'High Fever',
  'Hip Joint Pain',
  'History Of Alcohol Consumption',
  'Increased Appetite',
  'Indigestion',
  'Inflammatory Nails',
  'Internal Itching',
  'Irregular Sugar Level',
  'Irritability',
  'Irritation In Anus',
  'Itching',
  'Joint Pain',
  'Knee Pain',
  'Lack Of Concentration',
  'Lethargy',
  'Loss Of Appetite',
  'Loss Of Balance',
  'Loss Of Smell',
  'Malaise',
  'Mild Fever',
  'Mood Swings',
  'Movement Stiffness',
  'Mucoid Sputum',
  'Muscle Pain',
  'Muscle Wasting',
  'Muscle Weakness',
  'Nausea',
  'Neck Pain',
  'No Symptom',
  'Nodal Skin Eruptions',
  'Obesity',
  'Pain Behind The Eyes',
  'Pain During Bowel Movements',
  'Pain In Anal Region',
  'Painful Walking',
  'Palpitations',
  'Passage Of Gases',
  'Patches In Throat',
  'Phlegm',
  'Polyuria',
  'Prominent Veins On Calf',
  'Puffy Face And Eyes',
  'Pus Filled Pimples',
  'Receiving Blood Transfusion',
  'Receiving Unsterile Injections',
  'Red Sore Around Nose',
  'Red Spots Over Body',
  'Redness Of Eyes',
  'Restlessness',
  'Runny Nose',
  'Rusty Sputum',
  'Scurring',
  'Shivering',
  'Silver Like Dusting',
  'Sinus Pressure',
  'Skin Peeling',
  'Skin Rash',
  'Slurred Speech',
  'Small Dents In Nails',
  'Spinning Movements',
  'Spotting Urination',
  'Stiff Neck',
  'Stomach Bleeding',
  'Stomach Pain',
  'Sunken Eyes',
  'Sweating',
  'Swelled Lymph Nodes',
  'Swelling Joints',
  'Swelling Of Stomach',
  'Swollen Blood Vessels',
  'Swollen Extremeties',
  'Swollen Legs',
  'Throat Irritation',
  'Toxic Look (Typhos)',
  'Ulcers On Tongue',
  'Unsteadiness',
  'Visual Disturbances',
  'Vomiting',
  'Watering From Eyes',
  'Weakness In Limbs',
  'Weakness Of One Body Side',
  'Weight Gain',
  'Weight Loss',
  'Yellow Crust Ooze',
  'Yellow Urine',
  'Yellowing Of Eyes',
  'Yellowish Skin',
  ];

  void predictDisease() async {
    if (selectedSymptoms.isEmpty) return;

    if (selectedSymptoms.length == symptoms.length) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/pictures/yang-benar.gif',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup')),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse("http://127.0.0.1:5000/predict");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({"symptoms": selectedSymptoms});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          predictedDisease = data["predicted_disease"];
          confidence = data["confidence"];
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal prediksi: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak bisa terhubung ke server: $e")),
      );
    }
  }



  void resetAll() {
    setState(() {
      selectedSymptoms.clear();
      predictedDisease = null;
      confidence = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.health_and_safety, color: Colors.green, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "AI Prediksi Penyakit",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Pilih gejala yang Anda rasakan dari daftar di bawah ini. "
                "AI akan membantu memprediksi kemungkinan penyakit Anda berdasarkan data yang ada.",
                style: TextStyle(color: Colors.black87, fontSize: 14),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 16),

              // Warning box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Peringatan : ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Aplikasi ini adalah purwarupa dan tidak menggantikan diagnosis medis profesional. "
                      "Selalu konsultasikan dengan dokter.",
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Gejala section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pilih gejala Anda:",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (selectedSymptoms.isNotEmpty ||
                      predictedDisease != null) ...[
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.redAccent),
                      tooltip: "Reset semua",
                      onPressed: resetAll,
                    ),
                  ]
                ],
              ),

              const SizedBox(height: 8),

              // Container dropdown + chips
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedSymptoms
                          .map(
                            (s) => Chip(
                              label: Text(
                                s,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              deleteIcon:
                                  const Icon(Icons.close, color: Colors.white),
                              onDeleted: () {
                                setState(() {
                                  selectedSymptoms.remove(s);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Custom picker that opens a searchable modal bottom sheet
                    InkWell(
                      onTap: () => _showSymptomsPicker(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Flexible(
                              child: Text(
                                "Tambah gejala...",
                                style: TextStyle(color: Colors.black54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.search, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text('Anda yakin ingin menambahkan semua gejala?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ya')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                setState(() {
                                  selectedSymptoms = List.from(symptoms);
                                });
                              }
                            },
                            child: const Text(
                              'Tambah semua gejala',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: ElevatedButton.icon(
                  onPressed: selectedSymptoms.isEmpty ? null : predictDisease,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text("Prediksi Penyakit Saya"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF79C171),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Hasil prediksi
              if (predictedDisease != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade400),
                  ),
                  child: Text(
                    "Prediksi Penyakit: $predictedDisease",
                    style: const TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade400),
                  ),
                  child: Text(
                    "Tingkat Keyakinan: ${confidence!.toStringAsFixed(2)}%",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 24),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                // Konsultasi warning + button to navigate to MapsPage and find nearest hospital
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Butuh konsultasi?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Jika gejala Anda dan hasil pemeriksaan menunjukkan kondisi yang serius harap segera konsultasikan dengan dokter dari rumah sakit terdekat.',
                        style: TextStyle(color: Colors.black87),
                        textAlign: TextAlign.justify,
                      ),
                        const SizedBox(height: 8),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to MapsPage and trigger nearest hospital search
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapsPage(findNearestOnOpen: true)));
                          },
                          icon: const Icon(Icons.local_hospital),
                          label: const Text('Cari RS Terdekat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),

              const Text(
                "Gejala yang Anda Pilih:",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),

              if (selectedSymptoms.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedSymptoms
                      .map((s) => Text("• $s",
                          style: const TextStyle(color: Colors.black87)))
                      .toList(),
                )
              else
                const Text(
                  "Belum ada gejala yang dipilih.",
                  style: TextStyle(color: Colors.black54),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Open a modal bottom sheet with searchable list of symptoms
  void _showSymptomsPicker(BuildContext context) {
    // Persist these while the modal is open so filtering doesn't reset on rebuild
    final available = symptoms.where((s) => !selectedSymptoms.contains(s)).toList();
    List<String> filtered = List.from(available);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: StatefulBuilder(builder: (context, setModalState) {
            void applyFilter(String q) {
              setModalState(() {
                filtered = available.where((s) => s.toLowerCase().contains(q.toLowerCase())).toList();
              });
            }

            final ScrollController listScrollCtrl = ScrollController();

            return Column(
              children: [
                // Drag handle and title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Tambah Gejala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Pilih satu atau lebih gejala', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari gejala...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: applyFilter,
                  ),
                ),

                const SizedBox(height: 8),

                // List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Tidak ada gejala sesuai pencarian'))
                      : ListView.separated(
                          controller: listScrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final s = filtered[i];
                            return ListTile(
                              title: Text(s),
                              leading: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                              onTap: () {
                                setState(() {
                                  selectedSymptoms.add(s);
                                });
                                // remove from modal list
                                setModalState(() {
                                  filtered.removeAt(i);
                                });
                              },
                            );
                          },
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Selesai'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

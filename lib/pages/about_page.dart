import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> teamMembers = [
      {
        "name": "Muhammad Jarez",
        "nim": "20230801198",
        "desc": "i lop kaoruko.",
        "image": "assets/pictures/moocchi.jpg",
        "isAsset": true,
        "followers": 312,
        "projects": 48,
      },
      {
        "name": "Muhammad Iqbal Al Kautsar",
        "nim": "20230801032",
        "desc": "Roblox",
        "image": "assets/pictures/blek.jpg",
        "isAsset": true,
        "followers": 210,
        "projects": 69,
      },
      {
        "name": "Bima Setya Ramadhan",
        "nim": "20230801175",
        "desc": "Labubuk",
        "image": "assets/pictures/bima.jpg",
        "isAsset": true,
        "followers": 150,
        "projects": 28,
      },
      {
        "name": "Farhan Fatahillah",
        "nim": "20230801045",
        "desc": "our komandan kita kami aku my General",
        "image": "assets/pictures/sodonk.jpg",
        "isAsset": true,
        "followers": 198,
        "projects": 40,
      },
      {
        "name": "Chandika Eka Prasetya",
        "nim": "2023081268",
        "desc": "Kink Sepedah bicycle",
        "image": "assets/pictures/dika.jpg",
        "isAsset": true,
        "followers": 120,
        "projects": 18,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: PageView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: member["isAsset"] == true
                            ? Image.asset(
                                member["image"],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                member["image"],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        member["name"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        member["nim"],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        member["desc"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people, size: 18),
                              const SizedBox(width: 4),
                              Text("${member["followers"]}"),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.work, size: 18),
                              const SizedBox(width: 4),
                              Text("${member["projects"]}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

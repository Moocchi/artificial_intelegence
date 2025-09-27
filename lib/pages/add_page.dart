import 'package:flutter/material.dart';

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Page"),
        backgroundColor: const Color(0xFF79C171),
      ),
      body: Center(
        child: Container(
          width: 200, // diameter lingkaran
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // bentuk lingkaran
            color: Colors.green[400], // background lingkaran
            border: Border.all(
              color: Colors.green.shade800, // warna border
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "Tambah",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // warna teks putih
              ),
            ),
          ),
        ),
      ),
    );
  }
}

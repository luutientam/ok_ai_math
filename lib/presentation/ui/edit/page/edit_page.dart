import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

import '../../solve/page/solve_page.dart';// SolvePage

class EditPage extends StatefulWidget {
  final String imagePath;

  const EditPage({super.key, required this.imagePath});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  void initState() {
    super.initState();
    _openEditor();
  }

  Future<void> _openEditor() async {
    // Đọc ảnh async
    final imageBytes = await File(widget.imagePath).readAsBytes();

    final editedImage = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditor(image: imageBytes),
      ),
    );

    if (!mounted) return;

    if (editedImage != null) {
      // Chuyển sang SolvePage ngay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SolvePage(imageBytes: editedImage),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

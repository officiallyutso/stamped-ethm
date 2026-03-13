import 'dart:io';
import 'package:flutter/material.dart';
import 'capture_metadata.dart';

abstract class ReportBlock {
  final String id;
  ReportBlock({required this.id});
}

class TextBlock extends ReportBlock {
  final TextEditingController controller;
  
  TextBlock({
    required String id,
    String initialText = '',
  })  : controller = TextEditingController(text: initialText),
        super(id: id);
}

class ImageBlock extends ReportBlock {
  final File file;
  final CaptureMetadata? metadata;
  final String base64Data;
  
  ImageBlock({
    required String id,
    required this.file,
    this.metadata,
    required this.base64Data,
  }) : super(id: id);
}

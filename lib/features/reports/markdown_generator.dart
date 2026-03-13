import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'models/capture_metadata.dart';
import 'models/report_block.dart';

class MarkdownGenerator {
  static final _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  static Future<String> generateFromBlocks(List<ReportBlock> blocks, {String? title}) async {
    final now = DateTime.now();
    StringBuffer sb = StringBuffer();
    sb.writeln('# ${title ?? "Field Inspection Report"}');
    sb.writeln('\n**Generated on:** ${_formatter.format(now)}');
    sb.writeln('\n---\n');

    for (var block in blocks) {
      if (block is TextBlock) {
        sb.writeln(block.controller.text);
        sb.writeln();
      } else if (block is ImageBlock) {
        sb.writeln('\n![photo](data:image/jpeg;base64,${block.base64Data})\n');
        _appendMetadataTable(sb, block.metadata);
        sb.writeln('\n---\n');
      }
    }
    return sb.toString();
  }

  /// Generates markdown suitable for sending to Fileverse.
  /// Base64 image data is replaced with a compact placeholder to avoid
  /// exceeding Cloudflare Worker memory limits (Error 1102).
  static Future<String> generateForFileverse(List<ReportBlock> blocks, {String? title}) async {
    final now = DateTime.now();
    StringBuffer sb = StringBuffer();
    sb.writeln('# ${title ?? "Field Inspection Report"}');
    sb.writeln('\n**Generated on:** ${_formatter.format(now)}');
    sb.writeln('\n---\n');

    int imageIndex = 1;
    for (var block in blocks) {
      if (block is TextBlock) {
        sb.writeln(block.controller.text);
        sb.writeln();
      } else if (block is ImageBlock) {
        sb.writeln('\n**[Evidence Photo $imageIndex]**\n');
        _appendMetadataTable(sb, block.metadata);
        sb.writeln('\n---\n');
        imageIndex++;
      }
    }
    return sb.toString();
  }

  static String generatePreviewMarkdown(List<ReportBlock> blocks, {String? title}) {
    final now = DateTime.now();
    StringBuffer sb = StringBuffer();
    sb.writeln('# ${title ?? "Field Inspection Report"}');
    sb.writeln('\n**Generated on:** ${_formatter.format(now)}');
    sb.writeln('\n---\n');

    for (var block in blocks) {
      if (block is TextBlock) {
        sb.writeln(block.controller.text);
        sb.writeln();
      } else if (block is ImageBlock) {
        // Use a special internal scheme for preview to avoid parsing huge strings
        sb.writeln('\n![photo](block-image://${block.id})\n');
        _appendMetadataTable(sb, block.metadata);
        sb.writeln('\n---\n');
      }
    }
    return sb.toString();
  }

  static void _appendMetadataTable(StringBuffer sb, CaptureMetadata? metadata) {
    sb.writeln('| Field | Value |');
    sb.writeln('|-------|-------|');
    
    if (metadata != null) {
      sb.writeln('| Capture ID | `${metadata.captureId}` |');
      sb.writeln('| Timestamp | ${_formatter.format(metadata.timestamp)} |');
      sb.writeln('| Image Hash | `${metadata.imageHash}` |');
      
      if (metadata.location != null) {
        final loc = metadata.location!;
        sb.writeln('| Latitude | ${loc['latitude']} |');
        sb.writeln('| Longitude | ${loc['longitude']} |');
        if (loc['address'] != null) {
          sb.writeln('| Address | ${loc['address']} |');
        }
      }
      
      if (metadata.cameraDirection != null) {
        sb.writeln('| Camera | ${metadata.cameraDirection} |');
      }
    } else {
      sb.writeln('| Status | Metadata not found in Firestore |');
    }
  }

  // Deprecated: keeping for compatibility during refactor if needed
  static Future<String> generateReport({
    required List<File> imageFiles,
    required Map<String, CaptureMetadata> metadataMap,
    String? title,
  }) async {
    // ... implementation remains the same or redirects to generateFromBlocks
    final blocks = <ReportBlock>[];
    for (var file in imageFiles) {
      final bytes = await file.readAsBytes();
      blocks.add(ImageBlock(
        id: file.path, 
        file: file, 
        base64Data: base64Encode(bytes),
        metadata: metadataMap[file.path],
      ));
      blocks.add(TextBlock(id: 'text_${file.path}', initialText: '> [Enter notes here]'));
    }
    return generateFromBlocks(blocks, title: title);
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ReportResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String? fileverseLink;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ReportResultScreen({
    super.key,
    required this.isSuccess,
    this.fileverseLink,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.black),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
              size: 80,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess ? "REPORT GENERATED" : "GENERATION FAILED",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess 
                  ? "Your report has been successfully stored on Fileverse and recorded in history."
                  : (errorMessage ?? "An unexpected error occurred while generating your report."),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (isSuccess && fileverseLink != null) ...[
              const SizedBox(height: 32),
              const Text(
                "FILEVERSE DOCUMENT LINK",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => launchUrl(Uri.parse(fileverseLink!)),
                child: Text(
                  fileverseLink!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Generated At: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(fileverseLink!)),
                icon: const Icon(LucideIcons.externalLink),
                label: const Text("View Report"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangle_circular(12),
                ),
              ),
            ],
            if (!isSuccess && onRetry != null) ...[
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onRetry!();
                },
                icon: const Icon(LucideIcons.rotateCcw),
                label: const Text("Retry Generation"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangle_circular(12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper for rounded rectangle with specific name if needed by Flutter version
  static RoundedRectangleBorder RoundedRectangle_circular(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}

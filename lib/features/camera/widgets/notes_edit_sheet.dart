import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';

class NotesEditSheet extends StatefulWidget {
  const NotesEditSheet({super.key});

  @override
  State<NotesEditSheet> createState() => _NotesEditSheetState();
}

class _NotesEditSheetState extends State<NotesEditSheet> {
  late TextEditingController _controller;
  
  final List<Color> _availableColors = [
    Colors.white,
    Colors.black,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.lightBlueAccent,
    Colors.purpleAccent,
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CameraProvider>(context, listen: false);
    _controller = TextEditingController(text: provider.overlayNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.check, color: Color(0xFFFB4128)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Text Field
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                maxLength: 120, // Limit lengths so it doesn't break UI
                onChanged: (text) => provider.setOverlayNotes(text),
                decoration: InputDecoration(
                  hintText: 'Type your custom note or reference here...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Color Picker
              const Text(
                'Text Color',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = provider.notesColor == color;
                    return GestureDetector(
                      onTap: () => provider.setNotesColor(color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: const Color(0xFFFB4128), width: 3) : Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: isSelected ? [
                            BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                          ] : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

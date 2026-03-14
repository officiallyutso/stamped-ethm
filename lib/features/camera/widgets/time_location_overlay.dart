import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/location/location_service.dart';
import 'package:stamped/features/camera/camera_provider.dart';

class TimeLocationOverlay extends StatefulWidget {
  final bool isCapturing;
  final double turns;
  
  const TimeLocationOverlay({super.key, this.isCapturing = false, this.turns = 0.0});

  @override
  State<TimeLocationOverlay> createState() => TimeLocationOverlayState();
}

class TimeLocationOverlayState extends State<TimeLocationOverlay> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  String _address = "Fetching location...";
  final LocationService _locationService = LocationService();

  // Drag and Scale state
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    fetchLocation();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> fetchLocation() async {
    if (mounted) {
      setState(() {
        _address = "Fetching location...";
      });
    }
    final address = await _locationService.getCurrentLocationAddress();
    if (mounted) {
      setState(() {
        _address = address;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeString = DateFormat('hh:mm').format(_currentTime);
    String amPmString = DateFormat('a').format(_currentTime).toLowerCase();
    String dateString = DateFormat('dd MMM yyyy').format(_currentTime);
    String dayString = DateFormat('E').format(_currentTime);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: _offset.dx,
      bottom: -_offset.dy + 20, // offset.dy increases as we drag down, so -dy pushes it up
      child: AnimatedRotation(
        turns: widget.turns,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onScaleStart: (details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_previousScale * details.scale).clamp(0.5, 2.5);
            _offset += details.focalPointDelta;
            
            // Constrain Bounds so the text doesn't disappear out of the viewfinder entirely
            final double boxWidth = screenWidth * 0.85 * _scale;
            final double boxHeight = 120 * _scale; // Approx height of text block
            
            final double minX = 0;
            double maxX = screenWidth - boxWidth;
            if (maxX < 0) maxX = 0;

            // _offset.dy increases when dragging DOWN, so we want to cap how far positive it goes.
            // When dragged DOWN, bottom edge goes towards 0. So maxDy is ~20 to reach bottom.
            double maxDy = 20.0;
            
            // _offset.dy decreases (negative) when dragging UP.
            // We want to limit how far negative it can go so it doesn't cross the top app bars.
            // screenHeight subtracted by boxHeight and some padding.
            double minDy = 20.0 - (screenHeight - boxHeight - 200);
            if (minDy > maxDy) minDy = maxDy;

            if (_offset.dx < minX) _offset = Offset(minX, _offset.dy); 
            if (_offset.dx > maxX) _offset = Offset(maxX, _offset.dy);
            
            if (_offset.dy > maxDy) _offset = Offset(_offset.dx, maxDy); 
            if (_offset.dy < minDy) _offset = Offset(_offset.dx, minDy); 
          });
        },
        child: Transform.scale(
          scale: _scale,
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.transparent, // to catch gestures across whole bound
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: screenWidth * 0.85, // bound width so it doesn't take full screen when scaled/dragged
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        height: 1.0,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        amPmString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 44,
                      width: 2,
                      color: Colors.orange.shade300,
                      margin: const EdgeInsets.only(bottom: 4, right: 8),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                            ),
                          ),
                          Text(
                            dayString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                Consumer<CameraProvider>(
                  builder: (context, provider, child) {
                    if (provider.overlayNotes.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Text(
                          provider.overlayNotes,
                          style: TextStyle(
                            color: provider.notesColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}


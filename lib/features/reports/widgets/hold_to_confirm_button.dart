import 'package:flutter/material.dart';

class HoldToConfirmButton extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;
  final Duration duration;
  final Color color;

  const HoldToConfirmButton({
    super.key,
    required this.text,
    required this.onConfirmed,
    this.duration = const Duration(seconds: 2),
    this.color = Colors.blue,
  });

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onConfirmed();
        _controller.reset();
        setState(() => _isHolding = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isHolding = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
    setState(() => _isHolding = false);
  }

  void _onTapCancel() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isHolding ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Progress Fill
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _controller.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              // Button Content
              Center(
                child: Text(
                  _isHolding ? "HOLD TO GENERATE..." : widget.text,
                  style: TextStyle(
                    color: _isHolding ? Colors.white : widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

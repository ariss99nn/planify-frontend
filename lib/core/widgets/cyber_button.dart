import 'package:flutter/material.dart';

class CyberButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final double height;

  const CyberButton({
    super.key,
    required this.label,
    this.loading = false,
    this.onPressed,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(label),
      ),
    );
  }
}
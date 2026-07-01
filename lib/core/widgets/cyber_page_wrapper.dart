import 'package:flutter/material.dart';

class CyberPageWrapper extends StatefulWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const CyberPageWrapper({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  });

  @override
  State<CyberPageWrapper> createState() => _CyberPageWrapperState();
}

class _CyberPageWrapperState extends State<CyberPageWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: widget.padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
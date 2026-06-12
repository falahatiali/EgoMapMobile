import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';

class ScanPreviewCards extends StatefulWidget {
  const ScanPreviewCards({super.key});

  @override
  State<ScanPreviewCards> createState() => _ScanPreviewCardsState();
}

class _ScanPreviewCardsState extends State<ScanPreviewCards> {
  static const _cards = [
    _PreviewCardData(icon: '📍', title: 'Where you are right now'),
    _PreviewCardData(icon: '⚠️', title: 'Risk you face tonight'),
    _PreviewCardData(icon: '🎯', title: 'First need'),
  ];

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_cards.length, (index) {
        final card = _cards[index];
        final delay = index * 120;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 6, right: index == 2 ? 0 : 6),
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, 0.12),
                duration: Duration(milliseconds: 500 + delay),
                curve: Curves.easeOutCubic,
                child: _PreviewCard(data: card),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PreviewCardData {
  const _PreviewCardData({required this.icon, required this.title});

  final String icon;
  final String title;
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.data});

  final _PreviewCardData data;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EgColors.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.icon, style: const TextStyle(fontSize: 22, height: 1.1)),
            const SizedBox(height: 10),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: EgFonts.style(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: EgColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

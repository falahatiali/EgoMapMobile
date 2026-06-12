import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';

class HeroTypedLine extends StatefulWidget {
  const HeroTypedLine({
    super.key,
    required this.prefix,
    required this.words,
  });

  final String prefix;
  final List<String> words;

  @override
  State<HeroTypedLine> createState() => _HeroTypedLineState();
}

class _HeroTypedLineState extends State<HeroTypedLine> {
  int _index = 0;
  bool _cursorVisible = true;
  Timer? _wordTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    if (widget.words.isEmpty) {
      return;
    }

    _wordTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (mounted) {
        setState(() => _index = (_index + 1) % widget.words.length);
      }
    });

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) {
        setState(() => _cursorVisible = !_cursorVisible);
      }
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.words.isEmpty ? '' : widget.words[_index];

    return SizedBox(
      height: 32,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: Text.rich(
          key: ValueKey(word),
          textAlign: TextAlign.center,
          TextSpan(
            style: EgFonts.style(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: EgColors.textPrimary,
            ),
            children: [
              TextSpan(text: '${widget.prefix} '),
              TextSpan(
                text: word,
                style: const TextStyle(
                  color: Color(0xFF60A5FA),
                  fontWeight: FontWeight.w600,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: AnimatedOpacity(
                  opacity: _cursorVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 2,
                    height: 18,
                    margin: const EdgeInsets.only(left: 2),
                    color: const Color(0xFF60A5FA),
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

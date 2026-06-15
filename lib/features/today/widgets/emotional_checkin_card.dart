import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';

const List<_Mood> _kMoods = [
  _Mood(emoji: '😤', label: 'Angry', message: 'That energy is fuel. Channel it into action.'),
  _Mood(emoji: '💪', label: 'Strong', message: "You're in the zone. Stay here."),
  _Mood(emoji: '😌', label: 'Calm', message: 'Peace is power. Use this clarity well.'),
  _Mood(emoji: '😢', label: 'Low', message: "It's okay to feel this. Tomorrow you rebuild."),
  _Mood(emoji: '🔥', label: 'Fired up', message: 'That fire? Keep it burning. Now move.'),
];

class EmotionalCheckinCard extends StatefulWidget {
  const EmotionalCheckinCard({super.key});

  @override
  State<EmotionalCheckinCard> createState() => _EmotionalCheckinCardState();
}

class _EmotionalCheckinCardState extends State<EmotionalCheckinCard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EgSpacing.lg),
      decoration: BoxDecoration(
        color: EgColors.navy900.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        border: Border.all(color: EgColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW DO YOU FEEL NOW?',
            style: EgFonts.style(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: EgColors.slate500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _kMoods.length,
              (i) => _MoodButton(
                mood: _kMoods[i],
                selected: _selected == i,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selected = i);
                },
              ),
            ),
          ),
          if (_selected != null) ...[
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Container(
                key: ValueKey(_selected),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: EgColors.success.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EgColors.success.withValues(alpha: 0.18)),
                ),
                child: Text(
                  _kMoods[_selected!].message,
                  style: EgFonts.style(fontSize: 14, height: 1.55),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final _Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? EgColors.success.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? EgColors.success.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 5),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: EgFonts.style(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? EgColors.textPrimary : EgColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mood {
  const _Mood({
    required this.emoji,
    required this.label,
    required this.message,
  });

  final String emoji;
  final String label;
  final String message;
}

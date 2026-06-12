import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/bootstrap_models.dart';

class StepOneCard extends StatelessWidget {
  const StepOneCard({
    super.key,
    required this.step,
    required this.note,
    required this.onTap,
  });

  final StepItem step;
  final String note;
  final VoidCallback onTap;

  static const _previewItems = [
    'Where you are emotionally right now',
    'What you are most afraid of',
    'What you need first',
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x406366F1)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF151B2E),
                Color(0xFF111827),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x266366F1),
                blurRadius: 32,
                offset: Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1F6366F1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x336366F1)),
                ),
                child: Text(
                  'STEP 1 · START HERE',
                  style: EgFonts.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: EgColors.accentBright,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                step.title,
                style: EgFonts.style(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.4,
                  color: EgColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                step.description,
                style: EgFonts.style(
                  fontSize: 15,
                  height: 1.6,
                  color: EgColors.slate400,
                ),
              ),
              const SizedBox(height: 22),
              ...List.generate(_previewItems.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x146366F1),
                          border: Border.all(color: const Color(0x266366F1)),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: EgFonts.style(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: EgColors.accentBright,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _previewItems[index],
                            style: EgFonts.style(
                              fontSize: 14,
                              height: 1.45,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: EgColors.slate500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: EgFonts.style(fontSize: 13, height: 1.4, color: EgColors.slate500),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: EgColors.accentBright),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

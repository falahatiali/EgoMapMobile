import 'eg_surface.dart';

/// Thin alias — no blur, no glass. Kept for existing imports.
class EgGlassCard extends EgSurface {
  const EgGlassCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.radius,
  });
}

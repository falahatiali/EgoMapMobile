class AetherWizardCopy {
  const AetherWizardCopy._();

  static String kicker(String stepKey) => switch (stepKey) {
        'gender' => 'About you',
        'age' => 'About you',
        'height' => 'Body metrics',
        'weight' => 'Body metrics',
        'current_body' => 'Body shape',
        'target_body' => 'Body goal',
        'goal' => 'Training goal',
        'gym_confidence' => 'Experience',
        'days' => 'Schedule',
        'session' => 'Schedule',
        'equipment' => 'Gear',
        'injuries' => 'Safety',
        'style' => 'Training vibe',
        'motivation' => 'Mindset',
        'review' => 'Final check',
        _ => 'AetherEngine',
      };

  static String title(String stepKey) => switch (stepKey) {
        'gender' => 'Which best describes you?',
        'age' => 'How old are you?',
        'height' => "What's your height?",
        'weight' => "What's your current weight?",
        'current_body' => 'How do you see your body right now?',
        'target_body' => 'What body do you want to build toward?',
        'goal' => "What's your primary training goal?",
        'gym_confidence' => 'How confident are you in the gym?',
        'days' => 'How many days can you train each week?',
        'session' => 'How long can each session be?',
        'equipment' => 'What equipment do you have access to?',
        'injuries' => 'Any injuries or limitations?',
        'style' => 'What kind of training do you enjoy most?',
        'motivation' => 'What keeps you showing up?',
        'review' => 'Ready to build your plan?',
        _ => 'Calibrate AetherEngine',
      };

  static String? help(String stepKey) => switch (stepKey) {
        'current_body' => 'No judgment — pick the silhouette that feels closest to you today.',
        'target_body' => "We'll shape volume and progression around this vision.",
        'injuries' => "We'll avoid movements that aggravate these areas.",
        _ => null,
      };

  static const genders = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('other', 'Other'),
  ];

  static const ageRanges = [
    ('18_29', '18–29'),
    ('30_39', '30–39'),
    ('40_49', '40–49'),
    ('50_plus', '50+'),
  ];

  static const bodyBuilds = [
    ('slender', 'Slender'),
    ('average', 'Average build'),
    ('stocky', 'Stocky'),
    ('heavy', 'Heavy'),
  ];

  static const bodyGoals = [
    ('lean', 'Lean & toned'),
    ('athletic', 'Athletic'),
    ('defined', 'Defined & ripped'),
    ('muscular', 'Muscular & strong'),
  ];

  static const goals = [
    ('fat_loss', 'Fat loss'),
    ('muscle_gain', 'Muscle gain'),
    ('recomposition', 'Recomposition'),
    ('strength', 'Strength'),
    ('endurance', 'Endurance'),
    ('aesthetics', 'Aesthetics'),
    ('health', 'Health'),
  ];

  static const gymConfidence = [
    ('never_been', "I've never been to a gym"),
    ('lost_unsure', 'I feel lost and unsure of what to do'),
    ('basics_unsure', "I know the basics but not sure if I'm doing it right"),
    ('comfortable_guidance', "I'm comfortable but want more guidance"),
    ('confident_plan', 'I feel confident and just need a structured plan'),
  ];

  static const sessions = [
    ('10_20', '10–20 min'),
    ('20_30', '20–30 min'),
    ('30_45', '30–45 min'),
    ('45_60', '45–60 min'),
    ('60_plus', '60+ min'),
  ];

  static const equipment = [
    ('full_gym', 'Full gym'),
    ('home_gym', 'Home gym'),
    ('resistance_bands', 'Resistance bands'),
    ('bodyweight_only', 'Bodyweight only'),
    ('outdoor', 'Outdoor'),
  ];

  static const styles = [
    ('heavy_weights', 'Heavy weights'),
    ('hiit', 'HIIT circuits'),
    ('yoga_stretch', 'Yoga & mobility'),
    ('cardio', 'Cardio focus'),
  ];

  static const motivation = [
    ('data_tracking', 'Data tracking'),
    ('aesthetics', 'Aesthetics'),
    ('feeling_strong', 'Feeling strong'),
    ('competition', 'Competition'),
    ('community', 'Community'),
  ];

  static const injuries = [
    ('knee', 'Knee pain'),
    ('lower_back', 'Lower back'),
    ('shoulder', 'Shoulder pain'),
    ('none', 'None'),
  ];

  static int ageFromRange(String range) => switch (range) {
        '18_29' => 25,
        '30_39' => 35,
        '40_49' => 45,
        '50_plus' => 55,
        _ => 28,
      };

  static String trainingExperienceFromConfidence(String value) => switch (value) {
        'never_been' || 'lost_unsure' || 'basics_unsure' => 'beginner',
        'comfortable_guidance' => 'intermediate',
        'confident_plan' => 'advanced',
        _ => 'intermediate',
      };
}

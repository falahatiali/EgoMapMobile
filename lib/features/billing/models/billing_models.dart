class BillingCatalog {
  const BillingCatalog({
    required this.subscription,
    required this.plans,
    required this.features,
    required this.labels,
    this.yearlySavingsPercent,
    this.proDescription,
  });

  factory BillingCatalog.fromJson(Map<String, dynamic> json) {
    return BillingCatalog(
      subscription: BillingSubscription.fromJson(
        json['subscription'] as Map<String, dynamic>? ?? const {},
      ),
      plans: (json['plans'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BillingPlan.fromJson)
          .toList(),
      yearlySavingsPercent: json['yearly_savings_percent'] as int?,
      proDescription: json['pro_description'] as String?,
      features: BillingFeatures.fromJson(
        json['features'] as Map<String, dynamic>? ?? const {},
      ),
      labels: BillingLabels.fromJson(
        json['labels'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final BillingSubscription subscription;
  final List<BillingPlan> plans;
  final int? yearlySavingsPercent;
  final String? proDescription;
  final BillingFeatures features;
  final BillingLabels labels;
}

class BillingSubscription {
  const BillingSubscription({
    required this.active,
    required this.isPro,
    required this.hasIncompletePayment,
    this.currentPlan,
  });

  factory BillingSubscription.fromJson(Map<String, dynamic> json) {
    return BillingSubscription(
      active: json['active'] == true,
      isPro: json['is_pro'] == true,
      hasIncompletePayment: json['has_incomplete_payment'] == true,
      currentPlan: json['current_plan'] is Map<String, dynamic>
          ? BillingPlan.fromJson(json['current_plan'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool active;
  final bool isPro;
  final bool hasIncompletePayment;
  final BillingPlan? currentPlan;
}

class BillingPlan {
  const BillingPlan({
    required this.id,
    required this.billingPeriod,
    required this.name,
    required this.price,
    required this.cadenceLabel,
    required this.relation,
    required this.ctaLabel,
    required this.selectable,
    this.description,
    this.badge,
    this.savingsPercent,
    this.savingsLabel,
  });

  factory BillingPlan.fromJson(Map<String, dynamic> json) {
    return BillingPlan(
      id: json['id'] as int,
      billingPeriod: json['billing_period'] as String? ?? 'other',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: BillingPrice.fromJson(json['price'] as Map<String, dynamic>? ?? const {}),
      cadenceLabel: json['cadence_label'] as String? ?? '',
      relation: json['relation'] as String?,
      badge: json['badge'] as String?,
      savingsPercent: json['savings_percent'] as int?,
      savingsLabel: json['savings_label'] as String?,
      ctaLabel: json['cta_label'] as String? ?? 'Get Pro',
      selectable: json['selectable'] != false,
    );
  }

  final int id;
  final String billingPeriod;
  final String name;
  final String? description;
  final BillingPrice price;
  final String cadenceLabel;
  final String? relation;
  final String? badge;
  final int? savingsPercent;
  final String? savingsLabel;
  final String ctaLabel;
  final bool selectable;

  bool get isCurrent => relation == 'current';
  bool get isUpgrade => relation == 'upgrade';
  bool get isDowngrade => relation == 'downgrade';
}

class BillingPrice {
  const BillingPrice({
    this.formatted,
    this.unitAmount,
    this.currency,
  });

  factory BillingPrice.fromJson(Map<String, dynamic> json) {
    return BillingPrice(
      formatted: json['formatted'] as String?,
      unitAmount: json['unit_amount'] as int?,
      currency: json['currency'] as String?,
    );
  }

  final String? formatted;
  final int? unitAmount;
  final String? currency;
}

class BillingFeatures {
  const BillingFeatures({
    required this.free,
    required this.pro,
  });

  factory BillingFeatures.fromJson(Map<String, dynamic> json) {
    return BillingFeatures(
      free: _stringList(json['free']),
      pro: _stringList(json['pro']),
    );
  }

  final List<String> free;
  final List<String> pro;
}

class BillingLabels {
  const BillingLabels({
    required this.pageTitle,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.freeTitle,
    required this.freePrice,
    required this.freeInterval,
    required this.proTitle,
    required this.alreadyPro,
    required this.alreadySubscribed,
    required this.compareTitle,
    required this.compareSubtitle,
    required this.emptyPlans,
    required this.secureCheckout,
    required this.checkoutCancelled,
    required this.currentPlanBadge,
    required this.popularBadge,
    required this.bestValueBadge,
    required this.returnToAppHint,
    this.activePlan,
  });

  factory BillingLabels.fromJson(Map<String, dynamic> json) {
    return BillingLabels(
      pageTitle: json['page_title'] as String? ?? 'Pricing',
      heroTitle: json['hero_title'] as String? ?? '',
      heroSubtitle: json['hero_subtitle'] as String? ?? '',
      freeTitle: json['free_title'] as String? ?? 'Free',
      freePrice: json['free_price'] as String? ?? '\$0',
      freeInterval: json['free_interval'] as String? ?? '',
      proTitle: json['pro_title'] as String? ?? 'Pro',
      alreadyPro: json['already_pro'] as String? ?? '',
      alreadySubscribed: json['already_subscribed'] as String? ?? '',
      activePlan: json['active_plan'] as String?,
      compareTitle: json['compare_title'] as String? ?? '',
      compareSubtitle: json['compare_subtitle'] as String? ?? '',
      emptyPlans: json['empty_plans'] as String? ?? '',
      secureCheckout: json['secure_checkout'] as String? ?? '',
      checkoutCancelled: json['checkout_cancelled'] as String? ?? '',
      currentPlanBadge: json['current_plan_badge'] as String? ?? '',
      popularBadge: json['popular_badge'] as String? ?? '',
      bestValueBadge: json['best_value_badge'] as String? ?? '',
      returnToAppHint: json['return_to_app_hint'] as String? ?? '',
    );
  }

  final String pageTitle;
  final String heroTitle;
  final String heroSubtitle;
  final String freeTitle;
  final String freePrice;
  final String freeInterval;
  final String proTitle;
  final String alreadyPro;
  final String alreadySubscribed;
  final String? activePlan;
  final String compareTitle;
  final String compareSubtitle;
  final String emptyPlans;
  final String secureCheckout;
  final String checkoutCancelled;
  final String currentPlanBadge;
  final String popularBadge;
  final String bestValueBadge;
  final String returnToAppHint;
}

class BillingCheckoutResult {
  const BillingCheckoutResult({
    required this.outcome,
    this.checkoutUrl,
    this.message,
    this.title,
    this.body,
  });

  factory BillingCheckoutResult.fromJson(Map<String, dynamic> json) {
    final labels = _readStringMap(json['labels']);

    return BillingCheckoutResult(
      outcome: json['outcome'] as String? ?? 'error',
      checkoutUrl: json['checkout_url'] as String?,
      message: json['message'] as String?,
      title: labels['title'] as String?,
      body: labels['body'] as String?,
    );
  }

  final String outcome;
  final String? checkoutUrl;
  final String? message;
  final String? title;
  final String? body;

  bool get isRedirect => outcome == 'redirect';
  bool get isChanged => outcome == 'changed';
  bool get isCurrent => outcome == 'current';
  bool get isError => outcome == 'error';
}

List<String> _stringList(dynamic value) {
  if (value is! List<dynamic>) {
    return const [];
  }

  return value.whereType<String>().toList();
}

Map<String, dynamic> _readStringMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const {};
}

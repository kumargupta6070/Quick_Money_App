import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animation trigger notifier for Home Screen.
/// Increments whenever the user returns to or taps the Home tab,
/// forcing all child widgets, items, and text to re-trigger their entrance animations.
class HomeAnimationTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final homeAnimationTriggerProvider =
    NotifierProvider<HomeAnimationTriggerNotifier, int>(() {
  return HomeAnimationTriggerNotifier();
});

/// Animation trigger notifier for Buy RP Screen.
/// Increments whenever the user returns to or taps the Buy RP tab,
/// forcing all child widgets, level tabs, and order cards to re-trigger their entrance animations.
class BuyRpAnimationTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final buyRpAnimationTriggerProvider =
    NotifierProvider<BuyRpAnimationTriggerNotifier, int>(() {
  return BuyRpAnimationTriggerNotifier();
});

/// Animation trigger notifier for Sell RP Screen.
/// Increments whenever the user returns to or taps the Sell RP tab,
/// forcing all child widgets, wallet cards, tutorials, and actions to re-trigger their entrance animations.
class SellRpAnimationTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final sellRpAnimationTriggerProvider =
    NotifierProvider<SellRpAnimationTriggerNotifier, int>(() {
  return SellRpAnimationTriggerNotifier();
});

/// Animation trigger notifier for Mine (Profile) Screen.
/// Increments whenever the user returns to or taps the Mine tab,
/// forcing all child widgets, balance cards, team banner, and menu items to re-trigger their entrance animations.
class MineAnimationTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final mineAnimationTriggerProvider =
    NotifierProvider<MineAnimationTriggerNotifier, int>(() {
  return MineAnimationTriggerNotifier();
});


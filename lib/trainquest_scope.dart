import 'package:flutter/widgets.dart';

import 'app_controller.dart';

class TrainQuestScope extends InheritedNotifier<AppController> {
  const TrainQuestScope({
    super.key,
    required AppController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AppController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<TrainQuestScope>();
    assert(scope != null, 'TrainQuestScope not found in widget tree.');
    return scope!.notifier!;
  }
}

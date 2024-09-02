import 'package:journal_app/controllers/notification_service.dart';
import 'package:workmanager/workmanager.dart';

void registerNotificationTask(
  int id,
  String title,
  String body,
  DateTime scheduledDate,
) {
  Workmanager().registerOneOffTask(
    'notification_task_$id',
    'notification_task',
    initialDelay: scheduledDate.difference(DateTime.now()),
    inputData: {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    },
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationService = NotificationService();
    await notificationService.init();

    if (inputData != null) {
      final title = inputData['title'] as String?;
      final body = inputData['body'] as String?;

      if (title != null && body != null) {
        await notificationService.showNotification(
          title,
          body,
        );
      }
    }

    return Future.value(true);
  });
}

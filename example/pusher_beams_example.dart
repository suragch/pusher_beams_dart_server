import 'package:pusher_beams_server/push_notifications.dart';

main() async {
  // constructor
  final beamsClient = PushNotifications(
    'your_instance_id_here',
    'your_secret_key_here',
  );

  // push notification for interests on Android
  final interests = ['pears', 'apples'];
  final fcm = {
    'notification': {
      'title': 'Hello',
      'body': 'Hello, world!',
    }
  };
  final response = await beamsClient.publishToInterests(interests, fcm: fcm);

  // push notification for users on Apple device
  final users = ["user-001", "user-002"];
  final apns = {
    'aps': {
      'alert': {
        'title': 'Hello',
        'body': 'Hello, world!',
      }
    }
  };
  final response2 = await beamsClient.publishToUsers(users, apns: apns);
}

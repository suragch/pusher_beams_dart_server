import 'package:pusher_beams/pusher_beams.dart';
import 'package:test/test.dart';

void main() {
  PushNotifications beamsClient;

  const instanceId = '9aa32e04-a212-44ab-a592-9aeba66e46ac';
  const secretKey =
      '188C879D394E09FDECC04606A126FAE2125FEABD24A2D12C6AC969AE1CEE2AEC';
  const List<String> validInterests = ['pears', 'apples'];
  final validApns = {
    'aps': {
      'alert': 'Hello!',
    }
  };

  setUp(() {
    beamsClient = PushNotifications(instanceId, secretKey);
  });

  // Constructor
  group('Constructor:', () {
    test('Empty instanceId argument throws error', () {
      expect(() {
        PushNotifications(null, secretKey);
      }, throwsArgumentError);
      expect(() {
        PushNotifications('', secretKey);
      }, throwsArgumentError);
    });

    test('Empty secretKey argument throws error', () {
      expect(() {
        PushNotifications(instanceId, null);
      }, throwsArgumentError);
      expect(() {
        PushNotifications(instanceId, '');
      }, throwsArgumentError);
    });
  });

  // Publish to interests
  group('publishToInterests:', () {
    test('Empty interests argument throws error', () {
      expect(() async {
        await beamsClient.publishToInterests(null, apns: validApns);
      }, throwsArgumentError);
      expect(() async {
        await beamsClient.publishToInterests([], apns: validApns);
      }, throwsArgumentError);
    });

    test('too many interests throws error', () {
      final bigList = List.generate(200, (int index) => index.toString());
      expect(() async {
        await beamsClient.publishToInterests(bigList, apns: validApns);
      }, throwsArgumentError);
    });

    test('interest names longer than 164 characters throws error', () {
      final longName = List.filled(200, 'a').join();
      expect(() async {
        await beamsClient.publishToInterests([longName], apns: validApns);
      }, throwsArgumentError);
    });

    test('interest name with invalid character throws error', () {
      expect(() async {
        await beamsClient.publishToInterests(['hello*'], apns: validApns);
      }, throwsArgumentError);
    });

    test('Empty apns and fcm arguments throws error', () {
      expect(() async {
        await beamsClient.publishToInterests(validInterests,
            apns: null, fcm: null);
      }, throwsArgumentError);
      expect(() async {
        await beamsClient.publishToInterests(validInterests, apns: {}, fcm: {});
      }, throwsArgumentError);
    });

    test('publishRequest without an apns or fcm payload throws error', () {
      expect(() async {
        await beamsClient.publishToInterests(validInterests);
      }, throwsArgumentError);
    });

    test('valid publish request returns a 200 response', () async {
      var response = await beamsClient.publishToInterests(
        validInterests,
        apns: validApns,
      );
      expect(response, isNotNull);
      expect(response.statusCode, 200);
    });

  });
}

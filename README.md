# Pusher Beams Dart server SDK

## Installation

The Beams Dart Server SDK is available on Pub.

Add the dependency to your `pubspec.yaml` file:

```
dependencies:
  pusher_beams_server: ^0.1.4
```

Depend on it:

```
import 'package:pusher_beams_server/pusher_beams_server.dart';
```

## Configuring the SDK for your instance

You can create a new Pusher Beams Client connected to your Beams instance by providing your instance ID and secret key, which you can get from the dashboard.

```
PushNotifications(String instanceId, String secretKey)
```

**Arguments**

- `instanceId`: The unique identifier for your Push notifications instance. This can be found in the dashboard under "Credentials".
- `secretKey`: The secret key your server will use to access your Beams instance. This can be found in the dashboard under "Credentials".

**Example**

```
final beamsClient = PushNotifications(
  'your_instance_id_here',
  'your_secret_key_here',
);
```

## Publishing a notification

Once you have an instance you can publish notifications to registered users who have subscribed to one or more interests. You must choose at least one of [apns] (Apple) or [fcm] (Google) as the payload for the push notification. Setting both is fine.

```
Future<Response> publishToInterests(
      List<String> interests,
      {Map<String, dynamic> apns,
      Map<String, dynamic> fcm,
      String webhookUrl})
```

**Arguments**

- `interests`: List of interests to send the push notification to, ranging from 1 to 100 per publish request. No interest name can be longer that 164 characters.
- `apns`: Map containing the body of the [apns] (Apple) push notification publish request.
- `fcm`:  Map containing the body of the [fcm] (Google) push notification publish request.
- `webhookUrl`: Optional parameter if you want to receive webhooks at key points throughout the publishing process.

**Example**

```

final interests = ['pears', 'apples'];
final apns = {
  'aps': {
    'alert': {
      'title': 'Hello',
      'body': 'Hello, world!',
    }
  }
};
final fcm = {
  'notification': {
    'title': 'Hello',
    'body': 'Hello, world!',
  }
};

final response = await beamsClient.publishToInterests(interests, apns: apns, fcm: fcm);

print(response.body);
```

## Publish to users

You can also publish private notifications to authenticated users. You need to choose at least of [apns] (Apple) or [fcm] (Google) as the payload for the push notification. Setting both is fine.

```
Future<Response> publishToUsers(
    List<String> users,
    {Map<String, dynamic> apns, 
    Map<String, dynamic> fcm})
```

**Arguments**

- `users`: List of user IDs. There must be at least 1 and no more than 1000 user IDs in [users] per publish request. The user ID cannot be longer than 164 bytes and is encoded in UTF-8.
- `apns`: Map containing the body of the [apns] (Apple) push notification publish request.
- `fcm`:  Map containing the body of the [fcm] (Google) push notification publish request.

**Example**

```
final users = ["user-001", "user-002"];
final apns = {
  'aps': {
    'alert': {
      'title': 'Hello',
      'body': 'Hello, world!',
    }
  }
};
final fcm = {
  'notification': {
    'title': 'Hello',
    'body': 'Hello, world!',
  }
};

final response = await beamsClient.publishToUsers(users, apns: apns, fcm: fcm);

print(response['publishId']);
```

## Delete user

You can delete a user from Pusher Beams using their user ID. The user will no longer receive notifications, and saved state about them will be removed.

```
Future<Response> deleteUser(String userId)
```

**Arguments**

- `userId`: ID of the user to delete from Pusher Beams.

**Example**

```
final result = await beamsClient.deleteUser('user-001');
print(result.body); // will only have body content if there is an error.
```

## Generate token

You can generate a Beams auth token for an authenticated user. The returned token is valid for 24 hours. Give this token to the client, who can use it to associate their device with their Beams user ID.

```
String generateToken(String userId)
```

**Arguments**

- `userId`: ID of the already authenticated user to generate the token for.

**Return**

- `String`: This method returns the token as a raw String, but when sending the token to the user you should put it in a JSON string with a key name of `token`. (This is what the `BeamsTokenProvider` expects on the client side.)

**Example**

```
final token = beamsClient.generateToken('user-001');
return Response.ok({'token':token});
```
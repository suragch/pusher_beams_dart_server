# Dart server SDK

## Installation

The Beams Dart Server SDK is available on Pub [here](TODO).

Add the dependency to your `pubspec.yaml` file:

```
dependencies:
  pusher_beams: ^0.1.0
```

Depend on it:

```
import 'package:pusher_beams/pusher_beams.dart';
```

## Usage

### Configuring the SDK for your instance

You can create a `PushNotifications` instance by providing your instance ID and secret key, which you can get from the dashboard.

```
final beamsClient = PushNotifications(
  instanceId: 'your_instance_id_here',
  secretKey: 'your_secret_key_here',
);
```

### Publishing a notification

Once you have an instance you can publish notifications to registered and subscribed users.

```
// arguments
Set<String> interests = {'pears', 'apples'};
final publishRequest = {
  'apns': {
    'aps': {
      'alert': 'Hello!',
    }
  },
  'fcm': {
    'notification': {
      'title': 'Hello',
      'body': 'Hello, world!',
    }
  }
};

// publish
final response = await beamsClient.publishToInterests(interests, publishRequest);

print(response['publishId']);
```

### Publish to users

You can also publish private messages to authenticated users.

```
final users = ["user-001", "user-002"];
final publishRequest = {
  apns: {
    aps: {
      alert: 'Hello!'
    }
  },
  fcm: {
    notification: {
      title: 'Hello',
      body: 'Hello, world!'
    }
  }
};

final response = await beamsClient.publishToUsers(users, publishRequest);

print(response['publishId']);
```

### Generate token

```
final token = await beamsClient.generateToken('bob');
```

### Delete user

```
final result = await beamsClient.deleteUser('user-001');
print(result['user deleted']);
```

## Reference

### class PushNotifications

```
PushNotifications(String instanceId, String secretKey)
```

Construct a new Pusher Beams Client connected to your Beams instance.

**Arguments**

- `instanceId` (String): The unique identifier for your Push notifications instance. This can be found in the dashboard under "Credentials".
- `secretKey` (String): The secret key your server will use to access your Beams instance. This can be found in the dashboard under "Credentials".

### publishToInterests(interests, publishRequest)

Publish a new push notification to Pusher Beams with the given payload.

**Arguments**

- `interests`: List of interests to send the push notification to, ranging from 1 to 100 per publish request. See Interests.
- `publishRequest`: Map containing the body of the push notification publish request. See publish API reference.

**Returns**

String that contains `publish_id`: See [publish API reference](https://pusher.com/docs/beams/reference/publish-api#success-response-body)

### publishToUsers(users, publishRequest)

Publish the given `publishRequest` to specified users.

**Arguments**

- `users`: Array of ids of users to send the push notification to, ranging from 1 to 1000 per publish request. See Authenticated Users.
- `publishRequest`: Map containing the body of the push notification publish request. See publish API reference.

**Returns**

String that contains `publishId`: See publish API reference

### generateToken(userId)

Generate a Beams auth token to allow a user to associate their device with their user ID. The token is valid for 24 hours.

**Arguments**

- `userId`: ID of the user you would like to generate a Beams auth token for.

**Return**

The token.

### deleteUser(userId)

Remove the given user (and all of their devices) from Beams. This user will no longer receive any notifications and all state stored about their devices will be deleted.

**Arguments**

- `userId`: ID of the user you would like to remove from Beams.
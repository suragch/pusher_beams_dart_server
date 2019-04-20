import 'dart:convert';
import 'package:http/http.dart';

/// Pusher Beams Client class for sending push notifications to users.
class PushNotifications {
  static const _maxInterests = 100;
  static const _maxUsers = 1000;
  static const _maxNameLength = 164;
  static final _validCharacters = RegExp(r'^[a-zA-Z0-9_\-=@,\.;]+$');

  final String _instanceId;
  final String _secretKey;

  /// Construct a new Pusher Beams Client connected to your Beams instance.
  ///
  /// You can get the [instanceId] and [secretKey] strings from the Dashboard.
  /// These strings can't be empty.
  PushNotifications(this._instanceId, this._secretKey) {
    if (_instanceId == null || _instanceId == '') {
      throw ArgumentError('Instance ID cannot be empty');
    }
    if (_secretKey == null || _secretKey == '') {
      throw ArgumentError('Secret key cannot be empty');
    }
  }

  /// Publishes a new push notification to users who are subscribed
  /// anything in the list of [interests].
  ///
  /// The [interests] are strings in a [List]. There can be 1 to 100 items in
  /// the list. No interest name can be longer that 164 characters.
  ///
  /// You must choose at least one of [apns] (Apple) or [fcm] (Google) as the
  /// payload for the push notification. Setting both is fine. Add the appropriate
  /// content as a [Map<String, dynamic>]. See the Apple and Google docs for
  /// details on key values pairs to include.
  ///
  /// The [webhookUrl] is an optional parameter if you want to receive webhooks
  /// at key points throughout the publishing process.
  Future<Response> publishToInterests(List<String> interests,
      {Map<String, dynamic> apns,
      Map<String, dynamic> fcm,
      String webhookUrl}) async {
    _validateInterests(interests);
    _validatePublishRequests(apns, fcm);

    final uri = _getPublishInterestsUri();
    final headers = _getHeaders();
    final body = _getInterestsBody(interests, apns, fcm, webhookUrl);
    final encoding = _getUtf8Encoding();

    Response response = await post(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    return response;
  }

  /// Make sure that the submitted interests list conforms to the
  /// [Publish API](https://pusher.com/docs/beams/reference/publish-api) specs.
  _validateInterests(List<String> interests) {
    if (interests == null || interests.isEmpty) {
      throw ArgumentError('interests cannot be empty');
    }
    if (interests.length > _maxInterests) {
      throw ArgumentError('The maximum number of interests is $_maxInterests, '
          'but you have ${interests.length}.');
    }
    for (String name in interests) {
      if (name.length > _maxNameLength) {
        throw ArgumentError(
            'Interest name length cannot be greater than $_maxNameLength. '
            'Error found here: $name');
      }
      if (!_validCharacters.hasMatch(name)) {
        throw ArgumentError(
            'Interest name "$name" has invalid characters. Each character '
            'in the name must be an ASCII upper or lower-case letter, a '
            'number, or one of _-=@,.;');
      }
    }
  }

  // Make sure that there is at least one of apns and fcm.
  _validatePublishRequests(
      Map<String, dynamic> apns, Map<String, dynamic> fcm) {
    if ((apns == null || apns.isEmpty) && (fcm == null || fcm.isEmpty)) {
      throw ArgumentError('request must contain at least one payload '
          'for apns (Apple) or fcm (Google)');
    }
  }

  String _baseUri() {
    return 'https://$_instanceId.pushnotifications.pusher.com/'
        'publish_api/v1/instances/$_instanceId/publishes/';
  }

  String _getPublishInterestsUri() {
    return '${_baseUri()}interests';
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $_secretKey',
      'Content-Type': 'application/json',
    };
  }

  String _getInterestsBody(List<String> interests, Map<String, dynamic> apns,
      Map<String, dynamic> fcm, String webhookUrl) {
    // interests
    Map<String, dynamic> body = {'interests': interests};

    // Apple APNs
    if (apns != null && apns.isNotEmpty) {
      body['apns'] = apns;
    }

    // Google FCM
    if (fcm != null && fcm.isNotEmpty) {
      body['fcm'] = fcm;
    }

    // Webhook URL
    if (webhookUrl != null && webhookUrl.isNotEmpty) {
      body['webhookUrl'] = webhookUrl;
    }

    // encode as JSON string
    return json.encode(body);
  }

  Encoding _getUtf8Encoding() {
    return Encoding.getByName('utf-8');
  }

  /// Publishes a new push notification to [users] in the list who have 
  /// been authenticated.
  ///
  /// There must be at least 1 and no more that can be 1 to 1000 user 
  /// IDs in [users] per publish request. The user ID name cannot be 
  /// longer than 164 bytes and is encoded in UTF-8.
  ///
  /// You must choose at least one of [apns] (Apple) or [fcm] (Google) as the
  /// payload for the push notification. Setting both is fine. Add the appropriate
  /// content as a [Map<String, dynamic>]. See the Apple and Google docs for
  /// details on key values pairs to include.
  Future<Response> publishToUsers(List<String> users,
      {Map<String, dynamic> apns, Map<String, dynamic> fcm}) async {
    _validateUsers(users);
    _validatePublishRequests(apns, fcm);

    final uri = _getPublishUsersUri();
    final headers = _getHeaders();
    final body = _getUsersBody(users, apns, fcm);
    final encoding = _getUtf8Encoding();

    Response response = await post(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    return response;
  }

  /// Make sure that the submitted users list conforms to the
  /// [Publish API](https://pusher.com/docs/beams/reference/publish-api) specs.
  _validateUsers(List<String> users) {
    if (users == null || users.isEmpty) {
      throw ArgumentError('users cannot be empty');
    }
    if (users.length > _maxUsers) {
      throw ArgumentError('The maximum number of users per publish request '
          'is $_maxUsers, but you have ${users.length}.');
    }
    for (String name in users) {
      final bytes = utf8.encode(name);
      if (bytes.length > _maxNameLength) {
        throw ArgumentError('User name length cannot be greater than '
            '$_maxNameLength bytes. Error found here: $name');
      }
    }
  }

  String _getPublishUsersUri() {
    return '${_baseUri()}users';
  }

  String _getUsersBody(List<String> users, Map<String, dynamic> apns,
      Map<String, dynamic> fcm) {
    // interests
    Map<String, dynamic> body = {'users': users};

    // Apple APNs
    if (apns != null && apns.isNotEmpty) {
      body['apns'] = apns;
    }

    // Google FCM
    if (fcm != null && fcm.isNotEmpty) {
      body['fcm'] = fcm;
    }

    // encode as JSON string
    return json.encode(body);
  }
}

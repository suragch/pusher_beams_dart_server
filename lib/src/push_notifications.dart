import 'dart:convert';
import 'package:http/http.dart';

/// Pusher Beams Client class for sending push notifications to users.
class PushNotifications {
  static const _maxInterests = 100;
  static const _maxInterestNameLength = 164;
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

  /// Publishes a new push notification to Pusher Beams with the given payload.
  ///
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

    final uri = _getUri();
    final headers = _getHeaders();
    final body = _getBody(interests, apns, fcm, webhookUrl);
    final encoding = Encoding.getByName('utf-8');

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
    if (interests.length > 100) {
      throw ArgumentError(
          'The maximum number of interests is $_maxInterests, but you have ${interests.length}.');
    }
    for (String name in interests) {
      if (name.length > _maxInterestNameLength) {
        throw ArgumentError(
            'Interest name length cannot be greater than $_maxInterestNameLength. Error found here: $name');
      }
      if (!_validCharacters.hasMatch(name)) {
        throw ArgumentError(
            'Interest name "$name" has invalid characters. Each character in the name must be an ASCII upper or lower-case letter, a number, or one of _-=@,.;');
      }
    }
  }

  // Make sure that there is at least one of apns and fcm.
  _validatePublishRequests(
      Map<String, dynamic> apns, Map<String, dynamic> fcm) {
    if ((apns == null || apns.isEmpty) && (fcm == null || fcm.isEmpty)) {
      throw ArgumentError(
          'request must contain at least one payload for apns (Apple) or fcm (Google)');
    }
  }

  String _getUri() {
    return 'https://$_instanceId.pushnotifications.pusher.com/publish_api/v1/instances/$_instanceId/publishes/interests';
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $_secretKey',
      'Content-Type': 'application/json',
    };
  }

  String _getBody(List<String> interests, Map<String, dynamic> apns,
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
}

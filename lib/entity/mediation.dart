/// https://developer.mozilla.org/en-US/docs/Web/API/CredentialsContainer/get
/// Credential Management API
/// User mediation Type
enum Mediation {
  /// No user mediation
  Silent,

  /// User mediation required if needed
  Optional,

  /// User mediation required always
  Required
}

extension ToString on Mediation {
  String get string => toString().split('.').last;
}

Mediation mediationFrom(String value) {
  try {
    return Mediation.values
        .firstWhere((v) => v.toString().split(".").last == value);
  } catch (_) {
    throw ArgumentError.value(value);
  }
}

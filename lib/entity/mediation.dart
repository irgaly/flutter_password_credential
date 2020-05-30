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

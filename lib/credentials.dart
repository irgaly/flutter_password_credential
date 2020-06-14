import "dart:async";
import 'dart:convert';

import "package:flutter/services.dart";
import 'package:password_credential/entity/password_credential.dart';

import "entity/mediation.dart";
import 'entity/result.dart';

/// Credential Management API Access
class Credentials {
  static const MethodChannel _channel =
      const MethodChannel("password_credential");

  /// Weather this platform has PasswordCredential Feature.
  Future<bool> get hasCredentialFeature async {
    return await _channel.invokeMethod("hasCredentialFeature");
  }

  /// get Password Credential
  ///
  /// mediation: if null, default is Mediation.Silent
  /// return: a PasswordCredential, or null if cannot get single Password from Credential Store
  Future<PasswordCredential> get(Mediation mediation) async {
    String result = await _channel.invokeMethod("get",
        <String, dynamic>{"mediation": (mediation ?? Mediation.Silent).string});
    PasswordCredential credential;
    if (result != null) {
      credential = PasswordCredential.fromJson(jsonDecode(result));
    }
    return credential;
  }

  /// store ID/Password
  ///
  /// mediation: if null, default is Mediation.Optional. This is ignored in Web.
  ///            with Mediation.Required, stored entry will force deleted before asking user.
  ///            so Mediation.Required is not Recommended option.
  /// return: Result enum value
  /// throws ArgumentError: id or password is empty
  Future<Result> store(String id, String password, Mediation mediation) async {
    return await storeCredential(
        PasswordCredential(id: id, password: password, name: id), mediation);
  }

  /// store Password Credential
  ///
  /// mediation: if null, default is Mediation.Optional. This is ignored in Web.
  /// return: Result enum value. This is always Result.Unknown in Web Platform.
  /// throws ArgumentError: id or password is empty
  Future<Result> storeCredential(
      PasswordCredential credential, Mediation mediation) async {
    if (credential.id.isEmpty) {
      throw ArgumentError.value(credential, "id cannot be empty");
    }
    if (credential.password.isEmpty) {
      throw ArgumentError.value(credential, "password cannot be empty");
    }
    var result = await _channel.invokeMethod("store", <String, dynamic>{
      "credential": jsonEncode(credential),
      "mediation": (mediation ?? Mediation.Optional).string
    });
    return resultFrom(result);
  }

  /// clear password for an id
  ///
  /// id: ID String, this cannot be empty
  /// throws ArgumentError: id is empty
  ///
  /// Web: Overwrite Credential with Empty Password
  /// Android: Delete Credential
  Future<void> delete(String id) async {
    if (id.isEmpty) {
      throw ArgumentError.value(id, "id cannot be empty");
    }
    return await _channel.invokeMethod("delete", <String, dynamic>{"id": id});
  }

  /// Disable Silent Access to Current Credential
  Future<void> preventSilentAccess() async {
    return await _channel.invokeMethod("preventSilentAccess");
  }

  /// Open Platform Specific Password Credential Settings
  ///
  /// Android: Google Play Services Account Settings Page
  /// Web Chrome: Not supported
  Future<void> openPlatformCredentialSettings() async {
    return await _channel.invokeMethod("openPlatformCredentialSettings");
  }
}

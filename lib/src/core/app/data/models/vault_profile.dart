import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/core/utils/json_validator_mixin.dart';

class VaultProfile with JsonValidatorMixin {
  final String id;
  final String name;
  final String vaultOrigin;
  final String vaultUiDomain;
  final String scrapingUrl;
  final String vaultNamespace;
  final String vaultDiscoveryPath;
  final String vaultFingerprint;
  final bool verifySsl;
  final int? accentColor;
  final int? iconData;

  VaultProfile({
    required this.id,
    required this.name,
    required this.vaultOrigin,
    required this.vaultUiDomain,
    required this.scrapingUrl,
    required this.vaultNamespace,
    required this.vaultDiscoveryPath,
    this.vaultFingerprint = '',
    required this.verifySsl,
    this.accentColor,
    this.iconData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vaultOrigin': vaultOrigin,
      'vaultUiDomain': vaultUiDomain,
      'scrapingUrl': scrapingUrl,
      'vaultNamespace': vaultNamespace,
      'vaultDiscoveryPath': vaultDiscoveryPath,
      'vaultFingerprint': vaultFingerprint,
      'verifySsl': verifySsl,
      'accentColor': accentColor,
      'iconData': iconData,
    };
  }

  /// Secure factory that returns Either a Failure or a Validated Profile.
  static Either<Failure, VaultProfile> fromMapSecure(Map<String, dynamic> map) {
    final validator = _VaultProfileValidator();
    final result = validator.validate(map, ['id', 'name', 'vaultOrigin']);

    return result.map(
      (validMap) => VaultProfile(
        id: validMap['id'],
        name: validMap['name'],
        vaultOrigin: validMap['vaultOrigin'],
        vaultUiDomain: validMap['vaultUiDomain'] ?? '',
        scrapingUrl: validMap['scrapingUrl'] ?? '',
        vaultNamespace: validMap['vaultNamespace'] ?? '',
        vaultDiscoveryPath: validMap['vaultDiscoveryPath'] ?? '',
        vaultFingerprint: validMap['vaultFingerprint'] ?? '',
        verifySsl: validMap['verifySsl'] ?? true,
        accentColor: validMap['accentColor'],
        iconData: validMap['iconData'],
      ),
    );
  }

  factory VaultProfile.fromMap(Map<String, dynamic> map) {
    return VaultProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unnamed',
      vaultOrigin: map['vaultOrigin'] ?? '',
      vaultUiDomain: map['vaultUiDomain'] ?? '',
      scrapingUrl: map['scrapingUrl'] ?? '',
      vaultNamespace: map['vaultNamespace'] ?? '',
      vaultDiscoveryPath: map['vaultDiscoveryPath'] ?? '',
      vaultFingerprint: map['vaultFingerprint'] ?? '',
      verifySsl: map['verifySsl'] ?? true,
      accentColor: map['accentColor'],
      iconData: map['iconData'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VaultProfile.fromJson(String source) =>
      VaultProfile.fromMap(json.decode(source));

  VaultProfile copyWith({
    String? name,
    String? vaultOrigin,
    String? vaultUiDomain,
    String? scrapingUrl,
    String? vaultNamespace,
    String? vaultDiscoveryPath,
    String? vaultFingerprint,
    bool? verifySsl,
    int? accentColor,
    int? iconData,
  }) {
    return VaultProfile(
      id: id,
      name: name ?? this.name,
      vaultOrigin: vaultOrigin ?? this.vaultOrigin,
      vaultUiDomain: vaultUiDomain ?? this.vaultUiDomain,
      scrapingUrl: scrapingUrl ?? this.scrapingUrl,
      vaultNamespace: vaultNamespace ?? this.vaultNamespace,
      vaultDiscoveryPath: vaultDiscoveryPath ?? this.vaultDiscoveryPath,
      vaultFingerprint: vaultFingerprint ?? this.vaultFingerprint,
      verifySsl: verifySsl ?? this.verifySsl,
      accentColor: accentColor ?? this.accentColor,
      iconData: iconData ?? this.iconData,
    );
  }
}

class _VaultProfileValidator with JsonValidatorMixin {}

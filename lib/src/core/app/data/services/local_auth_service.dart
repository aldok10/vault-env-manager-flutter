import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
// ignore: unnecessary_import
import 'package:local_auth_darwin/local_auth_darwin.dart';

class LocalAuthService extends GetxService {
  static LocalAuthService get to => Get.find();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<LocalAuthService> init() async {
    return this;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to unlock Vault Master',
  }) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException {
      return false;
    }
  }
}

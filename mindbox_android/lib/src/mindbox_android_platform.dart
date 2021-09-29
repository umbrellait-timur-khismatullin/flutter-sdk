import 'package:mindbox_platform_interface/mindbox_platform_interface.dart';

/// An [MindboxPlatform] that wraps Mindbox Android SDK.
class MindboxAndroidPlatform extends MindboxPlatform {
  MindboxAndroidPlatform._();

  final MindboxMethodHandler _methodHandler = MindboxMethodHandler();

  /// Registers this class as the default instance of [MindboxPlatform].
  static void registerPlatform() {
    /// Register the platform instance with the plugin platform interface.
    MindboxPlatform.instance = MindboxAndroidPlatform._();
  }

  /// Returns SDK version or empty string("") on error
  @override
  Future<String> get sdkVersion async => _methodHandler.sdkVersion;

  /// Initializes the SDK for further work
  @override
  Future<void> init({required Configuration configuration}) async {
    await _methodHandler.init(configuration: configuration);
  }

  /// Returns device UUID to callback
  @override
  void getDeviceUUID({required Function(String uuid) callback}) {
    _methodHandler.getDeviceUUID(callback: callback);
  }

  /// Returns token to callback
  @override
  void getToken({required Function(String token) callback}) {
    _methodHandler.getToken(callback: callback);
  }

  /// Updates FMS token.
  @override
  Future<void> updateToken({required String token}) async {
    await _methodHandler.updateToken(token: token);
  }
}

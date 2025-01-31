import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindbox/mindbox.dart';
import 'package:mindbox_ios/mindbox_ios.dart';
import 'package:mindbox_platform_interface/mindbox_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MindboxIosPlatform.registerPlatform();
    channel.setMockMethodCallHandler(mindboxMockMethodCallHandler);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Mindbox.instance.sdkVersion, 'dummy-sdk-version');
  });

  test('init()', () async {
    final validConfig = Configuration(
        domain: 'domain',
        endpointIos: 'endpointIos',
        endpointAndroid: 'endpointAndroid',
        subscribeCustomerIfCreated: true);

    await Mindbox.instance.init(configuration: validConfig);
  });

  test('When config is invalid, init() calling should throws MindboxException',
      () async {
    final invalidConfig = Configuration(
        domain: '',
        endpointIos: '',
        endpointAndroid: '',
        subscribeCustomerIfCreated: true);

    expect(() async => Mindbox.instance.init(configuration: invalidConfig),
        throwsA(isA<MindboxInitializeError>()));
  });

  test('When SDK was initialized, getDeviceUUID() should return device uuid',
      () async {
    final completer = Completer<String>();

    Mindbox.instance.getDeviceUUID((uuid) => completer.complete(uuid));

    final validConfig = Configuration(
        domain: 'domain',
        endpointIos: 'endpointIos',
        endpointAndroid: 'endpointAndroid',
        subscribeCustomerIfCreated: true);

    await Mindbox.instance.init(configuration: validConfig);

    expect(completer.isCompleted, isTrue);
    expect(await completer.future, equals('dummy-device-uuid'));
  });

  test(
      'When SDK was not initialized, getDeviceUUID() should not return '
      'device uuid', () async {
    final completer = Completer<String>();

    Mindbox.instance.getDeviceUUID((uuid) => completer.complete(uuid));

    expect(completer.isCompleted, isFalse);
  });

  test('When SDK was initialized, getToken() should return token', () async {
    final completer = Completer<String>();

    Mindbox.instance.getToken((deviceToken) => completer.complete(deviceToken));

    final validConfig = Configuration(
        domain: 'domain',
        endpointIos: 'endpointIos',
        endpointAndroid: 'endpointAndroid',
        subscribeCustomerIfCreated: true);

    await Mindbox.instance.init(configuration: validConfig);

    expect(completer.isCompleted, isTrue);
    expect(await completer.future, equals('dummy-token'));
  });

  test('When SDK was not initialized, getToken() should not return token',
      () async {
    final completer = Completer<String>();

    Mindbox.instance.getToken((deviceToken) => completer.complete(deviceToken));

    expect(completer.isCompleted, isFalse);
  });

  test('onPushClickReceived()', () async {
    StubMindboxPlatform.registerPlatform();
    final completer = Completer<String>();

    Mindbox.instance.onPushClickReceived((url) => completer.complete(url));

    expect(completer.isCompleted, isTrue);
    expect(await completer.future, equals('dummy-url'));
  });
}

class StubMindboxPlatform extends MindboxPlatform {
  StubMindboxPlatform._();

  static void registerPlatform() {
    MindboxPlatform.instance = StubMindboxPlatform._();
  }

  @override
  void onPushClickReceived({required Function(String url) callback}) {
    callback('dummy-url');
  }
}

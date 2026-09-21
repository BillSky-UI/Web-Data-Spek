import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spek_komputer/services/pin_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PIN default 0000 dapat digunakan untuk login', () async {
    final ok = await PinController.instance.verify('0000');
    expect(ok, isTrue);
  });

  test('PIN salah ditolak', () async {
    final ok = await PinController.instance.verify('1234');
    expect(ok, isFalse);
  });

  test('PIN disimpan sebagai hash, bukan teks polos', () async {
    await PinController.instance.changePin('0000', '4321');
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('app_pin_hash')!;
    expect(stored, isNot(contains('4321')));
    expect(stored, hasLength(64)); // SHA-256 hex
    expect(await PinController.instance.verify('4321'), isTrue);
    expect(await PinController.instance.verify('0000'), isFalse);
  });

  test('changePin menolak PIN lama yang salah', () async {
    final ok = await PinController.instance.changePin('9999', '4321');
    expect(ok, isFalse);
    expect(await PinController.instance.verify('0000'), isTrue);
  });

  test('isValidFormat hanya menerima angka 4-6 digit', () {
    expect(PinController.instance.isValidFormat('0000'), isTrue);
    expect(PinController.instance.isValidFormat('123456'), isTrue);
    expect(PinController.instance.isValidFormat('123'), isFalse);
    expect(PinController.instance.isValidFormat('1234567'), isFalse);
    expect(PinController.instance.isValidFormat('12ab'), isFalse);
  });
}
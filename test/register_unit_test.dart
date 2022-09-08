import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/screens/register/register.dart';

void main() {
  group('test input', () {
    test('empty name returns error string', () {
      var result = NameFieldValidator.validate('');
      expect(result, 'Enter a name');
    });
    test('non-empty name returns nothing', () {
      var result = NameFieldValidator.validate('test');
      expect(result, null);
    });
    test('empty email returns error string', () {
      var result = EmailFieldValidator.validate('');
      expect(result, 'Enter an email');
    });
    test('non-empty email returns nothing', () {
      var result = EmailFieldValidator.validate('test');
      expect(result, null);
    });
    test('empty password returns error string', () {
      var result = PasswordFieldValidator.validate('');
      expect(result, 'Enter an password');
    });
    test('non-empty password returns nothing', () {
      var result = PasswordFieldValidator.validate('123456');
      expect(result, null);
    });
  });
}

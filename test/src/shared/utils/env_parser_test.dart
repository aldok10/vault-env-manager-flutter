import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/utils/env_parser.dart';

void main() {
  group('EnvParser', () {
    group('parse', () {
      test('should parse standard key-value pairs', () {
        const content = '''
KEY1=value1
KEY2=value2
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1', 'KEY2': 'value2'});
      });

      test('should ignore empty lines and full line comments', () {
        const content = '''
# This is a comment

KEY1=value1
# Another comment

KEY2=value2
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1', 'KEY2': 'value2'});
      });

      test('should trim keys and values', () {
        const content = '''
  KEY1  =  value1
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1'});
      });

      test('should handle values containing equals signs', () {
        const content = '''
KEY1=value1=with=equals
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1=with=equals'});
      });

      test('should handle double quoted values', () {
        const content = '''
KEY1="value with spaces"
KEY2="value_without_spaces"
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value with spaces', 'KEY2': 'value_without_spaces'});
      });

      test('should handle single quoted values', () {
        const content = '''
KEY1='value with spaces'
KEY2='value_without_spaces'
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value with spaces', 'KEY2': 'value_without_spaces'});
      });

      test('should handle escaped double quotes in double quoted values', () {
        const content = '''
KEY1="value with \\"quotes\\""
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value with "quotes"'});
      });

      test('should handle inline comments when not quoted and no space', () {
        const content = '''
KEY1=value1#comment
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1'});
      });

      test('should handle missing values after equals sign', () {
        const content = '''
KEY1=
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': ''});
      });

      test('should skip lines without equals sign', () {
        const content = '''
INVALID_LINE
KEY1=value1
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1'});
      });
    });

    group('stringify', () {
      test('should stringify standard key-value pairs', () {
        final data = {'KEY1': 'value1', 'KEY2': 'value2'};
        final result = EnvParser.stringify(data);
        expect(result, 'KEY1=value1\nKEY2=value2\n');
      });

      test('should add double quotes if value contains spaces', () {
        final data = {'KEY1': 'value with spaces'};
        final result = EnvParser.stringify(data);
        expect(result, 'KEY1="value with spaces"\n');
      });

      test('should not add quotes if value does not contain spaces', () {
        final data = {'KEY1': 'value_without_spaces'};
        final result = EnvParser.stringify(data);
        expect(result, 'KEY1=value_without_spaces\n');
      });
    });
  });
}

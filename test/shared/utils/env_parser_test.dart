import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/utils/env_parser.dart';

void main() {
  group('EnvParser', () {
    group('parse', () {
      test('parses basic key-value pairs', () {
        final content = '''
KEY1=value1
KEY2=value2
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1', 'KEY2': 'value2'});
      });

      test('ignores empty lines and comments', () {
        final content = '''
# This is a comment

KEY1=value1
# Another comment
KEY2=value2

''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1', 'KEY2': 'value2'});
      });

      test('handles values with multiple = symbols', () {
        final content = 'KEY=value=with=equals';
        final result = EnvParser.parse(content);
        expect(result, {'KEY': 'value=with=equals'});
      });

      test('handles single and double quoted values', () {
        final content = '''
KEY1="value with spaces"
KEY2='another value'
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value with spaces', 'KEY2': 'another value'});
      });

      test('handles double quoted values with escaped quotes', () {
        final content = 'KEY="value with \\"escaped\\" quotes"';
        final result = EnvParser.parse(content);
        expect(result, {'KEY': 'value with "escaped" quotes'});
      });

      test('handles simplified inline comments', () {
        final content = 'KEY=value#comment';
        final result = EnvParser.parse(content);
        expect(result, {'KEY': 'value'});
      });

      test('trims leading and trailing spaces', () {
        final content = '  KEY  =  value  ';
        final result = EnvParser.parse(content);
        expect(result, {'KEY': 'value'});
      });

      test('ignores lines without = symbol', () {
        final content = '''
KEY1=value1
INVALID_LINE
KEY2=value2
''';
        final result = EnvParser.parse(content);
        expect(result, {'KEY1': 'value1', 'KEY2': 'value2'});
      });
    });

    group('stringify', () {
      test('stringifies basic keys and values', () {
        final data = {'KEY1': 'value1', 'KEY2': 'value2'};
        final result = EnvParser.stringify(data);
        expect(result, 'KEY1=value1\nKEY2=value2\n');
      });

      test('adds double quotes to values with spaces', () {
        final data = {'KEY1': 'value with spaces', 'KEY2': 'value2'};
        final result = EnvParser.stringify(data);
        expect(result, 'KEY1="value with spaces"\nKEY2=value2\n');
      });

      test('stringifies empty map', () {
        final data = <String, String>{};
        final result = EnvParser.stringify(data);
        expect(result, '');
      });
    });
  });
}

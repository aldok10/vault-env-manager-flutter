import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/shared/utils/env_classifier.dart';

void main() {
  group('EnvClassifier.classify', () {
    test('returns unknown for null or empty input', () {
      expect(EnvClassifier.classify(null), EnvVariant.unknown);
      expect(EnvClassifier.classify(''), EnvVariant.unknown);
    });

    test('returns prod for strings containing "prod"', () {
      expect(EnvClassifier.classify('prod'), EnvVariant.prod);
      expect(EnvClassifier.classify('production'), EnvVariant.prod);
      expect(EnvClassifier.classify('PROD_ENV'), EnvVariant.prod);
      expect(EnvClassifier.classify('my-prod-app'), EnvVariant.prod);
    });

    test('returns staging for strings containing "uat", "stag", or "pre"', () {
      expect(EnvClassifier.classify('uat'), EnvVariant.staging);
      expect(EnvClassifier.classify('staging'), EnvVariant.staging);
      expect(EnvClassifier.classify('stag'), EnvVariant.staging);
      expect(EnvClassifier.classify('pre'), EnvVariant.staging);
      expect(EnvClassifier.classify('my-uat-env'), EnvVariant.staging);
    });

    test('returns prod for "PRE-PROD" because it contains "prod" and "prod" comes first in switch', () {
      expect(EnvClassifier.classify('PRE-PROD'), EnvVariant.prod);
    });

    test('returns dev for strings containing "dev"', () {
      expect(EnvClassifier.classify('dev'), EnvVariant.dev);
      expect(EnvClassifier.classify('development'), EnvVariant.dev);
      expect(EnvClassifier.classify('DEV_1'), EnvVariant.dev);
    });

    test('returns test for strings containing "test" or "qa"', () {
      expect(EnvClassifier.classify('test'), EnvVariant.test);
      expect(EnvClassifier.classify('testing'), EnvVariant.test);
      expect(EnvClassifier.classify('qa'), EnvVariant.test);
      expect(EnvClassifier.classify('QA_ENV'), EnvVariant.test);
    });

    test('returns local for strings containing "local" or "lab"', () {
      expect(EnvClassifier.classify('local'), EnvVariant.local);
      expect(EnvClassifier.classify('localhost'), EnvVariant.local);
      expect(EnvClassifier.classify('lab'), EnvVariant.local);
      expect(EnvClassifier.classify('LAB_01'), EnvVariant.local);
    });

    test('returns unknown for unrecognized strings', () {
      expect(EnvClassifier.classify('foo'), EnvVariant.unknown);
      expect(EnvClassifier.classify('bar'), EnvVariant.unknown);
      expect(EnvClassifier.classify('custom'), EnvVariant.unknown);
    });

    test('is case-insensitive', () {
      expect(EnvClassifier.classify('PROD'), EnvVariant.prod);
      expect(EnvClassifier.classify('Staging'), EnvVariant.staging);
      expect(EnvClassifier.classify('UAT'), EnvVariant.staging);
      expect(EnvClassifier.classify('Development'), EnvVariant.dev);
      expect(EnvClassifier.classify('TEST'), EnvVariant.test);
      expect(EnvClassifier.classify('LOCAL'), EnvVariant.local);
    });
  });
}

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:math';

import 'package:meta/meta.dart';

import '../money2.dart';
import 'pattern_decoder.dart';

/// Allows you to create a [Currency] which is then used to construct
/// [Money] instances.
///
/// **NOTE: This is a value type, do not extend or re-implement it.**
///
/// Money2 does not create a default set of currencies instead you need
/// to explicitly create each currency type you want to use.
///
/// Normally you create one global currency instance for each currency type.
/// If you wish you can register each [Currency] instance with the
/// [CommonCurrencies] class which then is able to provides a global
/// directory of [Currency] instances.
///
//@sealed
@immutable
class Currency {
  /// Creates a currency with a given [isoCode] and [decimalDigits].
  ///
  /// * [isoCode] - the currency isoCode e.g. USD
  /// * [decimalDigits] - the number of digits after the decimal place the
  /// the currency uses. e.g. 2 for USD as it uses cents to 2 digits.
  /// * [pattern] - the default output format used when you call toString
  /// on a Money instance created with this currency. See [Money.format]
  /// for details on the supported patterns.
  /// [groupSeparator] controls the character used to separate blocks of 1000.
  ///  e.g. 1,000,000.
  /// By default the [groupSeparator] is ','
  /// [decimalSeparator] controls the character used for the decimal place.
  /// By default the [decimalSeparator] is '.'
  Currency.create(this.isoCode, this.decimalDigits,
      {this.symbol = r'$',
      this.pattern = defaultPattern,
      this.groupSeparator = ',',
      this.decimalSeparator = '.',
      this.country = '',
      this.unit = '',
      this.name = ''})
      : scaleFactor = Currency._calcPrecisionFactor(decimalDigits) {
    if (isoCode.isEmpty) {
      throw ArgumentError.value(
          isoCode, 'isoCode', 'Must be a non-empty string.');
    }
  }
  static const String defaultPattern = 'S0.00';

  /// Creates a [Currency] from an existing [Currency] with changes.
  Currency copyWith({
    String? isoCode,
    int? precision,
    String? symbol,
    String? pattern,
    String? groupSeparator,
    String? decimalSeparator,
  }) =>
      Currency.create(isoCode ?? this.isoCode, precision ?? decimalDigits,
          symbol: symbol ?? this.symbol,
          pattern: pattern ?? this.pattern,
          groupSeparator: groupSeparator ?? this.groupSeparator,
          decimalSeparator: decimalSeparator ?? this.decimalSeparator);

  /// Takes a monetary amount encoded as a string
  /// and converts it to a [Money] instance.
  ///
  /// You can pass in a [pattern] to define the
  /// format of the [monetaryAmount].
  /// If you don't pass in a [pattern] then the [Currency]s
  /// default pattern is used.
  ///
  /// If the number of minorUnits in [monetaryAmount]
  /// exceeds the [Currency]s precision then excess digits will be ignored.
  ///
  /// Currency aud = Currency.create('AUD', 2);
  /// Money audAmount = aud.parse('10.50');
  ///
  /// A [MoneyParseException] is thrown if the [monetaryAmount]
  /// doesn't match the [pattern].
  ///
  Money parse(String monetaryAmount, {String? pattern}) {
    if (monetaryAmount.isEmpty) {
      throw MoneyParseException('Empty monetaryAmount passed.');
    }
    pattern ??= this.pattern;
    final decoder = PatternDecoder(this, pattern);
    final moneyData = decoder.decode(monetaryAmount);

    return Money.fromFixedWithCurrency(moneyData.amount, this);
  }

  /// The isoCode of the currency (e.g. 'USD').
  final String isoCode;

  /// The currency symbol (e.g. $)
  final String symbol;

  /// The number of decimals for the currency (zero or more).
  final int decimalDigits;

  /// The factor of 10 to divide a minor value by to get the intended
  /// currency value.
  ///
  ///  e.g. if [decimalDigits] is 2 then this value will be 100.
  final BigInt scaleFactor;

  /// the default pattern used to format and parse monetary amounts for this
  /// currency.
  final String pattern;

  /// Full name of the currency. e.g. Australian Dollar
  final String country;

  /// The major units of the currency. e.g. 'Dollar'
  final String unit;

  /// The name of the currency. e.g. Australian Dollar
  final String name;

  /// The character used for the decimal place
  final String decimalSeparator;

  /// The character used for the group separator.
  final String groupSeparator;

  @override
  int get hashCode => isoCode.hashCode;

  /// Two currencies are considered equivalent if the
  /// [isoCode] and [decimalDigits] are the same.
  ///
  /// Are we breaking the semantics of the == operator?
  /// Maybe we need another method that just compares the isoCode?
  @override
  bool operator ==(covariant Currency other) =>
      identical(this, other) ||
      (isoCode == other.isoCode && decimalDigits == other.decimalDigits);

  static BigInt _calcPrecisionFactor(int precision) {
    if (precision.isNegative) {
      throw ArgumentError.value(
          precision, 'precision', 'Must be a non-negative value.');
    }
    return BigInt.from(pow(10, precision));
  }

  /// Takes a [majorUnits] and a [minorUnits] and returns
  /// a BigInt which represents the two combined values in
  /// [minorUnits].
  BigInt toMinorUnits(BigInt majorUnits, BigInt minorUnits) =>
      majorUnits * scaleFactor + minorUnits;
}

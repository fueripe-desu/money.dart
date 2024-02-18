/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */
import '../../money2.dart';

typedef CurrencyIsoCode = String;

/// When defining an exchange rate we need to specify
/// the conditions under which the exchange is calculated.
///
/// An [ExchangeRate] allows us to convert a [Money] instance
/// from one [Currency] to another.
///
/// e.g.
///
/// AUD 1.00 = USD 65c.
///
class ExchangeRate {
  /// Create an exchange rate from a [Fixed] decimal.
  ///
  /// The target currency, as defined by [toIsoCode], describes the
  /// currency of the [Money] instance that is returned by the excchange.
  ///
  /// The [toDecimalDigits] is the number of decimal digits of the resulting
  /// [Money] amount. If not supplied the decimalDigits of the
  /// [toIsoCode]'s currency is used.
  ///
  /// The [toDecimalDigits] for the [exchangeRate] should normally be quoted to
  /// a high precision such as 8 decimal places.
  ///
  factory ExchangeRate.fromFixed(Fixed exchangeRate,
          {required CurrencyIsoCode fromIsoCode,
          required CurrencyIsoCode toIsoCode,
          int? toDecimalDigits}) =>
      ExchangeRate.fromFixedWithCurrency(exchangeRate,
          fromCurrency: _findCurrency(fromIsoCode),
          toCurrency: _findCurrency(toIsoCode),
          toDecimalDigits: toDecimalDigits);

  /// Create an exchange rate from a [Fixed] decimal.
  ///
  /// If supplied the [toDecimalDigits] sets the decimalDigits of the
  /// resulting [Money] amount. If not
  /// supplied then the [toCurrency]'s decimalDigits is used.
  ExchangeRate.fromFixedWithCurrency(this.exchangeRate,
      {required this.fromCurrency,
      required this.toCurrency,
      this.toDecimalDigits});

  /// Create an exchange rate from an integer holding minor units
  /// to the provided number of [decimalDigits].
  ///
  /// The [toDecimalDigits] is the number of decimals of the resulting [Money]
  ///  amount. If not supplied the decimalDigits of the [toCode]'s currency
  /// is used.
  factory ExchangeRate.fromMinorUnits(int exchangeRateMinorUnits,
          {required int decimalDigits,
          required CurrencyIsoCode fromCode,
          required CurrencyIsoCode toCode,
          int? toDecimalDigits}) =>
      ExchangeRate.fromMinorUnitsWithCurrency(exchangeRateMinorUnits,
          decimalDigits: decimalDigits,
          fromCurrency: _findCurrency(fromCode),
          toCurrency: _findCurrency(toCode),
          toDecimalDigits: toDecimalDigits);

  /// Create an exchange rate from an integer holding minor units
  /// to the provided [decimalDigits].
  ///
  /// The [decimalDigits] is the number of decimalDigits of the passed
  /// [exchangeRateMinorUnits].
  ///
  /// [toDecimalDigits] is the number of digits to store in the
  /// [toCurrency].  If not supplied, the decimalDigits of the [toCurrency]'s
  /// currency is used.
  ExchangeRate.fromMinorUnitsWithCurrency(int exchangeRateMinorUnits,
      {required int decimalDigits,
      required this.fromCurrency,
      required this.toCurrency,
      this.toDecimalDigits})
      : exchangeRate =
            Fixed.fromInt(exchangeRateMinorUnits, scale: decimalDigits);

  /// Create an exchange rate from an integer or decimal holding major units
  ///
  /// The [exchangeRate] is stored, rounded to [decimalDigits] decimal places.
  ///
  /// The [toDecimalDigits] is the number of decimal digits
  ///  of the resulting [Money] amount. If not
  /// supplied the decimalDigits of the [toCode]'s currency is used.
  factory ExchangeRate.fromNum(
    num exchangeRate, {
    required int decimalDigits,
    required CurrencyIsoCode fromCode,
    required CurrencyIsoCode toCode,
    int? toDecimalDigits,
  }) =>
      ExchangeRate.fromNumWithCurrency(exchangeRate,
          decimalDigits: decimalDigits,
          fromCurrency: _findCurrency(fromCode),
          toCurrency: _findCurrency(toCode),
          toDecimalDigits: toDecimalDigits);

  /// Create an exchange rate from an integer or decimal holding major units
  ///
  /// The amount is stored, rounded to [decimalDigits] decimal places.
  ///
  /// The [decimalDigits] is the number of decimals of the resulting
  ///   [Money] amount. If not supplied the decimalDigits of the [toCurrency]'s
  ///   is
  ExchangeRate.fromNumWithCurrency(
    num rateAsNum, {
    required int decimalDigits,
    required this.fromCurrency,
    required this.toCurrency,
    this.toDecimalDigits,
  }) {
    exchangeRate = Fixed.fromNum(rateAsNum, scale: decimalDigits);
  }

  /// Create an exchange rate from an BigInt holding minor units
  /// to the provided [decimalDigits].
  ///
  /// The amount is stored with  [decimalDigits] decimal places.
  ///
  /// The [decimalDigits] is the number of decimal Digits of the resulting
  ///   [Money] amount. If not supplied the decimalDigits of the [toIsoCode]'s
  ///  currency is used.
  factory ExchangeRate.fromBigInt(BigInt exchangeRateMinorUnits,
          {required int decimalDigits,
          required CurrencyIsoCode fromIsoCode,
          required CurrencyIsoCode toIsoCode}) =>
      ExchangeRate.fromBigIntWithCurrency(exchangeRateMinorUnits,
          decimalDigits: decimalDigits,
          fromCurrency: _findCurrency(fromIsoCode),
          toCurrency: _findCurrency(toIsoCode));

  ExchangeRate.fromBigIntWithCurrency(
    BigInt exchangeRateMinorUnits, {
    required int decimalDigits,
    required this.fromCurrency,
    required this.toCurrency,
    this.toDecimalDigits,
  }) {
    exchangeRate =
        Fixed.fromBigInt(exchangeRateMinorUnits, scale: decimalDigits);
  }

  /// The Currency that we are converting from.
  late final Currency fromCurrency;

  /// The exchange rate
  late final Fixed exchangeRate;

  /// After the exchange rate is applied this
  /// will the resulting [Currency] of the returned [Money]
  late final Currency toCurrency;

  /// The number of decimal digigs of the resulting [Currency]
  /// If not passed then we use the default decimalDigits
  /// of the [toCurrency]
  final int? toDecimalDigits;

  /// Apply the exchange rate to [amount] and return
  /// a new [Money] in the [toCurrency].
  ///
  /// The [Currency] of the [amount] must be the same as
  /// the [fromCurrency] otherwise a [MismatchedCurrencyException] is thown.
  Money applyRate(Money amount) {
    if (fromCurrency != amount.currency) {
      throw MismatchedCurrencyException(
          expected: fromCurrency.isoCode, actual: amount.currency.isoCode);
    }

    /// convertedUnits now has this.decimalDigits + exchangeRate.decimalDigits
    /// decimal digits.
    final convertedUnits = amount.amount * exchangeRate;

    return Money.fromFixed(convertedUnits,
        isoCode: toCurrency.isoCode,
        decimalDigits: toDecimalDigits ?? toCurrency.decimalDigits);
  }

  /// Applies the exchange rate in the reverse direction.
  /// The [Currency] of the [amount] must be the same as
  /// the [toCurrency] otherwise a [MismatchedCurrencyException] is thown.
  Money applyInverseRate(Money amount) {
    if (toCurrency != amount.currency) {
      throw MismatchedCurrencyException(
          expected: toCurrency.isoCode, actual: amount.currency.isoCode);
    }

    return Money.fromFixedWithCurrency(
        amount.amount *
            Fixed.fromNum(1,
                scale: toDecimalDigits ?? toCurrency.decimalDigits) /
            exchangeRate,
        fromCurrency,
        decimalDigits: toDecimalDigits ?? toCurrency.decimalDigits);
  }

  static Currency _findCurrency(String isoCode) {
    final currency = Currencies().find(isoCode);
    if (currency == null) {
      throw UnknownCurrencyException(isoCode);
    }

    return currency;
  }

  // Display the exchange rate as a fixed decimal
  @override
  String toString() => exchangeRate.toString();

  /// Formats the [exchangeRate] using the given [pattern]
  String format(String pattern) => exchangeRate.format(pattern);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rokkhakoboch/core/sms/mfs_sms_filter.dart';

void main() {
  test('matches MFS provider keywords', () {
    expect(MfsSmsFilter.looksFinanceRelated('bKash', 'Your payment'), isTrue);
    expect(MfsSmsFilter.looksFinanceRelated('16247', 'Nagad cash out'), isTrue);
    expect(MfsSmsFilter.looksFinanceRelated('Rocket', 'টাকা পাঠানো'), isTrue);
  });

  test('ignores unrelated personal SMS', () {
    expect(MfsSmsFilter.looksFinanceRelated('Mom', 'দুপুরে খাবে?'), isFalse);
    expect(MfsSmsFilter.looksFinanceRelated('+8801', 'কাল স্কুলে যাবো'), isFalse);
  });

  test('matches scam-related finance keywords', () {
    expect(MfsSmsFilter.looksFinanceRelated('Unknown', 'OTP verify করুন'), isTrue);
    expect(MfsSmsFilter.looksFinanceRelated('Promo', 'You won prize'), isTrue);
  });
}

/// In-memory keyword filter for MFS/finance-related SMS — no persistence.
abstract final class MfsSmsFilter {
  static const _keywords = [
    'bkash',
    'b-kash',
    'বিকাশ',
    'nagad',
    'নগদ',
    'rocket',
    'রকেট',
    'upay',
    'উপায়',
    'tap',
    'ট্যাপ',
    'otp',
    'pin',
    'টাকা',
    'payment',
    'pay',
    'bank',
    'loan',
    'ঋণ',
    'cash out',
    'cashout',
    'send money',
    'merchant',
    'mfs',
    'verify',
    'account',
    'হিসাব',
    'লেনদেন',
    'refund',
    'win',
    'prize',
    'jackpot',
    'urgent',
  ];

  /// Quick client-side check only — caller must discard non-matching SMS immediately.
  static bool looksFinanceRelated(String sender, String body) {
    final haystack = '${sender.toLowerCase()} ${body.toLowerCase()}';
    for (final keyword in _keywords) {
      if (haystack.contains(keyword)) return true;
    }
    return false;
  }
}

/// In-memory keyword filter for MFS/finance-related SMS — no persistence.
abstract final class MfsSmsFilter {
  static const _keywords = [
    'bkash', 'b-kash', 'বিকাশ', 'nagad', 'নগদ', 'rocket', 'রকেট', 'upay', 'উপায়', 'tap', 'ট্যাপ',
    'otp', 'pin', 'পিন', 'টাকা', 'payment', 'pay', 'bank', 'loan', 'ঋণ', 'cash out', 'cashout',
    'send money', 'merchant', 'mfs', 'verify', 'account', 'হিসাব', 'লেনদেন', 'refund', 'win', 'prize',
    'jackpot', 'urgent', 'জরুরি', 'লটারি', 'জিতেছেন', 'পুরস্কার', 'বিনিয়োগ', 'ক্রিপ্টো', 'চাকরি',
    'ইনকাম', 'ব্লক', 'বন্ধ', 'কোড', 'পাসওয়ার্ড', 'cutt.ly', 'bit.ly',
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

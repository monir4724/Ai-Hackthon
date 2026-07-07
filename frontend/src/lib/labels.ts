export function riskLabelBn(risk: string): string {
  switch (risk) {
    case 'high':
      return 'উচ্চ ঝুঁকি'
    case 'medium':
      return 'মাঝারি ঝুঁকি'
    case 'low':
      return 'কম ঝুঁকি'
    case 'safe':
    case 'none':
      return 'নিরাপদ'
    default:
      return 'সতর্ক'
  }
}

export function riskBadgeClass(risk: string): string {
  switch (risk) {
    case 'high':
      return 'border-danger text-danger bg-danger/5'
    case 'medium':
      return 'border-secondary-container text-on-secondary-container bg-secondary-container/5'
    case 'low':
      return 'border-secondary text-secondary bg-secondary/5'
    case 'safe':
    case 'none':
      return 'border-safe text-safe bg-safe/5'
    default:
      return 'border-outline text-outline bg-surface-container'
  }
}

const FLAG_LABELS: Record<string, string> = {
  shortened_url: 'সংক্ষিপ্ত URL (bit.ly ইত্যাদি)',
  brand_impersonation_in_domain: 'ডোমেইনে ব্র্যান্ড নামের অনুকরণ',
  official_domain_match: 'পরিচিত অফিসিয়াল ডোমেইন',
  fake_example_domain: 'উদাহরণ/ভুয়া ডোমেইন',
  no_https: 'HTTPS নেই',
}

export function flagLabelBn(flag: string): string {
  if (FLAG_LABELS[flag]) return FLAG_LABELS[flag]
  if (flag.startsWith('suspicious_tld:')) {
    return `সন্দেহজনক TLD (${flag.split(':')[1] ?? ''})`
  }
  return flag.replace(/_/g, ' ')
}

export function moduleLabelBn(module: string): string {
  switch (module) {
    case 'call_transcript':
      return 'কল ট্রান্সক্রিপ্ট'
    case 'url':
      return 'URL যাচাই'
    default:
      return 'SMS স্ক্যান'
  }
}

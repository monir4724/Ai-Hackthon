import { Link } from 'react-router-dom'
import Icon from '../components/Icon'

const CHECKLIST = [
  'অজানা উৎস থেকে APK ইনস্টল করবেন না (নকল bKash/Nagad অ্যাপ থেকে সাবধান)',
  'কাউকে SMS পড়ার অনুমতি দেবেন না',
  'স্ক্রিন শেয়ার করবেন না (ফোন স্ক্যাম)',
  'Accessibility সার্ভিসে অজানা অ্যাপ যোগ করবেন না',
  'অজানা নম্বর থেকে OTP চাইলে কখনো দেবেন না',
  'bKash/Nagad/Rocket কখনো PIN ফোনে চায় না',
]

export default function DeviceProtectionPage() {
  return (
    <div className="mx-auto max-w-2xl">
      <Link to="/modules" className="mb-4 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline">
        <Icon name="arrow_back" className="text-base" />
        মডিউলে ফিরুন
      </Link>
      <p className="font-mono text-xs uppercase tracking-widest text-outline">মডিউল ০৭ — ডিভাইস সুরক্ষা</p>
      <h1 className="mt-2 font-tiro text-3xl text-primary">ডিভাইস সুরক্ষা চেকলিস্ট</h1>
      <p className="mt-3 text-on-surface-variant">বাংলাদেশ-নির্দিষ্ট সাইবার সুরক্ষা সচেতনতা — মোবাইল অ্যাপে লাইভ অনুমতি যাচাই পাওয়া যায়।</p>
      <ul className="mt-8 space-y-4">
        {CHECKLIST.map((item, i) => (
          <li key={item} className="flex gap-3 border border-outline-variant bg-surface-container-lowest p-4">
            <span className="font-mono text-sm font-bold text-primary">{i + 1}.</span>
            <span className="text-on-surface-variant">{item}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

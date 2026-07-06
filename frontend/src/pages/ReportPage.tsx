import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Icon from '../components/Icon'
import { submitReport } from '../lib/api'

const CATEGORIES = [
  { value: '', label: 'নির্বাচন করুন' },
  { value: 'sms', label: 'এসএমএস (SMS) ফিশিং' },
  { value: 'call', label: 'ভয়েস কল জালিয়াতি' },
  { value: 'job', label: 'ভুয়া চাকরির অফার' },
  { value: 'bank', label: 'ব্যাংক/বিকাশ জালিয়াতি' },
  { value: 'other', label: 'অন্যান্য' },
]

const DIVISIONS = [
  { value: '', label: 'বিভাগ নির্বাচন করুন (ঐচ্ছিক)' },
  { value: 'ঢাকা', label: 'ঢাকা' },
  { value: 'চট্টগ্রাম', label: 'চট্টগ্রাম' },
  { value: 'রাজশাহী', label: 'রাজশাহী' },
  { value: 'খুলনা', label: 'খুলনা' },
  { value: 'বরিশাল', label: 'বরিশাল' },
  { value: 'সিলেট', label: 'সিলেট' },
  { value: 'রংপুর', label: 'রংপুর' },
  { value: 'ময়মনসিংহ', label: 'ময়মনসিংহ' },
]

export default function ReportPage() {
  const [text, setText] = useState('')
  const [category, setCategory] = useState('')
  const [locationLabel, setLocationLabel] = useState('')
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const selected = CATEGORIES.find((c) => c.value === category)
      await submitReport({
        text_bn: text.trim(),
        category: selected?.label || category.trim() || undefined,
        location_label: locationLabel || undefined,
        risk_level: 'high',
      })
      setSuccess(true)
      setTimeout(() => navigate('/feed'), 2000)
    } catch {
      setError('রিপোর্ট জমা দিতে ব্যর্থ।')
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="mx-auto flex max-w-lg flex-col items-center py-12 text-center">
        <div className="verdict-seal ink-stamp-texture inline-block border-4 border-safe bg-safe/5 px-8 py-4 font-tiro text-3xl font-bold text-safe">
          ধন্যবাদ
        </div>
        <Icon name="check_circle" filled className="mt-8 text-6xl text-safe" />
        <h1 className="mt-4 font-tiro text-2xl text-primary">এটি অন্যদের সুরক্ষায় সাহায্য করবে।</h1>
        <div className="mt-8 w-full max-w-sm border border-outline-variant bg-surface-container-high p-6 text-left">
          <p className="text-on-surface-variant">
            আপনার রিপোর্ট সফলভাবে আমাদের ফরেনসিক ডাটাবেসে জমা হয়েছে। আমাদের বিশেষজ্ঞরা এটি
            বিশ্লেষণ করবেন।
          </p>
        </div>
        <p className="mt-6 text-sm text-on-surface-variant">ফিডে রিডাইরেক্ট হচ্ছে...</p>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-2xl">
      <div className="mb-6">
        <h1 className="font-tiro text-3xl text-primary md:text-4xl">রিপোর্ট করুন</h1>
        <p className="mt-2 text-on-surface-variant">
          সন্দেহজনক মেসেজ বা কল সম্পর্কে তথ্য দিয়ে অন্যদের সুরক্ষিত থাকতে সাহায্য করুন।
        </p>
      </div>

      <div className="mb-6 flex items-center gap-3 border border-outline-variant bg-surface-container-low p-4">
        <Icon name="privacy_tip" filled className="shrink-0 text-primary" />
        <span className="font-mono text-sm text-on-primary-fixed-variant">
          আপনার নাম প্রকাশ করা হবে না
        </span>
      </div>

      <form
        onSubmit={handleSubmit}
        className="ink-bleed space-y-6 border border-outline-variant bg-surface p-6"
      >
        <div>
          <label
            htmlFor="category"
            className="mb-2 block font-mono text-xs uppercase tracking-widest text-on-surface-variant"
          >
            স্ক্যামের ধরন
          </label>
          <select
            id="category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="w-full border-0 border-b-2 border-outline-variant bg-surface-container-lowest py-3 focus:border-primary focus:outline-none"
          >
            {CATEGORIES.map((c) => (
              <option key={c.value} value={c.value}>
                {c.label}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label
            htmlFor="division"
            className="mb-2 block font-mono text-xs uppercase tracking-widest text-on-surface-variant"
          >
            বিভাগ (ঐচ্ছিক)
          </label>
          <select
            id="division"
            value={locationLabel}
            onChange={(e) => setLocationLabel(e.target.value)}
            className="w-full border-0 border-b-2 border-outline-variant bg-surface-container-lowest py-3 focus:border-primary focus:outline-none"
          >
            {DIVISIONS.map((d) => (
              <option key={d.value} value={d.value}>
                {d.label}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label
            htmlFor="scam-content"
            className="mb-2 block font-mono text-xs uppercase tracking-widest text-on-surface-variant"
          >
            মেসেজ বা কল ডিটেইলস *
          </label>
          <textarea
            id="scam-content"
            value={text}
            onChange={(e) => setText(e.target.value)}
            required
            minLength={10}
            rows={5}
            placeholder="সন্দেহজনক মেসেজটি এখানে কপি করুন..."
            className="w-full resize-none border-0 border-b-2 border-outline-variant bg-surface-container-lowest py-3 focus:border-primary focus:outline-none"
          />
        </div>

        {error && (
          <p className="flex items-center gap-2 text-danger">
            <Icon name="error" />
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="flex w-full items-center justify-center gap-3 rounded bg-secondary-container py-4 font-bold text-on-secondary-container transition active:scale-95 disabled:opacity-50"
        >
          <span>{loading ? 'জমা দিচ্ছে...' : 'রিপোর্ট জমা দিন'}</span>
          <Icon name="send" />
        </button>
      </form>

      <Link
        to="/feed"
        className="mt-6 inline-flex items-center gap-2 font-semibold text-primary underline underline-offset-4"
      >
        <Icon name="arrow_back" className="text-base" />
        ফিডে ফিরে যান
      </Link>
    </div>
  )
}

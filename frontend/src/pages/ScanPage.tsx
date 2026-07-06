import { useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { analyzeText } from '../lib/api'

export default function ScanPage() {
  const [text, setText] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const module = params.get('module') === 'call_transcript' ? 'call_transcript' : 'sms'

  const isCall = module === 'call_transcript'

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (text.trim().length < 5) {
      setError('কমপক্ষে ৫ অক্ষর লিখুন')
      return
    }
    setLoading(true)
    setError('')
    try {
      const result = await analyzeText(text.trim(), module)
      navigate('/result', { state: { result, text: text.trim() } })
    } catch {
      setError('বিশ্লেষণ ব্যর্থ হয়েছে। ব্যাকএন্ড চালু আছে কিনা দেখুন।')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="mx-auto max-w-2xl">
      <p className="font-mono text-xs uppercase tracking-widest text-on-surface-variant">
        {isCall ? 'মডিউল ০২ — কল ট্রান্সক্রিপ্ট বিশ্লেষণ' : 'মডিউল ০১ — এমএফএস মেসেজ সেন্টিনেল'}
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary-container">
        {isCall ? 'কল ট্রান্সক্রিপ্ট যাচাই' : 'সন্দেহজন্য মেসেজ স্ক্যান'}
      </h1>
      {isCall && (
        <p className="mt-2 rounded border border-secondary-container/40 bg-secondary-container/10 p-3 text-sm text-on-secondary-container">
          এটি লাইভ কল সুরক্ষা নয় — কল রেকর্ডিং বা টাইপ করা ট্রান্সক্রিপ্ট বিশ্লেষণ।
        </p>
      )}

      <form onSubmit={handleSubmit} className="mt-8 space-y-4">
        <div>
          <label className="mb-2 block font-mono text-xs uppercase text-on-surface-variant">
            {isCall ? 'কল ট্রান্সক্রিপ্ট' : 'মেসেজ টেক্সট'}
          </label>
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            rows={8}
            placeholder={
              isCall
                ? 'কলার কী বলেছিল তা এখানে লিখুন...'
                : 'সন্দেহজন্য SMS/মেসেজ এখানে পেস্ট করুন...'
            }
            className="w-full rounded border border-outline-variant bg-surface-container-lowest p-4 font-siliguri text-on-surface focus:border-primary-container focus:outline-none"
          />
        </div>
        {error && <p className="text-sm text-danger">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded bg-primary-container py-4 font-bold text-white transition hover:opacity-90 disabled:opacity-50"
        >
          {loading ? 'বিশ্লেষণ চলছে...' : 'ঝুঁকি যাচাই করুন'}
        </button>
      </form>

      <div className="mt-8 paper-card p-4">
        <p className="font-mono text-xs uppercase text-on-surface-variant">দ্রুত উদাহরণ</p>
        <button
          type="button"
          onClick={() =>
            setText(
              'জরুরি সতর্কতা: আপনার bKash হিসাবে অস্বাভাবিক লগইন সনাক্ত হয়েছে। আজই ০১XXXXXXXXX নম্বরে কল করে আপনার ৪ ডিজিট কোড জানিয়ে হিসাব সচল রাখুন।'
            )
          }
          className="mt-2 text-left text-sm text-primary-container underline"
        >
          OTP ফিশিং উদাহরণ লোড করুন
        </button>
      </div>
    </div>
  )
}

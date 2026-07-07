import { useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import Icon from '../components/Icon'
import { analyzeText } from '../lib/api'

const EXAMPLE_TEXT =
  'জরুরি সতর্কতা: আপনার bKash হিসাবে অস্বাভাবিক লগইন সনাক্ত হয়েছে। আজই ০১XXXXXXXXX নম্বরে কল করে আপনার ৪ ডিজিট কোড জানিয়ে হিসাব সচল রাখুন।'

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
    } catch (err) {
      setError(err instanceof Error ? err.message : 'বিশ্লেষণ ব্যর্থ হয়েছে। ব্যাকএন্ড চালু আছে কিনা দেখুন।')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link
        to="/"
        className="mb-4 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline"
      >
        <Icon name="arrow_back" className="text-base" />
        হোমে ফিরুন
      </Link>

      <div className="mb-8 border-b border-outline-variant pb-4">
        <p className="font-mono text-xs uppercase tracking-widest text-outline">
          {isCall ? 'মডিউল ০২ — কল ট্রান্সক্রিপ্ট বিশ্লেষণ' : 'মডিউল ০১ — এমএফএস মেসেজ সেন্টিনেল'}
        </p>
        <h1 className="mt-2 font-tiro text-3xl text-primary md:text-4xl">
          {isCall ? 'কল ট্রান্সক্রিপ্ট যাচাই' : 'সন্দেহজন্য মেসেজ স্ক্যান'}
        </h1>
        <p className="mt-1 text-sm text-on-surface-variant">
          {isCall ? 'কলের লিখিত বিবরণ AI দিয়ে যাচাই করুন' : 'SMS বা মেসেজের ঝুঁকি তাৎক্ষণিক বিশ্লেষণ'}
        </p>
      </div>

      <div className="mb-6 flex items-center gap-2 font-mono text-xs text-safe">
        <span className="status-dot bg-safe" />
        লাইভ স্ক্যানিং প্রস্তুত
      </div>

      {isCall && (
        <div className="mb-6 flex items-start gap-3 border border-outline-variant bg-surface-container-low p-4">
          <Icon name="info" className="mt-0.5 shrink-0 text-secondary" />
          <p className="text-sm text-on-surface-variant">
            এটি লাইভ কল সুরক্ষা নয় — কল রেকর্ডিং বা টাইপ করা ট্রান্সক্রিপ্ট বিশ্লেষণ।
          </p>
        </div>
      )}

      <form
        onSubmit={handleSubmit}
        className="paper-grain ink-bleed space-y-6 border border-outline-variant bg-surface-container-lowest p-6"
      >
        <div>
          <label
            htmlFor="scan-input"
            className="mb-2 block font-mono text-xs uppercase tracking-widest text-on-surface-variant"
          >
            {isCall ? 'কল ট্রান্সক্রিপ্ট' : 'মেসেজ টেক্সট'}
          </label>
          <textarea
            id="scan-input"
            value={text}
            onChange={(e) => setText(e.target.value)}
            rows={8}
            placeholder={
              isCall
                ? 'কলার কী বলেছিল তা এখানে লিখুন...'
                : 'সন্দেহজনক মেসেজটি এখানে কপি করুন...'
            }
            className="w-full resize-none border-0 border-b-2 border-outline-variant bg-surface-container-low py-4 text-base leading-relaxed placeholder:text-outline-variant focus:border-primary focus:outline-none"
          />
        </div>

        {error && (
          <p className="flex items-center gap-2 text-sm text-danger">
            <Icon name="error" className="text-base" />
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="flex w-full items-center justify-center gap-3 rounded border border-secondary bg-secondary-container px-10 py-5 text-xl font-bold text-on-secondary-container transition-transform duration-200 hover:scale-[1.02] disabled:opacity-50"
        >
          <Icon name="search_check" />
          {loading ? 'বিশ্লেষণ চলছে...' : 'ঝুঁকি যাচাই করুন'}
        </button>
      </form>

      <div className="paper-card mt-8 p-5">
        <p className="font-mono text-xs uppercase tracking-widest text-outline">দ্রুত উদাহরণ</p>
        <div className="mt-3 flex flex-wrap items-center gap-2">
          <span className="font-mono text-xs uppercase text-outline">জনপ্রিয়:</span>
          <button
            type="button"
            onClick={() => setText(EXAMPLE_TEXT)}
            className="rounded bg-secondary-container px-3 py-1 font-mono text-xs text-on-secondary-container"
          >
            OTP
          </button>
        </div>
        <button
          type="button"
          onClick={() => setText(EXAMPLE_TEXT)}
          className="mt-3 flex items-center gap-2 text-left text-sm text-primary hover:underline"
        >
          <Icon name="content_paste" className="text-base" />
          OTP ফিশিং উদাহরণ লোড করুন
        </button>
      </div>
    </div>
  )
}

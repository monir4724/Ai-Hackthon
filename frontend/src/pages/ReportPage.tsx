import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { submitReport } from '../lib/api'

export default function ReportPage() {
  const [text, setText] = useState('')
  const [category, setCategory] = useState('')
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      await submitReport({
        text_bn: text.trim(),
        category: category.trim() || undefined,
        risk_level: 'high',
      })
      setSuccess(true)
      setTimeout(() => navigate('/feed'), 1500)
    } catch {
      setError('রিপোর্ট জমা দিতে ব্যর্থ।')
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="mx-auto max-w-lg text-center">
        <h1 className="font-tiro text-2xl text-safe">রিপোর্ট সংরক্ষিত!</h1>
        <p className="mt-2 text-on-surface-variant">ফিডে রিডাইরেক্ট হচ্ছে...</p>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="font-tiro text-3xl text-primary-container">
        স্ক্যাম রিপোর্ট করুন
      </h1>
      <p className="mt-2 text-on-surface-variant">
        আপনি যে মেসেজ/প্যাটার্ন দেখেছেন তা সম্প্রদায়ের সাথে শেয়ার করুন।
      </p>

      <form onSubmit={handleSubmit} className="mt-8 space-y-4">
        <div>
          <label className="mb-2 block font-mono text-xs uppercase">মেসেজ টেক্সট *</label>
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            required
            minLength={10}
            rows={6}
            className="w-full rounded border border-outline-variant bg-white p-4 focus:border-primary-container focus:outline-none"
          />
        </div>
        <div>
          <label className="mb-2 block font-mono text-xs uppercase">ক্যাটাগরি (ঐচ্ছিক)</label>
          <input
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            placeholder="যেমন: OTP phishing, lottery scam"
            className="w-full rounded border border-outline-variant bg-white p-3 focus:border-primary-container focus:outline-none"
          />
        </div>
        {error && <p className="text-danger">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded bg-danger py-4 font-bold text-white disabled:opacity-50"
        >
          {loading ? 'জমা দিচ্ছে...' : 'রিপোর্ট জমা দিন'}
        </button>
      </form>

      <Link to="/feed" className="mt-4 inline-block text-primary-container underline">
        ফিডে ফিরে যান
      </Link>
    </div>
  )
}

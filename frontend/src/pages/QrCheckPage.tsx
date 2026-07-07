import { useState } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../components/Icon'
import VerdictStamp from '../components/VerdictStamp'
import { checkQr } from '../lib/api'
import { flagLabelBn, riskScoreBarClass } from '../lib/labels'

export default function QrCheckPage() {
  const [payload, setPayload] = useState('')
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<Awaited<ReturnType<typeof checkQr>> | null>(null)
  const [error, setError] = useState('')

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')
    setResult(null)
    try {
      setResult(await checkQr(payload.trim()))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'QR যাচাই ব্যর্থ হয়েছে।')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link to="/modules" className="mb-4 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline">
        <Icon name="arrow_back" className="text-base" />
        মডিউলে ফিরুন
      </Link>
      <p className="font-mono text-xs uppercase tracking-widest text-outline">মডিউল ০৪ — আর্থিক প্রতারণা শিল্ড</p>
      <h1 className="mt-2 font-tiro text-3xl text-primary">QR / পেমেন্ট কোড যাচাই</h1>
      <p className="mt-3 text-on-surface-variant">
        ক্যামেরা ছাড়াই QR-এর টেক্সট/URL এখানে পেস্ট করুন — URL + টেক্সট উভয় বিশ্লেষণ হবে।
      </p>

      <form onSubmit={handleSubmit} className="ink-bleed mt-8 space-y-6 border border-outline-variant bg-surface p-6">
        <div>
          <label className="mb-2 block font-mono text-xs uppercase tracking-widest text-on-surface-variant">
            QR কন্টেন্ট
          </label>
          <textarea
            value={payload}
            onChange={(e) => setPayload(e.target.value)}
            rows={5}
            required
            placeholder="https://... অথবা bKash পেমেন্ট লিংক / QR টেক্সট"
            className="w-full resize-none border-0 border-b-2 border-outline-variant bg-surface-container-lowest py-3 font-mono text-sm focus:border-primary focus:outline-none"
          />
        </div>
        {error && (
          <p className="flex items-center gap-2 text-error">
            <Icon name="error" />
            {error}
          </p>
        )}
        <button
          type="submit"
          disabled={loading}
          className="flex w-full items-center justify-center gap-2 rounded border border-secondary bg-secondary-container py-4 font-bold text-on-secondary-container disabled:opacity-50"
        >
          {loading ? 'বিশ্লেষণ করা হচ্ছে...' : 'QR বিশ্লেষণ করুন'}
        </button>
      </form>

      {result && (
        <div className="mt-10">
          <VerdictStamp riskLevel={result.risk_level} verdictBn={result.verdict_bn} />
          {typeof result.risk_score === 'number' && (
            <div className="mt-4">
              <p className="mb-1 font-mono text-xs text-on-surface-variant">ঝুঁকি স্কোর: {result.risk_score}/100</p>
              <div className="h-2 w-full bg-surface-container-high">
                <div
                  className={`h-2 ${riskScoreBarClass(result.risk_score)}`}
                  style={{ width: `${Math.min(100, result.risk_score)}%` }}
                />
              </div>
            </div>
          )}
          <div className="mt-6 paper-card p-5">
            <p className="leading-relaxed">{result.explanation}</p>
            {(result.flags_bn ?? result.flags.map((f) => ({ key: f, label_bn: flagLabelBn(f), explanation_bn: '' }))).map((f) => (
              <p key={f.key} className="mt-2 text-sm text-on-surface-variant">
                • {f.label_bn}
              </p>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

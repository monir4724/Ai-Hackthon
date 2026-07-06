import { useState } from 'react'
import Icon from '../components/Icon'
import VerdictStamp from '../components/VerdictStamp'
import { checkUrl } from '../lib/api'

export default function UrlCheckPage() {
  const [url, setUrl] = useState('')
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<Awaited<ReturnType<typeof checkUrl>> | null>(null)
  const [error, setError] = useState('')

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')
    setResult(null)
    try {
      const res = await checkUrl(url.trim())
      setResult(res)
    } catch {
      setError('URL যাচাই ব্যর্থ হয়েছে।')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="mx-auto max-w-2xl">
      <p className="font-mono text-xs uppercase tracking-widest text-outline">
        মডিউল ০৩ — URL/ফিশিং লিংক গার্ড
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary md:text-4xl">
        লিংক নিরাপত্তা যাচাই
      </h1>
      <p className="mt-3 text-on-surface-variant">
        সন্দেহজনক URL পেস্ট করুন — ডোমেইন ও ফিশিং প্যাটার্ন যাচাই হবে।
      </p>

      <form
        onSubmit={handleSubmit}
        className="ink-bleed mt-8 space-y-6 border border-outline-variant bg-surface p-6"
      >
        <div>
          <label className="mb-2 block font-mono text-xs uppercase tracking-widest text-on-surface-variant">
            URL
          </label>
          <input
            type="url"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            placeholder="https://..."
            required
            className="w-full border-0 border-b-2 border-outline-variant bg-surface-container-lowest py-3 font-mono text-sm focus:border-primary focus:outline-none"
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
          <Icon name="link" />
          {loading ? 'যাচাই হচ্ছে...' : 'লিংক স্ক্যান করুন'}
        </button>
      </form>

      {result && (
        <div className="mt-10">
          <VerdictStamp riskLevel={result.risk_level} verdictBn={result.verdict_bn} />
          <div className="mt-6 paper-card p-5">
            <p className="font-mono text-xs uppercase tracking-widest text-outline">ব্যাখ্যা</p>
            <p className="mt-2 leading-relaxed">{result.explanation}</p>
            {result.flags?.length > 0 && (
              <ul className="mt-4 space-y-2">
                {result.flags.map((f) => (
                  <li key={f} className="flex items-start gap-2 text-sm text-on-surface-variant">
                    <Icon name="report_problem" className="mt-0.5 text-error" />
                    {f}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

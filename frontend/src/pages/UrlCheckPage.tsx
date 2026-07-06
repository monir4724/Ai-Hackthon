import { useState } from 'react'
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
      <p className="font-mono text-xs uppercase tracking-widest text-on-surface-variant">
        মডিউল ০৩ — URL/ফিশিং লিংক গার্ড
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary-container">
        লিংক নিরাপত্তা যাচাই
      </h1>

      <form onSubmit={handleSubmit} className="mt-8 space-y-4">
        <div>
          <label className="mb-2 block font-mono text-xs uppercase">URL</label>
          <input
            type="url"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            placeholder="https://..."
            required
            className="w-full rounded border border-outline-variant bg-white p-4 font-mono text-sm focus:border-primary-container focus:outline-none"
          />
        </div>
        {error && <p className="text-danger">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded bg-primary-container py-4 font-bold text-white disabled:opacity-50"
        >
          {loading ? 'যাচাই হচ্ছে...' : 'লিংক স্ক্যান করুন'}
        </button>
      </form>

      {result && (
        <div className="mt-10">
          <VerdictStamp riskLevel={result.risk_level} verdictBn={result.verdict_bn} />
          <div className="mt-6 paper-card p-5">
            <p className="font-mono text-xs uppercase">ব্যাখ্যা</p>
            <p className="mt-2">{result.explanation}</p>
            {result.flags?.length > 0 && (
              <ul className="mt-3 font-mono text-xs text-on-surface-variant">
                {result.flags.map((f) => (
                  <li key={f}>• {f}</li>
                ))}
              </ul>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

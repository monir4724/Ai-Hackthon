import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { fetchReports, type ScamPattern } from '../lib/api'

export default function FeedPage() {
  const [patterns, setPatterns] = useState<ScamPattern[]>([])
  const [filter, setFilter] = useState<'all' | 'community'>('all')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    fetchReports(filter === 'community')
      .then(setPatterns)
      .catch(() => setPatterns([]))
      .finally(() => setLoading(false))
  }, [filter])

  return (
    <div>
      <p className="font-mono text-xs uppercase tracking-widest text-on-surface-variant">
        মডিউল ১০ — জাতীয় হুমকি বুদ্ধিমত্তা
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary-container">
        প্রতারণা প্যাটার্ন ফিড
      </h1>
      <p className="mt-2 text-on-surface-variant">
        পরিচিত ও সম্প্রদায়-রিপোর্ট করা স্ক্যাম প্যাটার্ন।
      </p>

      <div className="mt-6 flex gap-3">
        <button
          type="button"
          onClick={() => setFilter('all')}
          className={`rounded px-4 py-2 font-mono text-sm ${
            filter === 'all'
              ? 'bg-primary-container text-white'
              : 'border border-outline-variant'
          }`}
        >
          সব প্যাটার্ন
        </button>
        <button
          type="button"
          onClick={() => setFilter('community')}
          className={`rounded px-4 py-2 font-mono text-sm ${
            filter === 'community'
              ? 'bg-primary-container text-white'
              : 'border border-outline-variant'
          }`}
        >
          সম্প্রদায় রিপোর্ট
        </button>
        <Link
          to="/report"
          className="ml-auto rounded border border-primary-container px-4 py-2 font-mono text-sm text-primary-container"
        >
          + রিপোর্ট
        </Link>
      </div>

      {loading && <p className="mt-8">লোড হচ্ছে...</p>}

      <div className="mt-6 space-y-4">
        {patterns.map((p) => (
          <PatternCard key={p.id} pattern={p} />
        ))}
      </div>
    </div>
  )
}

function PatternCard({ pattern }: { pattern: ScamPattern }) {
  const riskClass =
    pattern.risk_level === 'high'
      ? 'border-danger/30 bg-danger/5'
      : pattern.risk_level === 'safe' || pattern.risk_level === 'none'
        ? 'border-safe/30 bg-safe/5'
        : 'border-secondary-container/30'

  return (
    <article className={`paper-card p-5 ${riskClass}`}>
      <div className="flex flex-wrap items-center gap-2">
        <span className="font-mono text-xs uppercase text-primary-container">
          {pattern.category}
        </span>
        {pattern.is_community_report && (
          <span className="rounded bg-secondary-container/20 px-2 py-0.5 font-mono text-xs">
            সম্প্রদায়
          </span>
        )}
        <span className="font-mono text-xs text-on-surface-variant">
          {pattern.risk_level}
        </span>
      </div>
      <p className="mt-3 text-sm leading-relaxed">{pattern.text_bn}</p>
      {pattern.red_flags_bn && (
        <p className="mt-2 font-mono text-xs text-on-surface-variant">
          লাল পতাকা: {pattern.red_flags_bn}
        </p>
      )}
    </article>
  )
}

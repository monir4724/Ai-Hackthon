import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../components/Icon'
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

  const midpoint = Math.ceil(patterns.length / 2)
  const firstHalf = patterns.slice(0, midpoint)
  const secondHalf = patterns.slice(midpoint)

  return (
    <div className="-mx-5 md:-mx-10">
      <div className="px-5 md:px-10">
        <p className="font-mono text-xs uppercase tracking-widest text-outline">
          মডিউল ১০ — জাতীয় হুমকি বুদ্ধিমত্তা
        </p>
        <h1 className="mt-2 font-tiro text-3xl text-primary">থ্রেট ফিড</h1>
        <p className="mt-2 text-on-surface-variant">
          পরিচিত ও সম্প্রদায়-রিপোর্ট করা স্ক্যাম প্যাটার্ন।
        </p>
      </div>

      <div className="mt-6 flex items-center gap-3 overflow-hidden bg-primary px-5 py-2 text-on-primary md:px-10">
        <span className="status-dot animate-pulse bg-danger" />
        <span className="font-mono text-xs uppercase tracking-widest">
          লাইভ থ্রেট রিপোর্ট — বাংলাদেশ
        </span>
      </div>

      <div className="sticky top-[57px] z-40 border-b border-outline-variant bg-surface-container-low px-5 py-4 md:px-10">
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setFilter('all')}
            className={`shrink-0 rounded px-4 py-1.5 font-mono text-xs uppercase tracking-wider ${
              filter === 'all'
                ? 'bg-primary text-on-primary'
                : 'border border-outline-variant bg-surface-container-highest text-primary'
            }`}
          >
            সব রিপোর্ট
          </button>
          <button
            type="button"
            onClick={() => setFilter('community')}
            className={`shrink-0 rounded px-4 py-1.5 font-mono text-xs uppercase tracking-wider ${
              filter === 'community'
                ? 'bg-primary text-on-primary'
                : 'border border-outline-variant bg-surface-container-highest text-primary'
            }`}
          >
            সম্প্রদায় রিপোর্ট
          </button>
        </div>
      </div>

      <div className="space-y-4 px-5 py-6 md:mx-auto md:max-w-2xl md:px-10">
        {loading && (
          <p className="flex items-center gap-2 text-on-surface-variant">
            <Icon name="hourglass_empty" />
            লোড হচ্ছে...
          </p>
        )}

        {!loading && patterns.length === 0 && (
          <div className="border border-outline-variant bg-surface-container-lowest p-8 text-center text-on-surface-variant">
            কোনো প্যাটার্ন পাওয়া যায়নি।
          </div>
        )}

        {firstHalf.map((p) => (
          <PatternCard key={p.id} pattern={p} />
        ))}

        {!loading && patterns.length > 0 && (
          <div className="border-2 border-dashed border-outline-variant bg-surface-container p-6 text-center">
            <Icon name="upload_file" className="text-5xl text-primary" />
            <h3 className="mt-4 font-tiro text-2xl text-primary">আপনার কোনো সন্দেহ আছে?</h3>
            <p className="mt-2 text-on-surface-variant">
              সন্দেহজনক কোনো মেসেজ বা কল রিপোর্ট করে অন্যদের সাহায্য করুন।
            </p>
            <Link
              to="/report"
              className="mt-6 inline-flex items-center gap-2 rounded bg-primary px-8 py-3 font-mono text-sm text-on-primary transition hover:opacity-90"
            >
              <Icon name="add_alert" />
              রিপোর্ট জমা দিন
            </Link>
          </div>
        )}

        {secondHalf.map((p) => (
          <PatternCard key={p.id} pattern={p} />
        ))}
      </div>

      <Link
        to="/report"
        className="fixed right-6 bottom-24 z-40 flex h-14 w-14 items-center justify-center rounded bg-secondary-container text-on-secondary-container shadow-lg transition active:scale-90 md:bottom-8"
        aria-label="রিপোর্ট জমা দিন"
      >
        <Icon name="add_alert" className="text-3xl" />
      </Link>
    </div>
  )
}

function PatternCard({ pattern }: { pattern: ScamPattern }) {
  const isHigh = pattern.risk_level === 'high'
  const isSafe = pattern.risk_level === 'safe' || pattern.risk_level === 'none'
  const isMedium = !isHigh && !isSafe

  const borderClass = isHigh
    ? 'border-danger'
    : isMedium
      ? 'border-secondary-container'
      : 'border-outline'

  const labelClass = isHigh
    ? 'text-danger'
    : isMedium
      ? 'text-secondary'
      : 'text-outline'

  const labelText = isHigh ? 'উচ্চ ঝুঁকি' : isMedium ? 'সতর্কবার্তা' : 'পর্যবেক্ষণ'
  const labelIcon = isHigh ? 'warning' : isMedium ? 'info' : 'visibility'

  const preview =
    pattern.text_bn.length > 72 ? `${pattern.text_bn.slice(0, 72)}…` : pattern.text_bn

  return (
    <article
      className={`wire-card relative overflow-hidden border bg-surface-container-lowest p-4 ${borderClass}`}
    >
      <div className="flex items-start justify-between gap-3">
        <span className={`flex items-center gap-1 font-mono text-xs font-bold uppercase ${labelClass}`}>
          <Icon name={labelIcon} className="text-base" />
          {labelText}
        </span>
        <span className="font-mono text-xs text-on-surface-variant">{pattern.category}</span>
      </div>

      <h2 className="mt-2 text-lg font-semibold text-primary">{preview}</h2>

      {pattern.red_flags_bn && (
        <p className="mt-2 font-mono text-xs text-on-surface-variant">
          লাল পতাকা: {pattern.red_flags_bn}
        </p>
      )}

      <div className="mt-3 flex items-center justify-between border-t border-outline-variant pt-2">
        {pattern.is_community_report ? (
          <span className="flex items-center gap-1 font-mono text-xs text-on-surface-variant">
            <Icon name="group" className="text-base" />
            সম্প্রদায় রিপোর্ট
          </span>
        ) : (
          <span className="font-mono text-xs text-outline">ডাটাসেট প্যাটার্ন</span>
        )}
        <span className="font-mono text-xs uppercase text-primary">{pattern.risk_level}</span>
      </div>

      {isHigh && (
        <Icon
          name="report_problem"
          className="pointer-events-none absolute -top-2 -right-4 rotate-12 text-[80px] text-danger opacity-10"
        />
      )}
    </article>
  )
}

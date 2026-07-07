import { useEffect, useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Icon from '../components/Icon'
import { DISCLAIMER } from '../config/modules'
import { fetchHistory, type ScanHistoryItem } from '../lib/api'
import { moduleLabelBn, riskBadgeClass, riskLabelBn } from '../lib/labels'

export default function HistoryPage() {
  const [items, setItems] = useState<ScanHistoryItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const navigate = useNavigate()

  function loadHistory() {
    setLoading(true)
    setError('')
    fetchHistory()
      .then(setItems)
      .catch((err: Error) => {
        setItems([])
        setError(err.message || 'ইতিহাস লোড করতে ব্যর্থ হয়েছে।')
      })
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    loadHistory()
  }, [])

  const grouped = useMemo(() => {
    const map = new Map<string, ScanHistoryItem[]>()
    for (const item of items) {
      const label = groupLabel(new Date(item.created_at))
      if (!map.has(label)) map.set(label, [])
      map.get(label)!.push(item)
    }
    return Array.from(map.entries())
  }, [items])

  function openHistoryItem(item: ScanHistoryItem) {
    navigate('/result', {
      state: {
        text: item.input_text,
        result: {
          risk_level: item.risk_level as 'high' | 'medium' | 'low' | 'safe',
          verdict_bn: riskLabelBn(item.risk_level),
          explanation: item.explanation || 'বিস্তারিত ব্যাখ্যা সংরক্ষিত নেই।',
          matched_pattern: item.matched_pattern || '—',
          disclaimer: DISCLAIMER,
          module: item.module,
        },
      },
    })
  }

  return (
    <div className="mx-auto max-w-4xl">
      <Link
        to="/"
        className="mb-4 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline"
      >
        <Icon name="arrow_back" className="text-base" />
        হোমে ফিরুন
      </Link>

      <div className="mb-8 border-b border-outline-variant pb-4">
        <h1 className="font-tiro text-3xl text-primary">সাম্প্রতিক স্ক্যানসমূহ</h1>
        <p className="mt-1 font-mono text-xs uppercase tracking-widest text-on-surface-variant">
          আপনার যাচাই করা বার্তার তালিকা
        </p>
      </div>

      {loading && (
        <p className="flex items-center gap-2 text-on-surface-variant">
          <Icon name="hourglass_empty" />
          লোড হচ্ছে...
        </p>
      )}

      {error && (
        <div className="border border-danger/30 bg-danger/5 p-6 text-center">
          <p className="flex items-center justify-center gap-2 text-danger">
            <Icon name="error" />
            {error}
          </p>
          <button
            type="button"
            onClick={loadHistory}
            className="mt-4 rounded bg-primary px-6 py-2 font-mono text-sm text-on-primary"
          >
            আবার চেষ্টা করুন
          </button>
        </div>
      )}

      {!loading && !error && items.length === 0 && (
        <div className="flex flex-col items-center py-24 text-center">
          <div className="relative mb-8 flex h-40 w-40 items-center justify-center rounded-full border-4 border-dashed border-outline-variant opacity-30">
            <Icon name="history_toggle_off" className="text-[80px] text-outline-variant" />
          </div>
          <h2 className="font-tiro text-2xl text-on-surface-variant">
            এখনো কোনো মেসেজ যাচাই করা হয়নি
          </h2>
          <p className="mt-2 max-w-sm text-on-surface-variant">
            আপনার ডিজিটাল নিরাপত্তা নিশ্চিত করতে প্রথম মেসেজটি স্ক্যান করুন।
          </p>
          <Link
            to="/scan"
            className="mt-8 inline-flex items-center gap-3 rounded bg-primary px-8 py-4 font-bold text-white transition hover:opacity-90"
          >
            <Icon name="search_check" />
            স্ক্যান শুরু করুন
          </Link>
        </div>
      )}

      <div className="space-y-8">
        {grouped.map(([label, groupItems]) => (
          <section key={label}>
            <div className="mb-4 flex items-center gap-3">
              <span className="h-px flex-grow bg-outline-variant" />
              <h2 className="rounded bg-surface-container px-3 py-1 font-mono text-xs font-bold text-primary">
                {label}
              </h2>
              <span className="h-px flex-grow bg-outline-variant" />
            </div>
            <div className="space-y-2">
              {groupItems.map((item) => {
                const chipClass = riskBadgeClass(item.risk_level)
                return (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => openHistoryItem(item)}
                    className="group flex w-full items-center justify-between gap-4 border border-outline-variant bg-surface-container-lowest p-3 text-left transition hover:bg-surface-container active:opacity-70"
                  >
                    <div className="flex min-w-0 flex-1 items-center gap-4">
                      <div
                        className={`flex h-8 w-20 shrink-0 items-center justify-center border text-[10px] font-bold tracking-tighter ${chipClass}`}
                      >
                        {riskLabelBn(item.risk_level)}
                      </div>
                      <div className="min-w-0">
                        <p className="truncate text-base text-on-surface">{item.input_text}</p>
                        <p className="mt-0.5 font-mono text-[10px] text-outline">
                          {moduleLabelBn(item.module)}
                        </p>
                      </div>
                    </div>
                    <span className="shrink-0 font-mono text-xs text-outline">
                      {new Date(item.created_at).toLocaleTimeString('bn-BD', {
                        hour: '2-digit',
                        minute: '2-digit',
                        second: '2-digit',
                      })}
                    </span>
                  </button>
                )
              })}
            </div>
          </section>
        ))}
      </div>
    </div>
  )
}

function groupLabel(date: Date): string {
  const today = new Date()
  const yesterday = new Date()
  yesterday.setDate(today.getDate() - 1)

  if (date.toDateString() === today.toDateString()) return 'আজ'
  if (date.toDateString() === yesterday.toDateString()) return 'গতকাল'
  return date.toLocaleDateString('bn-BD', { day: 'numeric', month: 'long', year: 'numeric' })
}

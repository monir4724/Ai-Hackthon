import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { fetchHistory, type ScanHistoryItem } from '../lib/api'

const riskColors: Record<string, string> = {
  high: 'text-danger',
  medium: 'text-on-secondary-container',
  low: 'text-on-secondary-container',
  safe: 'text-safe',
}

export default function HistoryPage() {
  const [items, setItems] = useState<ScanHistoryItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchHistory()
      .then(setItems)
      .catch(() => setItems([]))
      .finally(() => setLoading(false))
  }, [])

  return (
    <div>
      <h1 className="font-tiro text-3xl text-primary-container">স্ক্যান ইতিহাস</h1>
      <p className="mt-2 text-on-surface-variant">
        এই ব্রাউজার সেশনের সাম্প্রতিক বিশ্লেষণ (লগইন ছাড়া)।
      </p>

      {loading && <p className="mt-8">লোড হচ্ছে...</p>}

      {!loading && items.length === 0 && (
        <div className="mt-8 paper-card p-8 text-center">
          <p className="text-on-surface-variant">এখনো কোনো স্ক্যান নেই।</p>
          <Link to="/scan" className="mt-4 inline-block text-primary-container underline">
            প্রথম স্ক্যান করুন
          </Link>
        </div>
      )}

      <div className="mt-6 space-y-3">
        {items.map((item) => (
          <div key={item.id} className="paper-card p-4">
            <div className="flex items-start justify-between gap-4">
              <div className="min-w-0 flex-1">
                <p className="font-mono text-xs text-on-surface-variant">
                  {new Date(item.created_at).toLocaleString('bn-BD')} — {item.module}
                </p>
                <p className="mt-1 truncate text-sm italic">{item.input_text}</p>
                {item.matched_pattern && (
                  <p className="mt-1 font-mono text-xs text-primary-container">
                    {item.matched_pattern}
                  </p>
                )}
              </div>
              <span
                className={`shrink-0 font-tiro font-bold ${riskColors[item.risk_level] || ''}`}
              >
                {item.risk_level === 'high'
                  ? 'উচ্চ ঝুঁকি'
                  : item.risk_level === 'safe'
                    ? 'নিরাপদ'
                    : 'সতর্ক'}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

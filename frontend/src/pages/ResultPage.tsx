import { Link, useLocation, Navigate } from 'react-router-dom'
import VerdictStamp from '../components/VerdictStamp'
import type { AnalysisResult } from '../lib/api'

export default function ResultPage() {
  const location = useLocation()
  const state = location.state as { result?: AnalysisResult; text?: string } | null

  if (!state?.result) {
    return <Navigate to="/scan" replace />
  }

  const { result, text } = state

  return (
    <div className="mx-auto max-w-2xl">
      <p className="font-mono text-xs uppercase tracking-widest text-on-surface-variant">
        ফরেনসিক রিপোর্ট — {result.analyzed_at ? new Date(result.analyzed_at).toLocaleString('bn-BD') : 'এখন'}
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary-container">
        বিশ্লেষণ ফলাফল
      </h1>

      <div className="mt-10 flex justify-center">
        <VerdictStamp riskLevel={result.risk_level} verdictBn={result.verdict_bn} />
      </div>

      <div className="mt-10 space-y-4">
        <div className="paper-card p-5">
          <p className="font-mono text-xs uppercase text-on-surface-variant">মূল বার্তা</p>
          <p className="mt-2 text-on-surface-variant italic">"{text}"</p>
        </div>

        <div className="paper-card p-5">
          <p className="font-mono text-xs uppercase text-on-surface-variant">ব্যাখ্যা</p>
          <p className="mt-2 leading-relaxed">{result.explanation}</p>
        </div>

        <div className="paper-card p-5">
          <p className="font-mono text-xs uppercase text-on-surface-variant">মিলে যাওয়া প্যাটার্ন</p>
          <p className="mt-2 font-mono text-primary-container">{result.matched_pattern}</p>
        </div>

        {result.prefilter && (
          <div className="paper-card p-5">
            <p className="font-mono text-xs uppercase text-on-surface-variant">
              প্রি-ফিল্টার স্কোর: {result.prefilter.risk_score}/100
            </p>
            {result.prefilter.flags.length > 0 && (
              <ul className="mt-3 space-y-1 font-mono text-xs text-on-surface-variant">
                {result.prefilter.flags.map((f) => (
                  <li key={f}>• {f}</li>
                ))}
              </ul>
            )}
          </div>
        )}
      </div>

      <div className="mt-8 flex flex-wrap gap-3">
        <Link
          to="/scan"
          className="rounded bg-primary-container px-6 py-3 font-bold text-white"
        >
          আরেকটি স্ক্যান
        </Link>
        <Link
          to="/report"
          className="rounded border border-primary-container px-6 py-3 font-bold text-primary-container"
        >
          স্ক্যাম রিপোর্ট করুন
        </Link>
      </div>
    </div>
  )
}

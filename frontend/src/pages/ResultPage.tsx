import { Link, useLocation, Navigate } from 'react-router-dom'
import Icon from '../components/Icon'
import VerdictStamp from '../components/VerdictStamp'
import { DISCLAIMER } from '../config/modules'
import { flagLabelBn } from '../lib/labels'
import type { AnalysisResult } from '../lib/api'

export default function ResultPage() {
  const location = useLocation()
  const state = location.state as { result?: AnalysisResult; text?: string } | null

  if (!state?.result) {
    return <Navigate to="/scan" replace />
  }

  const { result, text } = state
  const flags = result.prefilter?.flags ?? []
  const isHighRisk = result.risk_level === 'high'
  const module = result.module ?? 'sms'
  const rescanPath =
    module === 'call_transcript' ? '/scan?module=call_transcript' : module === 'url' ? '/url-check' : '/scan'

  return (
    <div className="mx-auto max-w-md">
      <Link
        to="/"
        className="mb-4 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline"
      >
        <Icon name="arrow_back" className="text-base" />
        হোমে ফিরুন
      </Link>

      <div className="flex justify-center">
        <VerdictStamp
          riskLevel={result.risk_level}
          verdictBn={result.verdict_bn}
          showDisclaimer={false}
        />
      </div>

      {result.matched_pattern && (
        <div className="mt-2 mb-8">
          <p className="mb-3 font-mono text-xs uppercase tracking-widest text-outline">
            মিলে যাওয়া প্যাটার্ন
          </p>
          <div className="flex flex-wrap gap-2">
            <span className="inline-flex items-center rounded-full bg-primary px-4 py-1 font-mono text-xs text-white">
              {result.matched_pattern}
            </span>
            {result.prefilter && result.prefilter.risk_score >= 50 && (
              <span className="inline-flex items-center rounded-full bg-surface-container-highest px-4 py-1 font-mono text-xs text-on-surface-variant">
                স্কোর {result.prefilter.risk_score}/100
              </span>
            )}
          </div>
        </div>
      )}

      <div className="paper-card mb-6 p-6">
        <div
          className={`mb-4 flex items-center gap-2 ${isHighRisk ? 'text-danger' : 'text-secondary'}`}
        >
          <Icon name="warning" filled />
          <h2 className="text-lg font-bold">ঝুঁকির কারণসমূহ</h2>
        </div>
        <p className="mb-6 leading-relaxed text-on-surface-variant">{result.explanation}</p>

        {flags.length > 0 && (
          <ul className="space-y-3">
            {flags.map((flag) => (
              <li
                key={flag}
                className="flex items-start gap-3 rounded border border-error-container bg-error-container/20 p-3"
              >
                <Icon name="report_problem" className="mt-0.5 shrink-0 text-danger" />
                <span className="text-sm text-on-surface-variant">{flagLabelBn(flag)}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      {text && (
        <div className="paper-card mb-6 p-5">
          <p className="font-mono text-xs uppercase tracking-widest text-outline">মূল বার্তা</p>
          <p className="mt-2 text-sm leading-relaxed italic text-on-surface-variant">"{text}"</p>
        </div>
      )}

      <div className="flex flex-col gap-3 border-t border-outline-variant pt-6">
        <Link
          to="/report"
          state={{ text }}
          className="flex items-center justify-between rounded px-4 py-4 font-semibold text-primary transition hover:bg-surface-container-high"
        >
          <span>এই ফলাফল রিপোর্ট করুন</span>
          <Icon name="flag" />
        </Link>
        <Link
          to={rescanPath}
          className="flex items-center justify-between rounded px-4 py-4 font-semibold text-primary transition hover:bg-surface-container-high"
        >
          <span>আরেকটি যাচাই করুন</span>
          <Icon name="refresh" />
        </Link>
      </div>

      <footer className="mt-10 border-t border-outline-variant bg-surface-container-low py-6 text-center">
        <p className="font-mono text-xs text-on-surface-variant/70 italic">
          "{result.disclaimer || DISCLAIMER}"
        </p>
      </footer>
    </div>
  )
}

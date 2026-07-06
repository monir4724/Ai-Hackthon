import { DISCLAIMER } from '../config/modules'

interface Props {
  riskLevel: string
  verdictBn: string
}

const styles: Record<string, { border: string; text: string; bg: string }> = {
  high: { border: 'border-danger', text: 'text-danger', bg: 'bg-danger/5' },
  medium: { border: 'border-secondary-container', text: 'text-on-secondary-container', bg: 'bg-secondary-container/10' },
  low: { border: 'border-secondary-container', text: 'text-on-secondary-container', bg: 'bg-secondary-container/10' },
  safe: { border: 'border-safe', text: 'text-safe', bg: 'bg-safe/5' },
}

export default function VerdictStamp({ riskLevel, verdictBn }: Props) {
  const s = styles[riskLevel] || styles.medium

  return (
    <div className="flex flex-col items-center gap-4">
      <div
        className={`verdict-seal inline-block border-[3px] px-6 py-3 font-tiro text-2xl font-bold uppercase tracking-wider md:text-3xl ${s.border} ${s.text} ${s.bg}`}
      >
        {verdictBn}
      </div>
      <p className="max-w-md text-center font-mono text-xs text-on-surface-variant">
        {DISCLAIMER}
      </p>
    </div>
  )
}

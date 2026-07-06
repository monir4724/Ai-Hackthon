import { DISCLAIMER } from '../config/modules'

interface Props {
  riskLevel: string
  verdictBn: string
  showDisclaimer?: boolean
  size?: 'md' | 'lg'
}

const styles: Record<string, { border: string; text: string; bg: string }> = {
  high: { border: 'border-danger', text: 'text-danger', bg: 'bg-danger/5' },
  medium: {
    border: 'border-secondary-container',
    text: 'text-on-secondary-container',
    bg: 'bg-secondary-container/10',
  },
  low: {
    border: 'border-secondary-container',
    text: 'text-on-secondary-container',
    bg: 'bg-secondary-container/10',
  },
  safe: { border: 'border-safe', text: 'text-safe', bg: 'bg-safe/5' },
}

export default function VerdictStamp({
  riskLevel,
  verdictBn,
  showDisclaimer = true,
  size = 'lg',
}: Props) {
  const s = styles[riskLevel] || styles.medium
  const textSize = size === 'lg' ? 'text-[42px] leading-tight' : 'text-xl'

  return (
    <div className="flex flex-col items-center gap-4 py-4">
      <div
        className={`verdict-seal ink-stamp-texture inline-block border-4 px-6 py-4 font-tiro font-bold tracking-tight uppercase ${textSize} ${s.border} ${s.text} ${s.bg}`}
      >
        {verdictBn}
      </div>
      <p className="font-mono text-xs tracking-widest text-outline uppercase">
        প্রাথমিক ফরেনসিক রিপোর্ট
      </p>
      {showDisclaimer && (
        <p className="max-w-md text-center font-mono text-xs text-on-surface-variant/70 italic">
          {DISCLAIMER}
        </p>
      )}
    </div>
  )
}

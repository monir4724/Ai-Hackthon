import { Link } from 'react-router-dom'
import { MODULES } from '../config/modules'

const statusBadge: Record<string, { label: string; className: string }> = {
  active: { label: 'সক্রিয়', className: 'bg-safe/15 text-safe' },
  partial: { label: 'আংশিক', className: 'bg-secondary-container/20 text-on-secondary-container' },
  roadmap: { label: 'রোডম্যাপ', className: 'bg-on-surface-variant/10 text-on-surface-variant' },
}

export default function ModulesPage() {
  return (
    <div>
      <p className="font-mono text-xs uppercase tracking-widest text-on-surface-variant">
        জাতীয় সাইবার ডিফেন্স — কমান্ড সেন্টার
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary-container md:text-4xl">
        ১০-মডিউল সুরক্ষা আর্কিটেকচার
      </h1>
      <p className="mt-3 max-w-3xl text-on-surface-variant">
        রক্ষাকবচ একটি মডুলার জাতীয়-স্তরের প্রতারণা প্রতিরোধ প্ল্যাটফর্ম। MVP-তে
        মডিউল ১–৩ সম্পূর্ণ কার্যকর; মডিউল ১০ আংশিক; বাকিগুলো স্ট্রাকচার্ড রোডম্যাপ।
      </p>

      <div className="mt-10 grid gap-4 md:grid-cols-2">
        {MODULES.map((mod) => {
          const badge = statusBadge[mod.status]
          const clickable = mod.status !== 'roadmap'

          const content = (
            <div
              className={`paper-card h-full p-5 transition ${
                clickable ? 'hover:border-primary-container/40' : 'opacity-80'
              }`}
            >
              <div className="flex items-start justify-between gap-3">
                <span className="font-mono text-2xl font-bold text-primary-container/30">
                  {String(mod.number).padStart(2, '0')}
                </span>
                <span className={`rounded px-2 py-0.5 font-mono text-xs ${badge.className}`}>
                  {badge.label}
                </span>
              </div>
              <h2 className="mt-3 font-tiro text-xl text-primary-container">{mod.title}</h2>
              <p className="mt-1 font-mono text-xs text-on-surface-variant">{mod.titleEn}</p>
              <p className="mt-3 text-sm text-on-surface-variant">{mod.description}</p>
              {mod.status === 'roadmap' && (
                <p className="mt-3 font-mono text-xs text-on-surface-variant">
                  শীঘ্রই আসছে — পরবর্তী ফেজে
                </p>
              )}
            </div>
          )

          return clickable ? (
            <Link key={mod.id} to={mod.path}>
              {content}
            </Link>
          ) : (
            <div key={mod.id}>{content}</div>
          )
        })}
      </div>
    </div>
  )
}

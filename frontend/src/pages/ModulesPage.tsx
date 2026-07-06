import { Link } from 'react-router-dom'
import Icon from '../components/Icon'
import { MODULES } from '../config/modules'

const statusBadge: Record<string, { label: string; className: string }> = {
  active: { label: 'সক্রিয়', className: 'bg-safe/15 text-safe' },
  partial: { label: 'আংশিক', className: 'bg-secondary-container/20 text-on-secondary-container' },
  roadmap: { label: 'শীঘ্রই আসছে', className: 'bg-on-surface-variant/10 text-on-surface-variant' },
}

export default function ModulesPage() {
  return (
    <div>
      <p className="font-mono text-xs uppercase tracking-widest text-outline">
        জাতীয় সাইবার ডিফেন্স — কমান্ড সেন্টার
      </p>
      <h1 className="mt-2 font-tiro text-3xl text-primary md:text-4xl">
        ১০-মডিউল সুরক্ষা আর্কিটেকচার
      </h1>
      <p className="mt-3 max-w-3xl text-on-surface-variant">
        রক্ষাকবচ একটি মডুলার জাতীয়-স্তরের প্রতারণা প্রতিরোধ প্ল্যাটফর্ম। MVP-তে
        মডিউল ১–৩ সম্পূর্ণ কার্যকর; মডিউল ১০ আংশিক; বাকিগুলো স্ট্রাকচার্ড রোডম্যাপ।
      </p>

      <div className="mt-10 grid gap-4 md:grid-cols-2">
        {MODULES.map((mod) => {
          const badge = statusBadge[mod.status]
          const isRoadmap = mod.status === 'roadmap'
          const isThreatIntel = mod.id === 'threat_intel'

          const content = (
            <div
              className={`paper-card h-full p-5 transition ${
                isRoadmap ? 'opacity-90' : 'hover:border-primary/40'
              }`}
            >
              <div className="flex items-start justify-between gap-3">
                <span className="font-mono text-2xl font-bold text-primary/30">
                  {String(mod.number).padStart(2, '0')}
                </span>
                <span className={`rounded px-2 py-0.5 font-mono text-xs ${badge.className}`}>
                  {badge.label}
                </span>
              </div>
              <div className="mt-3 flex items-center gap-2">
                <Icon name={mod.icon} className="text-primary" />
                <h2 className="font-tiro text-xl text-primary">{mod.title}</h2>
              </div>
              <p className="mt-1 font-mono text-xs text-on-surface-variant">{mod.titleEn}</p>
              <p className="mt-3 text-sm text-on-surface-variant">{mod.description}</p>

              {isRoadmap && (
                <p className="mt-4 flex items-center gap-2 font-mono text-xs text-outline">
                  <Icon name="schedule" className="text-base" />
                  শীঘ্রই আসছে
                </p>
              )}

              {isThreatIntel && (
                <div className="mt-4 flex flex-wrap gap-2">
                  <span className="inline-flex items-center gap-1 rounded border border-primary px-3 py-1 font-mono text-xs text-primary">
                    <Icon name="rss_feed" className="text-sm" />
                    ফিড
                  </span>
                  <span className="inline-flex items-center gap-1 rounded border border-primary px-3 py-1 font-mono text-xs text-primary">
                    <Icon name="flag" className="text-sm" />
                    রিপোর্ট
                  </span>
                </div>
              )}
            </div>
          )

          if (isThreatIntel) {
            return (
              <div key={mod.id} className="flex h-full flex-col gap-2">
                <Link to="/feed">{content}</Link>
                <Link
                  to="/report"
                  className="text-center font-mono text-xs text-primary underline"
                >
                  + নতুন স্ক্যাম রিপোর্ট করুন
                </Link>
              </div>
            )
          }

          return (
            <Link key={mod.id} to={mod.path}>
              {content}
            </Link>
          )
        })}
      </div>
    </div>
  )
}

import { Link, Navigate, useParams } from 'react-router-dom'
import Icon from '../components/Icon'
import { MODULES } from '../config/modules'

export default function ModulePlaceholderPage() {
  const { moduleId } = useParams()
  const mod = MODULES.find((m) => m.id === moduleId)

  if (mod && (mod.status === 'active' || mod.status === 'partial') && mod.path !== `/modules/${mod.id}`) {
    return <Navigate to={mod.path} replace />
  }

  return (
    <div className="mx-auto max-w-xl text-center">
      <p className="font-mono text-xs uppercase tracking-widest text-outline">রোডম্যাপ মডিউল</p>
      <div className="mt-8 flex justify-center">
        <div className="verdict-seal ink-stamp-texture inline-block border-4 border-outline px-6 py-3 font-tiro text-xl font-bold tracking-wider text-outline uppercase">
          শীঘ্রই আসছে
        </div>
      </div>
      <h1 className="mt-6 font-tiro text-3xl text-primary">{mod?.title || 'মডিউল'}</h1>
      <p className="mt-1 font-mono text-xs text-on-surface-variant">{mod?.titleEn}</p>
      <p className="mt-4 text-on-surface-variant">
        {mod?.description || 'এই মডিউল পরবর্তী ডেভেলপমেন্ট ফেজে আসবে।'}
      </p>
      <div className="mt-8 border border-outline-variant bg-surface-container-low p-6">
        <p className="flex items-center justify-center gap-2 font-mono text-sm text-on-surface-variant">
          <Icon name="engineering" />
          স্ট্যাটাস: পরিকল্পিত — জাতীয় সাইবার সুরক্ষা আর্কিটেকচারের অংশ
        </p>
      </div>
      <Link
        to="/modules"
        className="mt-8 inline-flex items-center gap-2 rounded bg-primary px-6 py-3 font-bold text-white transition hover:opacity-90"
      >
        <Icon name="arrow_back" />
        কমান্ড সেন্টারে ফিরুন
      </Link>
    </div>
  )
}

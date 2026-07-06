import { Link, useParams } from 'react-router-dom'
import { MODULES } from '../config/modules'

export default function ModulePlaceholderPage() {
  const { moduleId } = useParams()
  const mod = MODULES.find((m) => m.id === moduleId)

  return (
    <div className="mx-auto max-w-xl text-center">
      <p className="font-mono text-xs uppercase text-on-surface-variant">রোডম্যাপ মডিউল</p>
      <h1 className="mt-4 font-tiro text-3xl text-primary-container">
        {mod?.title || 'মডিউল'}
      </h1>
      <p className="mt-4 text-on-surface-variant">
        {mod?.description || 'এই মডিউল পরবর্তী ডেভেলপমেন্ট ফেজে আসবে।'}
      </p>
      <div className="mt-8 paper-card p-6">
        <p className="font-mono text-sm text-on-surface-variant">
          স্ট্যাটাস: পরিকল্পিত — জাতীয় সাইবার সুরক্ষা আর্কিটেকচারের অংশ
        </p>
      </div>
      <Link
        to="/modules"
        className="mt-8 inline-block rounded bg-primary-container px-6 py-3 font-bold text-white"
      >
        কমান্ড সেন্টারে ফিরুন
      </Link>
    </div>
  )
}

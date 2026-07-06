import { Link } from 'react-router-dom'
import { MODULES } from '../config/modules'

export default function HomePage() {
  const activeCount = MODULES.filter((m) => m.status === 'active').length

  return (
    <div>
      <section className="py-12 text-center md:py-20">
        <p className="mb-3 font-mono text-xs uppercase tracking-widest text-on-surface-variant">
          জাতীয় সাইবার সুরক্ষা প্ল্যাটফর্ম — প্রোটোটাইপ v1
        </p>
        <h1 className="font-tiro text-4xl leading-tight text-primary-container md:text-6xl">
          টাকা হারানোর আগেই ধরা পড়বে
        </h1>
        <p className="mx-auto mt-6 max-w-2xl text-lg text-on-surface-variant">
          রক্ষাকবচ — AI-চালিত বাংলা প্রতারণা সনাক্তকরণ। bKash, Nagad, Rocket
          মেসেজ, কল ট্রান্সক্রিপ্ট ও সন্দেহজন্য লিংক বিশ্লেষণ করে ঝুঁকি
          নির্দেশক দেয়।
        </p>
        <div className="mt-10 flex flex-wrap justify-center gap-4">
          <Link
            to="/scan"
            className="rounded bg-secondary-container px-8 py-4 font-bold text-on-secondary-container transition hover:opacity-90"
          >
            মেসেজ যাচাই করুন
          </Link>
          <Link
            to="/modules"
            className="rounded border border-primary-container px-8 py-4 font-bold text-primary-container transition hover:bg-primary-container/5"
          >
            ১০-মডিউল কমান্ড সেন্টার
          </Link>
        </div>

        <div className="mx-auto mt-16 max-w-lg">
          <div className="paper-card flex items-center justify-between gap-4 p-5">
            <div className="text-left">
              <div className="mb-2 flex items-center gap-2">
                <span className="status-dot bg-danger" />
                <span className="font-mono text-xs uppercase text-on-surface-variant">
                  Incoming SMS
                </span>
              </div>
              <p className="text-sm italic text-on-surface-variant">
                "আপনার bKash একাউন্ট ব্লক হয়েছে, OTP দিন..."
              </p>
            </div>
            <div className="verdict-seal border-[3px] border-danger bg-danger/5 px-3 py-2 font-tiro text-lg font-bold text-danger">
              উচ্চ ঝুঁকি
            </div>
          </div>
        </div>
      </section>

      <section className="border-y border-outline-variant bg-surface-container py-12">
        <div className="grid gap-4 md:grid-cols-3">
          <div className="paper-card p-6">
            <p className="font-mono text-2xl font-bold text-primary-container">
              ১০ জনে ১ জন
            </p>
            <p className="mt-3 text-on-surface-variant">
              বাংলাদেশে প্রতি ১০ জনে ১ জন মোবাইল ব্যাংকিং প্রতারণার শিকার।
            </p>
          </div>
          <div className="paper-card p-6">
            <p className="font-mono text-2xl font-bold text-primary-container">
              ২৩৭M+
            </p>
            <p className="mt-3 text-on-surface-variant">
              সক্রিয় এমএফএস একাউন্ট — সুরক্ষার চাহিদা বিশাল।
            </p>
          </div>
          <div className="paper-card p-6">
            <p className="font-mono text-2xl font-bold text-primary-container">
              {activeCount}/১০
            </p>
            <p className="mt-3 text-on-surface-variant">
              মডিউল সক্রিয়/আংশিক — বাকিগুলো রোডম্যাপে।
            </p>
          </div>
        </div>
      </section>

      <section className="py-16">
        <h2 className="mb-8 font-tiro text-3xl text-primary-container">
          কিভাবে কাজ করে?
        </h2>
        <div className="grid gap-6 md:grid-cols-3">
          {[
            {
              step: '০১',
              title: 'রুল-বেসড প্রি-ফিল্টার',
              desc: 'সন্দেহজন্য শব্দ, লিংক, OTP/পিন প্যাটার্ন আগে স্ক্যান।',
            },
            {
              step: '০২',
              title: 'AI যুক্তি',
              desc: 'GPT-4o বাংলা প্রসঙ্গ বুঝে ঝুঁকি ও প্যাটার্ন নির্ধারণ।',
            },
            {
              step: '০৩',
              title: 'সতর্কতা সিল',
              desc: 'নিরাপদ/সতর্ক/উচ্চ ঝুঁকি — স্পষ্ট বাংলা ব্যাখ্যা।',
            },
          ].map((item) => (
            <div key={item.step} className="paper-card p-6">
              <span className="font-mono text-sm text-secondary-container">
                {item.step}
              </span>
              <h3 className="mt-2 font-bold text-primary-container">
                {item.title}
              </h3>
              <p className="mt-2 text-on-surface-variant">{item.desc}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}

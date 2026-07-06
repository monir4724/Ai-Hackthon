import { Link } from 'react-router-dom'
import Icon from '../components/Icon'

const FORENSIC_IMAGE =
  'https://lh3.googleusercontent.com/aida-public/AB6AXuBqfGAWMS5MYSruDkBbmqsPuYxQXNmyflf9NTnLuBEno0IM1FySKQinK1QsjpYs_xYv6AOj5z6AfROuBx0W1DdMlunn7sTG_NRqud2RBcBPRWlP-jGb71HuM6bMCLP9W70N7gptpr65r0uD5HyD2wfSazTCafhCG6d3JQBrE6DDHkOxUqWDK0-phwc3rsyjl0NDRySj6QlKaZK8GV820_rC-4ySp-b3KmPmQiKYyWjbBqtkNGDqgzYLp_-XQHCdOJHhxc4MOxkbxSxD'

const HOW_IT_WORKS = [
  {
    icon: 'history',
    title: 'মেসেজ বিশ্লেষণ',
    desc: 'লিংক, ভাষার গঠন এবং প্রেরকের তথ্য মিলিয়ে দেখা হয়।',
  },
  {
    icon: 'report_problem',
    title: 'ঝুঁকি নির্ণয়',
    desc: 'আমাদের বিশাল ডেটাবেস থেকে প্রতারক চক্রের প্যাটার্ন খুঁজে বের করা হয়।',
  },
  {
    icon: 'verified_user',
    title: 'তাৎক্ষণিক সতর্কতা',
    desc: "ঝুঁকি থাকলে সরাসরি স্ক্রিনে সতর্ক বার্তা বা 'সিল' প্রদান করা হয়।",
  },
]

const STATS = [
  {
    value: '১০ জনে ১ জন',
    desc: 'বাংলাদেশে প্রতি ১০ জনে ১ জন মোবাইল ব্যাংকিং প্রতারণার শিকার হন।',
  },
  {
    value: '২৩৭ মিলিয়ন',
    desc: 'সারা দেশে বর্তমানে সক্রিয় এমএফএস একাউন্টের সংখ্যা।',
  },
  {
    value: '৯৮%+',
    desc: 'আমাদের কৃত্রিম বুদ্ধিমত্তা চালিত স্ক্যানিং সিস্টেমের সঠিকতা।',
  },
]

export default function HomePage() {
  return (
    <div>
      <section className="relative flex flex-col items-center overflow-hidden py-12 text-center md:py-20">
        <div className="pointer-events-none absolute inset-0 -z-10 opacity-10">
          <div className="absolute top-1/2 left-1/2 h-[600px] w-[600px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary blur-[120px]" />
        </div>

        <h1 className="font-tiro text-4xl leading-tight text-primary md:text-6xl">
          টাকা হারানোর আগেই ধরা পড়বে
        </h1>
        <p className="mx-auto mt-6 max-w-2xl text-lg text-on-surface-variant md:text-xl">
          আমাদের উন্নত AI সিস্টেম আপনার মোবাইলে আসা সন্দেহজনক bKash, Nagad এবং
          Rocket মেসেজগুলো বিশ্লেষণ করে আপনাকে প্রতারণা থেকে সুরক্ষা দেয়।
        </p>

        <div className="mt-10 flex flex-wrap justify-center gap-4">
          <Link
            to="/scan"
            className="flex items-center gap-3 rounded border border-secondary bg-secondary-container px-10 py-5 text-xl font-bold text-on-secondary-container transition-transform duration-200 hover:scale-105"
          >
            <Icon name="search_check" />
            মেসেজ যাচাই করুন
          </Link>
          <Link
            to="/modules"
            className="rounded border border-primary-container px-8 py-4 font-bold text-primary-container transition hover:bg-primary-container/5"
          >
            ১০-মডিউল কমান্ড সেন্টার
          </Link>
        </div>

        <div className="mx-auto mt-16 w-full max-w-md">
          <div className="paper-grain flex items-center justify-between gap-6 border border-outline-variant bg-surface-container-lowest p-5">
            <div className="flex-1 text-left">
              <div className="mb-2 flex items-center gap-2">
                <span className="status-dot bg-error" />
                <span className="font-mono text-xs uppercase tracking-widest text-outline">
                  Incoming SMS
                </span>
              </div>
              <p className="text-base leading-relaxed italic text-on-surface-variant opacity-80">
                "আপনার bKash একাউন্ট ব্লক হয়েছে, পুনরায় সচল করতে এই লিংকে
                ক্লিক করুন..."
              </p>
            </div>
            <div className="verdict-seal ink-stamp-texture border-[3px] border-error bg-error/5 px-4 py-2 font-tiro text-xl font-bold tracking-wider text-error uppercase">
              উচ্চ ঝুঁকি
            </div>
          </div>
          <p className="mt-3 text-center font-mono text-xs tracking-widest text-outline uppercase">
            লাইভ সিকিউরিটি প্যারামিটার সিমুলেশন
          </p>
        </div>
      </section>

      <section className="-mx-5 border-y border-outline-variant bg-surface-container-low px-5 py-12 md:-mx-10 md:px-10">
        <div className="grid gap-4 md:grid-cols-3">
          {STATS.map((stat) => (
            <div
              key={stat.value}
              className="flex flex-col gap-3 border border-outline-variant bg-surface p-8"
            >
              <span className="font-mono text-2xl font-bold text-primary">
                {stat.value}
              </span>
              <hr className="w-12 border-outline-variant" />
              <p className="text-on-surface-variant">{stat.desc}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="py-16">
        <div className="grid items-center gap-16 md:grid-cols-2">
          <div className="order-2 md:order-1">
            <div className="relative aspect-square w-full overflow-hidden border border-outline-variant bg-surface-container-high p-3">
              <img
                src={FORENSIC_IMAGE}
                alt="ডিজিটাল সুরক্ষা বিশ্লেষণ"
                className="h-full w-full object-cover"
              />
              <div className="pointer-events-none absolute top-8 right-8 h-24 w-24 border-2 border-primary/20" />
              <div className="pointer-events-none absolute bottom-8 left-8 h-24 w-24 border-2 border-primary/20" />
            </div>
          </div>
          <div className="order-1 md:order-2">
            <span className="mb-3 block font-mono text-xs font-bold tracking-widest text-secondary uppercase">
              তদারকি ও সুরক্ষা
            </span>
            <h2 className="mb-6 font-tiro text-3xl text-primary md:text-4xl">
              কিভাবে কাজ করে রক্ষা কবচ?
            </h2>
            <ul className="space-y-6">
              {HOW_IT_WORKS.map((item) => (
                <li key={item.title} className="flex gap-4">
                  <Icon name={item.icon} className="mt-1 text-primary" />
                  <div>
                    <h4 className="text-lg font-bold">{item.title}</h4>
                    <p className="text-on-surface-variant">{item.desc}</p>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>
    </div>
  )
}

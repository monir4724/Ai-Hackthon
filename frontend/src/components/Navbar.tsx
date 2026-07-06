import { Link, useLocation } from 'react-router-dom'

const navItems = [
  { to: '/', label: 'হোম' },
  { to: '/modules', label: 'মডিউল' },
  { to: '/scan', label: 'স্ক্যান' },
  { to: '/feed', label: 'ফিড' },
  { to: '/history', label: 'ইতিহাস' },
]

export default function Navbar() {
  const location = useLocation()

  return (
    <nav className="sticky top-0 z-50 flex items-center justify-between border-b border-outline-variant bg-surface px-5 py-3 md:px-10">
      <Link to="/" className="flex items-center gap-2">
        <span className="text-2xl text-primary-container">🛡</span>
        <span className="font-tiro text-xl font-bold text-primary-container">
          রক্ষাকবচ
        </span>
      </Link>
      <div className="hidden items-center gap-5 md:flex">
        {navItems.map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={`font-mono text-sm uppercase tracking-wider ${
              location.pathname === item.to
                ? 'font-bold text-primary-container'
                : 'text-on-surface-variant hover:text-primary-container'
            }`}
          >
            {item.label}
          </Link>
        ))}
      </div>
      <div className="flex items-center gap-2 font-mono text-xs text-safe">
        <span className="status-dot bg-safe" />
        সিস্টেম সচল
      </div>
    </nav>
  )
}

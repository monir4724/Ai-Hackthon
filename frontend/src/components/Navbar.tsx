import { Link, useLocation } from 'react-router-dom'
import Icon from './Icon'

const navItems = [
  { to: '/', label: 'হোম', match: (path: string) => path === '/' },
  { to: '/modules', label: 'মডিউল', match: (path: string) => path.startsWith('/modules') },
  { to: '/scan', label: 'স্ক্যান', match: (path: string) => path === '/scan' || path.startsWith('/result') },
  { to: '/feed', label: 'ফিড', match: (path: string) => path === '/feed' || path === '/report' },
  { to: '/history', label: 'ইতিহাস', match: (path: string) => path === '/history' },
]

export default function Navbar() {
  const location = useLocation()

  return (
    <nav className="sticky top-0 z-50 flex items-center justify-between border-b border-outline-variant bg-surface px-5 py-3 md:px-10">
      <Link to="/" className="flex items-center gap-2">
        <Icon name="shield_with_heart" filled className="text-2xl text-primary" />
        <span className="font-tiro text-xl font-bold text-primary">রক্ষাকবচ</span>
      </Link>
      <div className="hidden items-center gap-5 md:flex">
        {navItems.map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={`font-mono text-sm uppercase tracking-wider ${
              item.match(location.pathname)
                ? 'font-bold text-primary'
                : 'text-on-surface-variant hover:text-primary'
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

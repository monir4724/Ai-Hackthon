import { Link, useLocation } from 'react-router-dom'

const mobileNav = [
  { to: '/', label: 'হোম', icon: '🏠' },
  { to: '/scan', label: 'স্ক্যান', icon: '🔍' },
  { to: '/feed', label: 'ফিড', icon: '📡' },
  { to: '/modules', label: 'মডিউল', icon: '🛡' },
  { to: '/history', label: 'ইতিহাস', icon: '📋' },
]

export default function MobileNav() {
  const location = useLocation()

  return (
    <nav className="fixed bottom-0 left-0 z-50 flex h-16 w-full items-center justify-around border-t border-outline-variant bg-surface md:hidden">
      {mobileNav.map((item) => {
        const active =
          location.pathname === item.to ||
          (item.to === '/scan' && location.pathname.startsWith('/result'))
        return (
          <Link
            key={item.to}
            to={item.to}
            className={`flex flex-col items-center text-xs ${
              active ? 'font-bold text-primary-container' : 'text-on-surface-variant'
            }`}
          >
            <span className="text-lg">{item.icon}</span>
            <span className="font-mono">{item.label}</span>
          </Link>
        )
      })}
    </nav>
  )
}

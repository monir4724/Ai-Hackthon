import { Link, useLocation } from 'react-router-dom'
import Icon from './Icon'

const mobileNav = [
  { to: '/', label: 'হোম', icon: 'home' },
  { to: '/scan', label: 'স্ক্যান', icon: 'search_check' },
  { to: '/feed', label: 'ফিড', icon: 'rss_feed' },
  { to: '/modules', label: 'মডিউল', icon: 'shield' },
  { to: '/history', label: 'ইতিহাস', icon: 'history' },
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
              active ? 'font-bold text-primary' : 'text-outline'
            }`}
          >
            <Icon name={item.icon} filled={active} className="text-xl" />
            <span className="font-mono text-[10px]">{item.label}</span>
          </Link>
        )
      })}
    </nav>
  )
}

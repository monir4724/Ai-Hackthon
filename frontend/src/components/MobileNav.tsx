import { Link, useLocation } from 'react-router-dom'
import Icon from './Icon'

const mobileNav = [
  { to: '/', label: 'হোম', icon: 'home', match: (path: string) => path === '/' },
  {
    to: '/scan',
    label: 'স্ক্যান',
    icon: 'search_check',
    match: (path: string) => path === '/scan' || path.startsWith('/result') || path === '/url-check',
  },
  { to: '/feed', label: 'ফিড', icon: 'rss_feed', match: (path: string) => path === '/feed' || path === '/report' },
  { to: '/modules', label: 'মডিউল', icon: 'shield', match: (path: string) => path.startsWith('/modules') },
  { to: '/history', label: 'ইতিহাস', icon: 'history', match: (path: string) => path === '/history' },
]

export default function MobileNav() {
  const location = useLocation()

  return (
    <nav className="fixed bottom-0 left-0 z-50 flex h-16 w-full items-center justify-around border-t border-outline-variant bg-surface md:hidden">
      {mobileNav.map((item) => {
        const active = item.match(location.pathname)
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

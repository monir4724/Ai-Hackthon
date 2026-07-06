import { Outlet } from 'react-router-dom'
import Navbar from './Navbar'
import MobileNav from './MobileNav'

export default function Layout() {
  return (
    <div className="min-h-dvh bg-paper pb-20 md:pb-0">
      <Navbar />
      <main className="mx-auto max-w-6xl px-5 py-6 md:px-10">
        <Outlet />
      </main>
      <MobileNav />
    </div>
  )
}

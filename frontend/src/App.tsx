import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import HomePage from './pages/HomePage'
import ScanPage from './pages/ScanPage'
import ResultPage from './pages/ResultPage'
import HistoryPage from './pages/HistoryPage'
import FeedPage from './pages/FeedPage'
import ReportPage from './pages/ReportPage'
import UrlCheckPage from './pages/UrlCheckPage'
import ModulesPage from './pages/ModulesPage'
import ModulePlaceholderPage from './pages/ModulePlaceholderPage'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<HomePage />} />
          <Route path="/scan" element={<ScanPage />} />
          <Route path="/result" element={<ResultPage />} />
          <Route path="/history" element={<HistoryPage />} />
          <Route path="/feed" element={<FeedPage />} />
          <Route path="/report" element={<ReportPage />} />
          <Route path="/url-check" element={<UrlCheckPage />} />
          <Route path="/modules" element={<ModulesPage />} />
          <Route path="/modules/:moduleId" element={<ModulePlaceholderPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}

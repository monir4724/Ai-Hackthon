const SESSION_KEY = 'rokkhakoboch_session_id'

const PRODUCTION_API = 'https://ai-hackthon-production.up.railway.app/api'
const API_BASE =
  import.meta.env.VITE_API_URL ||
  (import.meta.env.PROD ? PRODUCTION_API : '/api')

export function getSessionId(): string {
  let id = localStorage.getItem(SESSION_KEY)
  if (!id) {
    id = crypto.randomUUID()
    localStorage.setItem(SESSION_KEY, id)
  }
  return id
}

export interface AnalysisResult {
  risk_level: 'high' | 'medium' | 'low' | 'safe'
  verdict_bn: string
  explanation: string
  matched_pattern: string
  confidence?: string
  disclaimer: string
  module?: string
  analyzed_at?: string
  prefilter?: {
    risk_score: number
    flags: string[]
    matched_patterns: string[]
    flag_count: number
  }
}

export interface ScamPattern {
  id: number
  category: string
  label: string
  risk_level: string
  text_bn: string
  location_label?: string | null
  red_flags_bn?: string
  is_community_report: boolean
  created_at: string
}

export interface ScanHistoryItem {
  id: number
  session_id: string
  module: string
  input_text: string
  risk_level: string
  matched_pattern?: string
  explanation?: string
  created_at: string
}

export interface UrlCheckResult {
  risk_level: string
  verdict_bn: string
  flags: string[]
  risk_score?: number
  explanation: string
  disclaimer: string
}

function parseApiError(payload: unknown, status: number): string {
  if (payload && typeof payload === 'object') {
    const err = payload as { message?: string; errors?: Record<string, string[]> }
    if (err.errors) {
      const first = Object.values(err.errors).flat()[0]
      if (first) return first
    }
    if (err.message) return err.message
  }
  if (status === 422) return 'অনুগ্রহ করে সঠিক তথ্য দিন।'
  if (status >= 500) return 'সার্ভারে সমস্যা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন।'
  return `API ত্রুটি (${status})`
}

async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    ...options,
  })
  if (!res.ok) {
    const err = await res.json().catch(() => ({}))
    throw new Error(parseApiError(err, res.status))
  }
  return res.json()
}

export async function analyzeText(
  text: string,
  module: string = 'sms'
): Promise<AnalysisResult> {
  return apiFetch<AnalysisResult>('/analyze', {
    method: 'POST',
    body: JSON.stringify({ text, module, session_id: getSessionId() }),
  })
}

export async function checkUrl(url: string): Promise<UrlCheckResult> {
  return apiFetch<UrlCheckResult>('/url-check', {
    method: 'POST',
    body: JSON.stringify({ url, session_id: getSessionId() }),
  })
}

export async function fetchReports(communityOnly = false): Promise<ScamPattern[]> {
  const q = communityOnly ? '?community_only=1' : ''
  const res = await apiFetch<{ data: ScamPattern[] }>(`/reports${q}`)
  return res.data
}

export async function submitReport(data: {
  text_bn: string
  category?: string
  location_label?: string
  risk_level?: string
}): Promise<ScamPattern> {
  const res = await apiFetch<{ data: ScamPattern }>('/reports', {
    method: 'POST',
    body: JSON.stringify(data),
  })
  return res.data
}

export async function fetchHistory(): Promise<ScanHistoryItem[]> {
  const res = await apiFetch<{ data: ScanHistoryItem[] }>(
    `/history/${getSessionId()}`
  )
  return res.data
}

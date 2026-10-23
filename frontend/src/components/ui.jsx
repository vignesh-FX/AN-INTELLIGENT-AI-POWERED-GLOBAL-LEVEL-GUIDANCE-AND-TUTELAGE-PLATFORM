import React, { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../lib/api.js'
import { assetUrl, initials } from '../lib/util.js'

const HUES = [212, 160, 28, 280, 340, 190, 100]
const hue = (s = '') => HUES[[...s].reduce((a, c) => a + c.charCodeAt(0), 0) % HUES.length]

export function Avatar({ user, size = 36 }) {
  const style = { width: size, height: size, fontSize: size * 0.38 }
  if (user?.avatar_url) return <img className="avatar" style={style} src={assetUrl(user.avatar_url)} alt="" />
  return <span className="avatar avatar-fallback" style={{ ...style, background: `hsl(${hue(user?.username)} 45% 90%)`, color: `hsl(${hue(user?.username)} 55% 28%)` }} aria-hidden="true">{initials(user?.name)}</span>
}

export function RoleBadge({ type }) {
  return <span className={`role-badge role-${type}`}>{type === 'expert' ? 'Expert' : 'Learner'}</span>
}

export function UserLink({ user, children }) {
  if (!user) return <span className="muted">[deleted]</span>
  return <Link to={`/u/${user.username}`} className="user-link">{children || user.name}</Link>
}

export const Spinner = () => <div className="spinner" role="progressbar" aria-label="Loading" />

export function Skeleton({ lines = 3, card = false }) {
  return (
    <div className={card ? 'card skeleton-card' : 'skeleton-block'} aria-hidden="true">
      <div className="sk sk-title" />
      {Array.from({ length: lines }, (_, i) => <div key={i} className="sk sk-line" style={{ width: `${95 - i * 12}%` }} />)}
    </div>
  )
}
export const SkeletonList = ({ n = 3 }) => <div className="stack">{Array.from({ length: n }, (_, i) => <Skeleton key={i} card />)}</div>

export function Empty({ icon = '∅', title, children, action }) {
  return (
    <div className="empty">
      <div className="empty-icon" aria-hidden="true">{icon}</div>
      <h3>{title}</h3>
      {children && <p className="muted">{children}</p>}
      {action}
    </div>
  )
}

export function ErrorState({ error, onRetry }) {
  return (
    <div className="empty error-state" role="alert">
      <div className="empty-icon" aria-hidden="true">!</div>
      <h3>{error?.status === 404 ? 'Not found' : 'Something went wrong'}</h3>
      <p className="muted">{error?.message || 'Please try again.'}</p>
      {onRetry && error?.status !== 404 && <button className="btn" onClick={onRetry}>Try again</button>}
    </div>
  )
}

/** Renders loading / error / empty / content for a useLoad() result. */
export function Async({ state, skeleton, empty, children }) {
  if (state.loading && !state.data) return skeleton || <SkeletonList />
  if (state.error) return <ErrorState error={state.error} onRetry={state.reload} />
  if (empty && (!state.data || (Array.isArray(state.data) && !state.data.length))) return empty
  return children(state.data)
}

export function Field({ label, hint, children, htmlFor }) {
  return (
    <div className="field">
      <label htmlFor={htmlFor}>{label}</label>
      {children}
      {hint && <div className="hint">{hint}</div>}
    </div>
  )
}

export function TagInput({ value, onChange, placeholder = 'Type a tag and press Enter', max = 8, id }) {
  const [text, setText] = useState('')
  const add = () => {
    const t = text.trim().replace(/^#/, '')
    if (t && !value.map(v => v.toLowerCase()).includes(t.toLowerCase()) && value.length < max) onChange([...value, t])
    setText('')
  }
  return (
    <div className="tag-input">
      {value.map(t => (
        <span key={t} className="chip">{t}<button type="button" aria-label={`Remove ${t}`} onClick={() => onChange(value.filter(x => x !== t))}>×</button></span>
      ))}
      <input id={id} value={text} placeholder={value.length ? '' : placeholder} maxLength={40}
        onChange={e => setText(e.target.value)} onBlur={add}
        onKeyDown={e => { if (e.key === 'Enter' || e.key === ',') { e.preventDefault(); add() } else if (e.key === 'Backspace' && !text && value.length) onChange(value.slice(0, -1)) }} />
    </div>
  )
}

export function Modal({ title, onClose, children }) {
  const ref = useRef()
  useEffect(() => {
    const prev = document.activeElement
    ref.current?.focus()
    const esc = (e) => e.key === 'Escape' && onClose()
    document.addEventListener('keydown', esc)
    return () => { document.removeEventListener('keydown', esc); prev?.focus?.() }
  }, [onClose])
  return (
    <div className="modal-backdrop" onMouseDown={(e) => e.target === e.currentTarget && onClose()}>
      <div className="modal" role="dialog" aria-modal="true" aria-label={title} tabIndex={-1} ref={ref}>
        <div className="modal-head"><h3>{title}</h3><button className="icon-btn" onClick={onClose} aria-label="Close">×</button></div>
        {children}
      </div>
    </div>
  )
}

export function Tabs({ tabs, value, onChange }) {
  return (
    <div className="tabs" role="tablist">
      {tabs.map(t => (
        <button key={t.id} role="tab" aria-selected={value === t.id} className={value === t.id ? 'tab active' : 'tab'} onClick={() => onChange(t.id)}>
          {t.label}{t.count != null && <span className="tab-count">{t.count}</span>}
        </button>
      ))}
    </div>
  )
}

// ── rich text (no dangerouslySetInnerHTML: everything is rendered as React nodes) ──────────
function inline(text, keyBase) {
  const re = /(`[^`\n]+`)|(https?:\/\/[^\s<]+[^\s<.,;:!?)])|(@[A-Za-z0-9_]{3,30})/g
  const out = []
  let last = 0, m, i = 0
  while ((m = re.exec(text))) {
    if (m.index > last) out.push(text.slice(last, m.index))
    const k = `${keyBase}-${i++}`
    if (m[1]) out.push(<code key={k}>{m[1].slice(1, -1)}</code>)
    else if (m[2]) out.push(<a key={k} href={m[2]} target="_blank" rel="noopener noreferrer nofollow">{m[2]}</a>)
    else out.push(<Link key={k} to={`/u/${m[3].slice(1)}`} className="mention">{m[3]}</Link>)
    last = m.index + m[0].length
  }
  if (last < text.length) out.push(text.slice(last))
  return out
}

export function RichText({ text, className = '' }) {
  const parts = (text || '').split(/```(?:[\w+-]*\n)?([\s\S]*?)```/g)
  return (
    <div className={`rich ${className}`}>
      {parts.map((p, i) => i % 2 === 1
        ? <pre key={i}><code>{p.replace(/\n$/, '')}</code></pre>
        : p.split(/\n{2,}/).filter(s => s.trim()).map((para, j) => (
          <p key={`${i}-${j}`}>{para.split('\n').map((line, k, arr) => <React.Fragment key={k}>{inline(line, `${i}-${j}-${k}`)}{k < arr.length - 1 && <br />}</React.Fragment>)}</p>
        )))}
    </div>
  )
}

export function useDebounced(value, ms = 300) {
  const [v, setV] = useState(value)
  useEffect(() => { const t = setTimeout(() => setV(value), ms); return () => clearTimeout(t) }, [value, ms])
  return v
}

export function ImageUpload({ value, onChange, user }) {
  const [busy, setBusy] = useState(false); const [err, setErr] = useState('')
  const pick = async (e) => {
    const f = e.target.files?.[0]; if (!f) return
    setBusy(true); setErr('')
    try { const r = await api.upload(f); onChange(r.url) }
    catch (ex) { setErr(ex.message) } finally { setBusy(false) }
  }
  return (
    <div className="row gap-sm">
      <Avatar user={{ ...(user || {}), avatar_url: value }} size={56} />
      <div>
        <label className="btn btn-sm">{busy ? 'Uploading…' : value ? 'Change picture' : 'Upload picture'}
          <input type="file" accept="image/png,image/jpeg,image/gif,image/webp" onChange={pick} hidden /></label>
        {value && <button type="button" className="link-btn" onClick={() => onChange(null)}> Remove</button>}
        {err && <div className="field-error" role="alert">{err}</div>}
      </div>
    </div>
  )
}

export function LangPicker({ value, onChange }) {
  const [langs, setLangs] = useState([])
  useEffect(() => { api.languages().then(setLangs).catch(() => {}) }, [])
  const toggle = (n) => onChange(value.includes(n) ? value.filter(x => x !== n) : [...value, n])
  return (
    <div className="chips-pick" role="group" aria-label="Preferred languages">
      {langs.map(l => <button type="button" key={l.code} aria-pressed={value.includes(l.name)} className={value.includes(l.name) ? 'chip on' : 'chip'} onClick={() => toggle(l.name)}>{l.name}</button>)}
      {!langs.length && <span className="muted small">Loading languages…</span>}
    </div>
  )
}

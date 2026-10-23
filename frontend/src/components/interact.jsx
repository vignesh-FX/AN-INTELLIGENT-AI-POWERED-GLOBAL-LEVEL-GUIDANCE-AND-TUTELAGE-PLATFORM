import React, { useEffect, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useOptimistic, useToast } from '../lib/hooks.jsx'
import { Modal } from './ui.jsx'

/** Wrap an action so signed-out visitors are sent to log in instead of getting a 401. */
export function useGate() {
  const { user } = useAuth(); const nav = useNavigate(); const loc = useLocation(); const toast = useToast()
  return (fn) => (...args) => {
    if (!user) { toast.error('Please log in to do that'); nav(`/login/learner?next=${encodeURIComponent(loc.pathname)}`); return }
    return fn(...args)
  }
}

export function VoteBar({ type, id, score, myVote, own, horizontal }) {
  const gate = useGate()
  const [s, act] = useOptimistic({ score, my_vote: myVote })
  const cast = (dir) => {
    const next = s.my_vote === dir ? 0 : dir
    act({ score: s.score - s.my_vote + next, my_vote: next }, () => api.vote(type, id, next))
  }
  const dis = own
  return (
    <div className={`votebar${horizontal ? ' horizontal' : ''}`} role="group" aria-label="Vote">
      <button className={`vote up${s.my_vote === 1 ? ' on' : ''}`} disabled={dis} title={own ? "You can't vote on your own content" : 'Upvote'} aria-pressed={s.my_vote === 1} aria-label="Upvote" onClick={gate(() => cast(1))}>▲</button>
      <span className="score" aria-label={`Score ${s.score}`}>{s.score}</span>
      <button className={`vote down${s.my_vote === -1 ? ' on' : ''}`} disabled={dis} title={own ? "You can't vote on your own content" : 'Downvote'} aria-pressed={s.my_vote === -1} aria-label="Downvote" onClick={gate(() => cast(-1))}>▼</button>
    </div>
  )
}

const EMOJI = ['👍', '❤️', '🎉', '💡', '🤔', '🙏']
export function ReactionBar({ type, id, reactions, mine }) {
  const gate = useGate()
  const [s, act] = useOptimistic({ reactions: reactions || {}, my_reactions: mine || [] })
  const [open, setOpen] = useState(false)
  const toggle = (e) => {
    const has = s.my_reactions.includes(e)
    act((cur) => {
      const r = { ...cur.reactions }
      r[e] = (r[e] || 0) + (has ? -1 : 1)
      if (r[e] <= 0) delete r[e]
      return { reactions: r, my_reactions: has ? cur.my_reactions.filter(x => x !== e) : [...cur.my_reactions, e] }
    }, () => api.react(type, id, e))
    setOpen(false)
  }
  return (
    <span className="reactions">
      {Object.entries(s.reactions).map(([e, n]) => (
        <button key={e} className={`react${s.my_reactions.includes(e) ? ' on' : ''}`} aria-pressed={s.my_reactions.includes(e)} onClick={gate(() => toggle(e))}>{e} {n}</button>
      ))}
      <span className="react-add">
        <button className="react" aria-label="Add reaction" aria-expanded={open} onClick={() => setOpen(o => !o)}>☺+</button>
        {open && <span className="react-pop">{EMOJI.map(e => <button key={e} onClick={gate(() => toggle(e))} aria-label={`React ${e}`}>{e}</button>)}</span>}
      </span>
    </span>
  )
}

export function SaveButton({ id, saved }) {
  const gate = useGate()
  const [s, act] = useOptimistic({ saved })
  return (
    <button className={`link-btn${s.saved ? ' on' : ''}`} aria-pressed={s.saved} onClick={gate(() =>
      act({ saved: !s.saved }, async () => { s.saved ? await api.unsave(id) : await api.save(id); return null }))}>
      {s.saved ? '★ Saved' : '☆ Save'}
    </button>
  )
}

export function ShareButton({ path }) {
  const toast = useToast()
  return <button className="link-btn" onClick={async () => {
    try { await navigator.clipboard.writeText(location.origin + path); toast.success('Link copied') } catch { toast.error('Could not copy the link') }
  }}>Share</button>
}

export function ReportButton({ type, id }) {
  const gate = useGate()
  const [open, setOpen] = useState(false)
  return (<>
    <button className="link-btn" onClick={gate(() => setOpen(true))}>Report</button>
    {open && <ReportModal type={type} id={id} onClose={() => setOpen(false)} />}
  </>)
}

function ReportModal({ type, id, onClose }) {
  const toast = useToast()
  const [reason, setReason] = useState('spam'); const [details, setDetails] = useState(''); const [busy, setBusy] = useState(false)
  const submit = async (e) => {
    e.preventDefault(); setBusy(true)
    try { const r = await api.report(type, id, reason, details); toast.success(r.duplicate ? 'You already reported this' : 'Thanks — moderators will take a look'); onClose() }
    catch (err) { toast.error(err.message); setBusy(false) }
  }
  return (
    <Modal title={`Report ${type}`} onClose={onClose}>
      <form onSubmit={submit} className="stack">
        <div className="field"><label htmlFor="rp-reason">Reason</label>
          <select id="rp-reason" value={reason} onChange={e => setReason(e.target.value)}>
            {['spam', 'abuse', 'harassment', 'off_topic', 'misinformation', 'other'].map(r => <option key={r} value={r}>{r.replace('_', ' ')}</option>)}
          </select></div>
        <div className="field"><label htmlFor="rp-details">Details (optional)</label>
          <textarea id="rp-details" rows={3} maxLength={1000} value={details} onChange={e => setDetails(e.target.value)} /></div>
        <div className="row end"><button type="button" className="btn" onClick={onClose}>Cancel</button><button className="btn btn-primary" disabled={busy}>Send report</button></div>
      </form>
    </Modal>
  )
}

// ── translation ──────────────────────────────────────────────────────────────
let langPromise
const loadLangs = () => (langPromise ||= api.languages().catch(e => { langPromise = null; throw e }))

/**
 * “See translation”: `render(parts)` is called with null (original) or the translated {title?, body}.
 * The original is never replaced — the user can always switch back.
 */
export function Translatable({ type, id, render, compact }) {
  const { user } = useAuth(); const gate = useGate()
  const [langs, setLangs] = useState([])
  const [open, setOpen] = useState(false)
  const [target, setTarget] = useState(() => localStorage.getItem('gg_lang') || 'en')
  const [source, setSource] = useState('')
  const [st, setSt] = useState({ phase: 'idle' })     // idle | loading | ok | same | needs_source | error
  const [showOriginal, setShowOriginal] = useState(false)

  useEffect(() => {
    if (!open || langs.length) return
    loadLangs().then(l => {
      setLangs(l)
      if (!localStorage.getItem('gg_lang') && user?.languages?.length) {
        const hit = l.find(x => user.languages.some(u => u.toLowerCase() === x.name.toLowerCase()))
        if (hit) setTarget(hit.code)
      }
    }).catch(() => setSt({ phase: 'error', message: 'Could not load languages' }))
  }, [open]) // eslint-disable-line

  const run = async (src = source) => {
    setSt({ phase: 'loading' }); setShowOriginal(false)
    localStorage.setItem('gg_lang', target)
    try {
      const r = await api.translate({ target_type: type, target_id: id, target_lang: target, source_lang: src || undefined })
      if (r.status === 'needs_source') setSt({ phase: 'needs_source', message: r.message })
      else if (r.status === 'same_language') setSt({ phase: 'same', r })
      else setSt({ phase: 'ok', r })
    } catch (e) { setSt({ phase: 'error', message: e.message }) }
  }
  const nameOf = (c) => langs.find(l => l.code === c)?.name || c
  const translated = st.phase === 'ok' && !showOriginal ? st.r.translated : null

  return (
    <>
      {render(translated)}
      <div className="translate">
        {!open ? (
          <button className="link-btn" onClick={gate(() => setOpen(true))}>Translate</button>
        ) : (
          <div className="translate-panel" aria-live="polite">
            <div className="row wrap gap-sm">
              {st.phase === 'needs_source' || source ? (
                <select aria-label="Original language" value={source} onChange={e => setSource(e.target.value)}>
                  <option value="">Auto-detect source</option>
                  {langs.map(l => <option key={l.code} value={l.code}>{l.name}</option>)}
                </select>) : null}
              <label className="sr-only" htmlFor={`tl-${id}`}>Translate to</label>
              <select id={`tl-${id}`} value={target} onChange={e => setTarget(e.target.value)}>
                {(langs.length ? langs : [{ code: target, name: target }]).map(l => <option key={l.code} value={l.code}>→ {l.name}</option>)}
              </select>
              <button className="btn btn-sm" onClick={() => run()} disabled={st.phase === 'loading'}>{st.phase === 'loading' ? 'Translating…' : st.phase === 'ok' ? 'Translate again' : 'Translate'}</button>
              {st.phase === 'ok' && <button className="link-btn" onClick={() => setShowOriginal(s => !s)}>{showOriginal ? 'Show translation' : 'Show original'}</button>}
              {!source && st.phase !== 'needs_source' && <button className="link-btn" onClick={() => setSource(st.phase === 'ok' ? st.r.source_lang : 'en')}>Wrong language?</button>}
              <button className="link-btn" onClick={() => { setOpen(false); setSt({ phase: 'idle' }) }}>Close</button>
            </div>
            {st.phase === 'loading' && <div className="muted small"><span className="spinner sm" /> Translating with NLLB-200…</div>}
            {st.phase === 'ok' && <div className="muted small">{showOriginal ? 'Showing original' : `Translated from ${nameOf(st.r.source_lang)}`}{st.r.cached ? ' · cached' : ''}</div>}
            {st.phase === 'same' && <div className="muted small">This is already in {nameOf(st.r.target_lang)}.</div>}
            {st.phase === 'needs_source' && <div className="notice">{st.message}</div>}
            {st.phase === 'error' && <div className="notice notice-error" role="alert">{st.message}</div>}
          </div>
        )}
      </div>
    </>
  )
}

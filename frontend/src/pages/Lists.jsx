import React from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad } from '../lib/hooks.jsx'
import PostCard from '../components/PostCard.jsx'
import { Async, Avatar, Empty } from '../components/ui.jsx'
import { timeAgo } from '../lib/util.js'

export function MyQuestions() {
  const s = useLoad(() => api.myQuestions(), [])
  return (<div><div className="page-head"><div><h1>My Questions</h1><p className="muted">Everything you've asked, and the answers it received.</p></div><Link className="btn btn-primary" to="/ask">Ask a Question</Link></div>
    <Async state={s} empty={<Empty icon="❓" title="You haven't asked anything yet" action={<Link className="btn btn-primary" to="/ask">Ask your first question</Link>}>Post a question and relevant experts will see it in their feeds.</Empty>}>
      {(d) => <div className="stack">{d.map(p => <PostCard key={p.id} post={p} />)}</div>}</Async></div>)
}

export function MyAnswers() {
  const s = useLoad(() => api.myAnswers(), [])
  return (<div><div className="page-head"><div><h1>My Answers</h1><p className="muted">Your answers and replies, with how learners rated them.</p></div></div>
    <Async state={s} empty={<Empty icon="💬" title="No answers yet" action={<Link className="btn btn-primary" to="/for-you">See questions for you</Link>}>Answer a question from your feed to see it here.</Empty>}>
      {(d) => <div className="stack">{d.map(a => (
        <div key={a.id} className="card">
          <div className="row between wrap"><Link to={`/post/${a.post.id}#c-${a.id}`}><strong>{a.post.title}</strong></Link><span className="muted small">{a.post.community} · {timeAgo(a.created_at)}</span></div>
          <p className="muted clamp">{a.body}</p>
          <div className="row gap-sm wrap">
            <span className="chip">{a.is_answer ? 'Answer' : 'Reply'}</span>
            {a.is_accepted && <span className="chip chip-accepted">✓ Accepted</span>}
            <span className="small">▲ {a.score}</span>
            {a.rating && <span className="small">⭐ {a.rating.average} <span className="muted">({a.rating.count})</span></span>}
          </div></div>))}</div>}</Async></div>)
}

export function Saved() {
  const s = useLoad(() => api.saved(), [])
  return (<div><div className="page-head"><div><h1>Saved</h1></div></div>
    <Async state={s} empty={<Empty icon="☆" title="Nothing saved yet">Use “Save” on any post to keep it here.</Empty>}>
      {(d) => <div className="stack">{d.map(p => <PostCard key={p.id} post={p} />)}</div>}</Async></div>)
}

const ICON = { answer: '💬', reply: '↩️', mention: '@', accepted: '✓', rated: '⭐', new_question: '🎯', post_activity: '🔔', announcement: '📣', moderation: '🛡️', join_request: '👥', community: '👥', banned: '⛔', moderator: '🛡️' }

export function Notifications() {
  const { setUnread, refreshUnread } = useAuth(); const nav = useNavigate()
  const s = useLoad(() => api.notifications(), [])
  const open = async (n) => {
    if (!n.is_read) { s.setData(d => d.map(x => x.id === n.id ? { ...x, is_read: true } : x)); api.readOne(n.id).then(refreshUnread).catch(() => {}) }
    if (n.post_id) nav(`/post/${n.post_id}${n.comment_id ? `#c-${n.comment_id}` : ''}`)
  }
  const all = async () => { s.setData(d => d.map(x => ({ ...x, is_read: true }))); setUnread(0); try { await api.readAll() } catch { s.reload(); refreshUnread() } }
  return (<div><div className="page-head"><div><h1>Notifications</h1></div><button className="btn" onClick={all}>Mark all as read</button></div>
    <Async state={s} empty={<Empty icon="🔔" title="You're all caught up">Answers, replies, mentions and ratings will show up here.</Empty>}>
      {(d) => <div className="card list">{d.map(n => (
        <button key={n.id} className={`notif${n.is_read ? '' : ' unread'}`} onClick={() => open(n)}>
          <span className="notif-ico" aria-hidden="true">{ICON[n.type] || '🔔'}</span>
          <span className="grow left">{n.message}<span className="muted small block">{timeAgo(n.created_at)}</span></span>
          {!n.is_read && <span className="sr-only">Unread</span>}{!n.is_read && <span className="unread-dot" aria-hidden="true" />}
        </button>))}</div>}</Async></div>)
}

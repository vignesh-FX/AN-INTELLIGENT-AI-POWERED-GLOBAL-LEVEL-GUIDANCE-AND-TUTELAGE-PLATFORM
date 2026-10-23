import React, { useState } from 'react'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad, useOptimistic, useToast } from '../lib/hooks.jsx'
import { timeAgo } from '../lib/util.js'
import { Link } from 'react-router-dom'
import { Avatar, ErrorState, RichText, RoleBadge, SkeletonList, UserLink } from './ui.jsx'
import { ReactionBar, ReportButton, ShareButton, Translatable, VoteBar, useGate } from './interact.jsx'

// ── immutable tree helpers ───────────────────────────────────────────────────
const mapTree = (nodes, id, fn) => nodes.map(n => n.id === id ? fn(n) : { ...n, children: mapTree(n.children, id, fn) })
const removeFrom = (nodes, id) => nodes.filter(n => n.id !== id).map(n => ({ ...n, children: removeFrom(n.children, id) }))
const insertInto = (nodes, parentId, node) => parentId
  ? mapTree(nodes, parentId, n => ({ ...n, children: [...n.children, node], reply_count: n.reply_count + 1 }))
  : [...nodes, node]
const mapAll = (nodes, fn) => nodes.map(n => ({ ...fn(n), children: mapAll(n.children, fn) }))

const STAR_LABELS = ['Not helpful', 'Slightly helpful', 'Helpful', 'Very helpful', 'Extremely helpful']

export function Composer({ onSubmit, placeholder, label, autoFocus, submitLabel = 'Reply', onCancel, initial = '' }) {
  const [text, setText] = useState(initial)
  const submit = async (e) => {
    e?.preventDefault()
    const body = text.trim()
    if (!body) return
    setText('')                                   // optimistic: clear right away…
    const ok = await onSubmit(body)
    if (ok === false) setText(body)               // …and put the text back if the server refused it
    else onCancel?.()
  }
  return (
    <form className="composer" onSubmit={submit}>
      <label className="sr-only" htmlFor={`cmp-${label}`}>{label}</label>
      <textarea id={`cmp-${label}`} rows={3} value={text} autoFocus={autoFocus} maxLength={10000} placeholder={placeholder}
        onChange={e => setText(e.target.value)} onKeyDown={e => { if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') submit(e) }} />
      <div className="row end gap-sm">
        <span className="muted small grow">Markdown-style `code` and ``` blocks work · @username to mention</span>
        {onCancel && <button type="button" className="btn btn-sm" onClick={onCancel}>Cancel</button>}
        <button className="btn btn-primary btn-sm" disabled={!text.trim()}>{submitLabel}</button>
      </div>
    </form>
  )
}

function RatingBox({ node, own }) {
  const gate = useGate()
  const [s, act] = useOptimistic({ rating: node.rating, helpful: node.helpful })
  const [picking, setPicking] = useState(false)
  const r = s.rating, h = s.helpful

  const rate = (n) => {
    setPicking(false)
    const prev = r
    const count = prev.mine ? prev.count : prev.count + 1
    const sum = (prev.average || 0) * prev.count - (prev.mine || 0) + n
    act({ rating: { average: Math.round((sum / count) * 100) / 100, count, mine: n } }, () => api.rate(node.id, n))
  }
  const unrate = () => {
    setPicking(false)
    const count = r.count - 1
    const sum = (r.average || 0) * r.count - r.mine
    act({ rating: { average: count ? Math.round((sum / count) * 100) / 100 : null, count, mine: null } }, () => api.unrate(node.id))
  }
  const toggleHelpful = () => act({ helpful: { ...h, mine: !h.mine, count: h.count + (h.mine ? -1 : 1) } }, () => api.helpful(node.id, !h.mine))

  return (
    <div className="rating-box">
      <div className="rating-stats">
        <span className="stars" aria-label={r.average ? `Rated ${r.average} out of 5 by ${r.count} people` : 'No ratings yet'}>
          {r.average ? <>⭐ <strong>{r.average.toFixed(1)}</strong> / 5 <span className="muted">· {r.count} rating{r.count === 1 ? '' : 's'}</span></> : <span className="muted">No ratings yet</span>}
        </span>
        {h.percent != null && <span>👍 <strong>{h.percent}%</strong> <span className="muted">found this helpful</span></span>}
      </div>
      {!own && (
        <div className="row wrap gap-sm">
          <button className={`btn btn-sm${h.mine ? ' btn-on' : ''}`} aria-pressed={h.mine} onClick={gate(toggleHelpful)}>👍 Helpful{h.count ? ` · ${h.count}` : ''}</button>
          <button className="btn btn-sm" aria-expanded={picking} onClick={gate(() => setPicking(p => !p))}>{r.mine ? `Your rating: ${'★'.repeat(r.mine)}` : 'Rate answer'}</button>
        </div>
      )}
      {picking && (
        <div className="star-picker" role="radiogroup" aria-label="Rate this answer">
          {[1, 2, 3, 4, 5].map(n => (
            <button key={n} role="radio" aria-checked={r.mine === n} className={r.mine === n ? 'on' : ''} onClick={() => rate(n)}>
              <span aria-hidden="true">{'★'.repeat(n)}</span> {n} — {STAR_LABELS[n - 1]}
            </button>
          ))}
          {r.mine && <button className="link-btn" onClick={unrate}>Remove my rating</button>}
        </div>
      )}
    </div>
  )
}

function CommentNode({ node, depth, ctx }) {
  const { user, post } = ctx
  const [collapsed, setCollapsed] = useState(false)
  const [replying, setReplying] = useState(false)
  const [editing, setEditing] = useState(false)
  const [revealBlocked, setRevealBlocked] = useState(false)
  const pending = node.id.startsWith('tmp-')
  const gone = node.is_deleted || node.is_removed
  const own = user?.id === node.author?.id
  const canAccept = user && post.author.id === user.id && node.is_answer && !gone
  const hidden = node.blocked && !revealBlocked && !own

  return (
    <div className={`comment d${Math.min(depth, 8)}${node.is_accepted ? ' accepted' : ''}${node.is_answer ? ' answer' : ''}${pending ? ' pending' : ''}`} id={`c-${node.id}`}>
      <button className="rail" aria-expanded={!collapsed} aria-label={collapsed ? 'Expand thread' : 'Collapse thread'} onClick={() => setCollapsed(c => !c)}><span /></button>
      <div className="c-main">
        <div className="c-head">
          {collapsed && <button className="link-btn" onClick={() => setCollapsed(false)} aria-label="Expand">[+]</button>}
          <Avatar user={node.author} size={node.is_answer ? 30 : 24} />
          <UserLink user={node.author} />
          {node.author && <RoleBadge type={node.author.user_type} />}
          {node.author?.title && node.is_answer && <span className="muted small">{node.author.title}</span>}
          {node.author?.quality_score != null && <span className="chip chip-quality" title="Expert quality score: Bayesian-weighted rating, helpfulness, accepted answers and votes">Quality {Math.round(node.author.quality_score)}</span>}
          {node.is_accepted && <span className="chip chip-accepted">✓ Accepted answer</span>}
          {node.is_best && <span className="chip chip-best">★ Best answer</span>}
          <span className="muted small">{pending ? 'posting…' : timeAgo(node.created_at)}{node.edited_at && ' · edited'}</span>
          {collapsed && node.reply_count > 0 && <span className="muted small">· {node.reply_count} hidden</span>}
        </div>

        {!collapsed && (hidden ? (
          <div className="muted small">You blocked this user. <button className="link-btn" onClick={() => setRevealBlocked(true)}>Show comment</button></div>
        ) : (
          <>
            {editing ? (
              <Composer label={`edit-${node.id}`} initial={node.body} submitLabel="Save" autoFocus onCancel={() => setEditing(false)}
                onSubmit={(b) => ctx.edit(node, b)} />
            ) : gone ? (
              <p className="muted gone">{node.body}</p>
            ) : (
              <Translatable type="comment" id={node.id} render={(p) => <RichText text={p?.body ?? node.body} />} />
            )}

            {node.is_answer && !gone && node.rating && <RatingBox node={node} own={own} />}

            {!gone && !editing && (
              <div className="c-actions">
                <VoteBar type="comment" id={node.id} score={node.score} myVote={node.my_vote} own={own || pending} horizontal />
                {!pending && <button className="link-btn" onClick={ctx.gate(() => setReplying(r => !r))}>Reply</button>}
                {!pending && <ReactionBar type="comment" id={node.id} reactions={node.reactions} mine={node.my_reactions} />}
                {canAccept && <button className={`link-btn${node.is_accepted ? ' on' : ''}`} onClick={() => ctx.accept(node)}>{node.is_accepted ? 'Unaccept' : '✓ Accept answer'}</button>}
                {own && !pending && <button className="link-btn" onClick={() => setEditing(true)}>Edit</button>}
                {(own || ctx.isMod) && !pending && <button className="link-btn danger" onClick={() => ctx.remove(node, own)}>Delete</button>}
                {!pending && <ShareButton path={`/post/${post.id}#c-${node.id}`} />}
                {!pending && !own && <ReportButton type="comment" id={node.id} />}
                {!pending && !own && user && node.author && <button className="link-btn" onClick={() => ctx.block(node.author)}>Block</button>}
              </div>
            )}
            {replying && (
              <Composer label={`reply-${node.id}`} placeholder={`Reply to ${node.author?.name || 'comment'}…`} autoFocus onCancel={() => setReplying(false)}
                onSubmit={(b) => ctx.add(b, node.id)} />
            )}
            {node.children.length > 0 && (
              <div className="children">
                {node.children.map(c => <CommentNode key={c.id} node={c} depth={depth + 1} ctx={ctx} />)}
              </div>
            )}
          </>
        ))}
      </div>
    </div>
  )
}

export default function Thread({ post, isMod, onPostChange }) {
  const { user } = useAuth(); const toast = useToast(); const gate = useGate()
  const [sort, setSort] = useState('best')
  const state = useLoad(() => api.comments(post.id, sort), [post.id, sort])
  const { setData } = state
  const tree = state.data || []

  const add = async (body, parentId) => {
    const tmp = {
      id: 'tmp-' + Date.now(), post_id: post.id, parent_id: parentId || null, author: { ...user }, body,
      is_answer: !parentId && user.user_type === 'expert' && post.post_type === 'question' && user.id !== post.author.id,
      is_accepted: false, is_deleted: false, is_removed: false, created_at: new Date().toISOString(), score: 0, my_vote: 0,
      reactions: {}, my_reactions: [], children: [], reply_count: 0, blocked: false,
    }
    setData(t => insertInto(t || [], parentId, tmp))
    try {
      const real = await api.addComment(post.id, body, parentId)
      setData(t => mapTree(t, tmp.id, () => real))
      if (real.is_answer) onPostChange?.({ status: post.status === 'open' ? 'answered' : post.status, answer_count: (post.answer_count || 0) + 1 })
      return true
    } catch (e) {
      setData(t => removeFrom(t, tmp.id)); toast.error(e.message); return false
    }
  }
  const edit = async (node, body) => {
    const prev = node.body
    setData(t => mapTree(t, node.id, n => ({ ...n, body, edited_at: new Date().toISOString() })))
    try { await api.editComment(node.id, body); return true }
    catch (e) { setData(t => mapTree(t, node.id, n => ({ ...n, body: prev, edited_at: node.edited_at }))); toast.error(e.message); return false }
  }
  const remove = async (node, own) => {
    if (!confirm(own ? 'Delete this comment? Replies stay visible.' : 'Remove this comment as a moderator?')) return
    const snapshot = state.data
    setData(t => mapTree(t, node.id, n => ({ ...n, [own ? 'is_deleted' : 'is_removed']: true, body: own ? '[deleted]' : '[removed by a moderator]', author: own ? null : n.author, is_accepted: false })))
    try { await api.deleteComment(node.id) } catch (e) { setData(snapshot); toast.error(e.message) }
  }
  const accept = async (node) => {
    const snapshot = state.data
    const to = !node.is_accepted
    setData(t => mapAll(t, n => ({ ...n, is_accepted: n.id === node.id ? to : (to ? false : n.is_accepted) })))
    try { const r = await api.accept(node.id); onPostChange?.({ status: r.post_status }) }
    catch (e) { setData(snapshot); toast.error(e.message) }
  }
  const block = async (author) => {
    if (!confirm(`Block ${author.name}? Their comments will be hidden from you.`)) return
    try { await api.block(author.id); state.reload(); toast.success('User blocked') } catch (e) { toast.error(e.message) }
  }

  const ctx = { user, post, isMod, add, edit, remove, accept, block, gate }
  const answerMode = user?.user_type === 'expert' && post.post_type === 'question' && user.id !== post.author.id

  return (
    <section className="thread" aria-label="Discussion">
      <div className="row between wrap">
        <h2 className="h-sm">{post.answer_count > 0 && post.post_type === 'question' ? `${post.answer_count} answer${post.answer_count === 1 ? '' : 's'} · ` : ''}{post.comment_count} comment{post.comment_count === 1 ? '' : 's'}</h2>
        <label className="sort">Sort by{' '}
          <select value={sort} onChange={e => setSort(e.target.value)} aria-label="Sort comments">
            <option value="best">Best</option><option value="newest">Newest</option><option value="active">Most active</option>
          </select>
        </label>
      </div>

      {user ? (
        <div className="card composer-card" id="answer">
          <strong>{answerMode ? 'Write your answer' : 'Add a comment'}</strong>
          <Composer label="top" placeholder={answerMode ? 'Share what you know. Experts’ top-level replies are rated by learners.' : 'What are your thoughts?'}
            submitLabel={answerMode ? 'Post answer' : 'Comment'} onSubmit={(b) => add(b, null)} />
        </div>
      ) : (
        <div className="card muted">Log in to join the discussion. <Link to="/login/learner">Learner login</Link> · <Link to="/login/expert">Expert login</Link></div>
      )}

      {state.loading && !state.data ? <SkeletonList n={2} /> : state.error ? <ErrorState error={state.error} onRetry={state.reload} /> :
        tree.length === 0 ? <p className="muted center pad">No replies yet — be the first.</p> :
          <div className="comments">{tree.map(n => <CommentNode key={n.id} node={n} depth={0} ctx={ctx} />)}</div>}
    </section>
  )
}

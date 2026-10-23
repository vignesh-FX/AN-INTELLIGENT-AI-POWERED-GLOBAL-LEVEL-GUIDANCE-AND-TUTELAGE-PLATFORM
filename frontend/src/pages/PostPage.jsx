import React, { useEffect, useState } from 'react'
import { Link, useLocation, useNavigate, useParams } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad, useToast } from '../lib/hooks.jsx'
import Thread from '../components/Thread.jsx'
import { STATUS_LABEL } from '../components/PostCard.jsx'
import { Avatar, ErrorState, RichText, RoleBadge, SkeletonList, TagInput, UserLink } from '../components/ui.jsx'
import { ReactionBar, ReportButton, SaveButton, ShareButton, Translatable, VoteBar } from '../components/interact.jsx'
import { POST_TYPES, assetUrl, timeAgo } from '../lib/util.js'
import { FIELDS } from './Compose.jsx'

export default function PostPage() {
  const { id } = useParams(); const { user } = useAuth(); const nav = useNavigate(); const toast = useToast(); const { hash } = useLocation()
  const state = useLoad(() => api.getPost(id), [id, user?.id])
  const [patch, setPatch] = useState({}); const [editing, setEditing] = useState(false)
  const [com, setCom] = useState(null)
  useEffect(() => { setPatch({}) }, [id])
  useEffect(() => { if (state.data) api.community(state.data.community.slug).then(setCom).catch(() => {}) }, [state.data?.community.slug, user?.id]) // eslint-disable-line
  useEffect(() => { if (state.data && hash) setTimeout(() => document.getElementById(hash.slice(1))?.scrollIntoView({ behavior: 'smooth', block: 'center' }), 500) }, [state.data, hash])

  if (state.loading && !state.data) return <SkeletonList n={2} />
  if (state.error) return <ErrorState error={state.error} onRetry={state.reload} />
  const post = { ...state.data, ...patch }
  const isMod = ['owner', 'moderator'].includes(com?.membership?.role) && com?.membership?.status === 'active'
  const own = user?.id === post.author.id

  const remove = async () => {
    if (!confirm('Delete this post?')) return
    try { await api.deletePost(post.id); toast.success('Post deleted'); nav(`/c/${post.community.slug}`) } catch (e) { toast.error(e.message) }
  }
  const pin = async () => { try { const r = await api.pinPost(post.id); setPatch(p => ({ ...p, is_pinned: r.is_pinned })) } catch (e) { toast.error(e.message) } }

  return (
    <article className="stack">
      <div className="card post-full">
        <VoteBar type="post" id={post.id} score={post.score} myVote={post.my_vote} own={own} />
        <div className="post-main">
          <div className="meta">
            <span className={`chip chip-type t-${post.post_type}`}>{POST_TYPES[post.post_type]}</span>
            <Link to={`/c/${post.community.slug}`} className="meta-link">{post.community.name}</Link><span>·</span>
            <Avatar user={post.author} size={20} /><UserLink user={post.author} /><RoleBadge type={post.author.user_type} /><span>·</span><span>{timeAgo(post.created_at)}</span>
            {post.updated_at && <span className="muted">(edited)</span>}
          </div>

          {editing ? <EditPost post={post} onCancel={() => setEditing(false)} onSaved={(p) => { setPatch(p); setEditing(false) }} /> : (
            <Translatable type="post" id={post.id} render={(t) => (<>
              <h1 className="post-h1">{t?.title || post.title}</h1>
              {(t?.body ?? post.body) && <RichText text={t?.body ?? post.body} />}
            </>)} />
          )}

          {post.attachments.length > 0 && (
            <div className="attachments">{post.attachments.map(a => a.kind === 'image'
              ? <a key={a.id} href={assetUrl(a.url)} target="_blank" rel="noopener noreferrer"><img src={assetUrl(a.url)} alt={a.name || 'attachment'} loading="lazy" /></a>
              : <a key={a.id} className="attach" href={assetUrl(a.url)} target="_blank" rel="noopener noreferrer nofollow">{a.kind === 'link' ? '🔗' : '📎'} {a.name || a.url}{post.resource_kind && post.post_type === 'resource' && a.kind === 'link' ? ` · ${post.resource_kind}` : ''}</a>)}</div>)}

          <div className="tags">{post.field && <span className="field-tag">{post.field}</span>}
            {post.tags.map(t => <Link key={t} className="chip" to={`/search?q=${encodeURIComponent(t)}`}>{t}</Link>)}
            {post.skill_level && <span className="chip chip-level">{post.skill_level}</span>}
            {post.post_type === 'question' && <span className={`status s-${post.status}`}>{STATUS_LABEL[post.status]}</span>}</div>

          <div className="post-foot wrap">
            <ReactionBar type="post" id={post.id} reactions={post.reactions} mine={post.my_reactions} />
            <SaveButton id={post.id} saved={post.saved} /><ShareButton path={`/post/${post.id}`} />
            {!own && <ReportButton type="post" id={post.id} />}
            {own && !editing && <button className="link-btn" onClick={() => setEditing(true)}>Edit</button>}
            {(own || isMod) && <button className="link-btn danger" onClick={remove}>Delete</button>}
            {isMod && <button className="link-btn" onClick={pin}>{post.is_pinned ? 'Unpin' : 'Pin'}</button>}
          </div>
        </div>
      </div>
      <Thread post={post} isMod={isMod} onPostChange={(p) => setPatch(x => ({ ...x, ...p }))} />
    </article>
  )
}

function EditPost({ post, onCancel, onSaved }) {
  const toast = useToast()
  const [f, setF] = useState({ title: post.title, body: post.body, tags: post.tags, field: post.field || '' })
  const [busy, setBusy] = useState(false)
  const save = async (e) => {
    e.preventDefault(); setBusy(true)
    try { const p = await api.editPost(post.id, { ...f, field: f.field || undefined }); onSaved({ title: p.title, body: p.body, tags: p.tags, field: p.field, updated_at: p.updated_at }) }
    catch (ex) { toast.error(ex.message); setBusy(false) }
  }
  return (
    <form className="stack" onSubmit={save}>
      <input aria-label="Title" value={f.title} minLength={5} maxLength={300} onChange={e => setF({ ...f, title: e.target.value })} />
      <textarea aria-label="Body" rows={8} value={f.body} onChange={e => setF({ ...f, body: e.target.value })} />
      <input aria-label="Field" list="fields2" value={f.field} onChange={e => setF({ ...f, field: e.target.value })} placeholder="Field" /><datalist id="fields2">{FIELDS.map(x => <option key={x} value={x} />)}</datalist>
      <TagInput value={f.tags} onChange={tags => setF({ ...f, tags })} />
      {post.post_type === 'question' && <p className="muted small">Saving re-runs expert matching for this question.</p>}
      <div className="row end gap-sm"><button type="button" className="btn" onClick={onCancel}>Cancel</button><button className="btn btn-primary" disabled={busy}>Save</button></div>
    </form>
  )
}

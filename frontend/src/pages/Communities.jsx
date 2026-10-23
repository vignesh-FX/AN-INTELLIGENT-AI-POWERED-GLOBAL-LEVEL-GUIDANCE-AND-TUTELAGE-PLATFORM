import React, { useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad, useToast } from '../lib/hooks.jsx'
import PostCard from '../components/PostCard.jsx'
import { Async, Avatar, Empty, ErrorState, Field, ImageUpload, RichText, SkeletonList, Tabs, UserLink, useDebounced } from '../components/ui.jsx'
import { CommunityMini, JoinButton } from './Feeds.jsx'
import { POST_TYPES, assetUrl, timeAgo } from '../lib/util.js'
import { useGate } from '../components/interact.jsx'

export function CommunitiesPage() {
  const { user } = useAuth()
  const [tab, setTab] = useState('all'); const [q, setQ] = useState(''); const dq = useDebounced(q)
  const list = useLoad(() => api.communities({ q: dq, mine: tab === 'mine' ? 1 : undefined }), [dq, tab, user?.id])
  return (
    <div>
      <div className="page-head"><div><h1>Communities</h1><p className="muted">Find a space for your topic — or start one.</p></div>
        <Link className="btn btn-primary" to="/communities/new">Create community</Link></div>
      <div className="row gap-sm wrap"><input type="search" className="grow" placeholder="Search communities…" aria-label="Search communities" value={q} onChange={e => setQ(e.target.value)} />
        {user && <Tabs value={tab} onChange={setTab} tabs={[{ id: 'all', label: 'All' }, { id: 'mine', label: 'Mine' }]} />}</div>
      <Async state={list} empty={<Empty icon="👥" title={tab === 'mine' ? "You haven't joined any communities" : 'No communities found'}>Try another search, or create the first one.</Empty>}>
        {(d) => <div className="grid-cards">{d.map(c => (
          <div key={c.id} className="card community-card">
            <div className="row gap-sm"><Avatar user={{ name: c.name, username: c.slug, avatar_url: c.avatar_url }} size={44} />
              <div><Link to={`/c/${c.slug}`}><strong>{c.name}</strong></Link>{c.is_private && <span className="chip"> 🔒 Private</span>}<div className="muted small">{c.member_count} member{c.member_count === 1 ? '' : 's'}</div></div></div>
            <p className="muted clamp">{c.description || 'No description yet.'}</p>
            <JoinButton community={c} />
          </div>))}</div>}
      </Async>
    </div>
  )
}

export function CreateCommunity() {
  const nav = useNavigate(); const toast = useToast(); const gate = useGate()
  const [f, setF] = useState({ name: '', description: '', is_private: false, avatar_url: null, banner_url: null, rules: [] })
  const [busy, setBusy] = useState(false); const [err, setErr] = useState('')
  const submit = async (e) => {
    e.preventDefault(); setBusy(true); setErr('')
    try {
      const c = await api.createCommunity({ ...f, rules: f.rules.filter(r => r.title.trim()) })
      toast.success('Community created'); nav(`/c/${c.slug}`)
    } catch (ex) { setErr(ex.message); setBusy(false) }
  }
  const setRule = (i, k, v) => setF(p => ({ ...p, rules: p.rules.map((r, j) => j === i ? { ...r, [k]: v } : r) }))
  return (
    <form className="card form-card stack" onSubmit={gate(submit)}>
      <h1>Create a community</h1>
      {err && <div className="notice notice-error" role="alert">{err}</div>}
      <Field label="Name" htmlFor="cname"><input id="cname" required minLength={3} maxLength={80} value={f.name} onChange={e => setF({ ...f, name: e.target.value })} placeholder="e.g. Natural Language Processing" /></Field>
      <Field label="Description" htmlFor="cdesc"><textarea id="cdesc" rows={3} maxLength={2000} value={f.description} onChange={e => setF({ ...f, description: e.target.value })} /></Field>
      <div className="grid2"><Field label="Avatar"><ImageUpload value={f.avatar_url} onChange={v => setF({ ...f, avatar_url: v })} user={{ name: f.name || 'C', username: f.name }} /></Field>
        <Field label="Banner image"><ImageUpload value={f.banner_url} onChange={v => setF({ ...f, banner_url: v })} user={{ name: 'B', username: 'banner' }} /></Field></div>
      <label className="check"><input type="checkbox" checked={f.is_private} onChange={e => setF({ ...f, is_private: e.target.checked })} /> Private — members must be approved by a moderator, and content is hidden from non-members</label>
      <fieldset><legend>Rules</legend>
        {f.rules.map((r, i) => (
          <div key={i} className="row gap-sm"><input aria-label={`Rule ${i + 1} title`} placeholder="Rule title" value={r.title} onChange={e => setRule(i, 'title', e.target.value)} />
            <input aria-label={`Rule ${i + 1} description`} className="grow" placeholder="Description" value={r.description} onChange={e => setRule(i, 'description', e.target.value)} />
            <button type="button" className="icon-btn" aria-label="Remove rule" onClick={() => setF(p => ({ ...p, rules: p.rules.filter((_, j) => j !== i) }))}>×</button></div>))}
        {f.rules.length < 15 && <button type="button" className="btn btn-sm" onClick={() => setF(p => ({ ...p, rules: [...p.rules, { title: '', description: '' }] }))}>+ Add rule</button>}
      </fieldset>
      <div className="row end"><button className="btn btn-primary" disabled={busy || f.name.trim().length < 3}>{busy ? 'Creating…' : 'Create community'}</button></div>
    </form>
  )
}

const TYPE_TABS = [['', 'All'], ['question', 'Questions'], ['discussion', 'Discussions'], ['project', 'Projects'], ['resource', 'Resources'], ['help_request', 'Help'], ['announcement', 'Announcements']]

export function CommunityPage() {
  const { slug } = useParams(); const { user } = useAuth()
  const c = useLoad(() => api.community(slug), [slug, user?.id])
  const [type, setType] = useState(''); const [sort, setSort] = useState('hot'); const [view, setView] = useState('posts')
  const [page, setPage] = useState(1)
  const posts = useLoad(() => api.communityPosts(slug, { type, sort, page }), [slug, type, sort, page, c.data?.membership?.status])
  const [extra, setExtra] = useState([])
  React.useEffect(() => { setPage(1); setExtra([]) }, [slug, type, sort])
  if (c.loading && !c.data) return <SkeletonList n={2} />
  if (c.error) return <ErrorState error={c.error} onRetry={c.reload} />
  const com = c.data
  const isMod = ['owner', 'moderator'].includes(com.membership?.role) && com.membership?.status === 'active'
  const active = com.membership?.status === 'active'
  const items = page === 1 ? (posts.data?.items || []) : [...extra, ...(posts.data?.items || [])]
  const loadMore = () => { setExtra(items); setPage(p => p + 1) }

  return (
    <div>
      <div className="community-head card">
        <div className="banner" style={com.banner_url ? { backgroundImage: `url(${assetUrl(com.banner_url)})` } : undefined} />
        <div className="community-head-body">
          <Avatar user={{ name: com.name, username: com.slug, avatar_url: com.avatar_url }} size={64} />
          <div className="grow"><h1>{com.name} {com.is_private && <span className="chip">🔒 Private</span>}</h1><p className="muted">{com.member_count} member{com.member_count === 1 ? '' : 's'}</p></div>
          <div className="row gap-sm wrap"><JoinButton community={com} size="md" onChange={() => c.reload()} />
            {active && user?.user_type === 'learner' && <Link className="btn btn-primary" to={`/ask?community=${com.slug}`}>Ask a question</Link>}
            {active && <Link className="btn" to={`/new?community=${com.slug}`}>New post</Link>}</div>
        </div>
        {com.is_banned && <div className="notice notice-error">You are banned from this community.</div>}
      </div>
      {isMod && <Tabs value={view} onChange={setView} tabs={[{ id: 'posts', label: 'Posts' }, { id: 'mod', label: 'Moderation' }]} />}
      {view === 'mod' && isMod ? <ModPanel com={com} reload={c.reload} /> : (
        <div className="cols">
          <div className="col-main">
            <div className="row between wrap"><div className="tabs scroll">{TYPE_TABS.map(([id, label]) => <button key={id} className={type === id ? 'tab active' : 'tab'} onClick={() => setType(id)}>{label}</button>)}</div>
              <select aria-label="Sort posts" value={sort} onChange={e => setSort(e.target.value)}><option value="hot">Hot</option><option value="new">New</option><option value="top">Top</option></select></div>
            {posts.error ? <ErrorState error={posts.error} onRetry={posts.reload} /> :
              posts.loading && !items.length ? <SkeletonList /> :
                !items.length ? <Empty icon="💬" title="No posts yet">{active ? 'Be the first to start a conversation.' : 'Join the community to post.'}</Empty> :
                  <div className="stack">{items.map(p => <PostCard key={p.id} post={p} />)}
                    {posts.data?.has_more && <button className="btn btn-block" disabled={posts.loading} onClick={loadMore}>{posts.loading ? 'Loading…' : 'Load more'}</button>}</div>}
          </div>
          <aside className="col-side">
            <div className="card"><h3 className="h-sm">About</h3><RichText text={com.description || 'No description yet.'} /></div>
            <div className="card"><h3 className="h-sm">Rules</h3>{com.rules?.length ? <ol className="rules">{com.rules.map((r, i) => <li key={i}><strong>{r.title}</strong>{r.description && <div className="muted small">{r.description}</div>}</li>)}</ol> : <p className="muted small">No rules posted.</p>}</div>
            <div className="card"><h3 className="h-sm">Moderators</h3>{com.moderators.map(m => <div key={m.id} className="row gap-sm mini"><Avatar user={m} size={24} /><UserLink user={m} /><span className="muted small">{m.role}</span></div>)}</div>
          </aside>
        </div>)}
    </div>
  )
}

function ModPanel({ com, reload }) {
  const toast = useToast()
  const reports = useLoad(() => api.communityReports(com.slug), [com.slug])
  const reqs = useLoad(() => api.requests(com.slug), [com.slug])
  const bans = useLoad(() => api.bans(com.slug), [com.slug])
  const members = useLoad(() => api.members(com.slug), [com.slug])
  const [about, setAbout] = useState({ description: com.description || '', rules: com.rules || [] })
  const owner = com.membership.role === 'owner'
  const run = async (fn, ok, ...reloads) => { try { await fn(); ok && toast.success(ok); reloads.forEach(r => r.reload()) } catch (e) { toast.error(e.message) } }
  const [banName, setBanName] = useState('')
  return (
    <div className="stack">
      <div className="card"><h3 className="h-sm">Reports ({reports.data?.length ?? '…'})</h3>
        <Async state={reports} skeleton={<SkeletonList n={1} />} empty={<p className="muted">No open reports. 🎉</p>}>
          {(d) => d.map(r => (
            <div key={r.id} className="report">
              <div className="row between wrap"><strong>{r.target_type}</strong><span className="chip">{r.reason}</span>{r.auto && <span className="chip">auto-flagged</span>}<span className="muted small">{timeAgo(r.created_at)}</span></div>
              {r.preview && <div><Link to={`/post/${r.preview.post_id}`}>{r.preview.title || 'View in context'}</Link><p className="muted clamp">{r.preview.body}</p><span className="muted small">by @{r.preview.author}</span></div>}
              {r.details && <p className="small">“{r.details}”</p>}
              <div className="row gap-sm wrap">
                <button className="btn btn-sm" onClick={() => run(() => api.resolveReport(r.id, 'dismiss'), 'Dismissed', reports)}>Dismiss</button>
                <button className="btn btn-sm" onClick={() => run(() => api.resolveReport(r.id, 'remove_content'), 'Content removed', reports)}>Remove content</button>
                <button className="btn btn-sm btn-danger" onClick={() => confirm('Remove content and ban its author?') && run(() => api.resolveReport(r.id, 'ban_user'), 'User banned', reports, bans, members)}>Ban author</button></div>
            </div>))}
        </Async></div>

      {com.is_private && (<div className="card"><h3 className="h-sm">Join requests</h3>
        <Async state={reqs} skeleton={<SkeletonList n={1} />} empty={<p className="muted">No pending requests.</p>}>
          {(d) => d.map(u => <div key={u.id} className="row between mini"><UserLink user={u} />
            <span className="row gap-sm"><button className="btn btn-sm btn-primary" onClick={() => run(() => api.decideRequest(com.slug, u.username, 'approve'), 'Approved', reqs, reload)}>Approve</button>
              <button className="btn btn-sm" onClick={() => run(() => api.decideRequest(com.slug, u.username, 'reject'), null, reqs)}>Reject</button></span></div>)}
        </Async></div>)}

      <div className="card"><h3 className="h-sm">Members</h3>
        <Async state={members} skeleton={<SkeletonList n={1} />}>
          {(d) => d.map(m => <div key={m.id} className="row between mini"><span className="row gap-sm"><Avatar user={m} size={24} /><UserLink user={m} /><span className="muted small">{m.role}</span></span>
            <span className="row gap-sm">
              {owner && m.role !== 'owner' && <button className="btn btn-sm" onClick={() => run(() => api.setModerator(com.slug, m.username, m.role !== 'moderator'), null, members, reload)}>{m.role === 'moderator' ? 'Remove mod' : 'Make mod'}</button>}
              {m.role === 'member' && <button className="btn btn-sm btn-danger" onClick={() => confirm(`Ban ${m.name}?`) && run(() => api.ban(com.slug, m.username), 'Banned', members, bans, reload)}>Ban</button>}</span></div>)}
        </Async></div>

      <div className="card"><h3 className="h-sm">Banned users</h3>
        <form className="row gap-sm" onSubmit={e => { e.preventDefault(); banName && run(() => api.ban(com.slug, banName.replace(/^@/, '')), 'Banned', bans, members).then(() => setBanName('')) }}>
          <input className="grow" aria-label="Username to ban" placeholder="username" value={banName} onChange={e => setBanName(e.target.value)} /><button className="btn btn-sm">Ban user</button></form>
        <Async state={bans} skeleton={<SkeletonList n={1} />} empty={<p className="muted small">No one is banned.</p>}>
          {(d) => d.map(u => <div key={u.id} className="row between mini"><span>@{u.username} <span className="muted small">{u.reason}</span></span><button className="btn btn-sm" onClick={() => run(() => api.unban(com.slug, u.username), 'Unbanned', bans)}>Unban</button></div>)}
        </Async></div>

      <div className="card stack"><h3 className="h-sm">Description & rules</h3>
        <textarea rows={3} aria-label="Description" value={about.description} onChange={e => setAbout({ ...about, description: e.target.value })} />
        {about.rules.map((r, i) => <div key={i} className="row gap-sm"><input aria-label="Rule title" value={r.title} onChange={e => setAbout({ ...about, rules: about.rules.map((x, j) => j === i ? { ...x, title: e.target.value } : x) })} />
          <input className="grow" aria-label="Rule description" value={r.description} onChange={e => setAbout({ ...about, rules: about.rules.map((x, j) => j === i ? { ...x, description: e.target.value } : x) })} />
          <button className="icon-btn" aria-label="Remove rule" onClick={() => setAbout({ ...about, rules: about.rules.filter((_, j) => j !== i) })}>×</button></div>)}
        <div className="row gap-sm"><button className="btn btn-sm" onClick={() => setAbout({ ...about, rules: [...about.rules, { title: '', description: '' }] })}>+ Rule</button>
          <button className="btn btn-primary btn-sm" onClick={() => run(() => api.updateCommunity(com.slug, { description: about.description, rules: about.rules.filter(r => r.title.trim()) }), 'Saved', { reload })}>Save changes</button></div>
        <p className="muted small">Pin announcements by posting one (type “Announcement”) or using “Pin” on any post.</p></div>
    </div>
  )
}

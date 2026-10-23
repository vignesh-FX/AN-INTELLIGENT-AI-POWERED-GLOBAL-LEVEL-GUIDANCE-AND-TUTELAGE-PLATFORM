import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad, useOptimistic, useToast } from '../lib/hooks.jsx'
import PostCard from '../components/PostCard.jsx'
import { Async, Empty, ErrorState, SkeletonList, Tabs } from '../components/ui.jsx'
import { timeAgo } from '../lib/util.js'
import { useGate } from '../components/interact.jsx'

/** Paged list helper: first page + "load more". */
function usePaged(fetchPage, deps) {
  const [items, setItems] = useState([]); const [page, setPage] = useState(1)
  const [more, setMore] = useState(false); const [loading, setLoading] = useState(true); const [error, setError] = useState(null)
  const [extra, setExtra] = useState({})
  const load = (p, replace) => {
    setLoading(true); setError(null)
    fetchPage(p).then(r => { setItems(i => replace ? r.items : [...i, ...r.items]); setMore(r.has_more); setPage(p); const { items: _i, has_more: _h, ...rest } = r; setExtra(rest) },
      e => setError(e)).finally(() => setLoading(false))
  }
  useEffect(() => { load(1, true) }, deps) // eslint-disable-line
  return { items, setItems, more, loading, error, extra, loadMore: () => load(page + 1, false), reload: () => load(1, true) }
}

export function JoinButton({ community, onChange, size = 'sm' }) {
  const gate = useGate()
  const [s, act] = useOptimistic({ membership: community.membership, member_count: community.member_count })
  const m = s.membership
  const isOwner = m?.role === 'owner'
  const click = () => {
    if (m) {
      act({ membership: null, member_count: s.member_count - (m.status === 'active' ? 1 : 0) }, async () => { await api.leave(community.slug); onChange?.(null); return null })
    } else {
      const pending = community.is_private
      act({ membership: { role: 'member', status: pending ? 'pending' : 'active' }, member_count: s.member_count + (pending ? 0 : 1) },
        async () => { const r = await api.join(community.slug); onChange?.(r); return { membership: r } })
    }
  }
  return (
    <button className={`btn btn-${size}${!m ? ' btn-primary' : ''}`} disabled={isOwner} title={isOwner ? 'Owners cannot leave' : undefined} onClick={gate(click)}>
      {m?.status === 'pending' ? 'Requested ✕' : m ? 'Joined ✓' : community.is_private ? 'Request to join' : 'Join'}
    </button>
  )
}

export function CommunityMini({ c }) {
  return (
    <div className="mini row between">
      <Link to={`/c/${c.slug}`} className="mini-main"><strong>{c.name}</strong><span className="muted small">{c.member_count} member{c.member_count === 1 ? '' : 's'}</span></Link>
      <JoinButton community={c} />
    </div>
  )
}

function SideRail() {
  const rec = useLoad(() => api.recommended(), [])
  const trend = useLoad(() => api.trending(), [])
  return (
    <aside className="col-side">
      <div className="card"><h3 className="h-sm">Recommended communities</h3>
        <Async state={rec} skeleton={<SkeletonList n={2} />} empty={<p className="muted small">You've joined everything — nice. <Link to="/communities/new">Start a community</Link>.</p>}>
          {(d) => d.slice(0, 5).map(c => <CommunityMini key={c.id} c={c} />)}
        </Async>
        <Link to="/communities" className="link small">Browse all communities →</Link>
      </div>
      <div className="card"><h3 className="h-sm">Trending discussions</h3>
        <Async state={trend} skeleton={<SkeletonList n={2} />} empty={<p className="muted small">Nothing trending this week yet.</p>}>
          {(d) => d.slice(0, 5).map(p => (
            <div key={p.id} className="trend"><Link to={`/post/${p.id}`}>{p.title}</Link><span className="muted small">{p.community.name} · 💬 {p.comment_count} · ▲ {p.score}</span></div>
          ))}
        </Async>
      </div>
    </aside>
  )
}

export function LearnerHome() {
  const { user } = useAuth()
  const [sort, setSort] = useState('hot')
  const feed = usePaged((p) => api.homeFeed({ sort, page: p }), [sort])
  const mine = useLoad(() => api.myQuestions(), [])
  const recent = (mine.data || []).slice(0, 3)
  return (
    <div className="cols">
      <div className="col-main">
        <div className="page-head">
          <div><h1>Welcome back, {user.name.split(' ')[0]}</h1><p className="muted">Questions, discussions and answers from your communities.</p></div>
          <Link to="/ask" className="btn btn-primary btn-lg">Ask a Question</Link>
        </div>
        {recent.length > 0 && (
          <div className="card strip">
            <div className="row between"><h3 className="h-sm">Your questions</h3><Link to="/my-questions" className="link small">View all →</Link></div>
            {recent.map(q => (
              <div key={q.id} className="strip-row"><Link to={`/post/${q.id}`}>{q.title}</Link>
                <span className={`status s-${q.status}`}>{q.answer_count ? `${q.answer_count} answer${q.answer_count > 1 ? 's' : ''}` : 'Waiting for answers'}</span></div>
            ))}
          </div>
        )}
        <Tabs value={sort} onChange={setSort} tabs={[{ id: 'hot', label: 'Hot' }, { id: 'new', label: 'New' }, { id: 'top', label: 'Top' }]} />
        {feed.error ? <ErrorState error={feed.error} onRetry={feed.reload} /> :
          feed.loading && !feed.items.length ? <SkeletonList /> :
            !feed.items.length ? (
              <Empty icon="🌱" title="Your feed is empty" action={<Link className="btn btn-primary" to="/communities">Find communities to join</Link>}>Join a community or ask your first question to get started.</Empty>
            ) : (<div className="stack">
              {!feed.extra.joined_any && <div className="notice">You haven't joined any communities yet — showing popular public posts. <Link to="/communities">Join some</Link> to personalise this feed.</div>}
              {feed.items.map(p => <PostCard key={p.id} post={p} />)}
              {feed.more && <button className="btn btn-block" disabled={feed.loading} onClick={feed.loadMore}>{feed.loading ? 'Loading…' : 'Load more'}</button>}
            </div>)}
      </div>
      <SideRail />
    </div>
  )
}

const STATUS_TABS = [['new', 'New'], ['saved', 'Saved'], ['ignored', 'Ignored'], ['answered', 'Answered']]

export function ExpertFeed() {
  const toast = useToast()
  const [status, setStatus] = useState('new')
  const feed = usePaged((p) => api.expertFeed({ status, page: p }), [status])
  const counts = feed.extra.counts || {}

  const move = async (item, to) => {
    const snapshot = feed.items
    feed.setItems(i => i.filter(x => x.id !== item.id))                   // optimistic: it leaves this tab immediately
    try { await api.setRelevance(item.id, to) }
    catch (e) { feed.setItems(snapshot); toast.error(e.message) }          // rollback
  }
  return (
    <div className="cols">
      <div className="col-main">
        <div className="page-head"><div>
          <h1>Questions For Your Expertise</h1>
          <p className="muted">Questions whose text is closest to your expertise (TF-IDF cosine similarity), re-ranked with field, tags, community, recency and activity. Hover a match badge to see why.</p>
        </div></div>
        <Tabs value={status} onChange={setStatus} tabs={STATUS_TABS.map(([id, label]) => ({ id, label, count: counts[id] }))} />
        {feed.error ? <ErrorState error={feed.error} onRetry={feed.reload} /> :
          feed.loading && !feed.items.length ? <SkeletonList /> :
            !feed.items.length ? (
              <Empty icon="🎯" title={status === 'new' ? 'No matching questions right now' : `Nothing ${status} yet`}
                action={status === 'new' ? <Link className="btn" to="/settings">Refine your expertise</Link> : null}>
                {status === 'new' ? 'New questions that match your expertise will appear here. The more specific your skills and expertise areas, the better the matching.' : 'Questions you move here will be listed.'}
              </Empty>
            ) : (<div className="stack">
              {feed.items.map(p => (
                <PostCard key={p.id} post={p} match={p.match} actions={
                  <>
                    <Link className="btn btn-primary btn-sm" to={`/post/${p.id}#answer`}>{status === 'answered' ? 'View thread' : 'Answer'}</Link>
                    {status !== 'answered' && status !== 'saved' && <button className="btn btn-sm" onClick={() => move(p, 'saved')}>Save</button>}
                    {status === 'saved' && <button className="btn btn-sm" onClick={() => move(p, 'new')}>Unsave</button>}
                    {status !== 'answered' && status !== 'ignored' && <button className="btn btn-sm btn-quiet" onClick={() => move(p, 'ignored')}>Ignore</button>}
                    {status === 'ignored' && <button className="btn btn-sm" onClick={() => move(p, 'new')}>Restore</button>}
                  </>} />
              ))}
              {feed.more && <button className="btn btn-block" disabled={feed.loading} onClick={feed.loadMore}>{feed.loading ? 'Loading…' : 'Load more'}</button>}
            </div>)}
      </div>
      <SideRail />
    </div>
  )
}

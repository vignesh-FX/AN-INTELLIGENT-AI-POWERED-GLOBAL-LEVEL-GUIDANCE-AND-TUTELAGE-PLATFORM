import React, { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useLoad } from '../lib/hooks.jsx'
import PostCard from '../components/PostCard.jsx'
import { Avatar, Empty, ErrorState, RoleBadge, SkeletonList, Tabs, UserLink } from '../components/ui.jsx'
import { CommunityMini } from './Feeds.jsx'

export default function SearchPage() {
  const [sp, setSp] = useSearchParams()
  const q = sp.get('q') || ''; const type = sp.get('type') || 'all'
  const [text, setText] = useState(q)
  useEffect(() => setText(q), [q])
  const s = useLoad(() => q.trim().length >= 2 ? api.search(q, type) : Promise.resolve(null), [q, type])
  const d = s.data
  const total = d ? d.questions.length + d.discussions.length + d.resources.length + d.communities.length + d.users.length : 0
  return (
    <div className="stack">
      <form onSubmit={e => { e.preventDefault(); setSp({ q: text, type }) }} role="search"><input type="search" aria-label="Search" value={text} onChange={e => setText(e.target.value)} placeholder="Search questions, discussions, communities, experts…" /></form>
      <Tabs value={type} onChange={t => setSp({ q, type: t })} tabs={[['all', 'All'], ['questions', 'Questions'], ['discussions', 'Discussions'], ['resources', 'Resources'], ['communities', 'Communities'], ['users', 'People'], ['experts', 'Experts']].map(([id, label]) => ({ id, label }))} />
      {q.trim().length < 2 ? <Empty icon="🔎" title="Search GlobalGuru">Type at least two characters.</Empty> :
        s.loading && !d ? <SkeletonList /> : s.error ? <ErrorState error={s.error} onRetry={s.reload} /> :
          total === 0 ? <Empty icon="🔎" title={`No results for “${q}”`}>Try different keywords. Search matches the words you use (TF-IDF), not synonyms.</Empty> : (<>
            <p className="muted small">Ranked by {d.method}.</p>
            {[['questions', 'Questions'], ['discussions', 'Discussions'], ['resources', 'Resources']].map(([k, label]) => d[k].length > 0 && <section key={k} className="stack"><h3>{label}</h3>{d[k].map(p => <PostCard key={p.id} post={p} />)}</section>)}
            {d.communities.length > 0 && <section className="stack"><h3>Communities</h3><div className="card">{d.communities.map(c => <CommunityMini key={c.id} c={c} />)}</div></section>}
            {d.users.length > 0 && <section className="stack"><h3>{type === 'experts' ? 'Experts' : 'People'}</h3><div className="card">{d.users.map(u => (
              <div key={u.id} className="row gap-sm mini"><Avatar user={u} size={32} /><div><UserLink user={u} /> <RoleBadge type={u.user_type} /><div className="muted small">@{u.username}{u.title ? ` · ${u.title}` : ''}</div></div></div>))}</div></section>}
          </>)}
    </div>
  )
}

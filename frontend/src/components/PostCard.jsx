import React from 'react'
import { Link } from 'react-router-dom'
import { Avatar, RoleBadge, UserLink } from './ui.jsx'
import { ReactionBar, SaveButton, Translatable, VoteBar } from './interact.jsx'
import { POST_TYPES, timeAgo } from '../lib/util.js'
import { useAuth } from '../lib/auth.jsx'

export const STATUS_LABEL = { open: 'Open', answered: 'Answered', resolved: 'Resolved ✓' }

export function MatchBadge({ match }) {
  const c = match.components
  const tip = `Expertise similarity (TF-IDF cosine) ${Math.round(c.similarity * 100)}% · field ${Math.round(c.field * 100)}% · tags ${Math.round(c.tag * 100)}% · community ${Math.round(c.community * 100)}% · recency ${Math.round(c.recency * 100)}% · activity ${Math.round(c.activity * 100)}%`
  return (
    <span className="match" title={tip}>
      <span className="match-bar" aria-hidden="true"><span style={{ width: `${Math.min(100, match.percent)}%` }} /></span>
      <strong>{match.percent}%</strong> expertise match
    </span>
  )
}

export default function PostCard({ post, match, actions, showTranslate = true }) {
  const { user } = useAuth()
  const href = `/post/${post.id}`
  const excerpt = (post.body || '').replace(/```[\s\S]*?```/g, ' [code] ').slice(0, 280)
  const body = (parts) => (
    <>
      <h3 className="post-title"><Link to={href}>{parts?.title || post.title}</Link></h3>
      {(parts?.body ?? excerpt) && <p className="post-excerpt">{parts?.body ? parts.body.slice(0, 280) : excerpt}{!parts && post.body.length > 280 ? '…' : ''}</p>}
    </>
  )
  return (
    <article className={`card post-card${post.is_pinned ? ' pinned' : ''}`}>
      <VoteBar type="post" id={post.id} score={post.score} myVote={post.my_vote} own={user?.id === post.author.id} />
      <div className="post-main">
        <div className="meta">
          {post.is_pinned && <span className="chip chip-pin">📌 Pinned</span>}
          <span className={`chip chip-type t-${post.post_type}`}>{POST_TYPES[post.post_type]}</span>
          <Link to={`/c/${post.community.slug}`} className="meta-link">{post.community.name}</Link>
          <span>·</span><Avatar user={post.author} size={18} /><UserLink user={post.author} /><RoleBadge type={post.author.user_type} />
          <span>·</span><span>{timeAgo(post.created_at)}</span>
        </div>
        {showTranslate ? <Translatable type="post" id={post.id} render={body} /> : body(null)}
        {(post.field || post.tags.length > 0) && (
          <div className="tags">
            {post.field && <span className="field-tag">{post.field}</span>}
            {post.tags.map(t => <Link key={t} to={`/search?q=${encodeURIComponent(t)}`} className="chip">{t}</Link>)}
            {post.skill_level && <span className="chip chip-level">{post.skill_level}</span>}
          </div>
        )}
        {match && (
          <div className="match-row"><MatchBadge match={match} />
            {match.matched_terms.length > 0 && <span className="muted small">matched: {match.matched_terms.slice(0, 4).join(', ')}</span>}</div>
        )}
        <div className="post-foot">
          <Link to={href} className="link-btn">💬 {post.comment_count}{post.post_type === 'question' ? ` · ${post.answer_count} answer${post.answer_count === 1 ? '' : 's'}` : ''}</Link>
          {post.post_type === 'question' && <span className={`status s-${post.status}`}>{STATUS_LABEL[post.status]}</span>}
          {!actions && <SaveButton id={post.id} saved={post.saved} />}
          {actions}
        </div>
      </div>
    </article>
  )
}

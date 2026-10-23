import React, { useState } from 'react'
import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useAuth } from '../lib/auth.jsx'
import { Avatar } from './ui.jsx'

const I = {
  home: 'M3 11l9-8 9 8v9a1 1 0 01-1 1h-5v-6H9v6H4a1 1 0 01-1-1z',
  feed: 'M4 5h16M4 12h16M4 19h10',
  people: 'M16 11a4 4 0 10-8 0 4 4 0 008 0zM4 21a8 8 0 0116 0',
  plus: 'M12 5v14M5 12h14',
  q: 'M9 9a3 3 0 115 2c-1 1-2 1.5-2 3M12 18h.01',
  chat: 'M4 5h16v11H9l-5 4z',
  bookmark: 'M6 3h12v18l-6-4-6 4z',
  bell: 'M6 16V11a6 6 0 1112 0v5l2 2H4zM10 21h4',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zM4 21a8 8 0 0116 0',
}
const Icon = ({ d }) => <svg className="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d={d} /></svg>

export default function Layout() {
  const { user, logout, unread } = useAuth()
  const navigate = useNavigate()
  const [q, setQ] = useState('')
  const expert = user?.user_type === 'expert'

  const items = !user ? [] : expert ? [
    { to: '/for-you', label: 'Questions For You', short: 'For you', icon: I.feed },
    { to: '/communities', label: 'Communities', short: 'Communities', icon: I.people },
    { to: '/my-answers', label: 'My Answers', short: 'Answers', icon: I.chat },
    { to: '/saved', label: 'Saved', icon: I.bookmark },
    { to: '/notifications', label: 'Notifications', short: 'Alerts', icon: I.bell, badge: unread },
    { to: `/u/${user.username}`, label: 'Profile', short: 'Profile', icon: I.user },
  ] : [
    { to: '/home', label: 'Home', short: 'Home', icon: I.home },
    { to: '/communities', label: 'Communities', short: 'Communities', icon: I.people },
    { to: '/ask', label: 'Ask Question', short: 'Ask', icon: I.plus, primary: true },
    { to: '/my-questions', label: 'My Questions', icon: I.q },
    { to: '/saved', label: 'Saved', icon: I.bookmark },
    { to: '/notifications', label: 'Notifications', short: 'Alerts', icon: I.bell, badge: unread },
    { to: `/u/${user.username}`, label: 'Profile', short: 'Profile', icon: I.user },
  ]
  const mobile = items.filter(i => i.short)

  const submit = (e) => { e.preventDefault(); if (q.trim().length >= 2) navigate(`/search?q=${encodeURIComponent(q.trim())}`) }

  return (
    <div className={`shell${user ? " role-" + user.user_type : ""}`}>
      <a href="#main" className="skip-link">Skip to content</a>
      <header className="topbar">
        <Link to={user ? (expert ? '/for-you' : '/home') : '/'} className="brand"><span className="brand-mark">G</span><span className="brand-name">GlobalGuru</span></Link>
        <form className="search" role="search" onSubmit={submit}>
          <input type="search" value={q} onChange={e => setQ(e.target.value)} placeholder="Search questions, communities, experts…" aria-label="Search" />
        </form>
        <div className="topbar-actions">
          {user ? (
            <>
              <Link to="/notifications" className="icon-btn bell" aria-label={`Notifications${unread ? `, ${unread} unread` : ''}`}>
                <Icon d={I.bell} />{unread > 0 && <span className="dot">{unread > 9 ? '9+' : unread}</span>}
              </Link>
              <Link to={`/u/${user.username}`} aria-label="Your profile"><Avatar user={user} size={32} /></Link>
              <button className="btn btn-quiet btn-sm hide-sm" onClick={() => { logout(); navigate('/') }}>Sign out</button>
            </>
          ) : (
            <>
              <Link className="btn btn-quiet btn-sm" to="/login/learner">Log in</Link>
              <Link className="btn btn-primary btn-sm" to="/register/learner">Join</Link>
            </>
          )}
        </div>
      </header>

      <div className="body">
        {user && (
          <nav className="sidebar" aria-label="Main">
            <div className={`role-pill role-${user.user_type}`}>{expert ? 'Expert workspace' : 'Learner workspace'}</div>
            {items.map(i => (
              <NavLink key={i.to} to={i.to} className={({ isActive }) => `nav-item${isActive ? ' active' : ''}${i.primary ? ' nav-primary' : ''}`}>
                <Icon d={i.icon} /><span>{i.label}</span>{i.badge > 0 && <span className="count">{i.badge}</span>}
              </NavLink>
            ))}
            <button className="nav-item nav-signout" onClick={() => { logout(); navigate('/') }}>Sign out</button>
          </nav>
        )}
        <main id="main" className="main"><Outlet /></main>
      </div>

      {user && (
        <nav className="bottom-nav" aria-label="Main">
          {mobile.map(i => (
            <NavLink key={i.to} to={i.to} className={({ isActive }) => `bn-item${isActive ? ' active' : ''}${i.primary ? ' bn-primary' : ''}`}>
              <span className="bn-ico"><Icon d={i.icon} />{i.badge > 0 && <span className="dot">{i.badge > 9 ? '9+' : i.badge}</span>}</span>
              <span>{i.short}</span>
            </NavLink>
          ))}
        </nav>
      )}
    </div>
  )
}

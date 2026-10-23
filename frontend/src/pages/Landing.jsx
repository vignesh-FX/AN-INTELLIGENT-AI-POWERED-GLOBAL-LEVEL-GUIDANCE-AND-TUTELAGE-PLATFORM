import React from 'react'
import { Link, Navigate } from 'react-router-dom'
import { useAuth } from '../lib/auth.jsx'
import { home } from '../lib/util.js'

export default function Landing() {
  const { user } = useAuth()
  if (user) return <Navigate to={home(user)} replace />
  return (
    <div className="landing">
      <header className="landing-nav">
        <span className="brand"><span className="brand-mark">G</span><span className="brand-name">GlobalGuru</span></span>
        <nav><Link to="/communities" className="btn btn-quiet btn-sm">Browse communities</Link></nav>
      </header>
      <section className="hero">
        <h1>Ask a question.<br />Reach the experts who can answer it.</h1>
        <p>GlobalGuru is a mentorship community. Learners post questions; we compare each question with experts' expertise using TF-IDF and cosine similarity, and place it in the feeds of the people best placed to help. Answers are discussed in threads, rated for helpfulness, and translated into your language.</p>
        <div className="hero-cta">
          <div className="hero-card role-learner">
            <h3>I want to learn</h3>
            <p>Join communities, ask questions, get expert answers.</p>
            <Link className="btn btn-primary" to="/register/learner">Create Learner Account</Link>
            <Link className="link" to="/login/learner">Learner Login</Link>
          </div>
          <div className="hero-card role-expert">
            <h3>I'm an expert</h3>
            <p>See questions matched to your expertise and build your reputation.</p>
            <Link className="btn btn-primary" to="/register/expert">Create Expert Account</Link>
            <Link className="link" to="/login/expert">Expert Login</Link>
          </div>
        </div>
      </section>
      <section className="how">
        {[['1', 'Ask', 'A learner posts a question with a field and tags.'], ['2', 'Route', 'TF-IDF vectors + cosine similarity score every expert against it.'], ['3', 'Answer', 'It appears in the feeds of the most relevant experts, who choose whether to answer.'], ['4', 'Discuss & rate', 'Threaded replies; learners rate answers 1–5 and mark them helpful.']].map(([n, t, d]) => (
          <div key={n} className="how-step"><span className="how-n">{n}</span><h4>{t}</h4><p className="muted">{d}</p></div>
        ))}
      </section>
    </div>
  )
}

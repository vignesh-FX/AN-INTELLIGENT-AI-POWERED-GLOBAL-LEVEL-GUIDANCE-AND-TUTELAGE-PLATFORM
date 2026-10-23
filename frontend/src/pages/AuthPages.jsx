import React, { useState } from 'react'
import { Link, Navigate, useNavigate, useSearchParams } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { Field, ImageUpload, LangPicker, TagInput } from '../components/ui.jsx'
import { LEVELS, home } from '../lib/util.js'

const COPY = {
  learner: { title: 'Learner Login', sub: 'Ask questions, join communities and learn from experts.', other: 'expert', otherLabel: 'Are you an Expert?', otherCta: 'Expert Login' },
  expert: { title: 'Expert Login', sub: 'See questions that match your expertise and help learners.', other: 'learner', otherLabel: 'Are you a Learner?', otherCta: 'Learner Login' },
}

function AuthShell({ type, title, sub, children, wide }) {
  return (
    <div className={`auth role-${type}`}>
      <aside className="auth-side">
        <Link to="/" className="brand light"><span className="brand-mark">G</span><span className="brand-name">GlobalGuru</span></Link>
        <h2>{type === 'expert' ? 'Questions find you.' : 'Ask. Learn. Get answers from experts.'}</h2>
        <p>{type === 'expert'
          ? 'Your expertise is matched to new questions, so your feed only shows questions you are qualified to answer.'
          : 'Post a question and it is routed to experts whose expertise matches it — then discuss the answers in threads and rate what helped.'}</p>
        <ul className="auth-points">
          {(type === 'expert' ? ['Personalised “Questions For You” feed', 'Threaded discussions with learners', 'Ratings build your quality score'] : ['Questions routed to the right experts', 'Reddit-style threaded answers', 'Translate any answer into your language']).map(x => <li key={x}>{x}</li>)}
        </ul>
      </aside>
      <main className={`auth-main${wide ? ' wide' : ''}`}>
        <div className="auth-card">
          <h1>{title}</h1><p className="muted">{sub}</p>
          {children}
        </div>
      </main>
    </div>
  )
}

export function LoginPage({ type }) {
  const { user, signIn } = useAuth(); const nav = useNavigate(); const [sp] = useSearchParams()
  const c = COPY[type]
  const [email, setEmail] = useState(''); const [password, setPassword] = useState('')
  const [err, setErr] = useState(''); const [busy, setBusy] = useState(false)
  if (user) return <Navigate to={home(user)} replace />
  const submit = async (e) => {
    e.preventDefault(); setErr(''); setBusy(true)
    try {
      const s = await api.login(type, email, password)
      signIn(s)
      const next = sp.get('next')
      nav(next && next.startsWith('/') ? next : home(s.user), { replace: true })
    } catch (ex) { setErr(ex.message); setBusy(false) }
  }
  return (
    <AuthShell type={type} title={c.title} sub={c.sub}>
      <form onSubmit={submit} className="stack" noValidate>
        <Field label="Email" htmlFor="email"><input id="email" type="email" autoComplete="email" required value={email} onChange={e => setEmail(e.target.value)} /></Field>
        <Field label="Password" htmlFor="pw"><input id="pw" type="password" autoComplete="current-password" required value={password} onChange={e => setPassword(e.target.value)} /></Field>
        {err && <div className="notice notice-error" role="alert">{err}</div>}
        <button className="btn btn-primary btn-block" disabled={busy || !email || !password}>{busy ? 'Signing in…' : 'Login'}</button>
      </form>
      <p className="auth-alt">Don't have an account? <Link to={`/register/${type}`}><strong>Create {type === 'expert' ? 'Expert' : 'Learner'} Account</strong></Link></p>
      <p className="auth-alt">{c.otherLabel} <Link to={`/login/${c.other}`}>→ {c.otherCta}</Link></p>
    </AuthShell>
  )
}

const EXPERT_INIT = { name: '', username: '', email: '', password: '', avatar_url: null, title: '', organization: '', years_experience: 0, education: '', skills: [], expertise_areas: [], projects: [], certifications: [], languages: [], biography: '', mentoring_areas: [], professional_interests: [] }
const LEARNER_INIT = { name: '', username: '', email: '', password: '', avatar_url: null, education: '', institution: '', work_status: '', skills: [], interests: [], skill_level: '', learning_goals: '', help_topics: [], languages: [] }

export function RegisterPage({ type }) {
  const { user, signIn } = useAuth(); const nav = useNavigate()
  const [f, setF] = useState(type === 'expert' ? EXPERT_INIT : LEARNER_INIT)
  const [err, setErr] = useState(''); const [busy, setBusy] = useState(false)
  if (user) return <Navigate to={home(user)} replace />
  const set = (k) => (v) => setF(p => ({ ...p, [k]: v }))
  const inp = (k, extra = {}) => ({ id: k, value: f[k] ?? '', onChange: e => set(k)(e.target.value), ...extra })
  const submit = async (e) => {
    e.preventDefault(); setErr(''); setBusy(true)
    const body = { ...f, skill_level: f.skill_level || undefined, years_experience: Number(f.years_experience) || 0 }
    Object.keys(body).forEach(k => (body[k] === '' || body[k] === null) && delete body[k])
    try { const s = await api.register(type, body); signIn(s); nav(home(s.user), { replace: true }) }
    catch (ex) { setErr(ex.message); setBusy(false); window.scrollTo({ top: 0 }) }
  }
  const expert = type === 'expert'
  return (
    <AuthShell type={type} wide title={`Create ${expert ? 'Expert' : 'Learner'} Account`}
      sub={expert ? 'What do you know — and which questions can you help answer?' : 'What do you know — and what do you want to learn?'}>
      <form onSubmit={submit} className="stack" noValidate>
        {err && <div className="notice notice-error" role="alert">{err}</div>}
        <fieldset><legend>Account</legend>
          <ImageUpload value={f.avatar_url} onChange={set('avatar_url')} user={f} />
          <div className="grid2">
            <Field label="Full name" htmlFor="name"><input {...inp('name')} required autoComplete="name" /></Field>
            <Field label="Username" htmlFor="username" hint="3–30 letters, numbers, underscores"><input {...inp('username')} required autoComplete="username" /></Field>
            <Field label="Email" htmlFor="email"><input {...inp('email', { type: 'email' })} required autoComplete="email" /></Field>
            <Field label="Password" htmlFor="password" hint="At least 8 characters"><input {...inp('password', { type: 'password' })} required minLength={8} autoComplete="new-password" /></Field>
          </div>
        </fieldset>

        {expert ? (<>
          <fieldset><legend>Professional profile</legend>
            <div className="grid2">
              <Field label="Professional title" htmlFor="title"><input {...inp('title')} required placeholder="e.g. NLP Research Engineer" /></Field>
              <Field label="Company / organisation" htmlFor="organization"><input {...inp('organization')} /></Field>
              <Field label="Years of experience" htmlFor="years_experience"><input {...inp('years_experience', { type: 'number', min: 0, max: 70 })} /></Field>
              <Field label="Education" htmlFor="education"><input {...inp('education')} placeholder="e.g. M.Sc. Computer Science" /></Field>
            </div>
            <Field label="Biography" htmlFor="biography"><textarea {...inp('biography')} rows={3} maxLength={3000} /></Field>
          </fieldset>
          <fieldset><legend>What can you help answer?</legend>
            <p className="hint">Questions are matched to you by comparing them with this text (TF-IDF + cosine similarity), so be specific.</p>
            <Field label="Areas of expertise *" htmlFor="exp"><TagInput id="exp" max={20} value={f.expertise_areas} onChange={set('expertise_areas')} placeholder="NLP, RAG, Cybersecurity…" /></Field>
            <Field label="Skills" htmlFor="skills"><TagInput id="skills" max={30} value={f.skills} onChange={set('skills')} placeholder="Python, PyTorch…" /></Field>
            <Field label="Mentoring areas" htmlFor="ment"><TagInput id="ment" max={20} value={f.mentoring_areas} onChange={set('mentoring_areas')} placeholder="Career guidance, thesis help…" /></Field>
            <Field label="Professional interests" htmlFor="pi"><TagInput id="pi" max={20} value={f.professional_interests} onChange={set('professional_interests')} /></Field>
            <Field label="Projects" htmlFor="proj"><TagInput id="proj" max={20} value={f.projects} onChange={set('projects')} placeholder="Describe a project, press Enter" /></Field>
            <Field label="Certifications" htmlFor="cert"><TagInput id="cert" max={20} value={f.certifications} onChange={set('certifications')} /></Field>
          </fieldset>
        </>) : (<>
          <fieldset><legend>About you</legend>
            <div className="grid2">
              <Field label="Education" htmlFor="education"><input {...inp('education')} placeholder="e.g. B.Tech, Class 12" /></Field>
              <Field label="College / university" htmlFor="institution"><input {...inp('institution')} /></Field>
              <Field label="Work status" htmlFor="work_status"><select {...inp('work_status')}><option value="">Select…</option>{['Student', 'Working professional', 'Job seeker', 'Self-taught', 'Other'].map(x => <option key={x}>{x}</option>)}</select></Field>
              <Field label="Current skill level" htmlFor="skill_level"><select {...inp('skill_level')}><option value="">Select…</option>{LEVELS.map(x => <option key={x}>{x}</option>)}</select></Field>
            </div>
          </fieldset>
          <fieldset><legend>What do I know? What do I want to learn?</legend>
            <Field label="Skills I have" htmlFor="skills"><TagInput id="skills" max={30} value={f.skills} onChange={set('skills')} placeholder="Python, HTML…" /></Field>
            <Field label="Interests" htmlFor="interests"><TagInput id="interests" max={30} value={f.interests} onChange={set('interests')} placeholder="AI, web development…" /></Field>
            <Field label="Topics I want help with" htmlFor="ht"><TagInput id="ht" max={30} value={f.help_topics} onChange={set('help_topics')} /></Field>
            <Field label="Learning goals" htmlFor="learning_goals"><textarea {...inp('learning_goals')} rows={3} maxLength={2000} placeholder="What do you want to achieve?" /></Field>
          </fieldset>
        </>)}
        <fieldset><legend>Preferred languages</legend><LangPicker value={f.languages} onChange={set('languages')} /></fieldset>

        <button className="btn btn-primary btn-block" disabled={busy}>{busy ? 'Creating account…' : 'Create account'}</button>
      </form>
      <p className="auth-alt">Already registered? <Link to={`/login/${type}`}>{expert ? 'Expert' : 'Learner'} Login</Link></p>
      <p className="auth-alt">{expert ? 'Here to learn?' : 'Are you an Expert?'} <Link to={`/register/${expert ? 'learner' : 'expert'}`}>→ Create {expert ? 'Learner' : 'Expert'} Account</Link></p>
    </AuthShell>
  )
}

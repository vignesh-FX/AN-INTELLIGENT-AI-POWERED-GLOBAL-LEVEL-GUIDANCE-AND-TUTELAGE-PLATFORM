import React, { useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad, useToast } from '../lib/hooks.jsx'
import PostCard from '../components/PostCard.jsx'
import { Avatar, ErrorState, Field, ImageUpload, LangPicker, RoleBadge, SkeletonList, TagInput } from '../components/ui.jsx'
import { LEVELS } from '../lib/util.js'

const List = ({ title, items }) => items?.length ? <div className="kv"><h4>{title}</h4><div className="tags">{items.map(i => <span key={i} className="chip">{i}</span>)}</div></div> : null

export function ProfilePage() {
  const { username } = useParams(); const { user, logout } = useAuth(); const nav = useNavigate(); const toast = useToast()
  const s = useLoad(() => api.profile(username), [username, user?.id])
  if (s.loading && !s.data) return <SkeletonList n={2} />
  if (s.error) return <ErrorState error={s.error} onRetry={s.reload} />
  const p = s.data; const q = p.quality; const pr = p.profile || {}
  const toggleBlock = async () => { try { p.is_blocked ? await api.unblock(p.id) : await api.block(p.id); toast.success(p.is_blocked ? 'Unblocked' : 'User blocked'); s.reload() } catch (e) { toast.error(e.message) } }
  return (
    <div className="stack">
      <div className="card profile-head">
        <Avatar user={p} size={84} />
        <div className="grow"><h1>{p.name} <RoleBadge type={p.user_type} /></h1>
          <p className="muted">@{p.username}{pr.title ? ` · ${pr.title}` : ''}{pr.organization ? ` at ${pr.organization}` : ''}{pr.institution ? ` · ${pr.institution}` : ''}</p>
          <div className="row gap-sm wrap"><span className="chip">★ {p.reputation} reputation</span>{p.badges.map(b => <span key={b.key} className="chip chip-badge">🏅 {b.label}</span>)}</div></div>
        <div className="row gap-sm">
          {p.is_me ? (<><Link className="btn btn-primary" to="/settings">Edit profile</Link><button className="btn hide-lg" onClick={() => { logout(); nav('/') }}>Sign out</button></>)
            : user && <button className="btn" onClick={toggleBlock}>{p.is_blocked ? 'Unblock' : 'Block'}</button>}
        </div>
      </div>

      {q && (
        <div className="card"><h3 className="h-sm">Expert quality score <span className="muted small">— how consistently helpful (separate from question relevance)</span></h3>
          <div className="quality">
            <div className="q-score"><strong>{Math.round(q.score)}</strong><span>/ 100</span></div>
            <dl className="q-stats">
              <div><dt>Avg rating</dt><dd>{q.average_rating ? `${q.average_rating} / 5` : '—'}</dd></div>
              <div><dt>Ratings</dt><dd>{q.rating_count}</dd></div>
              <div><dt>Helpful</dt><dd>{q.helpful_percent != null ? `${q.helpful_percent}%` : '—'}</dd></div>
              <div><dt>Answers</dt><dd>{q.answers}</dd></div>
              <div><dt>Accepted</dt><dd>{q.accepted_answers}</dd></div>
            </dl></div>
          <p className="muted small">Uses a Bayesian-weighted rating (current weighted rating {q.bayesian_rating}) so a perfect score from two raters can't outrank a long, consistent record.</p></div>)}

      <div className="card stack">
        {pr.biography && <p>{pr.biography}</p>}
        <List title="Areas of expertise" items={pr.expertise_areas} /><List title="Skills" items={pr.skills} /><List title="Mentoring areas" items={pr.mentoring_areas} />
        <List title="Interests" items={pr.interests || pr.professional_interests} /><List title="Wants help with" items={pr.help_topics} />
        <List title="Projects" items={pr.projects} /><List title="Certifications" items={pr.certifications} /><List title="Languages" items={p.languages} />
        {pr.learning_goals && <div className="kv"><h4>Learning goals</h4><p>{pr.learning_goals}</p></div>}
        {pr.education && <div className="kv"><h4>Education</h4><p>{pr.education}</p></div>}
        {pr.years_experience > 0 && <div className="kv"><h4>Experience</h4><p>{pr.years_experience} years</p></div>}
        {pr.skill_level && <div className="kv"><h4>Level</h4><p>{pr.skill_level}</p></div>}
        <div className="muted small">{p.stats.posts} posts · {p.stats.comments} comments</div>
      </div>
      {p.recent_posts.length > 0 && <><h3>Recent posts</h3><div className="stack">{p.recent_posts.map(x => <PostCard key={x.id} post={x} />)}</div></>}
    </div>
  )
}

export function SettingsPage() {
  const { user, reloadUser } = useAuth(); const toast = useToast(); const nav = useNavigate()
  const expert = user.user_type === 'expert'
  const [f, setF] = useState({ name: user.name, avatar_url: user.avatar_url || null, languages: user.languages || [], ...user.profile })
  const [busy, setBusy] = useState(false); const [err, setErr] = useState('')
  const set = (k) => (v) => setF(p => ({ ...p, [k]: v }))
  const inp = (k) => ({ id: k, value: f[k] ?? '', onChange: e => set(k)(e.target.value) })
  const save = async (e) => {
    e.preventDefault(); setBusy(true); setErr('')
    try { await api.updateProfile({ ...f, years_experience: expert ? Number(f.years_experience) || 0 : undefined, skill_level: f.skill_level || undefined }); await reloadUser(); toast.success('Profile saved'); nav(`/u/${user.username}`) }
    catch (ex) { setErr(ex.message); setBusy(false) }
  }
  return (
    <form className="card form-card stack" onSubmit={save}>
      <h1>Edit profile</h1>
      {err && <div className="notice notice-error" role="alert">{err}</div>}
      <ImageUpload value={f.avatar_url} onChange={set('avatar_url')} user={user} />
      <Field label="Name" htmlFor="name"><input {...inp('name')} required /></Field>
      {expert ? (<>
        <div className="grid2"><Field label="Professional title" htmlFor="title"><input {...inp('title')} /></Field><Field label="Organisation" htmlFor="organization"><input {...inp('organization')} /></Field>
          <Field label="Years of experience" htmlFor="years_experience"><input type="number" min={0} max={70} {...inp('years_experience')} /></Field><Field label="Education" htmlFor="education"><input {...inp('education')} /></Field></div>
        <Field label="Biography" htmlFor="biography"><textarea rows={3} {...inp('biography')} /></Field>
        <p className="hint">Changing your expertise re-computes which questions reach your feed.</p>
        <Field label="Areas of expertise" htmlFor="ea"><TagInput id="ea" max={20} value={f.expertise_areas || []} onChange={set('expertise_areas')} /></Field>
        <Field label="Skills" htmlFor="sk"><TagInput id="sk" max={30} value={f.skills || []} onChange={set('skills')} /></Field>
        <Field label="Mentoring areas" htmlFor="ma"><TagInput id="ma" max={20} value={f.mentoring_areas || []} onChange={set('mentoring_areas')} /></Field>
        <Field label="Professional interests" htmlFor="pi"><TagInput id="pi" max={20} value={f.professional_interests || []} onChange={set('professional_interests')} /></Field>
        <Field label="Projects" htmlFor="pj"><TagInput id="pj" max={20} value={f.projects || []} onChange={set('projects')} /></Field>
        <Field label="Certifications" htmlFor="ce"><TagInput id="ce" max={20} value={f.certifications || []} onChange={set('certifications')} /></Field>
      </>) : (<>
        <div className="grid2"><Field label="Education" htmlFor="education"><input {...inp('education')} /></Field><Field label="College / university" htmlFor="institution"><input {...inp('institution')} /></Field>
          <Field label="Work status" htmlFor="work_status"><input {...inp('work_status')} /></Field>
          <Field label="Skill level" htmlFor="skill_level"><select {...inp('skill_level')}><option value="">—</option>{LEVELS.map(l => <option key={l}>{l}</option>)}</select></Field></div>
        <Field label="Skills" htmlFor="sk"><TagInput id="sk" max={30} value={f.skills || []} onChange={set('skills')} /></Field>
        <Field label="Interests" htmlFor="in"><TagInput id="in" max={30} value={f.interests || []} onChange={set('interests')} /></Field>
        <Field label="Topics I want help with" htmlFor="ht"><TagInput id="ht" max={30} value={f.help_topics || []} onChange={set('help_topics')} /></Field>
        <Field label="Learning goals" htmlFor="learning_goals"><textarea rows={3} {...inp('learning_goals')} /></Field>
      </>)}
      <fieldset><legend>Preferred languages</legend><LangPicker value={f.languages} onChange={set('languages')} /></fieldset>
      <div className="row end gap-sm"><button type="button" className="btn" onClick={() => nav(-1)}>Cancel</button><button className="btn btn-primary" disabled={busy}>{busy ? 'Saving…' : 'Save changes'}</button></div>
    </form>
  )
}

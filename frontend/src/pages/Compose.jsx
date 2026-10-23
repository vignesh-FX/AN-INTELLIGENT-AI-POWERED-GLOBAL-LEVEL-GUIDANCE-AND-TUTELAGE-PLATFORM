import React, { useEffect, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { api } from '../lib/api.js'
import { useAuth } from '../lib/auth.jsx'
import { useLoad, useToast } from '../lib/hooks.jsx'
import { Empty, Field, SkeletonList, TagInput } from '../components/ui.jsx'
import { LEVELS, POST_TYPES, RESOURCE_KINDS } from '../lib/util.js'

export const FIELDS = ['Natural Language Processing', 'Machine Learning', 'Deep Learning', 'Computer Vision', 'Data Science', 'Python', 'Web Development', 'Cybersecurity', 'Electronics', 'Research', 'Career Development']

/** mode="question": the learner "Ask a Question" form.  mode="post": discussions, projects, resources, etc. */
export default function Compose({ mode }) {
  const { user } = useAuth(); const nav = useNavigate(); const toast = useToast(); const [sp] = useSearchParams()
  const mine = useLoad(() => api.communities({ mine: 1 }), [])
  const joined = (mine.data || []).filter(c => c.membership?.status === 'active')
  const types = Object.keys(POST_TYPES).filter(t => t !== 'question' || mode === 'question').filter(t => mode === 'question' ? t === 'question' : t !== 'question' && (user.user_type === 'learner' || t !== 'help_request'))
  const [f, setF] = useState({ community: '', post_type: mode === 'question' ? 'question' : (sp.get('type') || 'discussion'), title: '', body: '', field: '', tags: [], skill_level: '', resource_kind: 'link', attachments: [] })
  const [link, setLink] = useState(''); const [err, setErr] = useState(''); const [busy, setBusy] = useState(false); const [done, setDone] = useState(null)
  useEffect(() => {
    if (joined.length && !f.community) setF(p => ({ ...p, community: joined.find(c => c.slug === sp.get('community'))?.id || joined[0].id }))
  }, [mine.data]) // eslint-disable-line
  const set = (k) => (e) => setF(p => ({ ...p, [k]: e.target ? e.target.value : e }))
  const isQ = f.post_type === 'question'

  const attachFile = async (e) => {
    const file = e.target.files?.[0]; if (!file) return
    try { const r = await api.upload(file); setF(p => ({ ...p, attachments: [...p.attachments, { kind: r.kind, url: r.url, name: r.name, mime: r.mime, size: r.size }] })) }
    catch (ex) { toast.error(ex.message) }
    e.target.value = ''
  }
  const addLink = () => {
    if (!/^https?:\/\//.test(link)) return toast.error('Links must start with http:// or https://')
    setF(p => ({ ...p, attachments: [...p.attachments, { kind: 'link', url: link, name: link }] })); setLink('')
  }
  const submit = async (e) => {
    e.preventDefault(); setErr(''); setBusy(true)
    try {
      const body = { community_id: f.community, post_type: f.post_type, title: f.title, body: f.body, tags: f.tags, field: f.field || undefined,
        skill_level: f.skill_level || undefined, attachments: f.attachments, resource_kind: f.post_type === 'resource' ? f.resource_kind : undefined }
      const p = await api.createPost(body)
      if (isQ) setDone(p); else nav(`/post/${p.id}`)
    } catch (ex) { setErr(ex.message); setBusy(false) }
  }

  if (mine.loading && !mine.data) return <SkeletonList n={1} />
  if (!joined.length) return <Empty icon="👥" title="Join a community first" action={<Link className="btn btn-primary" to="/communities">Browse communities</Link>}>You post inside a community, so questions reach the right audience.</Empty>
  if (done) return (
    <div className="card center stack pad-lg">
      <div className="big-ok" aria-hidden="true">✓</div>
      <h2>Question posted</h2>
      <p className="muted">{done.routed_expert_count > 0
        ? `We compared your question with experts' expertise and placed it in the feeds of ${done.routed_expert_count} relevant expert${done.routed_expert_count === 1 ? '' : 's'}. You'll be notified when someone answers.`
        : 'No expert profile matched strongly yet. It is visible in the community, and experts who join or update their expertise later can still receive it.'}</p>
      <div className="row gap-sm center-row"><Link className="btn btn-primary" to={`/post/${done.id}`}>View your question</Link><Link className="btn" to="/home">Back to home</Link></div>
    </div>)

  return (
    <form className="card form-card stack" onSubmit={submit}>
      <h1>{isQ ? 'Ask a Question' : 'Create a post'}</h1>
      {isQ && <p className="muted">Clear titles, a specific field and good tags help us route your question to the right experts.</p>}
      {err && <div className="notice notice-error" role="alert">{err}</div>}
      {!isQ && <Field label="Post type" htmlFor="ptype"><select id="ptype" value={f.post_type} onChange={set('post_type')}>{types.map(t => <option key={t} value={t}>{POST_TYPES[t]}</option>)}</select></Field>}
      <Field label="Title" htmlFor="title" hint={isQ ? 'e.g. How can I improve retrieval quality in RAG?' : undefined}><input id="title" required minLength={5} maxLength={300} value={f.title} onChange={set('title')} /></Field>
      <Field label={isQ ? 'Description' : 'Body'} htmlFor="body"><textarea id="body" rows={8} maxLength={20000} value={f.body} onChange={set('body')} placeholder={isQ ? 'What have you tried? What did you expect? Include error messages or code in ``` blocks.' : ''} /></Field>
      <div className="grid2">
        <Field label="Field" htmlFor="field"><input id="field" list="fields" value={f.field} onChange={set('field')} maxLength={100} placeholder="Pick or type a field" /><datalist id="fields">{FIELDS.map(x => <option key={x} value={x} />)}</datalist></Field>
        <Field label="Skill level" htmlFor="lvl"><select id="lvl" value={f.skill_level} onChange={set('skill_level')}><option value="">Not specified</option>{LEVELS.map(l => <option key={l}>{l}</option>)}</select></Field>
      </div>
      <Field label="Tags" htmlFor="tags" hint="Up to 8. Tags are used to find experts."><TagInput id="tags" value={f.tags} onChange={set('tags')} placeholder="RAG, NLP, Python…" /></Field>
      <Field label="Community" htmlFor="community"><select id="community" value={f.community} onChange={set('community')}>{joined.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select></Field>
      {f.post_type === 'resource' && (
        <Field label="Resource type" htmlFor="rk"><select id="rk" value={f.resource_kind} onChange={set('resource_kind')}>{RESOURCE_KINDS.map(k => <option key={k}>{k}</option>)}</select></Field>)}
      {!isQ && (
        <fieldset><legend>Attachments {f.post_type === 'resource' && '(a file or link is required)'}</legend>
          {f.attachments.map((a, i) => <div key={i} className="row between mini"><span className="clamp1">{a.kind === 'link' ? '🔗' : a.kind === 'image' ? '🖼️' : '📎'} {a.name}</span>
            <button type="button" className="icon-btn" aria-label="Remove attachment" onClick={() => setF(p => ({ ...p, attachments: p.attachments.filter((_, j) => j !== i) }))}>×</button></div>)}
          <div className="row gap-sm wrap"><input className="grow" aria-label="Link URL" placeholder="https://github.com/…" value={link} onChange={e => setLink(e.target.value)} /><button type="button" className="btn btn-sm" onClick={addLink}>Add link</button>
            <label className="btn btn-sm">Upload file<input type="file" hidden onChange={attachFile} /></label></div>
          <p className="hint">Images, PDF, text, CSV, JSON, notebooks and zip files up to 10 MB.</p></fieldset>)}
      <div className="row end"><button className="btn btn-primary btn-lg" disabled={busy || f.title.trim().length < 5}>{busy ? 'Posting…' : isQ ? 'Post Question' : 'Post'}</button></div>
    </form>
  )
}

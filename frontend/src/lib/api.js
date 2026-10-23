/** Thin API client. Every request goes to the real backend — there is no mock fallback. */
const BASE = (import.meta.env.VITE_API_URL || '') + '/api'

let token = localStorage.getItem('gg_token')
let onUnauthorized = () => {}
export const setUnauthorizedHandler = (fn) => { onUnauthorized = fn }
export const setToken = (t) => { token = t; t ? localStorage.setItem('gg_token', t) : localStorage.removeItem('gg_token') }
export const getToken = () => token

export class ApiError extends Error {
  constructor(message, status) { super(message); this.status = status }
}

function detailToMessage(d) {
  if (!d) return 'Something went wrong'
  if (typeof d === 'string') return d
  if (Array.isArray(d)) return d.map(e => (e.loc ? e.loc.filter(x => x !== 'body').join('.') + ': ' : '') + (e.msg || '').replace(/^Value error, /, '')).join('; ')
  return JSON.stringify(d)
}

async function request(method, path, body, isForm = false) {
  const headers = {}
  if (token) headers.Authorization = `Bearer ${token}`
  if (body && !isForm) headers['Content-Type'] = 'application/json'
  let res
  try {
    res = await fetch(BASE + path, { method, headers, body: body ? (isForm ? body : JSON.stringify(body)) : undefined })
  } catch {
    throw new ApiError('Cannot reach the server. Is the backend running?', 0)
  }
  if (res.status === 204) return null
  const data = await res.json().catch(() => null)
  if (!res.ok) {
    if (res.status === 401 && token) { setToken(null); onUnauthorized() }
    throw new ApiError(detailToMessage(data?.detail), res.status)
  }
  return data
}

const qs = (o = {}) => {
  const p = new URLSearchParams()
  Object.entries(o).forEach(([k, v]) => v !== undefined && v !== null && v !== '' && p.set(k, v))
  const s = p.toString()
  return s ? `?${s}` : ''
}
const get = (p, params) => request('GET', p + qs(params))
const post = (p, b) => request('POST', p, b ?? {})
const put = (p, b) => request('PUT', p, b ?? {})
const del = (p) => request('DELETE', p)

export const api = {
  // auth
  login: (type, email, password) => post(`/auth/${type}/login`, { email, password }),
  register: (type, data) => post(`/auth/${type}/register`, data),
  me: () => get('/auth/me'),
  updateProfile: (d) => put('/me/profile', d),
  profile: (username) => get(`/users/${username}`),
  block: (id) => post(`/users/${id}/block`), unblock: (id) => del(`/users/${id}/block`),
  // communities
  communities: (p) => get('/communities', p), recommended: () => get('/communities/recommended'),
  community: (slug) => get(`/communities/${slug}`),
  createCommunity: (d) => post('/communities', d), updateCommunity: (slug, d) => put(`/communities/${slug}`, d),
  join: (slug) => post(`/communities/${slug}/join`), leave: (slug) => post(`/communities/${slug}/leave`),
  communityPosts: (slug, p) => get(`/communities/${slug}/posts`, p),
  members: (slug) => get(`/communities/${slug}/members`),
  setModerator: (slug, username, grant) => post(`/communities/${slug}/moderators`, { username, grant }),
  bans: (slug) => get(`/communities/${slug}/bans`), ban: (slug, username, reason) => post(`/communities/${slug}/bans`, { username, reason }),
  unban: (slug, username) => del(`/communities/${slug}/bans/${username}`),
  requests: (slug) => get(`/communities/${slug}/requests`),
  decideRequest: (slug, username, d) => post(`/communities/${slug}/requests/${username}/${d}`),
  communityReports: (slug) => get(`/communities/${slug}/reports`),
  resolveReport: (id, action) => post(`/reports/${id}/resolve`, { action }),
  // posts & comments
  createPost: (d) => post('/posts', d), getPost: (id) => get(`/posts/${id}`), editPost: (id, d) => put(`/posts/${id}`, d),
  deletePost: (id) => del(`/posts/${id}`), pinPost: (id) => post(`/posts/${id}/pin`),
  save: (id) => post(`/posts/${id}/save`), unsave: (id) => del(`/posts/${id}/save`),
  comments: (id, sort) => get(`/posts/${id}/comments`, { sort }),
  addComment: (id, body, parent_id) => post(`/posts/${id}/comments`, { body, parent_id }),
  editComment: (id, body) => put(`/comments/${id}`, { body }), deleteComment: (id) => del(`/comments/${id}`),
  accept: (id) => post(`/comments/${id}/accept`),
  rate: (id, rating) => put(`/comments/${id}/rating`, { rating }), unrate: (id) => del(`/comments/${id}/rating`),
  helpful: (id, value) => post(`/comments/${id}/helpful`, { value }),
  vote: (target_type, target_id, value) => post('/votes', { target_type, target_id, value }),
  react: (target_type, target_id, emoji) => post('/reactions', { target_type, target_id, emoji }),
  report: (target_type, target_id, reason, details) => post('/reports', { target_type, target_id, reason, details }),
  // feeds
  expertFeed: (p) => get('/feed/expert', p), setRelevance: (id, status) => post(`/feed/expert/${id}/status`, { status }),
  homeFeed: (p) => get('/feed/home', p), trending: () => get('/feed/trending'),
  myQuestions: () => get('/me/questions'), myAnswers: () => get('/me/answers'), saved: () => get('/me/saved'),
  // misc
  notifications: () => get('/notifications'), unread: () => get('/notifications/unread-count'),
  readAll: () => post('/notifications/read-all'), readOne: (id) => post(`/notifications/${id}/read`),
  search: (q, type) => get('/search', { q, type }),
  languages: () => get('/translate/languages'),
  translate: (d) => post('/translate', d),
  upload: (file) => { const f = new FormData(); f.append('file', file); return request('POST', '/uploads', f, true) },
}

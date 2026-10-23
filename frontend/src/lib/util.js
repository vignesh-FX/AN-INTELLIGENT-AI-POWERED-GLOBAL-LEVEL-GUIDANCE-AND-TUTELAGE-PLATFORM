export function timeAgo(iso) {
  if (!iso) return ''
  const s = Math.max(1, Math.floor((Date.now() - new Date(iso).getTime()) / 1000))
  const units = [['y', 31536000], ['mo', 2592000], ['d', 86400], ['h', 3600], ['m', 60]]
  for (const [u, n] of units) if (s >= n) return `${Math.floor(s / n)}${u} ago`
  return 'just now'
}
export const initials = (name = '') => name.split(/\s+/).filter(Boolean).slice(0, 2).map(w => w[0]).join('').toUpperCase() || '?'
export const LEVELS = ['Beginner', 'Intermediate', 'Advanced']
export const POST_TYPES = {
  question: 'Question', discussion: 'Discussion', project: 'Project', resource: 'Resource',
  help_request: 'Help request', announcement: 'Announcement',
}
export const RESOURCE_KINDS = ['pdf', 'paper', 'github', 'article', 'video', 'dataset', 'notebook', 'project', 'link']
export const splitList = (s) => (s || '').split(/[,\n]/).map(x => x.trim()).filter(Boolean)
export const home = (user) => (user?.user_type === 'expert' ? '/for-you' : '/home')
export const assetUrl = (u) => (u && u.startsWith('/uploads/') ? (import.meta.env.VITE_API_URL || '') + u : u)

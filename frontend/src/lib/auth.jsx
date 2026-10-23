import React, { createContext, useCallback, useContext, useEffect, useState } from 'react'
import { api, getToken, setToken, setUnauthorizedHandler } from './api.js'

const AuthCtx = createContext(null)
export const useAuth = () => useContext(AuthCtx)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [ready, setReady] = useState(!getToken())
  const [unread, setUnread] = useState(0)

  const logout = useCallback(() => { setToken(null); setUser(null); setUnread(0) }, [])
  useEffect(() => { setUnauthorizedHandler(() => { setUser(null); setUnread(0) }) }, [])

  useEffect(() => {
    if (!getToken()) return
    api.me().then(setUser).catch(() => setToken(null)).finally(() => setReady(true))
  }, [])

  // Notifications are polled today; swap for WebSocket / Supabase Realtime later without touching callers.
  const refreshUnread = useCallback(() => {
    if (getToken()) api.unread().then(r => setUnread(r.count)).catch(() => {})
  }, [])
  useEffect(() => {
    if (!user) return
    refreshUnread()
    const t = setInterval(refreshUnread, 30000)
    return () => clearInterval(t)
  }, [user, refreshUnread])

  const signIn = (session) => { setToken(session.access_token); setUser(session.user) }
  const reloadUser = () => api.me().then(setUser)

  if (!ready) return <div className="boot"><div className="spinner" /></div>
  return <AuthCtx.Provider value={{ user, signIn, logout, reloadUser, unread, setUnread, refreshUnread }}>{children}</AuthCtx.Provider>
}

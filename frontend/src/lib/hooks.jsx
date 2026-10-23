import React, { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react'

/** Load data with loading / error / reload — drives skeleton and error states. */
export function useLoad(fn, deps = []) {
  const [state, setState] = useState({ data: null, loading: true, error: null })
  const seq = useRef(0)
  const run = useCallback(() => {
    const id = ++seq.current
    setState(s => ({ ...s, loading: true, error: null }))
    fn().then(
      data => id === seq.current && setState({ data, loading: false, error: null }),
      error => id === seq.current && setState({ data: null, loading: false, error }),
    )
  }, deps) // eslint-disable-line
  useEffect(() => { run() }, [run])
  const setData = useCallback((updater) => setState(s => ({ ...s, data: typeof updater === 'function' ? updater(s.data) : updater })), [])
  return { ...state, reload: run, setData }
}

/**
 * Optimistic state:  const [state, act] = useOptimistic(initial)
 *   act(patchOrFn, request)  → applies the patch immediately, then calls request().
 *   success → server fields are merged in (server is the source of truth);
 *   failure → rolls back to the snapshot taken before the action and shows the error.
 * Requests run one after another, so rapid clicks can never leave state diverging from the backend.
 */
export function useOptimistic(initial) {
  const [state, setState] = useState(initial)
  const ref = useRef(initial)
  const queue = useRef(Promise.resolve())
  const toast = useToast()
  const set = (v) => { ref.current = v; setState(v) }
  const act = useCallback((patch, request) => {
    const snapshot = ref.current
    set({ ...snapshot, ...(typeof patch === 'function' ? patch(snapshot) : patch), _pending: true })
    queue.current = queue.current.then(async () => {
      try {
        const server = await request()
        set({ ...ref.current, ...(server || {}), _pending: false })
      } catch (e) {
        set({ ...snapshot, _pending: false })
        toast.error(e.message || 'Action failed — change reverted')
      }
    })
    return queue.current
  }, []) // eslint-disable-line
  return [state, act, set]
}

// ── toasts ────────────────────────────────────────────────────────────────────
const ToastCtx = createContext({ error() {}, success() {} })
export const useToast = () => useContext(ToastCtx)

export function ToastProvider({ children }) {
  const [items, setItems] = useState([])
  const push = useCallback((kind, message) => {
    const id = Math.random().toString(36).slice(2)
    setItems(i => [...i.slice(-3), { id, kind, message }])
    setTimeout(() => setItems(i => i.filter(x => x.id !== id)), 4500)
  }, [])
  const api = useRef({ error: (m) => push('error', m), success: (m) => push('success', m) }).current
  return (
    <ToastCtx.Provider value={api}>
      {children}
      <div className="toasts" role="status" aria-live="polite">
        {items.map(t => <div key={t.id} className={`toast toast-${t.kind}`}>{t.message}</div>)}
      </div>
    </ToastCtx.Provider>
  )
}

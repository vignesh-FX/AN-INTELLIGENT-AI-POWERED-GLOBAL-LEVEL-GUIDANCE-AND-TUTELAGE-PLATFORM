import React from 'react'
import { Navigate, Route, Routes, useLocation } from 'react-router-dom'
import { AuthProvider, useAuth } from './lib/auth.jsx'
import { ToastProvider } from './lib/hooks.jsx'
import Layout from './components/Layout.jsx'
import Landing from './pages/Landing.jsx'
import { LoginPage, RegisterPage } from './pages/AuthPages.jsx'
import { ExpertFeed, LearnerHome } from './pages/Feeds.jsx'
import { CommunitiesPage, CommunityPage, CreateCommunity } from './pages/Communities.jsx'
import Compose from './pages/Compose.jsx'
import PostPage from './pages/PostPage.jsx'
import { MyAnswers, MyQuestions, Notifications, Saved } from './pages/Lists.jsx'
import { ProfilePage, SettingsPage } from './pages/Profile.jsx'
import SearchPage from './pages/Search.jsx'
import { home } from './lib/util.js'

/** Gate a route by sign-in and (optionally) account type. Wrong type → that user's own dashboard. */
function Guard({ type, children }) {
  const { user } = useAuth(); const loc = useLocation()
  if (!user) return <Navigate to={`/login/${type || 'learner'}?next=${encodeURIComponent(loc.pathname)}`} replace />
  if (type && user.user_type !== type) return <Navigate to={home(user)} replace />
  return children
}

export default function App() {
  return (
    <ToastProvider>
      <AuthProvider>
        <Routes>
          <Route path="/" element={<Landing />} />
          <Route path="/login/learner" element={<LoginPage type="learner" />} />
          <Route path="/login/expert" element={<LoginPage type="expert" />} />
          <Route path="/register/learner" element={<RegisterPage type="learner" />} />
          <Route path="/register/expert" element={<RegisterPage type="expert" />} />
          <Route path="/login" element={<Navigate to="/login/learner" replace />} />

          <Route element={<Layout />}>
            <Route path="/home" element={<Guard type="learner"><LearnerHome /></Guard>} />
            <Route path="/for-you" element={<Guard type="expert"><ExpertFeed /></Guard>} />
            <Route path="/ask" element={<Guard type="learner"><Compose mode="question" /></Guard>} />
            <Route path="/new" element={<Guard><Compose mode="post" /></Guard>} />
            <Route path="/my-questions" element={<Guard type="learner"><MyQuestions /></Guard>} />
            <Route path="/my-answers" element={<Guard type="expert"><MyAnswers /></Guard>} />
            <Route path="/saved" element={<Guard><Saved /></Guard>} />
            <Route path="/notifications" element={<Guard><Notifications /></Guard>} />
            <Route path="/settings" element={<Guard><SettingsPage /></Guard>} />
            <Route path="/communities" element={<CommunitiesPage />} />
            <Route path="/communities/new" element={<Guard><CreateCommunity /></Guard>} />
            <Route path="/c/:slug" element={<CommunityPage />} />
            <Route path="/post/:id" element={<PostPage />} />
            <Route path="/u/:username" element={<ProfilePage />} />
            <Route path="/search" element={<SearchPage />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </ToastProvider>
  )
}

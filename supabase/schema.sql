-- GlobalGuru schema for Supabase (Postgres). Paste into the Supabase SQL Editor and run.
-- Generated from backend/models.py by backend/scripts/generate_schema.py — do not edit by hand.

CREATE TABLE IF NOT EXISTS tags (
	id UUID NOT NULL, 
	name VARCHAR(40) NOT NULL, 
	PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_tags_name ON tags (name);

CREATE TABLE IF NOT EXISTS translations (
	id UUID NOT NULL, 
	text_hash VARCHAR(64) NOT NULL, 
	source_lang VARCHAR(12) NOT NULL, 
	target_lang VARCHAR(12) NOT NULL, 
	model VARCHAR(80) NOT NULL, 
	translated_text TEXT NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_translation UNIQUE (text_hash, source_lang, target_lang, model)
);

CREATE INDEX IF NOT EXISTS ix_translations_text_hash ON translations (text_hash);

CREATE TABLE IF NOT EXISTS users (
	id UUID NOT NULL, 
	email VARCHAR(255) NOT NULL, 
	username VARCHAR(40) NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	password_hash VARCHAR(255) NOT NULL, 
	user_type VARCHAR(10) NOT NULL, 
	avatar_url VARCHAR(500), 
	languages JSONB NOT NULL, 
	reputation INTEGER NOT NULL, 
	is_active BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_users_type CHECK (user_type in ('learner','expert'))
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_users_email ON users (email);
CREATE INDEX IF NOT EXISTS ix_users_user_type ON users (user_type);
CREATE UNIQUE INDEX IF NOT EXISTS ix_users_username ON users (username);

CREATE TABLE IF NOT EXISTS communities (
	id UUID NOT NULL, 
	slug VARCHAR(60) NOT NULL, 
	name VARCHAR(80) NOT NULL, 
	description TEXT NOT NULL, 
	avatar_url VARCHAR(500), 
	banner_url VARCHAR(500), 
	rules JSONB NOT NULL, 
	is_private BOOLEAN NOT NULL, 
	created_by UUID, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name), 
	FOREIGN KEY(created_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_communities_slug ON communities (slug);

CREATE TABLE IF NOT EXISTS expert_profiles (
	user_id UUID NOT NULL, 
	title VARCHAR(160), 
	organization VARCHAR(200), 
	years_experience INTEGER NOT NULL, 
	education VARCHAR(200), 
	skills JSONB NOT NULL, 
	expertise_areas JSONB NOT NULL, 
	projects JSONB NOT NULL, 
	certifications JSONB NOT NULL, 
	biography TEXT, 
	mentoring_areas JSONB NOT NULL, 
	professional_interests JSONB NOT NULL, 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS learner_profiles (
	user_id UUID NOT NULL, 
	education VARCHAR(160), 
	institution VARCHAR(200), 
	work_status VARCHAR(80), 
	skills JSONB NOT NULL, 
	interests JSONB NOT NULL, 
	skill_level VARCHAR(20), 
	learning_goals TEXT, 
	help_topics JSONB NOT NULL, 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS reactions (
	user_id UUID NOT NULL, 
	target_type VARCHAR(8) NOT NULL, 
	target_id UUID NOT NULL, 
	emoji VARCHAR(8) NOT NULL, 
	PRIMARY KEY (user_id, target_type, target_id, emoji), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_reactions_target ON reactions (target_type, target_id);

CREATE TABLE IF NOT EXISTS reputation_events (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	ref_key VARCHAR(160) NOT NULL, 
	kind VARCHAR(30) NOT NULL, 
	points INTEGER NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	UNIQUE (ref_key)
);

CREATE INDEX IF NOT EXISTS ix_reputation_events_user_id ON reputation_events (user_id);

CREATE TABLE IF NOT EXISTS user_badges (
	user_id UUID NOT NULL, 
	badge_key VARCHAR(40) NOT NULL, 
	awarded_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (user_id, badge_key), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS user_blocks (
	blocker_id UUID NOT NULL, 
	blocked_id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (blocker_id, blocked_id), 
	FOREIGN KEY(blocker_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(blocked_id) REFERENCES users (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS votes (
	user_id UUID NOT NULL, 
	target_type VARCHAR(8) NOT NULL, 
	target_id UUID NOT NULL, 
	value INTEGER NOT NULL, 
	PRIMARY KEY (user_id, target_type, target_id), 
	CONSTRAINT ck_votes_value CHECK (value in (-1, 1)), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_votes_target ON votes (target_type, target_id);

CREATE TABLE IF NOT EXISTS community_bans (
	community_id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	reason VARCHAR(300), 
	banned_by UUID, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (community_id, user_id), 
	FOREIGN KEY(community_id) REFERENCES communities (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(banned_by) REFERENCES users (id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS community_members (
	community_id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	role VARCHAR(12) NOT NULL, 
	status VARCHAR(10) NOT NULL, 
	joined_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (community_id, user_id), 
	FOREIGN KEY(community_id) REFERENCES communities (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_cm_user ON community_members (user_id);

CREATE TABLE IF NOT EXISTS posts (
	id UUID NOT NULL, 
	author_id UUID NOT NULL, 
	community_id UUID NOT NULL, 
	post_type VARCHAR(16) NOT NULL, 
	title VARCHAR(300) NOT NULL, 
	body TEXT NOT NULL, 
	field VARCHAR(100), 
	skill_level VARCHAR(20), 
	resource_kind VARCHAR(24), 
	status VARCHAR(12) NOT NULL, 
	is_pinned BOOLEAN NOT NULL, 
	is_removed BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE, 
	last_activity_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_posts_type CHECK (post_type in ('question','discussion','project','resource','help_request','announcement')), 
	FOREIGN KEY(author_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(community_id) REFERENCES communities (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_posts_author ON posts (author_id);
CREATE INDEX IF NOT EXISTS ix_posts_community_created ON posts (community_id, created_at);

CREATE TABLE IF NOT EXISTS reports (
	id UUID NOT NULL, 
	reporter_id UUID, 
	target_type VARCHAR(8) NOT NULL, 
	target_id UUID NOT NULL, 
	community_id UUID, 
	reason VARCHAR(40) NOT NULL, 
	details VARCHAR(1000), 
	status VARCHAR(12) NOT NULL, 
	resolved_by UUID, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(reporter_id) REFERENCES users (id) ON DELETE SET NULL, 
	FOREIGN KEY(community_id) REFERENCES communities (id) ON DELETE CASCADE, 
	FOREIGN KEY(resolved_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS ix_reports_community_status ON reports (community_id, status);

CREATE TABLE IF NOT EXISTS attachments (
	id UUID NOT NULL, 
	post_id UUID NOT NULL, 
	kind VARCHAR(10) NOT NULL, 
	url VARCHAR(1000) NOT NULL, 
	name VARCHAR(255), 
	mime VARCHAR(100), 
	size INTEGER, 
	PRIMARY KEY (id), 
	FOREIGN KEY(post_id) REFERENCES posts (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_attachments_post_id ON attachments (post_id);

CREATE TABLE IF NOT EXISTS comments (
	id UUID NOT NULL, 
	post_id UUID NOT NULL, 
	parent_id UUID, 
	author_id UUID NOT NULL, 
	body TEXT NOT NULL, 
	is_answer BOOLEAN NOT NULL, 
	is_accepted BOOLEAN NOT NULL, 
	is_deleted BOOLEAN NOT NULL, 
	is_removed BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	edited_at TIMESTAMP WITH TIME ZONE, 
	PRIMARY KEY (id), 
	FOREIGN KEY(post_id) REFERENCES posts (id) ON DELETE CASCADE, 
	FOREIGN KEY(parent_id) REFERENCES comments (id) ON DELETE CASCADE, 
	FOREIGN KEY(author_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_comments_parent_id ON comments (parent_id);
CREATE INDEX IF NOT EXISTS ix_comments_post ON comments (post_id, created_at);

CREATE TABLE IF NOT EXISTS post_tags (
	post_id UUID NOT NULL, 
	tag_id UUID NOT NULL, 
	PRIMARY KEY (post_id, tag_id), 
	FOREIGN KEY(post_id) REFERENCES posts (id) ON DELETE CASCADE, 
	FOREIGN KEY(tag_id) REFERENCES tags (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS question_relevance (
	post_id UUID NOT NULL, 
	expert_id UUID NOT NULL, 
	similarity FLOAT NOT NULL, 
	field_score FLOAT NOT NULL, 
	tag_score FLOAT NOT NULL, 
	community_score FLOAT NOT NULL, 
	matched_terms JSONB NOT NULL, 
	status VARCHAR(10) NOT NULL, 
	routed_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (post_id, expert_id), 
	FOREIGN KEY(post_id) REFERENCES posts (id) ON DELETE CASCADE, 
	FOREIGN KEY(expert_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_qr_expert_status ON question_relevance (expert_id, status);

CREATE TABLE IF NOT EXISTS saved_posts (
	user_id UUID NOT NULL, 
	post_id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (user_id, post_id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(post_id) REFERENCES posts (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS answer_ratings (
	id UUID NOT NULL, 
	comment_id UUID NOT NULL, 
	rater_id UUID NOT NULL, 
	rating INTEGER NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_rating_once UNIQUE (comment_id, rater_id), 
	CONSTRAINT ck_rating_range CHECK (rating between 1 and 5), 
	FOREIGN KEY(comment_id) REFERENCES comments (id) ON DELETE CASCADE, 
	FOREIGN KEY(rater_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_answer_ratings_comment_id ON answer_ratings (comment_id);

CREATE TABLE IF NOT EXISTS helpful_votes (
	comment_id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (comment_id, user_id), 
	FOREIGN KEY(comment_id) REFERENCES comments (id) ON DELETE CASCADE, 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS notifications (
	id UUID NOT NULL, 
	user_id UUID NOT NULL, 
	type VARCHAR(30) NOT NULL, 
	actor_id UUID, 
	post_id UUID, 
	comment_id UUID, 
	message VARCHAR(300) NOT NULL, 
	is_read BOOLEAN NOT NULL, 
	created_at TIMESTAMP WITH TIME ZONE NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE, 
	FOREIGN KEY(actor_id) REFERENCES users (id) ON DELETE SET NULL, 
	FOREIGN KEY(post_id) REFERENCES posts (id) ON DELETE CASCADE, 
	FOREIGN KEY(comment_id) REFERENCES comments (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_notif_user ON notifications (user_id, is_read, created_at);

-- The API connects with the database owner (DATABASE_URL), which bypasses Row Level Security, and
-- never exposes PostgREST to the browser. Enabling RLS with no policies makes these tables
-- unreachable through Supabase's public anon/authenticated REST API, which is what we want.
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expert_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learner_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reputation_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_bans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_relevance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answer_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

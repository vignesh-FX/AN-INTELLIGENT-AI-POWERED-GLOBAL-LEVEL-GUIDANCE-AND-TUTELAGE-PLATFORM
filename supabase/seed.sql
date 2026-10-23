-- GlobalGuru sample data: 100 learner users, each asking 1 question (100 questions).
-- Run AFTER schema.sql in the Supabase SQL Editor. Safe to re-run (ON CONFLICT DO NOTHING).
-- Seed users have a non-loginable placeholder password_hash and @example.test emails.
BEGIN;

-- Communities (posts need a community)
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','python-help','Python Help','Questions about Python programming, libraries and debugging.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','web-development','Web Development','HTML, CSS, JavaScript, React and backend web questions.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','data-science','Data Science','Data analysis, statistics, pandas and visualisation.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','machine-learning','Machine Learning','ML and AI concepts, model training and deployment.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','career-advice','Career Advice','Jobs, interviews, CVs and professional growth.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','ui-ux-design','UI/UX Design','User research, interface design and prototyping.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','cloud-devops','Cloud & DevOps','Cloud platforms, CI/CD, containers and infrastructure.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','mobile-development','Mobile Development','Android, iOS and cross-platform app development.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','cybersecurity','Cybersecurity','Security fundamentals, safe coding and careers in security.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO communities (id,slug,name,description,rules,is_private,created_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','databases-sql','Databases & SQL','SQL, database design and data modelling.','["Be respectful", "Search before asking", "Share what you tried"]'::jsonb,false,'2026-08-01T09:00:00+00:00') ON CONFLICT DO NOTHING;

-- Users + learner profiles
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('16f43cd6-8fad-5c6f-8f90-7f1666ff84ef','fatima_rossi1@example.test','fatima_rossi1','Fatima Rossi','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-02T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('16f43cd6-8fad-5c6f-8f90-7f1666ff84ef','Diploma','Tech Institute','employed full-time','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'beginner','I want to finish my university project.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('a41c002b-cef3-5733-838e-aa14bcfbdc5e','noah_lopez2@example.test','noah_lopez2','Noah Lopez','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-03T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('a41c002b-cef3-5733-838e-aa14bcfbdc5e','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('9b344911-eac1-5725-945a-ad0caaba86bb','yuki_garcia3@example.test','yuki_garcia3','Yuki Garcia','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-04T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('9b344911-eac1-5725-945a-ad0caaba86bb','Bachelor''s degree','State College','job seeker','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'intermediate','I want to switch careers within a year.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('dd410663-011f-50aa-b62a-027e3f1aeb4b','kofi_patel4@example.test','kofi_patel4','Kofi Patel','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-05T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('dd410663-011f-50aa-b62a-027e3f1aeb4b','Master''s degree (in progress)','Community College','freelancer','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('a2bb820c-0964-55d9-a42e-41b8e8b09c6f','hana_kim5@example.test','hana_kim5','Hana Kim','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-06T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('a2bb820c-0964-55d9-a42e-41b8e8b09c6f','Self-taught','Self-study','career changer','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'beginner','I want to improve at work.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('87a5814a-6977-584f-a088-4e7fa518a414','diego_wei6@example.test','diego_wei6','Diego Wei','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-07T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('87a5814a-6977-584f-a088-4e7fa518a414','High school','City University','student','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'beginner','I want to start freelancing.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('ffb4bec8-a7ac-59f8-b5f3-bfe934f6b9b3','maria_tanaka7@example.test','maria_tanaka7','Maria Tanaka','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-08T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('ffb4bec8-a7ac-59f8-b5f3-bfe934f6b9b3','Diploma','Tech Institute','employed full-time','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'intermediate','I want to prepare for interviews.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('699a00a8-07d6-5489-a536-cbe61d6b29a8','lucas_novak8@example.test','lucas_novak8','Lucas Novak','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-09T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('699a00a8-07d6-5489-a536-cbe61d6b29a8','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'intermediate','I want to learn at my own pace.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('089d806b-e6db-5891-b901-2e04c821d170','sofia_khan9@example.test','sofia_khan9','Sofia Khan','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-10T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('089d806b-e6db-5891-b901-2e04c821d170','Bachelor''s degree','State College','job seeker','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'advanced','I want to build an app for my community.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('d5f767f5-8721-5a25-b64c-8b1eca52851c','omar_haddad10@example.test','omar_haddad10','Omar Haddad','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-11T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('d5f767f5-8721-5a25-b64c-8b1eca52851c','Master''s degree (in progress)','Community College','freelancer','["Python"]'::jsonb,'["Python", "Questions about Python programming"]'::jsonb,'beginner','I want to get my first job in tech.','["Python"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f72c4762-41a6-567b-bbe0-4dbaa039ae3a','priya_costa11@example.test','priya_costa11','Priya Costa','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-12T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f72c4762-41a6-567b-bbe0-4dbaa039ae3a','Self-taught','Self-study','career changer','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'beginner','I want to finish my university project.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('bc054fce-bc5b-5e6c-aa98-186728bc6c62','ivan_okafor12@example.test','ivan_okafor12','Ivan Okafor','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-13T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('bc054fce-bc5b-5e6c-aa98-186728bc6c62','High school','City University','student','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('945e372b-a9d2-5bee-8b29-6a01af30c882','leila_mensah13@example.test','leila_mensah13','Leila Mensah','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-14T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('945e372b-a9d2-5bee-8b29-6a01af30c882','Diploma','Tech Institute','employed full-time','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'intermediate','I want to switch careers within a year.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('c00d44ba-529c-585b-9354-e972dadac134','chen_ahmed14@example.test','chen_ahmed14','Chen Ahmed','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-15T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('c00d44ba-529c-585b-9354-e972dadac134','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('b2bb0920-1c9e-58f3-a3df-25d34d1901c2','amina_nguyen15@example.test','amina_nguyen15','Amina Nguyen','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-16T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('b2bb0920-1c9e-58f3-a3df-25d34d1901c2','Bachelor''s degree','State College','job seeker','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'beginner','I want to improve at work.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('dc486bca-e24d-5667-8e4c-0d615f02ac32','ravi_reddy16@example.test','ravi_reddy16','Ravi Reddy','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-17T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('dc486bca-e24d-5667-8e4c-0d615f02ac32','Master''s degree (in progress)','Community College','freelancer','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'beginner','I want to start freelancing.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('bb5e0047-1354-523c-b218-9073cc978c8f','elena_sharma17@example.test','elena_sharma17','Elena Sharma','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-18T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('bb5e0047-1354-523c-b218-9073cc978c8f','Self-taught','Self-study','career changer','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'intermediate','I want to prepare for interviews.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('1f293bb8-bafc-5eb5-a6cf-e50ef92d9d22','mateo_rossi18@example.test','mateo_rossi18','Mateo Rossi','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-19T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('1f293bb8-bafc-5eb5-a6cf-e50ef92d9d22','High school','City University','student','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'intermediate','I want to learn at my own pace.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('0858866f-b75b-54a9-93e8-44615cae7d2b','zara_lopez19@example.test','zara_lopez19','Zara Lopez','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-20T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('0858866f-b75b-54a9-93e8-44615cae7d2b','Diploma','Tech Institute','employed full-time','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'advanced','I want to build an app for my community.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('ff18aa6f-98a5-57fd-98cd-88a46d039bd2','aarav_garcia20@example.test','aarav_garcia20','Aarav Garcia','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-21T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('ff18aa6f-98a5-57fd-98cd-88a46d039bd2','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Web Development"]'::jsonb,'["Web Development", "HTML"]'::jsonb,'beginner','I want to get my first job in tech.','["Web Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('36327cfb-5c54-51f2-b0cd-54f60941464b','fatima_tanaka21@example.test','fatima_tanaka21','Fatima Tanaka','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-22T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('36327cfb-5c54-51f2-b0cd-54f60941464b','Bachelor''s degree','State College','job seeker','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'beginner','I want to finish my university project.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('b8acf4ee-7829-5d53-bba8-f8df4cfd5650','noah_novak22@example.test','noah_novak22','Noah Novak','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-23T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('b8acf4ee-7829-5d53-bba8-f8df4cfd5650','Master''s degree (in progress)','Community College','freelancer','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('04187e03-b9a9-570e-9f75-01205e2208e3','yuki_khan23@example.test','yuki_khan23','Yuki Khan','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-24T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('04187e03-b9a9-570e-9f75-01205e2208e3','Self-taught','Self-study','career changer','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'intermediate','I want to switch careers within a year.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('ca3b963e-9c04-51f7-9391-0e3a4a1c67b9','kofi_haddad24@example.test','kofi_haddad24','Kofi Haddad','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-25T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('ca3b963e-9c04-51f7-9391-0e3a4a1c67b9','High school','City University','student','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f1b1f5ae-de17-5f80-b777-5fc2490ffbc6','hana_ali25@example.test','hana_ali25','Hana Ali','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-26T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f1b1f5ae-de17-5f80-b777-5fc2490ffbc6','Diploma','Tech Institute','employed full-time','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'beginner','I want to improve at work.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('aa79988e-6610-529c-a1bb-40702957681f','diego_silva26@example.test','diego_silva26','Diego Silva','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-27T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('aa79988e-6610-529c-a1bb-40702957681f','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'beginner','I want to start freelancing.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f9c6adf7-68cd-58ac-a8cb-85d7b1936e28','maria_petrova27@example.test','maria_petrova27','Maria Petrova','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-28T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f9c6adf7-68cd-58ac-a8cb-85d7b1936e28','Bachelor''s degree','State College','job seeker','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'intermediate','I want to prepare for interviews.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('0cac0b2f-f7bf-50fb-ac01-2929ab0b648f','lucas_costa28@example.test','lucas_costa28','Lucas Costa','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-29T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('0cac0b2f-f7bf-50fb-ac01-2929ab0b648f','Master''s degree (in progress)','Community College','freelancer','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'intermediate','I want to learn at my own pace.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('a5275e62-20d3-5d0c-b617-3e230fbeb2a3','sofia_okafor29@example.test','sofia_okafor29','Sofia Okafor','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-30T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('a5275e62-20d3-5d0c-b617-3e230fbeb2a3','Self-taught','Self-study','career changer','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'advanced','I want to build an app for my community.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('6a5dad2c-253c-5229-81f2-e0f1897b5483','omar_mensah30@example.test','omar_mensah30','Omar Mensah','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-31T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('6a5dad2c-253c-5229-81f2-e0f1897b5483','High school','City University','student','["Data Science"]'::jsonb,'["Data Science", "Data analysis"]'::jsonb,'beginner','I want to get my first job in tech.','["Data Science"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('9c267dc6-9078-5315-a815-02dc4d5f6ed4','priya_sharma31@example.test','priya_sharma31','Priya Sharma','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-09-01T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('9c267dc6-9078-5315-a815-02dc4d5f6ed4','Diploma','Tech Institute','employed full-time','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'beginner','I want to finish my university project.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('5c0bb011-3da7-5c53-b1ea-1e1eb288ca09','ivan_rossi32@example.test','ivan_rossi32','Ivan Rossi','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-09-02T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('5c0bb011-3da7-5c53-b1ea-1e1eb288ca09','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('267da74a-c78f-5fff-9bb7-f991ab0b8186','leila_lopez33@example.test','leila_lopez33','Leila Lopez','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-09-03T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('267da74a-c78f-5fff-9bb7-f991ab0b8186','Bachelor''s degree','State College','job seeker','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'intermediate','I want to switch careers within a year.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('c03b8bc2-c8c1-58d0-bee7-ec610e60f2d4','chen_garcia34@example.test','chen_garcia34','Chen Garcia','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-09-04T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('c03b8bc2-c8c1-58d0-bee7-ec610e60f2d4','Master''s degree (in progress)','Community College','freelancer','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('9f3bc17f-5d75-53dc-b8f7-c31c7b045f3a','amina_patel35@example.test','amina_patel35','Amina Patel','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-09-05T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('9f3bc17f-5d75-53dc-b8f7-c31c7b045f3a','Self-taught','Self-study','career changer','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'beginner','I want to improve at work.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('764e32a2-164e-5a20-ae36-84d5dfe24016','ravi_kim36@example.test','ravi_kim36','Ravi Kim','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-09-06T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('764e32a2-164e-5a20-ae36-84d5dfe24016','High school','City University','student','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'beginner','I want to start freelancing.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f3afb1af-804c-591e-abd4-9293d825b709','elena_wei37@example.test','elena_wei37','Elena Wei','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-09-07T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f3afb1af-804c-591e-abd4-9293d825b709','Diploma','Tech Institute','employed full-time','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'intermediate','I want to prepare for interviews.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('5ad7c719-3277-5f80-9f99-fa7f33e15f81','mateo_tanaka38@example.test','mateo_tanaka38','Mateo Tanaka','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-09-08T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('5ad7c719-3277-5f80-9f99-fa7f33e15f81','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'intermediate','I want to learn at my own pace.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('c4cbc44b-3320-559c-9d8d-a87607f33b8d','zara_novak39@example.test','zara_novak39','Zara Novak','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-09-09T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('c4cbc44b-3320-559c-9d8d-a87607f33b8d','Bachelor''s degree','State College','job seeker','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'advanced','I want to build an app for my community.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('5230ba02-b896-59c0-9d24-b48f8a7e7ba2','aarav_khan40@example.test','aarav_khan40','Aarav Khan','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-01T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('5230ba02-b896-59c0-9d24-b48f8a7e7ba2','Master''s degree (in progress)','Community College','freelancer','["Machine Learning"]'::jsonb,'["Machine Learning", "ML"]'::jsonb,'beginner','I want to get my first job in tech.','["Machine Learning"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('7e973743-f09d-502e-a7b4-6b9b54170dcd','fatima_petrova41@example.test','fatima_petrova41','Fatima Petrova','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-02T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('7e973743-f09d-502e-a7b4-6b9b54170dcd','Self-taught','Self-study','career changer','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'beginner','I want to finish my university project.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('7b44676d-a131-5e94-ae12-7e5a5381ee80','noah_costa42@example.test','noah_costa42','Noah Costa','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-03T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('7b44676d-a131-5e94-ae12-7e5a5381ee80','High school','City University','student','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('02c1baf4-dad4-5879-8ffe-534437e005f0','yuki_okafor43@example.test','yuki_okafor43','Yuki Okafor','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-04T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('02c1baf4-dad4-5879-8ffe-534437e005f0','Diploma','Tech Institute','employed full-time','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'intermediate','I want to switch careers within a year.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('e6516e16-5b40-5431-afbe-05886bda3063','kofi_mensah44@example.test','kofi_mensah44','Kofi Mensah','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-05T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('e6516e16-5b40-5431-afbe-05886bda3063','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('13621ff6-f08e-52c8-b1a1-d845c96ea013','hana_ahmed45@example.test','hana_ahmed45','Hana Ahmed','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-06T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('13621ff6-f08e-52c8-b1a1-d845c96ea013','Bachelor''s degree','State College','job seeker','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'beginner','I want to improve at work.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('77f74082-0ebc-52a0-9ba2-1b98dc1a9b75','diego_nguyen46@example.test','diego_nguyen46','Diego Nguyen','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-07T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('77f74082-0ebc-52a0-9ba2-1b98dc1a9b75','Master''s degree (in progress)','Community College','freelancer','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'beginner','I want to start freelancing.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('37f7325e-e6bb-5072-80b6-9b906634a135','maria_reddy47@example.test','maria_reddy47','Maria Reddy','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-08T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('37f7325e-e6bb-5072-80b6-9b906634a135','Self-taught','Self-study','career changer','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'intermediate','I want to prepare for interviews.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('161a5569-2904-5a1e-a6ef-b80bea0d4a70','lucas_sharma48@example.test','lucas_sharma48','Lucas Sharma','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-09T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('161a5569-2904-5a1e-a6ef-b80bea0d4a70','High school','City University','student','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'intermediate','I want to learn at my own pace.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('27b3e956-a4fd-5795-bde5-187b7e798e25','sofia_rossi49@example.test','sofia_rossi49','Sofia Rossi','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-10T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('27b3e956-a4fd-5795-bde5-187b7e798e25','Diploma','Tech Institute','employed full-time','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'advanced','I want to build an app for my community.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('b8eb3606-5d0a-5d95-b959-d1a2496a8437','omar_lopez50@example.test','omar_lopez50','Omar Lopez','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-11T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('b8eb3606-5d0a-5d95-b959-d1a2496a8437','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Career"]'::jsonb,'["Career", "Jobs"]'::jsonb,'beginner','I want to get my first job in tech.','["Career"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('c64b5a70-0b3f-54b2-bde1-f91b3c11ff32','priya_wei51@example.test','priya_wei51','Priya Wei','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-12T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('c64b5a70-0b3f-54b2-bde1-f91b3c11ff32','Bachelor''s degree','State College','job seeker','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'beginner','I want to finish my university project.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('d08cc740-5676-5c51-9975-c41acb3a53ec','ivan_tanaka52@example.test','ivan_tanaka52','Ivan Tanaka','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-13T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('d08cc740-5676-5c51-9975-c41acb3a53ec','Master''s degree (in progress)','Community College','freelancer','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('cd321184-0b74-5dd9-b59c-5616b2692e51','leila_novak53@example.test','leila_novak53','Leila Novak','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-14T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('cd321184-0b74-5dd9-b59c-5616b2692e51','Self-taught','Self-study','career changer','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'intermediate','I want to switch careers within a year.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('03c3b6c3-0656-574f-a362-250bb13b0f9f','chen_khan54@example.test','chen_khan54','Chen Khan','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-15T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('03c3b6c3-0656-574f-a362-250bb13b0f9f','High school','City University','student','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('59c24879-c50b-5e92-aaa5-05f3892a29e9','amina_haddad55@example.test','amina_haddad55','Amina Haddad','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-16T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('59c24879-c50b-5e92-aaa5-05f3892a29e9','Diploma','Tech Institute','employed full-time','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'beginner','I want to improve at work.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('2b77b9e2-5c2f-513e-9c99-6781acae1033','ravi_ali56@example.test','ravi_ali56','Ravi Ali','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-17T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('2b77b9e2-5c2f-513e-9c99-6781acae1033','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'beginner','I want to start freelancing.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('5c7ef6ed-8296-515c-b9c8-65f1743972e0','elena_silva57@example.test','elena_silva57','Elena Silva','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-18T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('5c7ef6ed-8296-515c-b9c8-65f1743972e0','Bachelor''s degree','State College','job seeker','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'intermediate','I want to prepare for interviews.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('609d55d3-bcc7-5886-aaa4-a394b698feb9','mateo_petrova58@example.test','mateo_petrova58','Mateo Petrova','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-19T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('609d55d3-bcc7-5886-aaa4-a394b698feb9','Master''s degree (in progress)','Community College','freelancer','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'intermediate','I want to learn at my own pace.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('37e41219-93da-59af-843f-7795188eccb5','zara_costa59@example.test','zara_costa59','Zara Costa','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-20T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('37e41219-93da-59af-843f-7795188eccb5','Self-taught','Self-study','career changer','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'advanced','I want to build an app for my community.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('38e2832b-dbb7-5a7b-9fae-2e2d92ce6210','aarav_okafor60@example.test','aarav_okafor60','Aarav Okafor','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-21T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('38e2832b-dbb7-5a7b-9fae-2e2d92ce6210','High school','City University','student','["Design"]'::jsonb,'["Design", "User research"]'::jsonb,'beginner','I want to get my first job in tech.','["Design"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('11952dd0-1238-50fb-90e9-eca36076cc15','fatima_reddy61@example.test','fatima_reddy61','Fatima Reddy','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-22T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('11952dd0-1238-50fb-90e9-eca36076cc15','Diploma','Tech Institute','employed full-time','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'beginner','I want to finish my university project.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('8221855e-6ce5-59c5-ba97-8144d08e1587','noah_sharma62@example.test','noah_sharma62','Noah Sharma','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-23T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('8221855e-6ce5-59c5-ba97-8144d08e1587','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f8705d18-5b23-5f91-8ec6-60b32e09c392','yuki_rossi63@example.test','yuki_rossi63','Yuki Rossi','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-24T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f8705d18-5b23-5f91-8ec6-60b32e09c392','Bachelor''s degree','State College','job seeker','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'intermediate','I want to switch careers within a year.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('0c4bba64-f38d-559d-ba2f-40da5ab3f7b5','kofi_lopez64@example.test','kofi_lopez64','Kofi Lopez','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-25T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('0c4bba64-f38d-559d-ba2f-40da5ab3f7b5','Master''s degree (in progress)','Community College','freelancer','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'advanced','I want to pass my upcoming exam.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('8182334b-07fb-5e40-af0c-6b776089297f','hana_garcia65@example.test','hana_garcia65','Hana Garcia','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-26T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('8182334b-07fb-5e40-af0c-6b776089297f','Self-taught','Self-study','career changer','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'beginner','I want to improve at work.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('98fcba5d-5d23-5f57-98b2-94366e714066','diego_patel66@example.test','diego_patel66','Diego Patel','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-27T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('98fcba5d-5d23-5f57-98b2-94366e714066','High school','City University','student','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'beginner','I want to start freelancing.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('fa57a545-157e-5174-8579-95aacd4aca23','maria_kim67@example.test','maria_kim67','Maria Kim','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-28T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('fa57a545-157e-5174-8579-95aacd4aca23','Diploma','Tech Institute','employed full-time','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'intermediate','I want to prepare for interviews.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('6d255dc4-8aad-5880-bbeb-a3105845e550','lucas_wei68@example.test','lucas_wei68','Lucas Wei','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-29T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('6d255dc4-8aad-5880-bbeb-a3105845e550','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'intermediate','I want to learn at my own pace.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('678d379d-b73f-5a47-a71b-b301aaa58576','sofia_tanaka69@example.test','sofia_tanaka69','Sofia Tanaka','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-30T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('678d379d-b73f-5a47-a71b-b301aaa58576','Bachelor''s degree','State College','job seeker','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'advanced','I want to build an app for my community.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('0565b2f2-5f7b-5b35-a0f5-45d7d1a3d992','omar_novak70@example.test','omar_novak70','Omar Novak','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-31T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('0565b2f2-5f7b-5b35-a0f5-45d7d1a3d992','Master''s degree (in progress)','Community College','freelancer','["DevOps"]'::jsonb,'["DevOps", "Cloud platforms"]'::jsonb,'beginner','I want to get my first job in tech.','["DevOps"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('57a7a0d7-a53d-50d8-9253-5231c5cdb2ad','priya_silva71@example.test','priya_silva71','Priya Silva','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-09-01T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('57a7a0d7-a53d-50d8-9253-5231c5cdb2ad','Self-taught','Self-study','career changer','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'beginner','I want to finish my university project.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('d359ea92-bfbb-5c7d-ba1e-3bccf0853038','ivan_petrova72@example.test','ivan_petrova72','Ivan Petrova','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-09-02T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('d359ea92-bfbb-5c7d-ba1e-3bccf0853038','High school','City University','student','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('a6016879-9f93-5b2c-91b3-c5bae42411ca','leila_costa73@example.test','leila_costa73','Leila Costa','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-09-03T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('a6016879-9f93-5b2c-91b3-c5bae42411ca','Diploma','Tech Institute','employed full-time','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'intermediate','I want to switch careers within a year.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('759b59b5-7b23-519d-8b25-3b3e37cd4b4a','chen_okafor74@example.test','chen_okafor74','Chen Okafor','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-09-04T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('759b59b5-7b23-519d-8b25-3b3e37cd4b4a','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('47447569-57ec-59ee-b3f2-fd7b2adfcfb0','amina_mensah75@example.test','amina_mensah75','Amina Mensah','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-09-05T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('47447569-57ec-59ee-b3f2-fd7b2adfcfb0','Bachelor''s degree','State College','job seeker','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'beginner','I want to improve at work.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('ab462a13-b175-5495-acec-5a2351dcf7b3','ravi_ahmed76@example.test','ravi_ahmed76','Ravi Ahmed','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-09-06T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('ab462a13-b175-5495-acec-5a2351dcf7b3','Master''s degree (in progress)','Community College','freelancer','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'beginner','I want to start freelancing.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('8341076a-653a-58bc-a923-68e37fa66e66','elena_nguyen77@example.test','elena_nguyen77','Elena Nguyen','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-09-07T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('8341076a-653a-58bc-a923-68e37fa66e66','Self-taught','Self-study','career changer','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'intermediate','I want to prepare for interviews.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f0d8a665-ce45-5e39-8f0d-1c2dfd2ed0eb','mateo_reddy78@example.test','mateo_reddy78','Mateo Reddy','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-09-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f0d8a665-ce45-5e39-8f0d-1c2dfd2ed0eb','High school','City University','student','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'intermediate','I want to learn at my own pace.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('a059fbeb-94f0-51d1-addd-24ab03555e5d','zara_sharma79@example.test','zara_sharma79','Zara Sharma','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-09-09T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('a059fbeb-94f0-51d1-addd-24ab03555e5d','Diploma','Tech Institute','employed full-time','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'advanced','I want to build an app for my community.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('987b4986-5d85-516c-a6ce-2cc794c9e39e','aarav_rossi80@example.test','aarav_rossi80','Aarav Rossi','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-01T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('987b4986-5d85-516c-a6ce-2cc794c9e39e','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Mobile Development"]'::jsonb,'["Mobile Development", "Android"]'::jsonb,'beginner','I want to get my first job in tech.','["Mobile Development"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('8c246dd0-42f7-5105-bc88-edbbdaf4ec8b','fatima_kim81@example.test','fatima_kim81','Fatima Kim','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-02T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('8c246dd0-42f7-5105-bc88-edbbdaf4ec8b','Bachelor''s degree','State College','job seeker','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'beginner','I want to finish my university project.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('3bd18e77-d0e1-58b8-93cf-548b0ac863b4','noah_wei82@example.test','noah_wei82','Noah Wei','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-03T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('3bd18e77-d0e1-58b8-93cf-548b0ac863b4','Master''s degree (in progress)','Community College','freelancer','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('d19afcd7-f364-5482-88ee-eb361b360dea','yuki_tanaka83@example.test','yuki_tanaka83','Yuki Tanaka','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-04T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('d19afcd7-f364-5482-88ee-eb361b360dea','Self-taught','Self-study','career changer','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'intermediate','I want to switch careers within a year.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f66dbb4c-ab1c-5f9b-a283-5362949f8114','kofi_novak84@example.test','kofi_novak84','Kofi Novak','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-05T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f66dbb4c-ab1c-5f9b-a283-5362949f8114','High school','City University','student','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('c25d1d8c-b83c-5557-acfa-1ae39d269450','hana_khan85@example.test','hana_khan85','Hana Khan','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-06T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('c25d1d8c-b83c-5557-acfa-1ae39d269450','Diploma','Tech Institute','employed full-time','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'beginner','I want to improve at work.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f0a4d4ab-31f1-5ce7-ab2a-c97e156d07e8','diego_haddad86@example.test','diego_haddad86','Diego Haddad','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-07T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f0a4d4ab-31f1-5ce7-ab2a-c97e156d07e8','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'beginner','I want to start freelancing.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('1d62a907-e328-54fb-beaa-764042aa2bd7','maria_ali87@example.test','maria_ali87','Maria Ali','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-08T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('1d62a907-e328-54fb-beaa-764042aa2bd7','Bachelor''s degree','State College','job seeker','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'intermediate','I want to prepare for interviews.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('691496d8-7e16-584f-9fc1-747ef8de7eef','lucas_silva88@example.test','lucas_silva88','Lucas Silva','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-09T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('691496d8-7e16-584f-9fc1-747ef8de7eef','Master''s degree (in progress)','Community College','freelancer','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'intermediate','I want to learn at my own pace.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('f20bdf29-f95d-5c02-bb58-b9cb535f6dd9','sofia_petrova89@example.test','sofia_petrova89','Sofia Petrova','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-10T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('f20bdf29-f95d-5c02-bb58-b9cb535f6dd9','Self-taught','Self-study','career changer','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'advanced','I want to build an app for my community.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('c08379f0-3706-537f-8e98-b92f7c71c2e0','omar_costa90@example.test','omar_costa90','Omar Costa','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-11T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('c08379f0-3706-537f-8e98-b92f7c71c2e0','High school','City University','student','["Cybersecurity"]'::jsonb,'["Cybersecurity", "Security fundamentals"]'::jsonb,'beginner','I want to get my first job in tech.','["Cybersecurity"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('effec6e3-ccf2-52ee-8687-4e2c7bd71172','priya_nguyen91@example.test','priya_nguyen91','Priya Nguyen','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-12T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('effec6e3-ccf2-52ee-8687-4e2c7bd71172','Diploma','Tech Institute','employed full-time','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'beginner','I want to finish my university project.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('998d21ba-ffd4-56a0-ba7b-ec02fa3791d5','ivan_reddy92@example.test','ivan_reddy92','Ivan Reddy','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-13T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('998d21ba-ffd4-56a0-ba7b-ec02fa3791d5','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'intermediate','I want to build a side project for my portfolio.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('8cc03af2-868e-592f-9535-37f766cf3ac1','leila_sharma93@example.test','leila_sharma93','Leila Sharma','!seed-not-a-real-hash','learner','["en", "zh"]'::jsonb,0,true,'2026-08-14T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('8cc03af2-868e-592f-9535-37f766cf3ac1','Bachelor''s degree','State College','job seeker','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'intermediate','I want to switch careers within a year.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('38ec1ac1-d3d4-5576-931b-ff5fd3ab0560','chen_rossi94@example.test','chen_rossi94','Chen Rossi','!seed-not-a-real-hash','learner','["en", "pt"]'::jsonb,0,true,'2026-08-15T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('38ec1ac1-d3d4-5576-931b-ff5fd3ab0560','Master''s degree (in progress)','Community College','freelancer','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'advanced','I want to pass my upcoming exam.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('19955e83-5829-513e-9628-605205675091','amina_lopez95@example.test','amina_lopez95','Amina Lopez','!seed-not-a-real-hash','learner','["en", "sw"]'::jsonb,0,true,'2026-08-16T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('19955e83-5829-513e-9628-605205675091','Self-taught','Self-study','career changer','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'beginner','I want to improve at work.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('76dd97ea-767f-5a05-bd2d-b2422b784848','ravi_garcia96@example.test','ravi_garcia96','Ravi Garcia','!seed-not-a-real-hash','learner','["en"]'::jsonb,0,true,'2026-08-17T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('76dd97ea-767f-5a05-bd2d-b2422b784848','High school','City University','student','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'beginner','I want to start freelancing.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('b58c3b10-5483-573d-b40a-a7eabcc8e15e','elena_patel97@example.test','elena_patel97','Elena Patel','!seed-not-a-real-hash','learner','["en", "hi"]'::jsonb,0,true,'2026-08-18T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('b58c3b10-5483-573d-b40a-a7eabcc8e15e','Diploma','Tech Institute','employed full-time','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'intermediate','I want to prepare for interviews.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('6931fc06-f42d-527d-ac6a-0bd574aae0fb','mateo_kim98@example.test','mateo_kim98','Mateo Kim','!seed-not-a-real-hash','learner','["en", "es"]'::jsonb,0,true,'2026-08-19T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('6931fc06-f42d-527d-ac6a-0bd574aae0fb','Bachelor''s degree (in progress)','Open Online Academy','employed part-time','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'intermediate','I want to learn at my own pace.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('4cb75c36-bd1f-5a17-91e6-094db7c75431','zara_wei99@example.test','zara_wei99','Zara Wei','!seed-not-a-real-hash','learner','["en", "fr"]'::jsonb,0,true,'2026-08-20T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('4cb75c36-bd1f-5a17-91e6-094db7c75431','Bachelor''s degree','State College','job seeker','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'advanced','I want to build an app for my community.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;
INSERT INTO users (id,email,username,name,password_hash,user_type,languages,reputation,is_active,created_at) VALUES ('2bea71c5-13d1-5b35-8fdf-2c5b1277d7a5','aarav_tanaka100@example.test','aarav_tanaka100','Aarav Tanaka','!seed-not-a-real-hash','learner','["en", "ar"]'::jsonb,0,true,'2026-08-21T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO learner_profiles (user_id,education,institution,work_status,skills,interests,skill_level,learning_goals,help_topics) VALUES ('2bea71c5-13d1-5b35-8fdf-2c5b1277d7a5','Master''s degree (in progress)','Community College','freelancer','["Databases"]'::jsonb,'["Databases", "SQL"]'::jsonb,'beginner','I want to get my first job in tech.','["Databases"]'::jsonb) ON CONFLICT DO NOTHING;

-- Tags
INSERT INTO tags (id,name) VALUES ('a8dfc9fd-de82-50f2-be6f-9e4f8091c19b','advanced') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('5b541937-92f6-5f95-a182-e4ab51473fb1','beginner') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('23d10123-da7f-5ee0-8783-dfcb6e760d27','career') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('7a120d80-68e7-5b05-98f5-57d9cac99bb2','cybersecurity') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('89a06dc1-b2bc-56d0-9e47-6907b0e708eb','data-science') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('a906eb5e-9fb9-5845-9201-cb8b0e81497a','databases') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3','design') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('f4ae48ac-d250-5fe0-b1d8-79376c07316f','devops') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('53440e8a-433a-5fef-8e17-8ec1ce3fb98c','help') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('4a35f1d1-f913-5c5a-81d0-aff8251c97ef','intermediate') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('d0f32b88-d818-5fb1-b4db-83d457ed3e52','machine-learning') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('0d97f474-e584-5749-874d-8d7ba14cdb49','mobile-development') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('adb59eca-fbe8-5e75-8db0-65e582130718','python') ON CONFLICT DO NOTHING;
INSERT INTO tags (id,name) VALUES ('aa12d513-d662-5484-b302-c85651920ae0','web-development') ON CONFLICT DO NOTHING;

-- Community memberships
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','16f43cd6-8fad-5c6f-8f90-7f1666ff84ef','member','active','2026-08-02T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','a41c002b-cef3-5733-838e-aa14bcfbdc5e','member','active','2026-08-03T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','9b344911-eac1-5725-945a-ad0caaba86bb','member','active','2026-08-04T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','dd410663-011f-50aa-b62a-027e3f1aeb4b','member','active','2026-08-05T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','a2bb820c-0964-55d9-a42e-41b8e8b09c6f','member','active','2026-08-06T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','87a5814a-6977-584f-a088-4e7fa518a414','member','active','2026-08-07T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','ffb4bec8-a7ac-59f8-b5f3-bfe934f6b9b3','member','active','2026-08-08T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','699a00a8-07d6-5489-a536-cbe61d6b29a8','member','active','2026-08-09T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','089d806b-e6db-5891-b901-2e04c821d170','member','active','2026-08-10T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('c42c5029-52eb-5703-be19-d1309049b53b','d5f767f5-8721-5a25-b64c-8b1eca52851c','member','active','2026-08-11T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','f72c4762-41a6-567b-bbe0-4dbaa039ae3a','member','active','2026-08-12T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','bc054fce-bc5b-5e6c-aa98-186728bc6c62','member','active','2026-08-13T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','945e372b-a9d2-5bee-8b29-6a01af30c882','member','active','2026-08-14T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','c00d44ba-529c-585b-9354-e972dadac134','member','active','2026-08-15T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','b2bb0920-1c9e-58f3-a3df-25d34d1901c2','member','active','2026-08-16T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','dc486bca-e24d-5667-8e4c-0d615f02ac32','member','active','2026-08-17T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','bb5e0047-1354-523c-b218-9073cc978c8f','member','active','2026-08-18T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','1f293bb8-bafc-5eb5-a6cf-e50ef92d9d22','member','active','2026-08-19T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','0858866f-b75b-54a9-93e8-44615cae7d2b','member','active','2026-08-20T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('da7b287e-d95a-57f7-9122-6c1e99fe0a89','ff18aa6f-98a5-57fd-98cd-88a46d039bd2','member','active','2026-08-21T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','36327cfb-5c54-51f2-b0cd-54f60941464b','member','active','2026-08-22T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','b8acf4ee-7829-5d53-bba8-f8df4cfd5650','member','active','2026-08-23T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','04187e03-b9a9-570e-9f75-01205e2208e3','member','active','2026-08-24T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','ca3b963e-9c04-51f7-9391-0e3a4a1c67b9','member','active','2026-08-25T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','f1b1f5ae-de17-5f80-b777-5fc2490ffbc6','member','active','2026-08-26T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','aa79988e-6610-529c-a1bb-40702957681f','member','active','2026-08-27T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','f9c6adf7-68cd-58ac-a8cb-85d7b1936e28','member','active','2026-08-28T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','0cac0b2f-f7bf-50fb-ac01-2929ab0b648f','member','active','2026-08-29T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','a5275e62-20d3-5d0c-b617-3e230fbeb2a3','member','active','2026-08-30T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','6a5dad2c-253c-5229-81f2-e0f1897b5483','member','active','2026-08-31T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','9c267dc6-9078-5315-a815-02dc4d5f6ed4','member','active','2026-09-01T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','5c0bb011-3da7-5c53-b1ea-1e1eb288ca09','member','active','2026-09-02T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','267da74a-c78f-5fff-9bb7-f991ab0b8186','member','active','2026-09-03T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','c03b8bc2-c8c1-58d0-bee7-ec610e60f2d4','member','active','2026-09-04T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','9f3bc17f-5d75-53dc-b8f7-c31c7b045f3a','member','active','2026-09-05T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','764e32a2-164e-5a20-ae36-84d5dfe24016','member','active','2026-09-06T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','f3afb1af-804c-591e-abd4-9293d825b709','member','active','2026-09-07T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','5ad7c719-3277-5f80-9f99-fa7f33e15f81','member','active','2026-09-08T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','c4cbc44b-3320-559c-9d8d-a87607f33b8d','member','active','2026-09-09T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('9ff111fb-ca12-58f6-889b-6f1aa564012c','5230ba02-b896-59c0-9d24-b48f8a7e7ba2','member','active','2026-08-01T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','7e973743-f09d-502e-a7b4-6b9b54170dcd','member','active','2026-08-02T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','7b44676d-a131-5e94-ae12-7e5a5381ee80','member','active','2026-08-03T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','02c1baf4-dad4-5879-8ffe-534437e005f0','member','active','2026-08-04T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','e6516e16-5b40-5431-afbe-05886bda3063','member','active','2026-08-05T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','13621ff6-f08e-52c8-b1a1-d845c96ea013','member','active','2026-08-06T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','77f74082-0ebc-52a0-9ba2-1b98dc1a9b75','member','active','2026-08-07T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','37f7325e-e6bb-5072-80b6-9b906634a135','member','active','2026-08-08T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','161a5569-2904-5a1e-a6ef-b80bea0d4a70','member','active','2026-08-09T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','27b3e956-a4fd-5795-bde5-187b7e798e25','member','active','2026-08-10T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('06b066dc-e130-53e6-93f1-79f71c09b66a','b8eb3606-5d0a-5d95-b959-d1a2496a8437','member','active','2026-08-11T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','c64b5a70-0b3f-54b2-bde1-f91b3c11ff32','member','active','2026-08-12T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','d08cc740-5676-5c51-9975-c41acb3a53ec','member','active','2026-08-13T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','cd321184-0b74-5dd9-b59c-5616b2692e51','member','active','2026-08-14T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','03c3b6c3-0656-574f-a362-250bb13b0f9f','member','active','2026-08-15T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','59c24879-c50b-5e92-aaa5-05f3892a29e9','member','active','2026-08-16T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','2b77b9e2-5c2f-513e-9c99-6781acae1033','member','active','2026-08-17T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','5c7ef6ed-8296-515c-b9c8-65f1743972e0','member','active','2026-08-18T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','609d55d3-bcc7-5886-aaa4-a394b698feb9','member','active','2026-08-19T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','37e41219-93da-59af-843f-7795188eccb5','member','active','2026-08-20T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('24b094d6-207e-587f-83f2-5cd3db439fab','38e2832b-dbb7-5a7b-9fae-2e2d92ce6210','member','active','2026-08-21T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','11952dd0-1238-50fb-90e9-eca36076cc15','member','active','2026-08-22T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','8221855e-6ce5-59c5-ba97-8144d08e1587','member','active','2026-08-23T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','f8705d18-5b23-5f91-8ec6-60b32e09c392','member','active','2026-08-24T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','0c4bba64-f38d-559d-ba2f-40da5ab3f7b5','member','active','2026-08-25T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','8182334b-07fb-5e40-af0c-6b776089297f','member','active','2026-08-26T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','98fcba5d-5d23-5f57-98b2-94366e714066','member','active','2026-08-27T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','fa57a545-157e-5174-8579-95aacd4aca23','member','active','2026-08-28T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','6d255dc4-8aad-5880-bbeb-a3105845e550','member','active','2026-08-29T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','678d379d-b73f-5a47-a71b-b301aaa58576','member','active','2026-08-30T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('951fd294-ba58-5091-a9a4-39550137cdb2','0565b2f2-5f7b-5b35-a0f5-45d7d1a3d992','member','active','2026-08-31T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','57a7a0d7-a53d-50d8-9253-5231c5cdb2ad','member','active','2026-09-01T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','d359ea92-bfbb-5c7d-ba1e-3bccf0853038','member','active','2026-09-02T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','a6016879-9f93-5b2c-91b3-c5bae42411ca','member','active','2026-09-03T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','759b59b5-7b23-519d-8b25-3b3e37cd4b4a','member','active','2026-09-04T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','47447569-57ec-59ee-b3f2-fd7b2adfcfb0','member','active','2026-09-05T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','ab462a13-b175-5495-acec-5a2351dcf7b3','member','active','2026-09-06T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','8341076a-653a-58bc-a923-68e37fa66e66','member','active','2026-09-07T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','f0d8a665-ce45-5e39-8f0d-1c2dfd2ed0eb','member','active','2026-09-08T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','a059fbeb-94f0-51d1-addd-24ab03555e5d','member','active','2026-09-09T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('2d03821b-66f7-5a95-b8e3-a6ba5feba122','987b4986-5d85-516c-a6ce-2cc794c9e39e','member','active','2026-08-01T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','8c246dd0-42f7-5105-bc88-edbbdaf4ec8b','member','active','2026-08-02T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','3bd18e77-d0e1-58b8-93cf-548b0ac863b4','member','active','2026-08-03T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','d19afcd7-f364-5482-88ee-eb361b360dea','member','active','2026-08-04T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','f66dbb4c-ab1c-5f9b-a283-5362949f8114','member','active','2026-08-05T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','c25d1d8c-b83c-5557-acfa-1ae39d269450','member','active','2026-08-06T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','f0a4d4ab-31f1-5ce7-ab2a-c97e156d07e8','member','active','2026-08-07T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','1d62a907-e328-54fb-beaa-764042aa2bd7','member','active','2026-08-08T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','691496d8-7e16-584f-9fc1-747ef8de7eef','member','active','2026-08-09T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','f20bdf29-f95d-5c02-bb58-b9cb535f6dd9','member','active','2026-08-10T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','c08379f0-3706-537f-8e98-b92f7c71c2e0','member','active','2026-08-11T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','effec6e3-ccf2-52ee-8687-4e2c7bd71172','member','active','2026-08-12T09:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','998d21ba-ffd4-56a0-ba7b-ec02fa3791d5','member','active','2026-08-13T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','8cc03af2-868e-592f-9535-37f766cf3ac1','member','active','2026-08-14T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','38ec1ac1-d3d4-5576-931b-ff5fd3ab0560','member','active','2026-08-15T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','19955e83-5829-513e-9628-605205675091','member','active','2026-08-16T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','76dd97ea-767f-5a05-bd2d-b2422b784848','member','active','2026-08-17T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','b58c3b10-5483-573d-b40a-a7eabcc8e15e','member','active','2026-08-18T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','6931fc06-f42d-527d-ac6a-0bd574aae0fb','member','active','2026-08-19T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','4cb75c36-bd1f-5a17-91e6-094db7c75431','member','active','2026-08-20T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO community_members (community_id,user_id,role,status,joined_at) VALUES ('e9bdfb81-38cb-5015-8224-23e22ee9fbad','2bea71c5-13d1-5b35-8fdf-2c5b1277d7a5','member','active','2026-08-21T18:00:00+00:00') ON CONFLICT DO NOTHING;

-- Questions (posts)
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('921e4043-7ae5-5b87-b9f9-64e7c5af3c26','16f43cd6-8fad-5c6f-8f90-7f1666ff84ef','c42c5029-52eb-5703-be19-d1309049b53b','question','Why does my list change after I pass it to a function?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to finish my university project.

My question: Why does my list change after I pass it to a function?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','beginner','open',false,false,'2026-08-03T11:00:00+00:00','2026-08-03T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('921e4043-7ae5-5b87-b9f9-64e7c5af3c26','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('921e4043-7ae5-5b87-b9f9-64e7c5af3c26','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f35e7155-ef9a-597f-a435-fcd7d22bc4e6','a41c002b-cef3-5733-838e-aa14bcfbdc5e','c42c5029-52eb-5703-be19-d1309049b53b','question','How do I read a large CSV without running out of memory?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to build a side project for my portfolio.

My question: How do I read a large CSV without running out of memory?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','intermediate','open',false,false,'2026-08-04T13:00:00+00:00','2026-08-04T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f35e7155-ef9a-597f-a435-fcd7d22bc4e6','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f35e7155-ef9a-597f-a435-fcd7d22bc4e6','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('608a6a5f-91e2-5c39-b0c1-c762397e6029','9b344911-eac1-5725-945a-ad0caaba86bb','c42c5029-52eb-5703-be19-d1309049b53b','question','What is the difference between a list and a tuple in practice?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to switch careers within a year.

My question: What is the difference between a list and a tuple in practice?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','intermediate','open',false,false,'2026-08-05T15:00:00+00:00','2026-08-05T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('608a6a5f-91e2-5c39-b0c1-c762397e6029','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('608a6a5f-91e2-5c39-b0c1-c762397e6029','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('c7244109-c5ba-535a-aa26-792368d1bff5','dd410663-011f-50aa-b62a-027e3f1aeb4b','c42c5029-52eb-5703-be19-d1309049b53b','question','How can I fix ''ModuleNotFoundError'' after pip install?','Hi everyone, I am a advanced learner (freelancer) and my goal is to pass my upcoming exam.

My question: How can I fix ''ModuleNotFoundError'' after pip install?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','advanced','answered',false,false,'2026-08-06T17:00:00+00:00','2026-08-06T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c7244109-c5ba-535a-aa26-792368d1bff5','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c7244109-c5ba-535a-aa26-792368d1bff5','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('ada344b4-00dc-58fb-be96-004d47edd211','a2bb820c-0964-55d9-a42e-41b8e8b09c6f','c42c5029-52eb-5703-be19-d1309049b53b','question','How do I handle exceptions without hiding real bugs?','Hi everyone, I am a beginner learner (career changer) and my goal is to improve at work.

My question: How do I handle exceptions without hiding real bugs?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','beginner','open',false,false,'2026-08-07T19:00:00+00:00','2026-08-07T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('ada344b4-00dc-58fb-be96-004d47edd211','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('ada344b4-00dc-58fb-be96-004d47edd211','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('689b72cf-51dc-5071-8398-7edcd1beb291','87a5814a-6977-584f-a088-4e7fa518a414','c42c5029-52eb-5703-be19-d1309049b53b','question','When should I use a generator instead of a list?','Hi everyone, I am a beginner learner (student) and my goal is to start freelancing.

My question: When should I use a generator instead of a list?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','beginner','open',false,false,'2026-08-08T21:00:00+00:00','2026-08-08T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('689b72cf-51dc-5071-8398-7edcd1beb291','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('689b72cf-51dc-5071-8398-7edcd1beb291','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('0a684b02-4e2d-5808-97e9-56bef9f37a92','ffb4bec8-a7ac-59f8-b5f3-bfe934f6b9b3','c42c5029-52eb-5703-be19-d1309049b53b','question','How do I structure a Python project with multiple files?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to prepare for interviews.

My question: How do I structure a Python project with multiple files?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','intermediate','open',false,false,'2026-08-09T23:00:00+00:00','2026-08-09T23:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('0a684b02-4e2d-5808-97e9-56bef9f37a92','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('0a684b02-4e2d-5808-97e9-56bef9f37a92','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('5d90a10d-b739-56e7-8416-d56820a6d39d','699a00a8-07d6-5489-a536-cbe61d6b29a8','c42c5029-52eb-5703-be19-d1309049b53b','question','What is the best way to learn decorators?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to learn at my own pace.

My question: What is the best way to learn decorators?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','intermediate','answered',false,false,'2026-08-11T01:00:00+00:00','2026-08-11T01:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5d90a10d-b739-56e7-8416-d56820a6d39d','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5d90a10d-b739-56e7-8416-d56820a6d39d','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('9ea25905-32a4-586f-8ed9-b7b7157a9043','089d806b-e6db-5891-b901-2e04c821d170','c42c5029-52eb-5703-be19-d1309049b53b','question','How do I schedule a script to run every morning?','Hi everyone, I am a advanced learner (job seeker) and my goal is to build an app for my community.

My question: How do I schedule a script to run every morning?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','advanced','open',false,false,'2026-08-11T18:00:00+00:00','2026-08-11T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9ea25905-32a4-586f-8ed9-b7b7157a9043','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9ea25905-32a4-586f-8ed9-b7b7157a9043','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('eaa73206-23fe-5c3b-bd49-d6512f81081e','d5f767f5-8721-5a25-b64c-8b1eca52851c','c42c5029-52eb-5703-be19-d1309049b53b','question','Why is my loop so slow with 1 million rows?','Hi everyone, I am a beginner learner (freelancer) and my goal is to get my first job in tech.

My question: Why is my loop so slow with 1 million rows?

What I tried: I read the official docs and a few tutorials and tried changing the code, but I still get the same result.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Python','beginner','open',false,false,'2026-08-12T20:00:00+00:00','2026-08-12T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('eaa73206-23fe-5c3b-bd49-d6512f81081e','adb59eca-fbe8-5e75-8db0-65e582130718') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('eaa73206-23fe-5c3b-bd49-d6512f81081e','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('756bde46-29d3-5ec8-8ce1-d9c9324d237a','f72c4762-41a6-567b-bbe0-4dbaa039ae3a','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','How do I center a div both vertically and horizontally?','Hi everyone, I am a beginner learner (career changer) and my goal is to finish my university project.

My question: How do I center a div both vertically and horizontally?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','beginner','open',false,false,'2026-08-13T22:00:00+00:00','2026-08-13T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('756bde46-29d3-5ec8-8ce1-d9c9324d237a','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('756bde46-29d3-5ec8-8ce1-d9c9324d237a','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('3c96e8cb-cd26-59df-863a-ce94d255f497','bc054fce-bc5b-5e6c-aa98-186728bc6c62','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','Why does my React component re-render on every keystroke?','Hi everyone, I am a intermediate learner (student) and my goal is to build a side project for my portfolio.

My question: Why does my React component re-render on every keystroke?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','intermediate','answered',false,false,'2026-08-15T00:00:00+00:00','2026-08-15T00:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('3c96e8cb-cd26-59df-863a-ce94d255f497','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('3c96e8cb-cd26-59df-863a-ce94d255f497','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('9cecf1bb-29a3-5606-b5b3-e3da0ddc5344','945e372b-a9d2-5bee-8b29-6a01af30c882','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','What is the difference between localStorage and cookies?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to switch careers within a year.

My question: What is the difference between localStorage and cookies?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','intermediate','open',false,false,'2026-08-15T13:00:00+00:00','2026-08-15T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9cecf1bb-29a3-5606-b5b3-e3da0ddc5344','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9cecf1bb-29a3-5606-b5b3-e3da0ddc5344','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('e204541a-b032-5333-ba12-3ff5366e0787','c00d44ba-529c-585b-9354-e972dadac134','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','How do I connect a React frontend to a REST API?','Hi everyone, I am a advanced learner (employed part-time) and my goal is to pass my upcoming exam.

My question: How do I connect a React frontend to a REST API?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','advanced','open',false,false,'2026-08-16T15:00:00+00:00','2026-08-16T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e204541a-b032-5333-ba12-3ff5366e0787','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e204541a-b032-5333-ba12-3ff5366e0787','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('b6f51ef6-9563-557d-81c8-73f8346391a8','b2bb0920-1c9e-58f3-a3df-25d34d1901c2','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','Why do I get a CORS error when calling my API?','Hi everyone, I am a beginner learner (job seeker) and my goal is to improve at work.

My question: Why do I get a CORS error when calling my API?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','beginner','open',false,false,'2026-08-17T17:00:00+00:00','2026-08-17T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b6f51ef6-9563-557d-81c8-73f8346391a8','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b6f51ef6-9563-557d-81c8-73f8346391a8','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('5c80a3a5-9e16-5e76-ba4f-28475ae37594','dc486bca-e24d-5667-8e4c-0d615f02ac32','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','How can I make my site load faster on mobile?','Hi everyone, I am a beginner learner (freelancer) and my goal is to start freelancing.

My question: How can I make my site load faster on mobile?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','beginner','answered',false,false,'2026-08-18T19:00:00+00:00','2026-08-18T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5c80a3a5-9e16-5e76-ba4f-28475ae37594','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5c80a3a5-9e16-5e76-ba4f-28475ae37594','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('b35fb485-81c3-5db5-afd2-de9a03f1dae2','bb5e0047-1354-523c-b218-9073cc978c8f','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','Should I learn Next.js before plain React?','Hi everyone, I am a intermediate learner (career changer) and my goal is to prepare for interviews.

My question: Should I learn Next.js before plain React?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','intermediate','open',false,false,'2026-08-19T21:00:00+00:00','2026-08-19T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b35fb485-81c3-5db5-afd2-de9a03f1dae2','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b35fb485-81c3-5db5-afd2-de9a03f1dae2','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('07918e27-a7a2-507a-b209-6f7ec3048606','1f293bb8-bafc-5eb5-a6cf-e50ef92d9d22','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','How do I deploy a Node.js app for free?','Hi everyone, I am a intermediate learner (student) and my goal is to learn at my own pace.

My question: How do I deploy a Node.js app for free?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','intermediate','open',false,false,'2026-08-20T14:00:00+00:00','2026-08-20T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('07918e27-a7a2-507a-b209-6f7ec3048606','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('07918e27-a7a2-507a-b209-6f7ec3048606','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('1f5df3e6-1380-5fd4-a4d4-37043cfbc3fe','0858866f-b75b-54a9-93e8-44615cae7d2b','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','What is the best way to validate a signup form?','Hi everyone, I am a advanced learner (employed full-time) and my goal is to build an app for my community.

My question: What is the best way to validate a signup form?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','advanced','open',false,false,'2026-08-21T16:00:00+00:00','2026-08-21T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1f5df3e6-1380-5fd4-a4d4-37043cfbc3fe','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1f5df3e6-1380-5fd4-a4d4-37043cfbc3fe','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('ddce5cee-9371-5cd1-9973-f594c663dc15','ff18aa6f-98a5-57fd-98cd-88a46d039bd2','da7b287e-d95a-57f7-9122-6c1e99fe0a89','question','How do I protect routes so only logged-in users can open them?','Hi everyone, I am a beginner learner (employed part-time) and my goal is to get my first job in tech.

My question: How do I protect routes so only logged-in users can open them?

What I tried: I searched Stack Overflow and tested in Chrome and Firefox, and the behaviour is the same in both.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Web Development','beginner','answered',false,false,'2026-08-22T18:00:00+00:00','2026-08-22T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('ddce5cee-9371-5cd1-9973-f594c663dc15','aa12d513-d662-5484-b302-c85651920ae0') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('ddce5cee-9371-5cd1-9973-f594c663dc15','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('4b0d3993-a993-5cff-8e3f-70a51d279634','36327cfb-5c54-51f2-b0cd-54f60941464b','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','How do I deal with missing values in a survey dataset?','Hi everyone, I am a beginner learner (job seeker) and my goal is to finish my university project.

My question: How do I deal with missing values in a survey dataset?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','beginner','open',false,false,'2026-08-23T20:00:00+00:00','2026-08-23T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4b0d3993-a993-5cff-8e3f-70a51d279634','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4b0d3993-a993-5cff-8e3f-70a51d279634','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('0f07550d-b220-5947-a550-a67ed74fcb05','b8acf4ee-7829-5d53-bba8-f8df4cfd5650','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','When should I use median instead of mean?','Hi everyone, I am a intermediate learner (freelancer) and my goal is to build a side project for my portfolio.

My question: When should I use median instead of mean?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','intermediate','open',false,false,'2026-08-24T22:00:00+00:00','2026-08-24T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('0f07550d-b220-5947-a550-a67ed74fcb05','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('0f07550d-b220-5947-a550-a67ed74fcb05','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('488bd368-ed2b-5054-9e01-74ff5ad8fb83','04187e03-b9a9-570e-9f75-01205e2208e3','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','How can I merge two tables with different key names in pandas?','Hi everyone, I am a intermediate learner (career changer) and my goal is to switch careers within a year.

My question: How can I merge two tables with different key names in pandas?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','intermediate','open',false,false,'2026-08-26T00:00:00+00:00','2026-08-26T00:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('488bd368-ed2b-5054-9e01-74ff5ad8fb83','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('488bd368-ed2b-5054-9e01-74ff5ad8fb83','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('4e6d4160-3660-586a-999a-ea8e0e67946a','ca3b963e-9c04-51f7-9391-0e3a4a1c67b9','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','What chart is best for comparing 5 categories over time?','Hi everyone, I am a advanced learner (student) and my goal is to pass my upcoming exam.

My question: What chart is best for comparing 5 categories over time?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','advanced','answered',false,false,'2026-08-27T02:00:00+00:00','2026-08-27T02:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4e6d4160-3660-586a-999a-ea8e0e67946a','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4e6d4160-3660-586a-999a-ea8e0e67946a','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('604a5850-828f-50e9-85a5-9a17fcc1f865','f1b1f5ae-de17-5f80-b777-5fc2490ffbc6','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','How do I know if my sample size is big enough?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to improve at work.

My question: How do I know if my sample size is big enough?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','beginner','open',false,false,'2026-08-28T04:00:00+00:00','2026-08-28T04:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('604a5850-828f-50e9-85a5-9a17fcc1f865','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('604a5850-828f-50e9-85a5-9a17fcc1f865','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('797b8176-785e-5fc6-a53a-78aa8d4014ab','aa79988e-6610-529c-a1bb-40702957681f','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','What is the difference between correlation and causation in a report?','Hi everyone, I am a beginner learner (employed part-time) and my goal is to start freelancing.

My question: What is the difference between correlation and causation in a report?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','beginner','open',false,false,'2026-08-28T17:00:00+00:00','2026-08-28T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('797b8176-785e-5fc6-a53a-78aa8d4014ab','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('797b8176-785e-5fc6-a53a-78aa8d4014ab','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('703892a6-63a9-59f3-98a6-9efd9cfaa7d4','f9c6adf7-68cd-58ac-a8cb-85d7b1936e28','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','How do I clean messy text columns with inconsistent spelling?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to prepare for interviews.

My question: How do I clean messy text columns with inconsistent spelling?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','intermediate','open',false,false,'2026-08-29T10:00:00+00:00','2026-08-29T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('703892a6-63a9-59f3-98a6-9efd9cfaa7d4','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('703892a6-63a9-59f3-98a6-9efd9cfaa7d4','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('28a70811-04df-5b83-81ff-cc78a74abef9','0cac0b2f-f7bf-50fb-ac01-2929ab0b648f','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','Which SQL skills do I need for a data analyst job?','Hi everyone, I am a intermediate learner (freelancer) and my goal is to learn at my own pace.

My question: Which SQL skills do I need for a data analyst job?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','intermediate','answered',false,false,'2026-08-30T12:00:00+00:00','2026-08-30T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('28a70811-04df-5b83-81ff-cc78a74abef9','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('28a70811-04df-5b83-81ff-cc78a74abef9','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f86efdf2-9c9d-5377-9b91-3a90544ea55e','a5275e62-20d3-5d0c-b617-3e230fbeb2a3','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','How do I explain p-values to a non-technical manager?','Hi everyone, I am a advanced learner (career changer) and my goal is to build an app for my community.

My question: How do I explain p-values to a non-technical manager?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','advanced','open',false,false,'2026-08-31T14:00:00+00:00','2026-08-31T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f86efdf2-9c9d-5377-9b91-3a90544ea55e','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f86efdf2-9c9d-5377-9b91-3a90544ea55e','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('908a357a-2e79-5f69-99ec-6adbf74bfd3d','6a5dad2c-253c-5229-81f2-e0f1897b5483','acdddb3c-7584-5fd4-8f0b-bd07ecd10e4f','question','How do I build a simple dashboard without paid tools?','Hi everyone, I am a beginner learner (student) and my goal is to get my first job in tech.

My question: How do I build a simple dashboard without paid tools?

What I tried: I tried a few pandas and matplotlib examples from tutorials, but my numbers do not match what I expected.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Data Science','beginner','open',false,false,'2026-09-01T16:00:00+00:00','2026-09-01T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('908a357a-2e79-5f69-99ec-6adbf74bfd3d','89a06dc1-b2bc-56d0-9e47-6907b0e708eb') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('908a357a-2e79-5f69-99ec-6adbf74bfd3d','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('5037e731-5ae4-5664-b955-a5eed2d7fbcb','9c267dc6-9078-5315-a815-02dc4d5f6ed4','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','Why is my model 99% accurate on training but poor on test data?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to finish my university project.

My question: Why is my model 99% accurate on training but poor on test data?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','beginner','open',false,false,'2026-09-02T18:00:00+00:00','2026-09-02T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5037e731-5ae4-5664-b955-a5eed2d7fbcb','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5037e731-5ae4-5664-b955-a5eed2d7fbcb','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('2f4b63a8-e1bc-5c1e-b423-1557596d1cb6','5c0bb011-3da7-5c53-b1ea-1e1eb288ca09','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','How do I choose between a random forest and a neural network?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to build a side project for my portfolio.

My question: How do I choose between a random forest and a neural network?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','intermediate','answered',false,false,'2026-09-03T20:00:00+00:00','2026-09-03T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2f4b63a8-e1bc-5c1e-b423-1557596d1cb6','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2f4b63a8-e1bc-5c1e-b423-1557596d1cb6','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('e031ccc6-f0bb-59fa-bee4-2a4d40ae8964','267da74a-c78f-5fff-9bb7-f991ab0b8186','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','What is the best way to handle an imbalanced dataset?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to switch careers within a year.

My question: What is the best way to handle an imbalanced dataset?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','intermediate','open',false,false,'2026-09-04T22:00:00+00:00','2026-09-04T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e031ccc6-f0bb-59fa-bee4-2a4d40ae8964','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e031ccc6-f0bb-59fa-bee4-2a4d40ae8964','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('8334e554-c061-5006-b5ea-eb294f9f5111','c03b8bc2-c8c1-58d0-bee7-ec610e60f2d4','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','How many examples do I need to fine-tune a language model?','Hi everyone, I am a advanced learner (freelancer) and my goal is to pass my upcoming exam.

My question: How many examples do I need to fine-tune a language model?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','advanced','open',false,false,'2026-09-06T00:00:00+00:00','2026-09-06T00:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('8334e554-c061-5006-b5ea-eb294f9f5111','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('8334e554-c061-5006-b5ea-eb294f9f5111','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('5cab695c-095d-533e-9c1a-48b40bf5ee86','9f3bc17f-5d75-53dc-b8f7-c31c7b045f3a','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','How do I explain a model''s predictions to non-experts?','Hi everyone, I am a beginner learner (career changer) and my goal is to improve at work.

My question: How do I explain a model''s predictions to non-experts?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','beginner','open',false,false,'2026-09-07T02:00:00+00:00','2026-09-07T02:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5cab695c-095d-533e-9c1a-48b40bf5ee86','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5cab695c-095d-533e-9c1a-48b40bf5ee86','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('62eac41e-88dd-5c7a-b935-dc8f99e1049e','764e32a2-164e-5a20-ae36-84d5dfe24016','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','What does learning rate really do during training?','Hi everyone, I am a beginner learner (student) and my goal is to start freelancing.

My question: What does learning rate really do during training?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','beginner','answered',false,false,'2026-09-07T19:00:00+00:00','2026-09-07T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('62eac41e-88dd-5c7a-b935-dc8f99e1049e','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('62eac41e-88dd-5c7a-b935-dc8f99e1049e','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('1a84c385-bc23-53eb-b8b4-32eaee1ee2dd','f3afb1af-804c-591e-abd4-9293d825b709','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','How do I deploy a trained model as an API?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to prepare for interviews.

My question: How do I deploy a trained model as an API?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','intermediate','open',false,false,'2026-09-08T21:00:00+00:00','2026-09-08T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1a84c385-bc23-53eb-b8b4-32eaee1ee2dd','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1a84c385-bc23-53eb-b8b4-32eaee1ee2dd','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('056ac8af-706f-531e-92ac-c3091b63d65b','5ad7c719-3277-5f80-9f99-fa7f33e15f81','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','Which maths topics should I learn first for ML?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to learn at my own pace.

My question: Which maths topics should I learn first for ML?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','intermediate','open',false,false,'2026-09-09T23:00:00+00:00','2026-09-09T23:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('056ac8af-706f-531e-92ac-c3091b63d65b','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('056ac8af-706f-531e-92ac-c3091b63d65b','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f29888ae-7d64-5e04-b9ed-186df4513a81','c4cbc44b-3320-559c-9d8d-a87607f33b8d','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','How do I avoid data leakage in feature engineering?','Hi everyone, I am a advanced learner (job seeker) and my goal is to build an app for my community.

My question: How do I avoid data leakage in feature engineering?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','advanced','open',false,false,'2026-09-10T12:00:00+00:00','2026-09-10T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f29888ae-7d64-5e04-b9ed-186df4513a81','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f29888ae-7d64-5e04-b9ed-186df4513a81','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('a278d9ca-d77c-53e2-acd9-05ddaca7e477','5230ba02-b896-59c0-9d24-b48f8a7e7ba2','9ff111fb-ca12-58f6-889b-6f1aa564012c','question','What is the difference between precision and recall?','Hi everyone, I am a beginner learner (freelancer) and my goal is to get my first job in tech.

My question: What is the difference between precision and recall?

What I tried: I trained a baseline model following a tutorial and checked my data split, but the results are not improving.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Machine Learning','beginner','answered',false,false,'2026-08-02T14:00:00+00:00','2026-08-02T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('a278d9ca-d77c-53e2-acd9-05ddaca7e477','d0f32b88-d818-5fb1-b4db-83d457ed3e52') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('a278d9ca-d77c-53e2-acd9-05ddaca7e477','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('2f01b0cb-d17a-5ea8-be48-3135969f69e3','7e973743-f09d-502e-a7b4-6b9b54170dcd','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How do I write a CV with no work experience?','Hi everyone, I am a beginner learner (career changer) and my goal is to finish my university project.

My question: How do I write a CV with no work experience?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','beginner','open',false,false,'2026-08-03T16:00:00+00:00','2026-08-03T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2f01b0cb-d17a-5ea8-be48-3135969f69e3','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2f01b0cb-d17a-5ea8-be48-3135969f69e3','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('5388acd2-eeb3-5c89-839f-23c7418d82f6','7b44676d-a131-5e94-ae12-7e5a5381ee80','06b066dc-e130-53e6-93f1-79f71c09b66a','question','What should I include in a portfolio for an entry-level job?','Hi everyone, I am a intermediate learner (student) and my goal is to build a side project for my portfolio.

My question: What should I include in a portfolio for an entry-level job?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','intermediate','open',false,false,'2026-08-04T18:00:00+00:00','2026-08-04T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5388acd2-eeb3-5c89-839f-23c7418d82f6','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('5388acd2-eeb3-5c89-839f-23c7418d82f6','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('9a33d035-5a14-5219-925a-9d0d0bca590a','02c1baf4-dad4-5879-8ffe-534437e005f0','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How do I answer ''tell me about yourself'' in interviews?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to switch careers within a year.

My question: How do I answer ''tell me about yourself'' in interviews?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','intermediate','open',false,false,'2026-08-05T20:00:00+00:00','2026-08-05T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9a33d035-5a14-5219-925a-9d0d0bca590a','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9a33d035-5a14-5219-925a-9d0d0bca590a','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f988810a-e635-5f8e-8da6-bf5062d9d108','e6516e16-5b40-5431-afbe-05886bda3063','06b066dc-e130-53e6-93f1-79f71c09b66a','question','Is a certificate worth it, or should I build projects?','Hi everyone, I am a advanced learner (employed part-time) and my goal is to pass my upcoming exam.

My question: Is a certificate worth it, or should I build projects?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','advanced','answered',false,false,'2026-08-06T22:00:00+00:00','2026-08-06T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f988810a-e635-5f8e-8da6-bf5062d9d108','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f988810a-e635-5f8e-8da6-bf5062d9d108','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('df06ca41-84ce-5d68-a292-e8bcd9191ec7','13621ff6-f08e-52c8-b1a1-d845c96ea013','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How do I switch careers into tech after age 30?','Hi everyone, I am a beginner learner (job seeker) and my goal is to improve at work.

My question: How do I switch careers into tech after age 30?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','beginner','open',false,false,'2026-08-07T15:00:00+00:00','2026-08-07T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('df06ca41-84ce-5d68-a292-e8bcd9191ec7','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('df06ca41-84ce-5d68-a292-e8bcd9191ec7','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('2d079d05-c86c-5d37-8e89-44ef5a6d6ae1','77f74082-0ebc-52a0-9ba2-1b98dc1a9b75','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How should I negotiate my first salary offer?','Hi everyone, I am a beginner learner (freelancer) and my goal is to start freelancing.

My question: How should I negotiate my first salary offer?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','beginner','open',false,false,'2026-08-08T17:00:00+00:00','2026-08-08T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2d079d05-c86c-5d37-8e89-44ef5a6d6ae1','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2d079d05-c86c-5d37-8e89-44ef5a6d6ae1','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('bae5e917-b0ec-5193-97c2-195d6c43530a','37f7325e-e6bb-5072-80b6-9b906634a135','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How do I find a mentor in my industry?','Hi everyone, I am a intermediate learner (career changer) and my goal is to prepare for interviews.

My question: How do I find a mentor in my industry?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','intermediate','open',false,false,'2026-08-09T19:00:00+00:00','2026-08-09T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('bae5e917-b0ec-5193-97c2-195d6c43530a','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('bae5e917-b0ec-5193-97c2-195d6c43530a','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('01125284-6a7f-5a52-90d5-4c6e8c95c96c','161a5569-2904-5a1e-a6ef-b80bea0d4a70','06b066dc-e130-53e6-93f1-79f71c09b66a','question','What should I do if I fail a technical interview?','Hi everyone, I am a intermediate learner (student) and my goal is to learn at my own pace.

My question: What should I do if I fail a technical interview?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','intermediate','answered',false,false,'2026-08-10T21:00:00+00:00','2026-08-10T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('01125284-6a7f-5a52-90d5-4c6e8c95c96c','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('01125284-6a7f-5a52-90d5-4c6e8c95c96c','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f75fc160-683a-5021-a8bd-1973109572c7','27b3e956-a4fd-5795-bde5-187b7e798e25','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How do I get remote work as a beginner?','Hi everyone, I am a advanced learner (employed full-time) and my goal is to build an app for my community.

My question: How do I get remote work as a beginner?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','advanced','open',false,false,'2026-08-11T23:00:00+00:00','2026-08-11T23:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f75fc160-683a-5021-a8bd-1973109572c7','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f75fc160-683a-5021-a8bd-1973109572c7','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('1bcaddf7-b4ab-52e2-99a4-abece4838e40','b8eb3606-5d0a-5d95-b959-d1a2496a8437','06b066dc-e130-53e6-93f1-79f71c09b66a','question','How do I balance a full-time job with studying?','Hi everyone, I am a beginner learner (employed part-time) and my goal is to get my first job in tech.

My question: How do I balance a full-time job with studying?

What I tried: I asked friends and read a few blog posts, but I would like advice from someone working in the field.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Career','beginner','open',false,false,'2026-08-13T01:00:00+00:00','2026-08-13T01:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1bcaddf7-b4ab-52e2-99a4-abece4838e40','23d10123-da7f-5ee0-8783-dfcb6e760d27') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1bcaddf7-b4ab-52e2-99a4-abece4838e40','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('02f9682a-57eb-5ecc-a8c9-6b68bf72f164','c64b5a70-0b3f-54b2-bde1-f91b3c11ff32','24b094d6-207e-587f-83f2-5cd3db439fab','question','How do I choose a colour palette that is accessible?','Hi everyone, I am a beginner learner (job seeker) and my goal is to finish my university project.

My question: How do I choose a colour palette that is accessible?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','beginner','open',false,false,'2026-08-14T03:00:00+00:00','2026-08-14T03:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('02f9682a-57eb-5ecc-a8c9-6b68bf72f164','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('02f9682a-57eb-5ecc-a8c9-6b68bf72f164','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('838bb2eb-0bb1-5f43-b717-e0ec47f6e324','d08cc740-5676-5c51-9975-c41acb3a53ec','24b094d6-207e-587f-83f2-5cd3db439fab','question','What is the difference between UX and UI in a real team?','Hi everyone, I am a intermediate learner (freelancer) and my goal is to build a side project for my portfolio.

My question: What is the difference between UX and UI in a real team?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','intermediate','answered',false,false,'2026-08-14T16:00:00+00:00','2026-08-14T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('838bb2eb-0bb1-5f43-b717-e0ec47f6e324','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('838bb2eb-0bb1-5f43-b717-e0ec47f6e324','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('01dbdf56-605e-5f03-82b7-93625c874cb1','cd321184-0b74-5dd9-b59c-5616b2692e51','24b094d6-207e-587f-83f2-5cd3db439fab','question','How do I run a usability test with only 5 people?','Hi everyone, I am a intermediate learner (career changer) and my goal is to switch careers within a year.

My question: How do I run a usability test with only 5 people?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','intermediate','open',false,false,'2026-08-15T18:00:00+00:00','2026-08-15T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('01dbdf56-605e-5f03-82b7-93625c874cb1','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('01dbdf56-605e-5f03-82b7-93625c874cb1','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('c4fee0be-c849-508e-a3b1-c78a16b0f516','03c3b6c3-0656-574f-a362-250bb13b0f9f','24b094d6-207e-587f-83f2-5cd3db439fab','question','Which fonts work well for mobile apps?','Hi everyone, I am a advanced learner (student) and my goal is to pass my upcoming exam.

My question: Which fonts work well for mobile apps?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','advanced','open',false,false,'2026-08-16T11:00:00+00:00','2026-08-16T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c4fee0be-c849-508e-a3b1-c78a16b0f516','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c4fee0be-c849-508e-a3b1-c78a16b0f516','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('53defef3-a13a-5fd0-87ab-d67b292e5ab5','59c24879-c50b-5e92-aaa5-05f3892a29e9','24b094d6-207e-587f-83f2-5cd3db439fab','question','How do I present my design decisions in a portfolio?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to improve at work.

My question: How do I present my design decisions in a portfolio?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','beginner','open',false,false,'2026-08-17T13:00:00+00:00','2026-08-17T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('53defef3-a13a-5fd0-87ab-d67b292e5ab5','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('53defef3-a13a-5fd0-87ab-d67b292e5ab5','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('311048e8-aeed-5c66-a780-e54861dd8b93','2b77b9e2-5c2f-513e-9c99-6781acae1033','24b094d6-207e-587f-83f2-5cd3db439fab','question','How many steps should a signup flow have?','Hi everyone, I am a beginner learner (employed part-time) and my goal is to start freelancing.

My question: How many steps should a signup flow have?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','beginner','answered',false,false,'2026-08-18T15:00:00+00:00','2026-08-18T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('311048e8-aeed-5c66-a780-e54861dd8b93','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('311048e8-aeed-5c66-a780-e54861dd8b93','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('2e923feb-90a0-5978-bd84-1f1b2a519fae','5c7ef6ed-8296-515c-b9c8-65f1743972e0','24b094d6-207e-587f-83f2-5cd3db439fab','question','How do I design for people who use screen readers?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to prepare for interviews.

My question: How do I design for people who use screen readers?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','intermediate','open',false,false,'2026-08-19T17:00:00+00:00','2026-08-19T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2e923feb-90a0-5978-bd84-1f1b2a519fae','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2e923feb-90a0-5978-bd84-1f1b2a519fae','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('387e78ec-eacf-518d-8bc5-233dbf38678f','609d55d3-bcc7-5886-aaa4-a394b698feb9','24b094d6-207e-587f-83f2-5cd3db439fab','question','Figma or Adobe XD for a beginner?','Hi everyone, I am a intermediate learner (freelancer) and my goal is to learn at my own pace.

My question: Figma or Adobe XD for a beginner?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','intermediate','open',false,false,'2026-08-20T19:00:00+00:00','2026-08-20T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('387e78ec-eacf-518d-8bc5-233dbf38678f','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('387e78ec-eacf-518d-8bc5-233dbf38678f','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('7bf2d8f4-91f6-56a4-b620-8bd09744b80b','37e41219-93da-59af-843f-7795188eccb5','24b094d6-207e-587f-83f2-5cd3db439fab','question','How do I give and receive design feedback politely?','Hi everyone, I am a advanced learner (career changer) and my goal is to build an app for my community.

My question: How do I give and receive design feedback politely?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','advanced','open',false,false,'2026-08-21T21:00:00+00:00','2026-08-21T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('7bf2d8f4-91f6-56a4-b620-8bd09744b80b','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('7bf2d8f4-91f6-56a4-b620-8bd09744b80b','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('4602a0ee-f936-5b9e-b0b8-b3d663ffd5ef','38e2832b-dbb7-5a7b-9fae-2e2d92ce6210','24b094d6-207e-587f-83f2-5cd3db439fab','question','What makes a good empty state screen?','Hi everyone, I am a beginner learner (student) and my goal is to get my first job in tech.

My question: What makes a good empty state screen?

What I tried: I looked at examples on Dribbble and Behance and tried a few layouts, but I cannot tell why mine feels off.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Design','beginner','answered',false,false,'2026-08-22T23:00:00+00:00','2026-08-22T23:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4602a0ee-f936-5b9e-b0b8-b3d663ffd5ef','2928dc2a-0f1d-55a8-9d1c-226b40cbfbc3') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4602a0ee-f936-5b9e-b0b8-b3d663ffd5ef','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('be6db5da-dc7f-5596-9832-a4a343f0e4ae','11952dd0-1238-50fb-90e9-eca36076cc15','951fd294-ba58-5091-a9a4-39550137cdb2','question','What is the real difference between Docker and a virtual machine?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to finish my university project.

My question: What is the real difference between Docker and a virtual machine?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','beginner','open',false,false,'2026-08-24T01:00:00+00:00','2026-08-24T01:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('be6db5da-dc7f-5596-9832-a4a343f0e4ae','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('be6db5da-dc7f-5596-9832-a4a343f0e4ae','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('e8ecb06d-034c-587e-aeb3-c6b117440ff0','8221855e-6ce5-59c5-ba97-8144d08e1587','951fd294-ba58-5091-a9a4-39550137cdb2','question','How do I set up a CI pipeline for a small project?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to build a side project for my portfolio.

My question: How do I set up a CI pipeline for a small project?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','intermediate','open',false,false,'2026-08-25T03:00:00+00:00','2026-08-25T03:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e8ecb06d-034c-587e-aeb3-c6b117440ff0','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e8ecb06d-034c-587e-aeb3-c6b117440ff0','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('2e09560b-16ec-5fee-8819-486f1378a8c5','f8705d18-5b23-5f91-8ec6-60b32e09c392','951fd294-ba58-5091-a9a4-39550137cdb2','question','Why does my container exit immediately after starting?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to switch careers within a year.

My question: Why does my container exit immediately after starting?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','intermediate','open',false,false,'2026-08-25T20:00:00+00:00','2026-08-25T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2e09560b-16ec-5fee-8819-486f1378a8c5','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2e09560b-16ec-5fee-8819-486f1378a8c5','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('456fd22f-2517-5aca-a28d-9942d42938db','0c4bba64-f38d-559d-ba2f-40da5ab3f7b5','951fd294-ba58-5091-a9a4-39550137cdb2','question','How do I keep secrets out of a Git repository?','Hi everyone, I am a advanced learner (freelancer) and my goal is to pass my upcoming exam.

My question: How do I keep secrets out of a Git repository?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','advanced','answered',false,false,'2026-08-26T22:00:00+00:00','2026-08-26T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('456fd22f-2517-5aca-a28d-9942d42938db','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('456fd22f-2517-5aca-a28d-9942d42938db','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('38cf833e-a941-5b1e-b080-7843ebdc7762','8182334b-07fb-5e40-af0c-6b776089297f','951fd294-ba58-5091-a9a4-39550137cdb2','question','Which cloud provider is best for a student project?','Hi everyone, I am a beginner learner (career changer) and my goal is to improve at work.

My question: Which cloud provider is best for a student project?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','beginner','open',false,false,'2026-08-27T11:00:00+00:00','2026-08-27T11:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('38cf833e-a941-5b1e-b080-7843ebdc7762','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('38cf833e-a941-5b1e-b080-7843ebdc7762','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('11651814-de7c-50a1-a622-e0f9918d541b','98fcba5d-5d23-5f57-98b2-94366e714066','951fd294-ba58-5091-a9a4-39550137cdb2','question','What is Kubernetes and do I need it as a beginner?','Hi everyone, I am a beginner learner (student) and my goal is to start freelancing.

My question: What is Kubernetes and do I need it as a beginner?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','beginner','open',false,false,'2026-08-28T13:00:00+00:00','2026-08-28T13:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('11651814-de7c-50a1-a622-e0f9918d541b','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('11651814-de7c-50a1-a622-e0f9918d541b','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('a0c61c21-e5e3-510b-b1b7-fb2ce8622d19','fa57a545-157e-5174-8579-95aacd4aca23','951fd294-ba58-5091-a9a4-39550137cdb2','question','How do I monitor a server with free tools?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to prepare for interviews.

My question: How do I monitor a server with free tools?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','intermediate','open',false,false,'2026-08-29T15:00:00+00:00','2026-08-29T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('a0c61c21-e5e3-510b-b1b7-fb2ce8622d19','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('a0c61c21-e5e3-510b-b1b7-fb2ce8622d19','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('be8f9d4c-0a7d-5d40-93ff-4a7d9f95cc95','6d255dc4-8aad-5880-bbeb-a3105845e550','951fd294-ba58-5091-a9a4-39550137cdb2','question','How do I roll back a bad deployment?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to learn at my own pace.

My question: How do I roll back a bad deployment?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','intermediate','answered',false,false,'2026-08-30T17:00:00+00:00','2026-08-30T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('be8f9d4c-0a7d-5d40-93ff-4a7d9f95cc95','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('be8f9d4c-0a7d-5d40-93ff-4a7d9f95cc95','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('d780ac77-d174-58ee-b62b-ac631b60a28e','678d379d-b73f-5a47-a71b-b301aaa58576','951fd294-ba58-5091-a9a4-39550137cdb2','question','What is infrastructure as code in simple words?','Hi everyone, I am a advanced learner (job seeker) and my goal is to build an app for my community.

My question: What is infrastructure as code in simple words?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','advanced','open',false,false,'2026-08-31T19:00:00+00:00','2026-08-31T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('d780ac77-d174-58ee-b62b-ac631b60a28e','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('d780ac77-d174-58ee-b62b-ac631b60a28e','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('aa29731d-6ca3-5a1f-8a60-176eb2ca2c3e','0565b2f2-5f7b-5b35-a0f5-45d7d1a3d992','951fd294-ba58-5091-a9a4-39550137cdb2','question','How can I reduce my cloud bill?','Hi everyone, I am a beginner learner (freelancer) and my goal is to get my first job in tech.

My question: How can I reduce my cloud bill?

What I tried: I followed the official getting-started guide and checked the logs, but the error message is not clear to me.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','DevOps','beginner','open',false,false,'2026-09-01T21:00:00+00:00','2026-09-01T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('aa29731d-6ca3-5a1f-8a60-176eb2ca2c3e','f4ae48ac-d250-5fe0-b1d8-79376c07316f') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('aa29731d-6ca3-5a1f-8a60-176eb2ca2c3e','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('76ccd3f0-3b57-59ab-ad12-b304b0df584b','57a7a0d7-a53d-50d8-9253-5231c5cdb2ad','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','Flutter or React Native for my first app?','Hi everyone, I am a beginner learner (career changer) and my goal is to finish my university project.

My question: Flutter or React Native for my first app?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','beginner','open',false,false,'2026-09-02T23:00:00+00:00','2026-09-02T23:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('76ccd3f0-3b57-59ab-ad12-b304b0df584b','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('76ccd3f0-3b57-59ab-ad12-b304b0df584b','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('76076071-e22c-5aaa-b0ea-56438c1b6976','d359ea92-bfbb-5c7d-ba1e-3bccf0853038','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How do I save data offline in a mobile app?','Hi everyone, I am a intermediate learner (student) and my goal is to build a side project for my portfolio.

My question: How do I save data offline in a mobile app?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','intermediate','answered',false,false,'2026-09-03T16:00:00+00:00','2026-09-03T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('76076071-e22c-5aaa-b0ea-56438c1b6976','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('76076071-e22c-5aaa-b0ea-56438c1b6976','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('41c152c8-af82-5d1b-b5e2-790ac42bfcf9','a6016879-9f93-5b2c-91b3-c5bae42411ca','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','Why does my app crash only on older Android phones?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to switch careers within a year.

My question: Why does my app crash only on older Android phones?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','intermediate','open',false,false,'2026-09-04T18:00:00+00:00','2026-09-04T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('41c152c8-af82-5d1b-b5e2-790ac42bfcf9','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('41c152c8-af82-5d1b-b5e2-790ac42bfcf9','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('378ae82c-6911-5ac5-ad02-f1a3d3160bd0','759b59b5-7b23-519d-8b25-3b3e37cd4b4a','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How do I send push notifications to users?','Hi everyone, I am a advanced learner (employed part-time) and my goal is to pass my upcoming exam.

My question: How do I send push notifications to users?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','advanced','open',false,false,'2026-09-05T20:00:00+00:00','2026-09-05T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('378ae82c-6911-5ac5-ad02-f1a3d3160bd0','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('378ae82c-6911-5ac5-ad02-f1a3d3160bd0','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f0d85261-d96b-50b6-bf43-eb217a42e755','47447569-57ec-59ee-b3f2-fd7b2adfcfb0','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','What is the cheapest way to publish on both app stores?','Hi everyone, I am a beginner learner (job seeker) and my goal is to improve at work.

My question: What is the cheapest way to publish on both app stores?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','beginner','open',false,false,'2026-09-06T22:00:00+00:00','2026-09-06T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f0d85261-d96b-50b6-bf43-eb217a42e755','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f0d85261-d96b-50b6-bf43-eb217a42e755','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('3afecad5-9f2b-5f19-b6de-942acd7d51a7','ab462a13-b175-5495-acec-5a2351dcf7b3','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How do I handle different screen sizes?','Hi everyone, I am a beginner learner (freelancer) and my goal is to start freelancing.

My question: How do I handle different screen sizes?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','beginner','answered',false,false,'2026-09-08T00:00:00+00:00','2026-09-08T00:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('3afecad5-9f2b-5f19-b6de-942acd7d51a7','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('3afecad5-9f2b-5f19-b6de-942acd7d51a7','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('8e5d8bab-83ef-5016-8f20-0699af83a4e0','8341076a-653a-58bc-a923-68e37fa66e66','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How do I add login with Google to my app?','Hi everyone, I am a intermediate learner (career changer) and my goal is to prepare for interviews.

My question: How do I add login with Google to my app?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','intermediate','open',false,false,'2026-09-09T02:00:00+00:00','2026-09-09T02:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('8e5d8bab-83ef-5016-8f20-0699af83a4e0','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('8e5d8bab-83ef-5016-8f20-0699af83a4e0','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('25cf51b4-ce9f-5518-8db9-7881b9520faa','f0d8a665-ce45-5e39-8f0d-1c2dfd2ed0eb','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How do I test an app without owning an iPhone?','Hi everyone, I am a intermediate learner (student) and my goal is to learn at my own pace.

My question: How do I test an app without owning an iPhone?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','intermediate','open',false,false,'2026-09-09T15:00:00+00:00','2026-09-09T15:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('25cf51b4-ce9f-5518-8db9-7881b9520faa','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('25cf51b4-ce9f-5518-8db9-7881b9520faa','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('3287d8fb-6a57-576c-95bc-257fe31d3215','a059fbeb-94f0-51d1-addd-24ab03555e5d','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How can I make my app start faster?','Hi everyone, I am a advanced learner (employed full-time) and my goal is to build an app for my community.

My question: How can I make my app start faster?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','advanced','open',false,false,'2026-09-10T17:00:00+00:00','2026-09-10T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('3287d8fb-6a57-576c-95bc-257fe31d3215','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('3287d8fb-6a57-576c-95bc-257fe31d3215','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('c50b287d-a57b-5d41-8002-623f696b45f7','987b4986-5d85-516c-a6ce-2cc794c9e39e','2d03821b-66f7-5a95-b8e3-a6ba5feba122','question','How do I get my first 100 users for an app?','Hi everyone, I am a beginner learner (employed part-time) and my goal is to get my first job in tech.

My question: How do I get my first 100 users for an app?

What I tried: I tested on an emulator and a real phone and read the documentation, but the problem only happens sometimes.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Mobile Development','beginner','answered',false,false,'2026-08-02T19:00:00+00:00','2026-08-02T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c50b287d-a57b-5d41-8002-623f696b45f7','0d97f474-e584-5749-874d-8d7ba14cdb49') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c50b287d-a57b-5d41-8002-623f696b45f7','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('4a2ba3d4-a6d7-595a-b4f2-822fb60f965c','8c246dd0-42f7-5105-bc88-edbbdaf4ec8b','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','How should I store user passwords in my app?','Hi everyone, I am a beginner learner (job seeker) and my goal is to finish my university project.

My question: How should I store user passwords in my app?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','beginner','open',false,false,'2026-08-03T12:00:00+00:00','2026-08-03T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4a2ba3d4-a6d7-595a-b4f2-822fb60f965c','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('4a2ba3d4-a6d7-595a-b4f2-822fb60f965c','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('e571c0cb-0d3f-5e9d-87a3-89e22d12c60a','3bd18e77-d0e1-58b8-93cf-548b0ac863b4','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','What is the difference between authentication and authorisation?','Hi everyone, I am a intermediate learner (freelancer) and my goal is to build a side project for my portfolio.

My question: What is the difference between authentication and authorisation?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','intermediate','open',false,false,'2026-08-04T14:00:00+00:00','2026-08-04T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e571c0cb-0d3f-5e9d-87a3-89e22d12c60a','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('e571c0cb-0d3f-5e9d-87a3-89e22d12c60a','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('2e94c4fd-b8b7-50c7-89a0-dc9ac5708262','d19afcd7-f364-5482-88ee-eb361b360dea','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','How do I start learning ethical hacking legally?','Hi everyone, I am a intermediate learner (career changer) and my goal is to switch careers within a year.

My question: How do I start learning ethical hacking legally?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','intermediate','open',false,false,'2026-08-05T16:00:00+00:00','2026-08-05T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2e94c4fd-b8b7-50c7-89a0-dc9ac5708262','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('2e94c4fd-b8b7-50c7-89a0-dc9ac5708262','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('d0134b9f-8d43-5810-b4d8-a117c8b6269f','f66dbb4c-ab1c-5f9b-a283-5362949f8114','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','What is SQL injection and how do I prevent it?','Hi everyone, I am a advanced learner (student) and my goal is to pass my upcoming exam.

My question: What is SQL injection and how do I prevent it?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','advanced','answered',false,false,'2026-08-06T18:00:00+00:00','2026-08-06T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('d0134b9f-8d43-5810-b4d8-a117c8b6269f','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('d0134b9f-8d43-5810-b4d8-a117c8b6269f','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('18a125fe-9d78-5baa-9116-765526aab4be','c25d1d8c-b83c-5557-acfa-1ae39d269450','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','How can I check if my email was in a data breach?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to improve at work.

My question: How can I check if my email was in a data breach?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','beginner','open',false,false,'2026-08-07T20:00:00+00:00','2026-08-07T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('18a125fe-9d78-5baa-9116-765526aab4be','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('18a125fe-9d78-5baa-9116-765526aab4be','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f89d5154-ed88-544b-9907-a706e7eb76ab','f0a4d4ab-31f1-5ce7-ab2a-c97e156d07e8','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','Is a VPN enough to stay safe on public Wi-Fi?','Hi everyone, I am a beginner learner (employed part-time) and my goal is to start freelancing.

My question: Is a VPN enough to stay safe on public Wi-Fi?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','beginner','open',false,false,'2026-08-08T22:00:00+00:00','2026-08-08T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f89d5154-ed88-544b-9907-a706e7eb76ab','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f89d5154-ed88-544b-9907-a706e7eb76ab','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('c48adda8-3817-5594-a8d1-6a8a59a6b8d5','1d62a907-e328-54fb-beaa-764042aa2bd7','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','How do I set up two-factor authentication for my users?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to prepare for interviews.

My question: How do I set up two-factor authentication for my users?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','intermediate','open',false,false,'2026-08-10T00:00:00+00:00','2026-08-10T00:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c48adda8-3817-5594-a8d1-6a8a59a6b8d5','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c48adda8-3817-5594-a8d1-6a8a59a6b8d5','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('c0ed5c81-34d2-5903-8fd7-e7b68e9baf15','691496d8-7e16-584f-9fc1-747ef8de7eef','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','Which certification is best for a security beginner?','Hi everyone, I am a intermediate learner (freelancer) and my goal is to learn at my own pace.

My question: Which certification is best for a security beginner?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','intermediate','answered',false,false,'2026-08-11T02:00:00+00:00','2026-08-11T02:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c0ed5c81-34d2-5903-8fd7-e7b68e9baf15','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('c0ed5c81-34d2-5903-8fd7-e7b68e9baf15','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('9f6edfbc-5977-580e-a20b-f1cb6d59089c','f20bdf29-f95d-5c02-bb58-b9cb535f6dd9','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','How do I safely test my own web app for vulnerabilities?','Hi everyone, I am a advanced learner (career changer) and my goal is to build an app for my community.

My question: How do I safely test my own web app for vulnerabilities?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','advanced','open',false,false,'2026-08-12T04:00:00+00:00','2026-08-12T04:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9f6edfbc-5977-580e-a20b-f1cb6d59089c','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('9f6edfbc-5977-580e-a20b-f1cb6d59089c','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('889025fd-802b-5d39-b54c-3b3f8c1acd64','c08379f0-3706-537f-8e98-b92f7c71c2e0','f569a3a2-8d40-5e4c-8cd2-e4d410ac6601','question','What should I do first if my account is hacked?','Hi everyone, I am a beginner learner (student) and my goal is to get my first job in tech.

My question: What should I do first if my account is hacked?

What I tried: I read about the topic in a couple of articles and a course, but I want to be sure I am doing it the safe way.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Cybersecurity','beginner','open',false,false,'2026-08-12T21:00:00+00:00','2026-08-12T21:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('889025fd-802b-5d39-b54c-3b3f8c1acd64','7a120d80-68e7-5b05-98f5-57d9cac99bb2') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('889025fd-802b-5d39-b54c-3b3f8c1acd64','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('b9c9e75a-0c4f-5494-9a70-9b2229ac0056','effec6e3-ccf2-52ee-8687-4e2c7bd71172','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','What is the difference between INNER JOIN and LEFT JOIN?','Hi everyone, I am a beginner learner (employed full-time) and my goal is to finish my university project.

My question: What is the difference between INNER JOIN and LEFT JOIN?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','beginner','open',false,false,'2026-08-13T10:00:00+00:00','2026-08-13T10:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b9c9e75a-0c4f-5494-9a70-9b2229ac0056','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b9c9e75a-0c4f-5494-9a70-9b2229ac0056','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('42c317ca-ec4b-5a61-88f6-4a3b14d046da','998d21ba-ffd4-56a0-ba7b-ec02fa3791d5','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','How do I design tables for a social app with posts and comments?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to build a side project for my portfolio.

My question: How do I design tables for a social app with posts and comments?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','intermediate','answered',false,false,'2026-08-14T12:00:00+00:00','2026-08-14T12:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('42c317ca-ec4b-5a61-88f6-4a3b14d046da','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('42c317ca-ec4b-5a61-88f6-4a3b14d046da','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('b793d283-5c0e-5557-bc95-5b8e4f4fe263','8cc03af2-868e-592f-9535-37f766cf3ac1','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','When should I add an index to a column?','Hi everyone, I am a intermediate learner (job seeker) and my goal is to switch careers within a year.

My question: When should I add an index to a column?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','intermediate','open',false,false,'2026-08-15T14:00:00+00:00','2026-08-15T14:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b793d283-5c0e-5557-bc95-5b8e4f4fe263','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('b793d283-5c0e-5557-bc95-5b8e4f4fe263','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('059daab6-1256-515e-92ec-99419d2b4054','38ec1ac1-d3d4-5576-931b-ff5fd3ab0560','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','What is normalisation and how far should I go?','Hi everyone, I am a advanced learner (freelancer) and my goal is to pass my upcoming exam.

My question: What is normalisation and how far should I go?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','advanced','open',false,false,'2026-08-16T16:00:00+00:00','2026-08-16T16:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('059daab6-1256-515e-92ec-99419d2b4054','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('059daab6-1256-515e-92ec-99419d2b4054','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('183e3202-2aa1-52f9-8191-428777c32b00','19955e83-5829-513e-9628-605205675091','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','Why is my query slow with 500,000 rows?','Hi everyone, I am a beginner learner (career changer) and my goal is to improve at work.

My question: Why is my query slow with 500,000 rows?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','beginner','open',false,false,'2026-08-17T18:00:00+00:00','2026-08-17T18:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('183e3202-2aa1-52f9-8191-428777c32b00','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('183e3202-2aa1-52f9-8191-428777c32b00','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('15d0eb96-bc1d-5ac1-97b1-e70ceafb480b','76dd97ea-767f-5a05-bd2d-b2422b784848','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','How do I find duplicate rows and remove them?','Hi everyone, I am a beginner learner (student) and my goal is to start freelancing.

My question: How do I find duplicate rows and remove them?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','beginner','answered',false,false,'2026-08-18T20:00:00+00:00','2026-08-18T20:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('15d0eb96-bc1d-5ac1-97b1-e70ceafb480b','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('15d0eb96-bc1d-5ac1-97b1-e70ceafb480b','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('305e0f5b-304e-5fbd-9537-a4c0f3f999f4','b58c3b10-5483-573d-b40a-a7eabcc8e15e','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','SQL or NoSQL for a small startup?','Hi everyone, I am a intermediate learner (employed full-time) and my goal is to prepare for interviews.

My question: SQL or NoSQL for a small startup?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','intermediate','open',false,false,'2026-08-19T22:00:00+00:00','2026-08-19T22:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('305e0f5b-304e-5fbd-9537-a4c0f3f999f4','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('305e0f5b-304e-5fbd-9537-a4c0f3f999f4','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('93908c6c-c912-543d-89c4-3c653c8ebbc1','6931fc06-f42d-527d-ac6a-0bd574aae0fb','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','How do I back up a Postgres database safely?','Hi everyone, I am a intermediate learner (employed part-time) and my goal is to learn at my own pace.

My question: How do I back up a Postgres database safely?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','intermediate','open',false,false,'2026-08-21T00:00:00+00:00','2026-08-21T00:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('93908c6c-c912-543d-89c4-3c653c8ebbc1','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('93908c6c-c912-543d-89c4-3c653c8ebbc1','4a35f1d1-f913-5c5a-81d0-aff8251c97ef') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('f6d54fbc-6088-5805-80c4-a88393f72fcd','4cb75c36-bd1f-5a17-91e6-094db7c75431','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','What does ON DELETE CASCADE do?','Hi everyone, I am a advanced learner (job seeker) and my goal is to build an app for my community.

My question: What does ON DELETE CASCADE do?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','advanced','open',false,false,'2026-08-21T17:00:00+00:00','2026-08-21T17:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f6d54fbc-6088-5805-80c4-a88393f72fcd','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('f6d54fbc-6088-5805-80c4-a88393f72fcd','a8dfc9fd-de82-50f2-be6f-9e4f8091c19b') ON CONFLICT DO NOTHING;
INSERT INTO posts (id,author_id,community_id,post_type,title,body,field,skill_level,status,is_pinned,is_removed,created_at,last_activity_at) VALUES ('1ad0318d-ebf9-563e-939d-56df2c825d0e','2bea71c5-13d1-5b35-8fdf-2c5b1277d7a5','e9bdfb81-38cb-5015-8224-23e22ee9fbad','question','How do I write a query for the top 3 items per category?','Hi everyone, I am a beginner learner (freelancer) and my goal is to get my first job in tech.

My question: How do I write a query for the top 3 items per category?

What I tried: I tried the query in a test table and checked the docs, but the output is different from what I need.

What I need: a clear explanation or an example I can follow, plus any resources you recommend for my level. If you need more details such as code, screenshots or my setup, tell me and I will add them.','Databases','beginner','answered',false,false,'2026-08-22T19:00:00+00:00','2026-08-22T19:00:00+00:00') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1ad0318d-ebf9-563e-939d-56df2c825d0e','a906eb5e-9fb9-5845-9201-cb8b0e81497a') ON CONFLICT DO NOTHING;
INSERT INTO post_tags (post_id,tag_id) VALUES ('1ad0318d-ebf9-563e-939d-56df2c825d0e','5b541937-92f6-5f95-a182-e4ab51473fb1') ON CONFLICT DO NOTHING;

COMMIT;

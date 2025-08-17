CREATE TABLE IF NOT EXISTS submissions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL, 
    submission_type TEXT NOT NULL,
    disclaimer TEXT,
    author TEXT NOT NULL DEFAULT 'Anonymous Writer',
    author_socials TEXT,
    author_bio TEXT,
    bibliography TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,                
    subs_id INT NOT NULL,                  
    parent_id INT REFERENCES comments(id)  
        ON DELETE CASCADE,                 
    author VARCHAR(100) NOT NULL,          
    content TEXT NOT NULL,                 
    created_at TIMESTAMP DEFAULT NOW(),    
    CONSTRAINT fk_post FOREIGN KEY (subs_id) REFERENCES submissions(id) ON DELETE CASCADE
);

-- TESTING PURPOSES + MOCK DATA FOR REFERENCE

-- Mock data
-- Insert mock submissions with diverse categories
INSERT INTO submissions (title, content, submission_type, disclaimer, author, author_socials, author_bio, bibliography, created_at) VALUES
-- Poetry submissions
('The Dawn of Spring', '<p>Petals unfold like whispered secrets,<br/>Morning dew catches first light,<br/>A symphony of rebirth begins<br/>In every blade of grass.</p>', 'poetry', NULL, 'Jane Doe', 'Instagram: @jane_doe_poetry, Twitter: @janepoet', 'Jane Doe is a contemporary poet exploring themes of nature and renewal.', NULL, NOW() - INTERVAL '10 days'),

('Urban Echoes', '<p>Concrete rivers flow with dreams,<br/>Neon signs spell out forgotten names,<br/>In the city''s heart, we find ourselves<br/>Lost and found in the same breath.</p>', 'poetry', 'This poem reflects personal urban experiences.', 'Miguel Santos', 'Instagram: @miguel_writes, LinkedIn: Miguel Santos Writer', 'Miguel Santos is an urban poet and city planner from São Paulo.', NULL, NOW() - INTERVAL '8 days'),

-- Short stories
('The Last Library', '<p>In a world where books had become extinct, Sarah discovered a hidden room behind her grandmother''s bookshelf. The musty smell of paper and ink filled her lungs as she stepped into what might be humanity''s final sanctuary of written knowledge.</p><p>"Every book here," her grandmother whispered, "contains a world that refuses to die."</p>', 'short-stories', NULL, 'Elena Rodriguez', 'Goodreads: Elena Rodriguez Author, Twitter: @elena_stories', 'Elena Rodriguez writes speculative fiction exploring the intersection of technology and humanity.', '<p><em>Sources of inspiration:</em></p><ul><li>Bradbury, Ray. <em>Fahrenheit 451</em>. Ballantine Books, 1953.</li><li>Calvino, Italo. <em>If on a winter''s night a traveler</em>. Harcourt Brace Jovanovich, 1981.</li></ul>', NOW() - INTERVAL '6 days'),

('The Coffee Shop Philosopher', '<p>Every Tuesday at 3 PM, an elderly man would sit at the corner table, solving the world''s problems one espresso at a time. Today, for the first time in three years, his table was empty.</p><p>The barista found a note: "The answers were never in the coffee. They were in listening to each other."</p>', 'short-stories', 'Based on observations from my local coffee shop.', 'Anonymous Writer', NULL, NULL, NULL, NOW() - INTERVAL '4 days'),

-- Essays, opinions, research papers
('The Digital Divide: Bridging Tomorrow', '<p>As we advance deeper into the digital age, the gap between those with access to technology and those without continues to widen. This essay examines the socioeconomic implications of digital inequality and proposes actionable solutions for creating more inclusive technological landscapes.</p><p>Research indicates that digital literacy is no longer optional—it has become a fundamental requirement for participation in modern society.</p>', 'essays-opinions-research-papers', 'Research conducted with IRB approval #2024-789.', 'Dr. Amira Hassan', 'LinkedIn: Dr. Amira Hassan, ResearchGate: A.Hassan', 'Dr. Amira Hassan is a professor of Digital Sociology at Columbia University, specializing in technology accessibility and social equity.', '<p><strong>References:</strong></p><ul><li>Norris, P. (2001). <em>Digital Divide: Civic Engagement, Information Poverty, and the Internet Worldwide</em>. Cambridge University Press.</li><li>Van Dijk, J. (2020). The Digital Divide. Polity Press.</li><li>Warschauer, M. (2003). <em>Technology and Social Inclusion: Rethinking the Digital Divide</em>. MIT Press.</li></ul>', NOW() - INTERVAL '12 days'),

('Climate Anxiety in Generation Z', '<p>This research paper explores the psychological impact of climate change awareness on individuals aged 18-25. Through interviews with 200 participants across five countries, we examine how environmental concerns shape mental health, career choices, and life planning decisions.</p>', 'essays-opinions-research-papers', 'This study was conducted in accordance with ethical research guidelines.', 'Sarah Kim & David Chen', 'Sarah: @sarahkimresearch (Twitter), David: LinkedIn - David Chen PhD', 'Sarah Kim is a graduate student in Environmental Psychology. David Chen is an Assistant Professor of Climate Psychology at UC Berkeley.', '<p><strong>Bibliography:</strong></p><ul><li>Clayton, S. (2020). Climate anxiety: Psychological predispositions and climate change worry among US adults. <em>Environment and Behavior</em>, 52(4), 362-384.</li><li>Cunsolo, A., & Ellis, N. R. (2017). Ecological grief as a mental health response to climate-related loss. <em>Nature Climate Change</em>, 7(12), 12-17.</li></ul>', NOW() - INTERVAL '15 days'),

-- Writing to spread awareness
('Breaking the Silence: Mental Health in the Workplace', '<p>One in four people will experience mental health issues at some point in their lives, yet workplace conversations about mental health remain taboo. This piece shares personal stories and practical steps organizations can take to create supportive environments.</p><p>It''s time to normalize these conversations and prioritize mental wellness as much as physical safety.</p>', 'writing-to-spread-awareness', 'Names have been changed to protect privacy. If you''re struggling, please reach out to mental health resources.', 'Jordan Martinez', 'Instagram: @mentalhealthadvocate_jm, Medium: @jordan.martinez', 'Jordan Martinez is a mental health advocate and HR consultant who has spoken at over 50 organizations about workplace wellness.', '<p><strong>Resources:</strong></p><ul><li>National Suicide Prevention Lifeline: 988</li><li>Mental Health America: <a href="https://www.mhanational.org">www.mhanational.org</a></li><li>Workplace Mental Health Institute resources</li></ul>', NOW() - INTERVAL '7 days'),

-- Other creative works
('Fragments of Memory: A Photo Essay', '<p>Through a collection of black and white photographs taken over five years, this visual narrative explores how abandoned places hold echoes of the lives once lived within them.</p><p>[Image descriptions and artistic statements accompany each photograph, creating a multimedia experience that bridges visual art and written reflection.]</p>', 'other-creative-works', 'All photographs taken with permission. Some locations have been anonymized for privacy.', 'Alex Thompson', 'Instagram: @alexthompson_photography, Website: alexthompsonphoto.com', 'Alex Thompson is a documentary photographer whose work focuses on urban decay and social memory.', NULL, NOW() - INTERVAL '9 days'),

-- Issues
('The Housing Crisis: A Local Perspective', '<p>Rent prices in our city have increased by 40% in two years, while median income has grown by only 8%. This investigation examines the local policies and market forces driving families out of neighborhoods they''ve called home for generations.</p><p>Through interviews with affected residents, landlords, and city officials, we reveal the human cost of unchecked gentrification.</p>', 'issues', 'All sources consented to be quoted. Some names changed upon request.', 'Community Action Network', 'Facebook: Community Action Network, Website: communityactionnetwork.org', 'A collective of local journalists and activists working to highlight social justice issues in our community.', '<p><strong>Data Sources:</strong></p><ul><li>City Housing Authority rental reports 2022-2024</li><li>U.S. Census Bureau American Community Survey data</li><li>Local property records and transaction databases</li></ul>', NOW() - INTERVAL '3 days'),

-- Interviews
('In Conversation with Local Hero: Maria Gonzalez', '<p><strong>Interviewer:</strong> Maria, you''ve been running the community food bank for 15 years. What drives you to continue this work?</p><p><strong>Maria:</strong> You know, it started when my own family needed help. I promised myself that if I ever got back on my feet, I''d make sure no child in this neighborhood went hungry. That promise became my life''s work.</p><p><em>[The interview continues, exploring themes of community resilience, food security, and grassroots activism.]</em></p>', 'interviews', 'Interview conducted with full consent. Maria reviewed and approved the final version.', 'Reporter Collective', 'Twitter: @reportercollective, Email: contact@reportercollective.org', 'The Reporter Collective is a group of citizen journalists documenting local community leaders and their impact.', NULL, NOW() - INTERVAL '5 days');

-- Insert mock comments

-- Top-level comments on submission #1 (Poetry)
INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
(1, NULL, 'Alice', 'Beautiful poem! Really loved the imagery of whispered secrets in petals.', NOW() - INTERVAL '9 days'),
(1, NULL, 'Bob', 'This makes me feel hopeful about spring coming.', NOW() - INTERVAL '8 days'),
(1, NULL, 'Nature Lover', 'Your connection to the natural world is so vivid. Do you have more nature poetry?', NOW() - INTERVAL '7 days');

-- Replies to Alice's comment
INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
(1, 1, 'Jane Doe', 'Thank you so much, Alice! I spent hours watching the garden come alive.', NOW() - INTERVAL '7 days'),
(1, 1, 'Charlie', 'I agree with Alice - the imagery is stunning.', NOW() - INTERVAL '7 days');

-- Top-level comment on submission #3 (The Last Library)
INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
(3, NULL, 'BookLover47', 'This gave me chills! The concept of a world without books is terrifying.', NOW() - INTERVAL '5 days'),
(3, NULL, 'Diana', 'Reminds me of Fahrenheit 451. Great homage to classic dystopian literature.', NOW() - INTERVAL '4 days');

-- Reply to BookLover47's comment
INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
(3, 6, 'Elena Rodriguez', 'That was exactly the feeling I was hoping to evoke! Books as sanctuaries.', NOW() - INTERVAL '4 days');

-- Comments on the climate anxiety research paper
INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
(5, NULL, 'Graduate Student', 'This research speaks to my experience so much. Thank you for studying this important topic.', NOW() - INTERVAL '14 days'),
(5, NULL, 'Prof. Williams', 'Excellent methodology. Have you considered expanding this to include international perspectives?', NOW() - INTERVAL '13 days');

-- Comments on mental health awareness piece
INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
(6, NULL, 'HR Manager', 'Sharing this with our leadership team. We need more conversations like this.', NOW() - INTERVAL '6 days'),
(6, NULL, 'Anonymous', 'Thank you for writing this. It helps me feel less alone in my struggles.', NOW() - INTERVAL '5 days');
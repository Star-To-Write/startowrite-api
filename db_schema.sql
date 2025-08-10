CREATE TABLE IF NOT EXISTS submissions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL, 
    submission_type TEXT NOT NULL,
    disclaimer TEXT,
    author TEXT NOT NULL DEFAULT 'Anonymous Writer',
    author_instagram TEXT,
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
-- Insert mock submissions
-- INSERT INTO submissions (title, content, submission_type, disclaimer, author, author_instagram, created_at) VALUES
-- ('The Dawn of Spring', '<p>This is a beautiful poem about spring.</p>', 'poetry', NULL, 'Jane Doe', '@jane_doe', NOW() - INTERVAL '10 days'),
-- ('Reflections on Society', '<p>An essay reflecting on modern social issues.</p>', 'shortstories', 'Views are personal.', 'John Smith', '@johnsmith', NOW() - INTERVAL '5 days'),
-- ('Short Story: The Lost City', '<p>A thrilling adventure story about a lost city.</p>', 'essays', NULL, 'Anonymous Writer', NULL, NOW() - INTERVAL '2 days');

-- -- Insert mock comments

-- -- Top-level comments on submission #1
-- INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
-- (1, NULL, 'Alice', 'Beautiful poem! Really loved the imagery.', NOW() - INTERVAL '9 days'),
-- (1, NULL, 'Bob', 'Makes me feel hopeful.', NOW() - INTERVAL '8 days');

-- -- Replies to Alice's comment
-- INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
-- (1, 1, 'Jane Doe', 'Thank you so much, Alice!', NOW() - INTERVAL '7 days'),
-- (1, 1, 'Charlie', 'I agree with Alice.', NOW() - INTERVAL '7 days');

-- -- Top-level comment on submission #2
-- INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
-- (2, NULL, 'Diana', 'Great insights on society.', NOW() - INTERVAL '4 days');

-- -- Reply to Diana's comment
-- INSERT INTO comments (subs_id, parent_id, author, content, created_at) VALUES
-- (2, 6, 'John Smith', 'Thanks for reading, Diana!', NOW() - INTERVAL '3 days');

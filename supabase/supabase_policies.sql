-- Enable Row Level Security for all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE reader_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_streams ENABLE ROW LEVEL SECURITY;
ALTER TABLE stream_gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
DROP POLICY IF EXISTS "Users can view all profiles" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can delete their own profile" ON users;

-- Users table policies
CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view all profiles" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (true);

CREATE POLICY "Users can delete their own profile" ON users
    FOR DELETE USING (auth.uid() = id);

-- Drop existing reader profile policies
DROP POLICY IF EXISTS "Readers can insert their own profile" ON reader_profiles;
DROP POLICY IF EXISTS "Anyone can view reader profiles" ON reader_profiles;
DROP POLICY IF EXISTS "Readers can update their own profile" ON reader_profiles;
DROP POLICY IF EXISTS "Readers can delete their own profile" ON reader_profiles;

-- Reader profiles policies
CREATE POLICY "Readers can insert their own profile" ON reader_profiles
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view reader profiles" ON reader_profiles
    FOR SELECT USING (true);

CREATE POLICY "Readers can update their own profile" ON reader_profiles
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (true);

CREATE POLICY "Readers can delete their own profile" ON reader_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- Drop existing reading session policies
DROP POLICY IF EXISTS "Users can view their own reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Authenticated users can create reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Participants can update reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Participants can delete reading sessions" ON reading_sessions;

-- Reading sessions policies
CREATE POLICY "Users can view their own reading sessions" ON reading_sessions
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reading sessions" ON reading_sessions
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Participants can update reading sessions" ON reading_sessions
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Participants can delete reading sessions" ON reading_sessions
    FOR DELETE USING (true);

-- Drop existing chat message policies
DROP POLICY IF EXISTS "Session participants can view messages" ON chat_messages;
DROP POLICY IF EXISTS "Session participants can send messages" ON chat_messages;
DROP POLICY IF EXISTS "Senders can update their messages" ON chat_messages;
DROP POLICY IF EXISTS "Senders can delete their messages" ON chat_messages;

-- Chat messages policies
CREATE POLICY "Session participants can view messages" ON chat_messages
    FOR SELECT USING (true);

CREATE POLICY "Session participants can send messages" ON chat_messages
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Senders can update their messages" ON chat_messages
    FOR UPDATE USING (auth.uid() = sender_id) WITH CHECK (true);

CREATE POLICY "Senders can delete their messages" ON chat_messages
    FOR DELETE USING (auth.uid() = sender_id);

-- Drop existing transaction policies
DROP POLICY IF EXISTS "Users can view their own transactions" ON transactions;
DROP POLICY IF EXISTS "Authenticated users can create transactions" ON transactions;
DROP POLICY IF EXISTS "Users can update their own transactions" ON transactions;
DROP POLICY IF EXISTS "Users can delete their own transactions" ON transactions;

-- Transactions policies
CREATE POLICY "Users can view their own transactions" ON transactions
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create transactions" ON transactions
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own transactions" ON transactions
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (true);

CREATE POLICY "Users can delete their own transactions" ON transactions
    FOR DELETE USING (auth.uid() = user_id);

-- Drop existing product policies
DROP POLICY IF EXISTS "Anyone can view active products" ON products;
DROP POLICY IF EXISTS "Readers can create products" ON products;
DROP POLICY IF EXISTS "Readers can update their own products" ON products;
DROP POLICY IF EXISTS "Readers can delete their own products" ON products;

-- Products policies
CREATE POLICY "Anyone can view active products" ON products
    FOR SELECT USING (true);

CREATE POLICY "Readers can create products" ON products
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Readers can update their own products" ON products
    FOR UPDATE USING (auth.uid() = reader_id) WITH CHECK (true);

CREATE POLICY "Readers can delete their own products" ON products
    FOR DELETE USING (auth.uid() = reader_id);

-- Drop existing order policies
DROP POLICY IF EXISTS "Clients can view their own orders" ON orders;
DROP POLICY IF EXISTS "Authenticated users can create orders" ON orders;
DROP POLICY IF EXISTS "Clients can update their own orders" ON orders;
DROP POLICY IF EXISTS "Clients can delete their own orders" ON orders;

-- Orders policies
CREATE POLICY "Clients can view their own orders" ON orders
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create orders" ON orders
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Clients can update their own orders" ON orders
    FOR UPDATE USING (auth.uid() = client_id) WITH CHECK (true);

CREATE POLICY "Clients can delete their own orders" ON orders
    FOR DELETE USING (auth.uid() = client_id);

-- Drop existing live stream policies
DROP POLICY IF EXISTS "Anyone can view live streams" ON live_streams;
DROP POLICY IF EXISTS "Readers can create live streams" ON live_streams;
DROP POLICY IF EXISTS "Readers can update their own streams" ON live_streams;
DROP POLICY IF EXISTS "Readers can delete their own streams" ON live_streams;

-- Live streams policies
CREATE POLICY "Anyone can view live streams" ON live_streams
    FOR SELECT USING (true);

CREATE POLICY "Readers can create live streams" ON live_streams
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Readers can update their own streams" ON live_streams
    FOR UPDATE USING (auth.uid() = reader_id) WITH CHECK (true);

CREATE POLICY "Readers can delete their own streams" ON live_streams
    FOR DELETE USING (auth.uid() = reader_id);

-- Drop existing stream gift policies
DROP POLICY IF EXISTS "Anyone can view stream gifts" ON stream_gifts;
DROP POLICY IF EXISTS "Authenticated users can send gifts" ON stream_gifts;
DROP POLICY IF EXISTS "Senders can update their gifts" ON stream_gifts;
DROP POLICY IF EXISTS "Senders can delete their gifts" ON stream_gifts;

-- Stream gifts policies
CREATE POLICY "Anyone can view stream gifts" ON stream_gifts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can send gifts" ON stream_gifts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Senders can update their gifts" ON stream_gifts
    FOR UPDATE USING (auth.uid() = sender_id) WITH CHECK (true);

CREATE POLICY "Senders can delete their gifts" ON stream_gifts
    FOR DELETE USING (auth.uid() = sender_id);

-- Drop existing review policies
DROP POLICY IF EXISTS "Anyone can view reviews" ON reviews;
DROP POLICY IF EXISTS "Clients can create reviews for their sessions" ON reviews;
DROP POLICY IF EXISTS "Clients can update their own reviews" ON reviews;
DROP POLICY IF EXISTS "Clients can delete their own reviews" ON reviews;

-- Reviews policies
CREATE POLICY "Anyone can view reviews" ON reviews
    FOR SELECT USING (true);

CREATE POLICY "Clients can create reviews for their sessions" ON reviews
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Clients can update their own reviews" ON reviews
    FOR UPDATE USING (auth.uid() = client_id) WITH CHECK (true);

CREATE POLICY "Clients can delete their own reviews" ON reviews
    FOR DELETE USING (auth.uid() = client_id);

-- Drop existing post policies
DROP POLICY IF EXISTS "Anyone can view posts" ON posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

-- Posts policies
CREATE POLICY "Anyone can view posts" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts" ON posts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (true);

CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (auth.uid() = user_id);

-- Drop existing post like policies
DROP POLICY IF EXISTS "Anyone can view post likes" ON post_likes;
DROP POLICY IF EXISTS "Authenticated users can like posts" ON post_likes;
DROP POLICY IF EXISTS "Users can update their own likes" ON post_likes;
DROP POLICY IF EXISTS "Users can delete their own likes" ON post_likes;

-- Post likes policies
CREATE POLICY "Anyone can view post likes" ON post_likes
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can like posts" ON post_likes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own likes" ON post_likes
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (true);

CREATE POLICY "Users can delete their own likes" ON post_likes
    FOR DELETE USING (auth.uid() = user_id);
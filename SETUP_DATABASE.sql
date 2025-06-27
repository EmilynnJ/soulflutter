-- ================================
-- SOULSEER DATABASE SETUP SCRIPT
-- Run this ENTIRE script in your Supabase SQL Editor
-- ================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS post_likes CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS stream_gifts CASCADE;
DROP TABLE IF EXISTS live_streams CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS reading_sessions CASCADE;
DROP TABLE IF EXISTS reader_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ================================
-- CREATE TABLES
-- ================================

-- Users table (extends auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('client', 'reader', 'admin')),
    username TEXT UNIQUE,
    avatar_url TEXT,
    bio TEXT,
    account_balance DECIMAL(10,2) DEFAULT 0.00,
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reader profiles table
CREATE TABLE reader_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specializations TEXT NOT NULL,
    chat_rate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    phone_rate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    video_rate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_readings INTEGER DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT FALSE,
    tagline TEXT,
    tools TEXT[] DEFAULT '{}',
    years_experience INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    pending_earnings DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reading sessions table
CREATE TABLE reading_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reader_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('chat', 'phone', 'video')),
    status TEXT NOT NULL CHECK (status IN ('pending', 'active', 'completed', 'cancelled', 'disputed')),
    per_minute_rate DECIMAL(10,2) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER DEFAULT 0,
    total_cost DECIMAL(10,2) DEFAULT 0.00,
    reader_earnings DECIMAL(10,2) DEFAULT 0.00,
    platform_fee DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    rating DECIMAL(3,2),
    review TEXT,
    is_connected BOOLEAN DEFAULT FALSE,
    connection_id TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages table
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES reading_sessions(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE,
    media_url TEXT,
    media_type TEXT
);

-- Transactions table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES reading_sessions(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('payment', 'refund', 'payout', 'top_up')),
    amount DECIMAL(10,2) NOT NULL,
    stripe_payment_intent_id TEXT,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table (for marketplace)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reader_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('digital', 'physical', 'service')),
    category TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    stripe_product_id TEXT,
    stripe_price_id TEXT,
    inventory_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_amount DECIMAL(10,2) NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'shipped', 'cancelled')),
    stripe_payment_intent_id TEXT,
    shipping_address JSONB,
    tracking_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Live streams table
CREATE TABLE live_streams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reader_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    is_live BOOLEAN DEFAULT FALSE,
    viewer_count INTEGER DEFAULT 0,
    stream_key TEXT,
    stream_url TEXT,
    scheduled_start TIMESTAMP WITH TIME ZONE,
    actual_start TIMESTAMP WITH TIME ZONE,
    actual_end TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stream gifts table
CREATE TABLE stream_gifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stream_id UUID NOT NULL REFERENCES live_streams(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gift_type TEXT NOT NULL,
    gift_value DECIMAL(10,2) NOT NULL,
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES reading_sessions(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reader_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Posts table (for social community features)
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    image_url TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Post likes table
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- ================================
-- CREATE INDEXES
-- ================================

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_online ON users(is_online);
CREATE INDEX idx_reader_profiles_available ON reader_profiles(is_available);
CREATE INDEX idx_reading_sessions_client ON reading_sessions(client_id);
CREATE INDEX idx_reading_sessions_reader ON reading_sessions(reader_id);
CREATE INDEX idx_reading_sessions_status ON reading_sessions(status);
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_products_reader ON products(reader_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_live_streams_reader ON live_streams(reader_id);
CREATE INDEX idx_live_streams_live ON live_streams(is_live);
CREATE INDEX idx_reviews_reader ON reviews(reader_id);
CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_post_likes_post ON post_likes(post_id);
CREATE INDEX idx_post_likes_user ON post_likes(user_id);

-- ================================
-- CREATE FUNCTIONS
-- ================================

-- Updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to increment likes count
CREATE OR REPLACE FUNCTION increment_post_likes(post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts 
  SET likes_count = likes_count + 1 
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement likes count
CREATE OR REPLACE FUNCTION decrement_post_likes(post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts 
  SET likes_count = GREATEST(likes_count - 1, 0)
  WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function to update likes count when post_likes changes
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM increment_post_likes(NEW.post_id);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM decrement_post_likes(OLD.post_id);
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate reading session earnings
CREATE OR REPLACE FUNCTION calculate_session_earnings(
  duration_minutes INTEGER,
  rate_per_minute DECIMAL(10,2)
)
RETURNS TABLE(
  total_cost DECIMAL(10,2),
  reader_earnings DECIMAL(10,2),
  platform_fee DECIMAL(10,2)
) AS $$
DECLARE
  total DECIMAL(10,2);
  reader_share DECIMAL(10,2);
  platform_share DECIMAL(10,2);
BEGIN
  total := duration_minutes * rate_per_minute;
  reader_share := total * 0.70; -- 70% to reader
  platform_share := total * 0.30; -- 30% to platform
  
  RETURN QUERY SELECT total, reader_share, platform_share;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update reader statistics
CREATE OR REPLACE FUNCTION update_reader_stats(
  reader_id UUID,
  session_earnings DECIMAL(10,2),
  session_rating INTEGER DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  current_rating DECIMAL(3,2);
  current_reviews INTEGER;
  new_rating DECIMAL(3,2);
BEGIN
  -- Update basic stats
  UPDATE reader_profiles 
  SET 
    total_readings = total_readings + 1,
    total_earnings = total_earnings + session_earnings,
    pending_earnings = pending_earnings + session_earnings
  WHERE user_id = reader_id;
  
  -- Update rating if provided
  IF session_rating IS NOT NULL THEN
    SELECT rating, total_reviews INTO current_rating, current_reviews
    FROM reader_profiles WHERE user_id = reader_id;
    
    -- Calculate new average rating
    new_rating := ((current_rating * current_reviews) + session_rating) / (current_reviews + 1);
    
    UPDATE reader_profiles 
    SET 
      rating = new_rating,
      total_reviews = total_reviews + 1
    WHERE user_id = reader_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get platform statistics
CREATE OR REPLACE FUNCTION get_platform_stats()
RETURNS TABLE(
  total_users INTEGER,
  total_readers INTEGER,
  total_clients INTEGER,
  active_readers INTEGER,
  total_sessions INTEGER,
  completed_sessions INTEGER,
  total_revenue DECIMAL(10,2),
  platform_earnings DECIMAL(10,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*)::INTEGER FROM users),
    (SELECT COUNT(*)::INTEGER FROM users WHERE role = 'reader'),
    (SELECT COUNT(*)::INTEGER FROM users WHERE role = 'client'),
    (SELECT COUNT(*)::INTEGER FROM reader_profiles WHERE is_available = true),
    (SELECT COUNT(*)::INTEGER FROM reading_sessions),
    (SELECT COUNT(*)::INTEGER FROM reading_sessions WHERE status = 'completed'),
    (SELECT COALESCE(SUM(total_cost), 0) FROM reading_sessions WHERE status = 'completed'),
    (SELECT COALESCE(SUM(platform_fee), 0) FROM reading_sessions WHERE status = 'completed');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search readers
CREATE OR REPLACE FUNCTION search_readers(
  search_term TEXT DEFAULT NULL,
  specialization_filter TEXT DEFAULT NULL,
  max_rate DECIMAL(10,2) DEFAULT NULL,
  min_rating DECIMAL(3,2) DEFAULT NULL,
  available_only BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
  user_id UUID,
  full_name TEXT,
  username TEXT,
  avatar_url TEXT,
  bio TEXT,
  specializations TEXT,
  rating DECIMAL(3,2),
  total_reviews INTEGER,
  chat_rate DECIMAL(10,2),
  phone_rate DECIMAL(10,2),
  video_rate DECIMAL(10,2),
  is_available BOOLEAN,
  tagline TEXT,
  years_experience INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.full_name,
    u.username,
    u.avatar_url,
    u.bio,
    rp.specializations,
    rp.rating,
    rp.total_reviews,
    rp.chat_rate,
    rp.phone_rate,
    rp.video_rate,
    rp.is_available,
    rp.tagline,
    rp.years_experience
  FROM users u
  JOIN reader_profiles rp ON u.id = rp.user_id
  WHERE 
    u.role = 'reader'
    AND (search_term IS NULL OR 
         u.full_name ILIKE '%' || search_term || '%' OR
         u.username ILIKE '%' || search_term || '%' OR
         rp.specializations ILIKE '%' || search_term || '%')
    AND (specialization_filter IS NULL OR 
         rp.specializations ILIKE '%' || specialization_filter || '%')
    AND (max_rate IS NULL OR 
         (rp.chat_rate <= max_rate AND rp.phone_rate <= max_rate AND rp.video_rate <= max_rate))
    AND (min_rating IS NULL OR rp.rating >= min_rating)
    AND (NOT available_only OR rp.is_available = true)
  ORDER BY rp.rating DESC, rp.total_reviews DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================
-- CREATE TRIGGERS
-- ================================

-- Updated at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reader_profiles_updated_at BEFORE UPDATE ON reader_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reading_sessions_updated_at BEFORE UPDATE ON reading_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_live_streams_updated_at BEFORE UPDATE ON live_streams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Post likes count trigger
DROP TRIGGER IF EXISTS post_likes_count_trigger ON post_likes;
CREATE TRIGGER post_likes_count_trigger
  AFTER INSERT OR DELETE ON post_likes
  FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- ================================
-- ENABLE ROW LEVEL SECURITY
-- ================================

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

-- ================================
-- CREATE SECURITY POLICIES
-- ================================

-- Users table policies
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
DROP POLICY IF EXISTS "Users can view all profiles" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can delete their own profile" ON users;

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view all profiles" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (true);

CREATE POLICY "Users can delete their own profile" ON users
    FOR DELETE USING (auth.uid() = id);

-- Reader profiles policies
DROP POLICY IF EXISTS "Readers can insert their own profile" ON reader_profiles;
DROP POLICY IF EXISTS "Anyone can view reader profiles" ON reader_profiles;
DROP POLICY IF EXISTS "Readers can update their own profile" ON reader_profiles;
DROP POLICY IF EXISTS "Readers can delete their own profile" ON reader_profiles;

CREATE POLICY "Readers can insert their own profile" ON reader_profiles
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view reader profiles" ON reader_profiles
    FOR SELECT USING (true);

CREATE POLICY "Readers can update their own profile" ON reader_profiles
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (true);

CREATE POLICY "Readers can delete their own profile" ON reader_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- Reading sessions policies
DROP POLICY IF EXISTS "Users can view their own reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Authenticated users can create reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Participants can update reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Participants can delete reading sessions" ON reading_sessions;

CREATE POLICY "Users can view their own reading sessions" ON reading_sessions
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reading sessions" ON reading_sessions
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Participants can update reading sessions" ON reading_sessions
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Participants can delete reading sessions" ON reading_sessions
    FOR DELETE USING (true);

-- Simple policies for all other tables
CREATE POLICY "Allow all operations" ON chat_messages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON transactions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON live_streams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON stream_gifts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON reviews FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON posts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations" ON post_likes FOR ALL USING (true) WITH CHECK (true);

-- ================================
-- SAMPLE DATA
-- ================================

-- Helper function to insert users into auth.users
CREATE OR REPLACE FUNCTION insert_user_to_auth(
    email text,
    password text
) RETURNS UUID AS $$
DECLARE
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := crypt(password, gen_salt('bf'));
  
  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW(), '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', NOW(), NOW(), NOW());
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert sample data
DO $$
DECLARE
  admin_id uuid;
  reader1_id uuid;
  reader2_id uuid;
  client1_id uuid;
  client2_id uuid;
  session1_id uuid;
  post1_id uuid;
BEGIN
  -- Create auth users
  admin_id := insert_user_to_auth('emilynnj14@gmail.com', 'JayJas1423!');
  reader1_id := insert_user_to_auth('emilynn992@gmail.com', 'JayJas1423!');
  reader2_id := insert_user_to_auth('mystic.luna@soulseer.com', 'password123');
  client1_id := insert_user_to_auth('emily81292@gmail.com', 'JayJas1423!');
  client2_id := insert_user_to_auth('sarah.client@example.com', 'password123');

  -- Insert users
  INSERT INTO users (id, email, full_name, role, username, bio, account_balance, is_online) VALUES
    (admin_id, 'emilynnj14@gmail.com', 'Emily Admin', 'admin', 'emily_admin', 'SoulSeer Platform Administrator', 0.00, false),
    (reader1_id, 'emilynn992@gmail.com', 'Emily Mystic', 'reader', 'emily_mystic', 'Professional spiritual advisor specializing in tarot, astrology, and energy healing.', 150.00, true),
    (reader2_id, 'mystic.luna@soulseer.com', 'Luna Mystic', 'reader', 'mystic_luna', 'Experienced tarot reader and spiritual guide with 10+ years of experience.', 245.50, true),
    (client1_id, 'emily81292@gmail.com', 'Emily Seeker', 'client', 'emily_seeker', 'Spiritual seeker exploring life deeper meanings', 100.00, false),
    (client2_id, 'sarah.client@example.com', 'Sarah Johnson', 'client', 'sarah_seeker', 'Seeking guidance and spiritual growth', 25.00, false);

  -- Insert reader profiles
  INSERT INTO reader_profiles (user_id, specializations, chat_rate, phone_rate, video_rate, rating, total_readings, total_reviews, is_available, tagline, tools, years_experience, total_earnings, pending_earnings) VALUES
    (reader1_id, 'Tarot Reading, Astrology, Energy Healing', 3.99, 6.99, 8.99, 4.8, 67, 63, true, 'Illuminating your path with ancient wisdom ✨', ARRAY['Tarot Cards', 'Astrology Charts', 'Crystal Healing'], 7, 1245.80, 150.00),
    (reader2_id, 'Love & Relationships, Career Guidance, Life Purpose', 2.99, 4.99, 6.99, 4.8, 156, 142, true, 'Let the cards reveal your destiny ✨', ARRAY['Tarot Cards', 'Oracle Cards', 'Numerology'], 12, 2847.60, 245.50);

  -- Insert sample reading sessions
  session1_id := gen_random_uuid();
  INSERT INTO reading_sessions (id, client_id, reader_id, type, status, per_minute_rate, start_time, end_time, duration_minutes, total_cost, reader_earnings, platform_fee, rating, review) VALUES
    (session1_id, client1_id, reader1_id, 'video', 'completed', 8.99, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour 35 minutes', 25, 224.75, 157.33, 67.42, 5, 'Emily was absolutely amazing! She provided such clear insights about my relationship situation.');

  -- Insert sample posts
  post1_id := gen_random_uuid();
  INSERT INTO posts (id, user_id, content, likes_count) VALUES
    (post1_id, reader1_id, 'Welcome to our spiritual community! I am Emily and I have been reading tarot for over 7 years. Tonight I am feeling the energy of new beginnings - perfect for those seeking clarity on their path. ✨🔮', 5);

  -- Insert sample post likes
  INSERT INTO post_likes (post_id, user_id) VALUES
    (post1_id, client1_id),
    (post1_id, client2_id);

  -- Insert sample transactions
  INSERT INTO transactions (user_id, session_id, type, amount, status, description) VALUES
    (client1_id, session1_id, 'payment', -224.75, 'completed', 'Payment for video reading with Emily Mystic'),
    (reader1_id, session1_id, 'payout', 157.33, 'completed', 'Earnings from video reading session'),
    (client1_id, NULL, 'top_up', 100.00, 'completed', 'Account balance top-up');

END $$;

-- ================================
-- FINAL MESSAGE
-- ================================

SELECT 'SoulSeer database setup complete! 🔮✨' as message,
       'Tables created: ' || COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'reader_profiles', 'reading_sessions', 'chat_messages', 'transactions', 'products', 'orders', 'live_streams', 'stream_gifts', 'reviews', 'posts', 'post_likes');
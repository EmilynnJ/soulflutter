-- Functions for managing post likes and counts

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

-- Create triggers
DROP TRIGGER IF EXISTS post_likes_count_trigger ON post_likes;
CREATE TRIGGER post_likes_count_trigger
  AFTER INSERT OR DELETE ON post_likes
  FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

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

-- Function to update reader statistics after a reading
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

-- Function to process reader payout
CREATE OR REPLACE FUNCTION process_reader_payout(
  reader_id UUID,
  payout_amount DECIMAL(10,2)
)
RETURNS void AS $$
BEGIN
  -- Update reader earnings
  UPDATE reader_profiles 
  SET 
    pending_earnings = pending_earnings - payout_amount,
    total_earnings = total_earnings
  WHERE user_id = reader_id
  AND pending_earnings >= payout_amount;
  
  -- Record transaction
  INSERT INTO transactions (
    user_id,
    type,
    amount,
    status,
    description
  ) VALUES (
    reader_id,
    'payout',
    payout_amount,
    'completed',
    'Reader earnings payout'
  );
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

-- Function to handle user balance updates
CREATE OR REPLACE FUNCTION update_user_balance(
  user_id UUID,
  amount DECIMAL(10,2),
  transaction_type TEXT,
  description TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  -- Update user balance
  UPDATE users 
  SET account_balance = account_balance + amount
  WHERE id = user_id;
  
  -- Record transaction
  INSERT INTO transactions (
    user_id,
    type,
    amount,
    status,
    description
  ) VALUES (
    user_id,
    transaction_type,
    amount,
    'completed',
    COALESCE(description, 'Balance update: ' || transaction_type)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search readers by criteria
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
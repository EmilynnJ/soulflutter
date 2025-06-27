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
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00', '{"provider":"email","providers":["email"]}', '{}', '2023-05-03 19:41:43.580424+00', '2023-05-03 19:41:43.585948+00', '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert comprehensive sample data
DO $$
DECLARE
  admin_id uuid;
  reader1_id uuid;
  reader2_id uuid;
  reader3_id uuid;
  reader4_id uuid;
  reader5_id uuid;
  client1_id uuid;
  client2_id uuid;
  client3_id uuid;
  custom_admin_id uuid;
  custom_reader_id uuid;
  custom_client_id uuid;
  session1_id uuid;
  session2_id uuid;
  session3_id uuid;
  product1_id uuid;
  product2_id uuid;
  product3_id uuid;
  stream1_id uuid;
  stream2_id uuid;
  post1_id uuid;
  post2_id uuid;
  post3_id uuid;
  post4_id uuid;
  post5_id uuid;
BEGIN
  -- Create production user accounts
  custom_admin_id := insert_user_to_auth('emilynnj14@gmail.com', 'JayJas1423!');
  custom_reader_id := insert_user_to_auth('emilynn992@gmail.com', 'JayJas1423!');
  custom_client_id := insert_user_to_auth('emily81292@gmail.com', 'JayJas1423!');
  
  -- Create sample auth users and get their IDs
  admin_id := insert_user_to_auth('admin@soulseer.com', 'admin123');
  reader1_id := insert_user_to_auth('mystic.luna@soulseer.com', 'password123');
  reader2_id := insert_user_to_auth('cosmic.sage@soulseer.com', 'password123');
  reader3_id := insert_user_to_auth('crystal.oracle@soulseer.com', 'password123');
  reader4_id := insert_user_to_auth('starlight.vision@soulseer.com', 'password123');
  reader5_id := insert_user_to_auth('celestial.guide@soulseer.com', 'password123');
  client1_id := insert_user_to_auth('sarah.client@example.com', 'password123');
  client2_id := insert_user_to_auth('michael.seeker@example.com', 'password123');
  client3_id := insert_user_to_auth('jennifer.soul@example.com', 'password123');

  -- Insert users into users table
  INSERT INTO users (id, email, full_name, role, username, bio, account_balance, is_online, created_at) VALUES
    -- Production user accounts
    (custom_admin_id, 'emilynnj14@gmail.com', 'Emily Admin', 'admin', 'emily_admin', 'SoulSeer Platform Administrator', 0.00, false, NOW() - INTERVAL '1 day'),
    (custom_reader_id, 'emilynn992@gmail.com', 'Emily Mystic', 'reader', 'emily_mystic', 'Professional spiritual advisor specializing in tarot, astrology, and energy healing. Bringing clarity and insight to life''s mysteries.', 150.00, true, NOW() - INTERVAL '1 day'),
    (custom_client_id, 'emily81292@gmail.com', 'Emily Seeker', 'client', 'emily_seeker', 'Spiritual seeker exploring life''s deeper meanings', 100.00, false, NOW() - INTERVAL '1 day'),
    
    -- Sample users
    (admin_id, 'admin@soulseer.com', 'SoulSeer Admin', 'admin', 'soulseer_admin', 'Platform administrator for SoulSeer', 0.00, false, NOW() - INTERVAL '30 days'),
    (reader1_id, 'mystic.luna@soulseer.com', 'Luna Mystic', 'reader', 'mystic_luna', 'Experienced tarot reader and spiritual guide with 10+ years of experience. Specializing in love, career, and life guidance.', 245.50, true, NOW() - INTERVAL '15 days'),
    (reader2_id, 'cosmic.sage@soulseer.com', 'Cosmic Sage', 'reader', 'cosmic_sage', 'Psychic medium connecting with spirit guides and passed loved ones. Crystal healing and chakra balancing expert.', 189.25, true, NOW() - INTERVAL '12 days'),
    (reader3_id, 'crystal.oracle@soulseer.com', 'Crystal Oracle', 'reader', 'crystal_oracle', 'Oracle card reader and astrologer. Helping souls find their path through ancient wisdom and celestial guidance.', 156.75, false, NOW() - INTERVAL '8 days'),
    (reader4_id, 'starlight.vision@soulseer.com', 'Starlight Vision', 'reader', 'starlight_vision', 'Intuitive healer and energy reader. Specializing in chakra healing, past life regression, and spiritual awakening.', 298.40, true, NOW() - INTERVAL '20 days'),
    (reader5_id, 'celestial.guide@soulseer.com', 'Celestial Guide', 'reader', 'celestial_guide', 'Master astrologer and numerologist. Providing cosmic insights for life''s journey through planetary alignments.', 167.20, false, NOW() - INTERVAL '6 days'),
    (client1_id, 'sarah.client@example.com', 'Sarah Johnson', 'client', 'sarah_seeker', 'Seeking guidance and spiritual growth', 25.00, false, NOW() - INTERVAL '5 days'),
    (client2_id, 'michael.seeker@example.com', 'Michael Thompson', 'client', 'mike_truth', 'Looking for answers and clarity', 50.00, true, NOW() - INTERVAL '3 days'),
    (client3_id, 'jennifer.soul@example.com', 'Jennifer Martinez', 'client', 'jen_soul', 'On a journey of self-discovery and healing', 75.00, false, NOW() - INTERVAL '2 days');

  -- Insert reader profiles
  INSERT INTO reader_profiles (user_id, specializations, chat_rate, phone_rate, video_rate, rating, total_readings, total_reviews, is_available, tagline, tools, years_experience, total_earnings, pending_earnings, created_at) VALUES
    -- Production reader profile
    (custom_reader_id, 'Tarot Reading, Astrology, Energy Healing', 3.99, 6.99, 8.99, 4.8, 67, 63, true, 'Illuminating your path with ancient wisdom ✨', ARRAY['Tarot Cards', 'Astrology Charts', 'Crystal Healing'], 7, 1245.80, 150.00, NOW() - INTERVAL '1 day'),
    
    -- Sample reader profiles
    (reader1_id, 'Love & Relationships, Career Guidance, Life Purpose', 2.99, 4.99, 6.99, 4.8, 156, 142, true, 'Let the cards reveal your destiny ✨', ARRAY['Tarot Cards', 'Oracle Cards', 'Numerology'], 12, 2847.60, 245.50, NOW() - INTERVAL '15 days'),
    (reader2_id, 'Mediumship, Spirit Communication, Energy Healing', 3.49, 5.49, 7.99, 4.9, 89, 81, true, 'Bridging the worlds between spirit and soul 🔮', ARRAY['Crystals', 'Chakra Healing', 'Spirit Communication'], 8, 1923.45, 189.25, NOW() - INTERVAL '12 days'),
    (reader3_id, 'Astrology, Oracle Reading, Past Life', 2.49, 3.99, 5.99, 4.6, 203, 187, false, 'Ancient wisdom for modern souls 🌙', ARRAY['Oracle Cards', 'Astrology', 'Crystal Ball'], 15, 3102.80, 156.75, NOW() - INTERVAL '8 days'),
    (reader4_id, 'Energy Healing, Chakra Balancing, Past Life Regression', 4.99, 7.99, 9.99, 4.9, 134, 128, true, 'Healing souls through divine energy 🌟', ARRAY['Energy Healing', 'Chakra Stones', 'Meditation'], 10, 4521.35, 298.40, NOW() - INTERVAL '20 days'),
    (reader5_id, 'Astrology, Numerology, Life Path Reading', 3.99, 5.99, 7.49, 4.7, 178, 165, false, 'Your cosmic blueprint awaits discovery 🌌', ARRAY['Birth Charts', 'Numerology', 'Planetary Cards'], 18, 3867.90, 167.20, NOW() - INTERVAL '6 days');

  -- Insert sample reading sessions
  session1_id := gen_random_uuid();
  session2_id := gen_random_uuid();
  session3_id := gen_random_uuid();

  INSERT INTO reading_sessions (id, client_id, reader_id, type, status, per_minute_rate, start_time, end_time, duration_minutes, total_cost, reader_earnings, platform_fee, rating, review, created_at) VALUES
    (session1_id, client1_id, reader1_id, 'video', 'completed', 6.99, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour 35 minutes', 25, 174.75, 122.33, 52.42, 5, 'Luna was absolutely amazing! She provided such clear insights about my relationship situation. Highly recommend!', NOW() - INTERVAL '2 hours'),
    (session2_id, client2_id, reader2_id, 'chat', 'completed', 3.49, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '5 hours 38 minutes', 22, 76.78, 53.75, 23.03, 4, 'Great reading with wonderful spiritual insights. Cosmic Sage really connected with my energy.', NOW() - INTERVAL '6 hours'),
    (session3_id, client3_id, reader4_id, 'phone', 'completed', 7.99, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '3 hours 42 minutes', 18, 143.82, 100.67, 43.15, 5, 'Starlight Vision helped me understand my spiritual blocks. Truly transformative!', NOW() - INTERVAL '4 hours');

  -- Insert chat messages for sessions
  INSERT INTO chat_messages (session_id, sender_id, message, timestamp, is_read) VALUES
    (session1_id, client1_id, 'Hi Luna, I''m really struggling with my relationship and need some guidance', NOW() - INTERVAL '2 hours', true),
    (session1_id, reader1_id, 'Hello Sarah! I can feel your energy and I''m here to help. Let me pull some cards for you...', NOW() - INTERVAL '1 hour 58 minutes', true),
    (session1_id, reader1_id, 'I''m seeing the Two of Cups here, which represents harmony in relationships. There''s definitely love present, but I sense some communication blocks...', NOW() - INTERVAL '1 hour 55 minutes', true),
    (session1_id, client1_id, 'That resonates so much! We have been having trouble talking lately', NOW() - INTERVAL '1 hour 52 minutes', true),
    (session1_id, reader1_id, 'The cards are showing that with patience and open communication, this relationship has beautiful potential. The Ace of Cups suggests new emotional beginnings.', NOW() - INTERVAL '1 hour 50 minutes', true),
    
    (session2_id, client2_id, 'I''ve been feeling disconnected spiritually lately', NOW() - INTERVAL '6 hours', true),
    (session2_id, reader2_id, 'I understand that feeling, Michael. Let me connect with your spirit guides to see what messages they have for you...', NOW() - INTERVAL '5 hours 58 minutes', true),
    (session2_id, reader2_id, 'Your guides are showing me that you''re in a period of spiritual growth. Sometimes we feel disconnected when we''re actually ascending to a higher vibration.', NOW() - INTERVAL '5 hours 55 minutes', true),
    (session2_id, client2_id, 'That makes sense. I have been going through a lot of changes lately', NOW() - INTERVAL '5 hours 52 minutes', true),
    (session2_id, reader2_id, 'Exactly! Your spirit guides want you to know that this is temporary. Trust the process and continue your meditation practice.', NOW() - INTERVAL '5 hours 50 minutes', true);

  -- Insert sample products
  product1_id := gen_random_uuid();
  product2_id := gen_random_uuid();
  product3_id := gen_random_uuid();

  INSERT INTO products (id, reader_id, name, description, price, type, category, is_active, created_at) VALUES
    (product1_id, reader1_id, 'Personalized Love Reading Report', 'Get a detailed written report about your love life and relationship potential. Includes 3-card spread analysis and personalized guidance.', 29.99, 'digital', 'readings', true, NOW() - INTERVAL '10 days'),
    (product2_id, reader2_id, 'Crystal Healing Meditation Audio', 'A 30-minute guided meditation for chakra alignment and crystal healing. Perfect for spiritual cleansing and energy balancing.', 19.99, 'digital', 'healing', true, NOW() - INTERVAL '7 days'),
    (product3_id, reader4_id, 'Past Life Regression Audio Session', 'A powerful guided journey to explore your past lives and understand karmic patterns affecting your current life.', 39.99, 'digital', 'regression', true, NOW() - INTERVAL '5 days');

  -- Insert sample orders
  INSERT INTO orders (client_id, product_id, quantity, total_amount, status, created_at) VALUES
    (client1_id, product1_id, 1, 29.99, 'completed', NOW() - INTERVAL '3 days'),
    (client2_id, product2_id, 1, 19.99, 'completed', NOW() - INTERVAL '1 day'),
    (client3_id, product3_id, 1, 39.99, 'completed', NOW() - INTERVAL '2 days');

  -- Insert sample live streams
  stream1_id := gen_random_uuid();
  stream2_id := gen_random_uuid();

  INSERT INTO live_streams (id, reader_id, title, description, is_live, viewer_count, scheduled_start, created_at) VALUES
    (stream1_id, reader1_id, 'Friday Night Love & Light Reading', 'Join me for general readings and spiritual guidance. Bring your questions about love, career, and life purpose!', false, 23, NOW() + INTERVAL '2 days', NOW() - INTERVAL '1 day'),
    (stream2_id, reader4_id, 'Sunday Healing Circle', 'A group healing session focused on chakra balancing and energy clearing. Open to all spiritual levels.', true, 15, NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '2 hours');

  -- Insert sample stream gifts
  INSERT INTO stream_gifts (stream_id, sender_id, gift_type, gift_value, message, created_at) VALUES
    (stream1_id, client1_id, 'Crystal Heart', 5.99, 'Thank you for the beautiful reading! 💖', NOW() - INTERVAL '12 hours'),
    (stream1_id, client2_id, 'Golden Star', 9.99, 'Your insights are always so helpful!', NOW() - INTERVAL '11 hours'),
    (stream2_id, client3_id, 'Healing Light', 7.99, 'Feeling so much better after this session! ✨', NOW() - INTERVAL '20 minutes');

  -- Insert sample reviews
  INSERT INTO reviews (session_id, client_id, reader_id, rating, review_text, created_at) VALUES
    (session1_id, client1_id, reader1_id, 5, 'Luna was absolutely amazing! She provided such clear insights about my relationship situation. Her tarot reading was spot-on and gave me the clarity I needed. Highly recommend!', NOW() - INTERVAL '1 hour'),
    (session2_id, client2_id, reader2_id, 4, 'Great reading with wonderful spiritual insights. Cosmic Sage really connected with my energy and provided meaningful guidance. Will definitely book again!', NOW() - INTERVAL '30 minutes'),
    (session3_id, client3_id, reader4_id, 5, 'Starlight Vision helped me understand my spiritual blocks and provided amazing healing energy. Truly transformative experience!', NOW() - INTERVAL '2 hours');

  -- Insert sample transactions
  INSERT INTO transactions (user_id, session_id, type, amount, status, description, created_at) VALUES
    -- Session payments
    (client1_id, session1_id, 'payment', -174.75, 'completed', 'Payment for video reading with Luna Mystic', NOW() - INTERVAL '1 hour 35 minutes'),
    (reader1_id, session1_id, 'payout', 122.33, 'completed', 'Earnings from video reading session', NOW() - INTERVAL '1 hour 35 minutes'),
    (client2_id, session2_id, 'payment', -76.78, 'completed', 'Payment for chat reading with Cosmic Sage', NOW() - INTERVAL '5 hours 38 minutes'),
    (reader2_id, session2_id, 'payout', 53.75, 'completed', 'Earnings from chat reading session', NOW() - INTERVAL '5 hours 38 minutes'),
    (client3_id, session3_id, 'payment', -143.82, 'completed', 'Payment for phone reading with Starlight Vision', NOW() - INTERVAL '3 hours 42 minutes'),
    (reader4_id, session3_id, 'payout', 100.67, 'completed', 'Earnings from phone reading session', NOW() - INTERVAL '3 hours 42 minutes'),
    
    -- Product purchases
    (client1_id, NULL, 'payment', -29.99, 'completed', 'Purchase: Personalized Love Reading Report', NOW() - INTERVAL '3 days'),
    (client2_id, NULL, 'payment', -19.99, 'completed', 'Purchase: Crystal Healing Meditation Audio', NOW() - INTERVAL '1 day'),
    (client3_id, NULL, 'payment', -39.99, 'completed', 'Purchase: Past Life Regression Audio Session', NOW() - INTERVAL '2 days'),
    
    -- Account top-ups
    (client1_id, NULL, 'top_up', 50.00, 'completed', 'Account balance top-up', NOW() - INTERVAL '4 days'),
    (client2_id, NULL, 'top_up', 75.00, 'completed', 'Account balance top-up', NOW() - INTERVAL '2 days'),
    (client3_id, NULL, 'top_up', 100.00, 'completed', 'Account balance top-up', NOW() - INTERVAL '3 days'),
    (custom_client_id, NULL, 'top_up', 100.00, 'completed', 'Account balance top-up', NOW() - INTERVAL '1 day'),
    
    -- Reader payouts
    (reader1_id, NULL, 'payout', 200.00, 'completed', 'Weekly earnings payout', NOW() - INTERVAL '3 days'),
    (reader2_id, NULL, 'payout', 150.00, 'completed', 'Weekly earnings payout', NOW() - INTERVAL '3 days'),
    (reader4_id, NULL, 'payout', 250.00, 'completed', 'Weekly earnings payout', NOW() - INTERVAL '3 days');

  -- Insert sample posts for social feed
  post1_id := gen_random_uuid();
  post2_id := gen_random_uuid();
  post3_id := gen_random_uuid();
  post4_id := gen_random_uuid();
  post5_id := gen_random_uuid();

  INSERT INTO posts (id, user_id, content, likes_count, comments_count, created_at) VALUES
    (post1_id, reader1_id, 'Welcome to our spiritual community! I''m Luna and I''ve been reading tarot for over 12 years. Tonight I''m feeling the energy of new beginnings - perfect for those seeking clarity on their path. ✨🔮', 15, 3, NOW() - INTERVAL '2 days'),
    (post2_id, reader2_id, 'Just finished an amazing session with a client who was looking for guidance about their twin flame connection. The spirits were so clear today! Remember, the universe always has a plan. 💫', 8, 2, NOW() - INTERVAL '1 day'),
    (post3_id, custom_reader_id, 'Mercury retrograde is ending soon! This is a wonderful time to reflect on the lessons learned and prepare for forward movement. What insights have you gained during this introspective period? 🌙', 12, 5, NOW() - INTERVAL '8 hours'),
    (post4_id, reader3_id, 'Full moon energy is building! Perfect time for manifestation and releasing what no longer serves you. I''ll be doing a special oracle reading tonight for anyone who needs guidance. 🌕✨', 22, 7, NOW() - INTERVAL '3 hours'),
    (post5_id, client1_id, 'Had the most incredible reading with Luna yesterday! She picked up on things she couldn''t possibly have known. So grateful for this platform connecting us with such gifted souls. 💖', 6, 1, NOW() - INTERVAL '1 hour');

  -- Insert sample post likes
  INSERT INTO post_likes (post_id, user_id, created_at) VALUES
    (post1_id, client1_id, NOW() - INTERVAL '1 day'),
    (post1_id, client2_id, NOW() - INTERVAL '1 day'),
    (post1_id, client3_id, NOW() - INTERVAL '1 day'),
    (post1_id, custom_client_id, NOW() - INTERVAL '1 day'),
    (post1_id, reader2_id, NOW() - INTERVAL '1 day'),
    (post1_id, reader4_id, NOW() - INTERVAL '18 hours'),
    
    (post2_id, client1_id, NOW() - INTERVAL '12 hours'),
    (post2_id, client3_id, NOW() - INTERVAL '12 hours'),
    
    (post3_id, client2_id, NOW() - INTERVAL '6 hours'),
    (post3_id, reader1_id, NOW() - INTERVAL '6 hours'),
    (post3_id, client1_id, NOW() - INTERVAL '5 hours'),
    (post3_id, client3_id, NOW() - INTERVAL '4 hours'),
    
    (post4_id, client1_id, NOW() - INTERVAL '2 hours'),
    (post4_id, client2_id, NOW() - INTERVAL '2 hours'),
    (post4_id, client3_id, NOW() - INTERVAL '2 hours'),
    (post4_id, custom_client_id, NOW() - INTERVAL '2 hours'),
    (post4_id, reader1_id, NOW() - INTERVAL '1 hour'),
    (post4_id, reader2_id, NOW() - INTERVAL '1 hour'),
    
    (post5_id, reader1_id, NOW() - INTERVAL '30 minutes'),
    (post5_id, custom_reader_id, NOW() - INTERVAL '25 minutes');

END $$;
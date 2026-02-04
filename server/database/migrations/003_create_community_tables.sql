-- Migration 003: Create Community and Social Features Tables
-- PostgreSQL + Supabase

-- ============================================
-- TABLE: community_posts
-- ============================================

CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID REFERENCES gyms(id) ON DELETE SET NULL,
    post_type post_type_enum NOT NULL,
    content TEXT,
    image_url TEXT,
    likes_count INT DEFAULT 0 CHECK (likes_count >= 0),
    comments_count INT DEFAULT 0 CHECK (comments_count >= 0),
    shares_count INT DEFAULT 0 CHECK (shares_count >= 0),
    is_vendor_post BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for community_posts
CREATE INDEX idx_posts_author ON community_posts(author_id);
CREATE INDEX idx_posts_gym ON community_posts(gym_id);
CREATE INDEX idx_posts_created ON community_posts(created_at DESC);
CREATE INDEX idx_posts_type ON community_posts(post_type);

-- ============================================
-- TABLE: community_events
-- ============================================

CREATE TABLE community_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID UNIQUE NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    event_name VARCHAR(255) NOT NULL,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(255) NOT NULL,
    ticket_price DECIMAL(10,2) DEFAULT 0.0 CHECK (ticket_price >= 0),
    banner_image_url TEXT,
    description TEXT,
    max_attendees INT,
    current_attendees INT DEFAULT 0 CHECK (current_attendees >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_event_attendees CHECK (max_attendees IS NULL OR current_attendees <= max_attendees)
);

-- Index for community_events
CREATE INDEX idx_events_date ON community_events(event_date);
CREATE INDEX idx_events_post ON community_events(post_id);

-- ============================================
-- TABLE: post_likes
-- ============================================

CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_post_like UNIQUE(post_id, user_id)
);

-- Indexes for post_likes
CREATE INDEX idx_post_likes_post ON post_likes(post_id);
CREATE INDEX idx_post_likes_user ON post_likes(user_id);

-- ============================================
-- TABLE: post_comments
-- ============================================

CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    likes_count INT DEFAULT 0 CHECK (likes_count >= 0),
    replies_count INT DEFAULT 0 CHECK (replies_count >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for post_comments
CREATE INDEX idx_post_comments_post ON post_comments(post_id);
CREATE INDEX idx_post_comments_user ON post_comments(user_id);
CREATE INDEX idx_post_comments_parent ON post_comments(parent_comment_id);
CREATE INDEX idx_post_comments_created ON post_comments(created_at DESC);

-- ============================================
-- TABLE: comment_likes
-- ============================================

CREATE TABLE comment_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID NOT NULL REFERENCES post_comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_comment_like UNIQUE(comment_id, user_id)
);

-- Indexes for comment_likes
CREATE INDEX idx_comment_likes_comment ON comment_likes(comment_id);
CREATE INDEX idx_comment_likes_user ON comment_likes(user_id);

-- ============================================
-- TABLE: saved_gyms
-- ============================================

CREATE TABLE saved_gyms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_saved_gym UNIQUE(user_id, gym_id)
);

-- Indexes for saved_gyms
CREATE INDEX idx_saved_gyms_user ON saved_gyms(user_id);
CREATE INDEX idx_saved_gyms_gym ON saved_gyms(gym_id);

-- ============================================
-- TABLE: reviews
-- ============================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for reviews
CREATE INDEX idx_reviews_gym ON reviews(gym_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- ============================================
-- TABLE: notifications
-- ============================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type notification_type_enum NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- ============================================
-- Triggers for auto-updating updated_at
-- ============================================

CREATE TRIGGER update_community_posts_updated_at BEFORE UPDATE ON community_posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Function to auto-update post likes count
-- ============================================

CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE community_posts 
        SET likes_count = likes_count + 1
        WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE community_posts 
        SET likes_count = GREATEST(0, likes_count - 1)
        WHERE id = OLD.post_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to post_likes table
CREATE TRIGGER trigger_update_post_likes_count
    AFTER INSERT OR DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- ============================================
-- Function to auto-update post comments count
-- ============================================

CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Only count top-level comments (not replies)
        IF NEW.parent_comment_id IS NULL THEN
            UPDATE community_posts 
            SET comments_count = comments_count + 1
            WHERE id = NEW.post_id;
        ELSE
            -- Update parent comment's replies count
            UPDATE post_comments
            SET replies_count = replies_count + 1
            WHERE id = NEW.parent_comment_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        -- Only count top-level comments (not replies)
        IF OLD.parent_comment_id IS NULL THEN
            UPDATE community_posts 
            SET comments_count = GREATEST(0, comments_count - 1)
            WHERE id = OLD.post_id;
        ELSE
            -- Update parent comment's replies count
            UPDATE post_comments
            SET replies_count = GREATEST(0, replies_count - 1)
            WHERE id = OLD.parent_comment_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to post_comments table
CREATE TRIGGER trigger_update_post_comments_count
    AFTER INSERT OR DELETE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();

-- ============================================
-- Function to auto-update comment likes count
-- ============================================

CREATE OR REPLACE FUNCTION update_comment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE post_comments 
        SET likes_count = likes_count + 1
        WHERE id = NEW.comment_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE post_comments 
        SET likes_count = GREATEST(0, likes_count - 1)
        WHERE id = OLD.comment_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to comment_likes table
CREATE TRIGGER trigger_update_comment_likes_count
    AFTER INSERT OR DELETE ON comment_likes
    FOR EACH ROW EXECUTE FUNCTION update_comment_likes_count();

-- ============================================
-- Function to auto-update gym rating
-- ============================================

CREATE OR REPLACE FUNCTION update_gym_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL(3,2);
    review_count INT;
BEGIN
    -- Calculate new average rating and count
    SELECT 
        COALESCE(AVG(rating), 0.0),
        COUNT(*)
    INTO avg_rating, review_count
    FROM reviews
    WHERE gym_id = COALESCE(NEW.gym_id, OLD.gym_id);
    
    -- Update gym with new rating and count
    UPDATE gyms
    SET 
        rating = avg_rating,
        total_reviews = review_count
    WHERE id = COALESCE(NEW.gym_id, OLD.gym_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to reviews table
CREATE TRIGGER trigger_update_gym_rating
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_gym_rating();

-- ============================================
-- Comments for documentation
-- ============================================

COMMENT ON TABLE community_posts IS 'Community feed posts (text, image, motivation, events)';
COMMENT ON TABLE community_events IS 'Event-specific details for event posts';
COMMENT ON TABLE post_likes IS 'Likes on community posts';
COMMENT ON TABLE post_comments IS 'Comments on community posts with nested reply support';
COMMENT ON TABLE comment_likes IS 'Likes on comments';
COMMENT ON TABLE saved_gyms IS 'Customer saved/favorite gyms';
COMMENT ON TABLE reviews IS 'Customer reviews for gyms';
COMMENT ON TABLE notifications IS 'User notifications';

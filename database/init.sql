-- PointPath Database Schema
-- Week 2: Core data model

-- ============================================
-- CORE REFERENCE DATA
-- ============================================

CREATE TABLE IF NOT EXISTS airports (
    code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    timezone VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    popular BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS airlines (
    code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    alliance VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- LOYALTY PROGRAMS
-- ============================================

CREATE TABLE IF NOT EXISTS credit_card_programs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    short_name VARCHAR(20) NOT NULL,
    portal_value DECIMAL(4, 2) DEFAULT 1.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transfer_partners (
    id SERIAL PRIMARY KEY,
    program_id INTEGER REFERENCES credit_card_programs(id),
    partner_name VARCHAR(100) NOT NULL,
    partner_type VARCHAR(20) NOT NULL,
    transfer_ratio VARCHAR(10) DEFAULT '1:1',
    transfer_time VARCHAR(50),
    minimum_transfer INTEGER DEFAULT 1000,
    transfer_increment INTEGER DEFAULT 1000,
    is_reversible BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(program_id, partner_name)
);

-- ============================================
-- AWARD CHARTS
-- ============================================

CREATE TABLE IF NOT EXISTS award_charts (
    id SERIAL PRIMARY KEY,
    partner_id INTEGER REFERENCES transfer_partners(id),
    origin_region VARCHAR(50),
    destination_region VARCHAR(50),
    cabin_class VARCHAR(20) NOT NULL,
    miles_required INTEGER NOT NULL,
    chart_type VARCHAR(20) DEFAULT 'saver',
    valid_from DATE,
    valid_until DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SEARCH CACHE
-- ============================================

CREATE TABLE IF NOT EXISTS search_cache (
    id SERIAL PRIMARY KEY,
    origin_code VARCHAR(3) REFERENCES airports(code),
    destination_code VARCHAR(3) REFERENCES airports(code),
    departure_date DATE NOT NULL,
    cabin_class VARCHAR(20) NOT NULL,
    partner_id INTEGER REFERENCES transfer_partners(id),
    miles_required INTEGER,
    cash_fees DECIMAL(10, 2),
    available_seats INTEGER,
    flight_details JSONB,
    cash_price DECIMAL(10, 2),
    cpp_value DECIMAL(5, 2),
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_search_lookup ON search_cache(origin_code, destination_code, departure_date, cabin_class);
CREATE INDEX IF NOT EXISTS idx_expires ON search_cache(expires_at);

-- ============================================
-- POPULAR ROUTES
-- ============================================

CREATE TABLE IF NOT EXISTS popular_routes (
    id SERIAL PRIMARY KEY,
    origin_code VARCHAR(3) REFERENCES airports(code),
    destination_code VARCHAR(3) REFERENCES airports(code),
    search_count INTEGER DEFAULT 1,
    last_searched TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(origin_code, destination_code)
);

-- ============================================
-- SEED DATA
-- ============================================

INSERT INTO airports (code, name, city, country, popular) VALUES
('JFK', 'John F. Kennedy International Airport', 'New York', 'USA', TRUE),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA', TRUE),
('SFO', 'San Francisco International Airport', 'San Francisco', 'USA', TRUE),
('ORD', 'O''Hare International Airport', 'Chicago', 'USA', TRUE),
('SEA', 'Seattle-Tacoma International Airport', 'Seattle', 'USA', TRUE),
('LHR', 'London Heathrow Airport', 'London', 'UK', TRUE),
('CDG', 'Charles de Gaulle Airport', 'Paris', 'France', TRUE),
('NRT', 'Narita International Airport', 'Tokyo', 'Japan', TRUE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO airlines (code, name, alliance) VALUES
('UA', 'United Airlines', 'Star Alliance'),
('AA', 'American Airlines', 'OneWorld'),
('DL', 'Delta Air Lines', 'SkyTeam'),
('WN', 'Southwest Airlines', 'None')
ON CONFLICT (code) DO NOTHING;

INSERT INTO credit_card_programs (name, short_name, portal_value) VALUES
('Chase Ultimate Rewards', 'Chase UR', 1.50)
ON CONFLICT (name) DO NOTHING;

INSERT INTO transfer_partners (program_id, partner_name, partner_type, transfer_ratio, transfer_time)
SELECT id, 'United MileagePlus', 'airline', '1:1', 'Instant'
FROM credit_card_programs WHERE short_name = 'Chase UR'
ON CONFLICT (program_id, partner_name) DO NOTHING;

INSERT INTO award_charts (partner_id, origin_region, destination_region, cabin_class, miles_required, chart_type)
SELECT id, 'North America', 'North America', 'economy', 12500, 'saver'
FROM transfer_partners WHERE partner_name = 'United MileagePlus'
ON CONFLICT DO NOTHING;
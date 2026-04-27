-- Initial database schema
-- Will be expanded in Week 2

CREATE TABLE IF NOT EXISTS airports (
    code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS loyalty_programs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    transfer_partner VARCHAR(100) NOT NULL,
    transfer_ratio VARCHAR(10) DEFAULT '1:1',
    transfer_time VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data
INSERT INTO airports (code, name, city, country) VALUES
('JFK', 'John F. Kennedy International Airport', 'New York', 'USA'),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA'),
('SFO', 'San Francisco International Airport', 'San Francisco', 'USA'),
('ORD', 'O''Hare International Airport', 'Chicago', 'USA');

INSERT INTO loyalty_programs (name, transfer_partner, transfer_ratio, transfer_time) VALUES
('Chase Ultimate Rewards', 'United MileagePlus', '1:1', 'Instant'),
('Chase Ultimate Rewards', 'Southwest Rapid Rewards', '1:1', 'Instant'),
('Chase Ultimate Rewards', 'Air France Flying Blue', '1:1', 'Instant');
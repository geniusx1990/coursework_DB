CREATE DATABASE arts_analytics;

-- I Measurement Tables 
-- 1. DimDate
CREATE TABLE DimDate (
    DateKey DATE PRIMARY KEY,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    Week INT,
    DayName VARCHAR(10),
    IsWeekend BOOLEAN
);

-- 2. DimArtist (SCD Type 2)
CREATE TABLE DimArtist (
    ArtistKey SERIAL PRIMARY KEY,
    ArtistID INT,
    FullName VARCHAR(100),
    Country VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    IsCurrent BOOLEAN
);

-- 3. DimCategory
CREATE TABLE DimCategory (
    CategoryKey SERIAL PRIMARY KEY,
    CategoryName VARCHAR(50),
    Description TEXT
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('Customer', 'Admin');
    END IF;
END $$;

-- 4. DimCustomer
CREATE TABLE DimCustomer (
    CustomerKey SERIAL PRIMARY KEY,
    UserID INT,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    Role user_role
);

-- II. Actual Tables
-- 1. Sales Fact
CREATE TABLE FactSales (
    SaleKey SERIAL PRIMARY KEY,
    DateKey DATE,
    ArtistKey INT,
    CategoryKey INT,
    CustomerKey INT,
    ArtworkID INT,
    Quantity INT,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ArtistKey) REFERENCES DimArtist(ArtistKey),
    FOREIGN KEY (CategoryKey) REFERENCES DimCategory(CategoryKey),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey)
);

-- 2. Payments Fact
CREATE TABLE FactPayments (
    PaymentKey SERIAL PRIMARY KEY,
    DateKey DATE,
    CustomerKey INT,
    PaymentMethod VARCHAR(50),
    Amount DECIMAL(10, 2),
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey)
);
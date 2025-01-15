CREATE DATABASE ARTS; 
-- Design and develop all needed DB objects to support functionality of your Application
-- 1.1 Develop OLTP solution
DO $$ 
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
            CREATE TYPE user_role AS ENUM ('Customer', 'Admin');
        END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE payment_status AS ENUM ('Pending', 'Completed', 'Failed');
        END IF;

	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'shipping_status') THEN
        CREATE TYPE shipping_status AS ENUM ('Pending', 'Shipped', 'Delivered', 'Cancelled');
        END IF;

	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_method') THEN
        CREATE TYPE payment_method AS ENUM ('Credit Card', 'PayPal', 'Bank Transfer');
        END IF;
    END $$;

CREATE TABLE IF NOT EXISTS Users (
    UserID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(15),
    Role user_role,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Artists (
    ArtistID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Bio TEXT,
    BirthDate DATE,
    DeathDate DATE,
    Country VARCHAR(50)
);

CREATE TABLE Categories (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT
);


CREATE TABLE Artworks (
    ArtworkID SERIAL PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    ArtistID INTEGER NOT NULL,
    CategoryID INTEGER NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    IsOriginal BOOLEAN DEFAULT FALSE,
    StockQuantity INTEGER DEFAULT 0,
    Description TEXT,
    ImageURL VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    UserID INTEGER NOT NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    PaymentStatus payment_status,
    ShippingStatus shipping_status,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE OrderItems (
    OrderItemID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL,
    ArtworkID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ArtworkID) REFERENCES Artworks(ArtworkID)
);

CREATE TABLE Payments (
    PaymentID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL,
    PaymentMethod payment_method NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Shipping (
    ShippingID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL,
    AddressLine1 VARCHAR(255) NOT NULL,
    AddressLine2 VARCHAR(255),
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50),
    PostalCode VARCHAR(20) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    ShippedDate TIMESTAMP,
    DeliveryDate TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
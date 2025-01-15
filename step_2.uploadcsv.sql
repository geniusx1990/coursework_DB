
-- 1.3 Prepare script to load data from CSV to your OLTP database

-- insert data from Users.csv
CREATE TEMP TABLE tmp_Users (
    UserID INTEGER,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    PasswordHash VARCHAR(255),
    PhoneNumber VARCHAR(15),
    Role user_role,
    CreatedAt TIMESTAMP
);

\COPY tmp_Users (UserID, FullName, Email, PasswordHash, PhoneNumber, Role, CreatedAt)
FROM '~/Downloads/data/Users.csv' WITH CSV HEADER;

INSERT INTO Users (FullName, Email, PasswordHash, PhoneNumber, Role, CreatedAt)
SELECT FullName, Email, PasswordHash, PhoneNumber, Role, CreatedAt
FROM tmp_Users
ON CONFLICT (Email) DO UPDATE
SET 
    FullName = EXCLUDED.FullName,
    PasswordHash = EXCLUDED.PasswordHash,
    PhoneNumber = EXCLUDED.PhoneNumber,
    Role = EXCLUDED.Role,
    CreatedAt = EXCLUDED.CreatedAt
WHERE 
    Users.FullName IS DISTINCT FROM EXCLUDED.FullName
    OR Users.PasswordHash IS DISTINCT FROM EXCLUDED.PasswordHash
    OR Users.PhoneNumber IS DISTINCT FROM EXCLUDED.PhoneNumber
    OR Users.Role IS DISTINCT FROM EXCLUDED.Role
    OR Users.CreatedAt IS DISTINCT FROM EXCLUDED.CreatedAt;

DROP TABLE tmp_Users;


-- insert data from Artists.csv

CREATE TEMP TABLE tmp_Artists (
    ArtistID INTEGER,
    FullName VARCHAR(100),
    Bio TEXT,
    BirthDate DATE,
    DeathDate DATE,
    Country VARCHAR(50)
);

\COPY tmp_Artists (ArtistID, FullName, Bio, BirthDate, DeathDate, Country)
FROM '~/Downloads/data/Artists.csv' WITH CSV HEADER;

INSERT INTO Artists (FullName, Bio, BirthDate, DeathDate, Country)
SELECT t.FullName, t.Bio, t.BirthDate, t.DeathDate, t.Country
FROM tmp_Artists t
LEFT JOIN Artists a
ON t.FullName = a.FullName AND t.BirthDate = a.BirthDate AND t.Country = a.Country
WHERE a.ArtistID IS NULL;

DROP TABLE tmp_Artists;

-- insert data from Categories.csv

CREATE TEMP TABLE tmp_Categories (
    CategoryID INTEGER,
    CategoryName VARCHAR(50),
    Description TEXT
);

\COPY tmp_Categories (CategoryID, CategoryName, Description)
FROM '~/Downloads/data/Categories.csv' WITH CSV HEADER;

INSERT INTO Categories (CategoryName, Description)
SELECT t.CategoryName, t.Description
FROM tmp_Categories t
LEFT JOIN Categories c
ON t.CategoryName = c.CategoryName
WHERE c.CategoryID IS NULL;

DROP TABLE tmp_Categories;


-- insert data from Artworks.csv

CREATE TEMP TABLE tmp_Artworks (
    ArtworkID INTEGER,
    Title VARCHAR(100),
    ArtistID INTEGER,
    CategoryID INTEGER,
    Price DECIMAL(10, 2),
    IsOriginal BOOLEAN,
    StockQuantity INTEGER,
    Description TEXT,
    ImageURL VARCHAR(255),
    CreatedAt TIMESTAMP
);

\COPY tmp_Artworks (ArtworkID, Title, ArtistID, CategoryID, Price, IsOriginal, StockQuantity, Description, ImageURL, CreatedAt)
FROM '~/Downloads/data/Artworks.csv' WITH CSV HEADER;

INSERT INTO Artworks (Title, ArtistID, CategoryID, Price, IsOriginal, StockQuantity, Description, ImageURL, CreatedAt)
SELECT t.Title, t.ArtistID, t.CategoryID, t.Price, t.IsOriginal, t.StockQuantity, t.Description, t.ImageURL, t.CreatedAt
FROM tmp_Artworks t
LEFT JOIN Artworks a
ON t.Title = a.Title AND t.ArtistID = a.ArtistID
WHERE a.ArtworkID IS NULL;

DROP TABLE tmp_Artworks;

-- insert data from Orders.csv

CREATE TEMP TABLE tmp_Orders (
    OrderID INTEGER,
    UserID INTEGER,
    OrderDate TIMESTAMP,
    TotalAmount DECIMAL(10, 2),
    PaymentStatus payment_status,
    ShippingStatus shipping_status
);

\COPY tmp_Orders (OrderID, UserID, OrderDate, TotalAmount, PaymentStatus, ShippingStatus)
FROM '~/Downloads/data/Orders.csv' WITH CSV HEADER;

INSERT INTO Orders (UserID, OrderDate, TotalAmount, PaymentStatus, ShippingStatus)
SELECT t.UserID, t.OrderDate, t.TotalAmount, t.PaymentStatus, t.ShippingStatus
FROM tmp_Orders t
LEFT JOIN Orders o
ON t.UserID = o.UserID AND t.OrderDate = o.OrderDate
WHERE o.OrderID IS NULL;

DROP TABLE tmp_Orders;


-- insert data from OrderItems.csv

CREATE TEMP TABLE tmp_OrderItems (
    OrderItemID INTEGER,
    OrderID INTEGER,
    ArtworkID INTEGER,
    Quantity INTEGER,
    Price DECIMAL(10, 2)
);

\COPY tmp_OrderItems (OrderItemID, OrderID, ArtworkID, Quantity, Price)
FROM '~/Downloads/data/OrderItems.csv' WITH CSV HEADER;

INSERT INTO OrderItems (OrderID, ArtworkID, Quantity, Price)
SELECT t.OrderID, t.ArtworkID, t.Quantity, t.Price
FROM tmp_OrderItems t
LEFT JOIN OrderItems o
ON t.OrderID = o.OrderID AND t.ArtworkID = o.ArtworkID
WHERE o.OrderItemID IS NULL;

DROP TABLE tmp_OrderItems;


-- insert data from Payments.csv

CREATE TEMP TABLE tmp_Payments (
    PaymentID INTEGER,
    OrderID INTEGER,
    PaymentMethod payment_method,
    Amount DECIMAL(10, 2),
    PaymentDate TIMESTAMP
);

\COPY tmp_Payments (PaymentID, OrderID, PaymentMethod, Amount, PaymentDate)
FROM '~/Downloads/data/Payments.csv' WITH CSV HEADER;

INSERT INTO Payments (OrderID, PaymentMethod, Amount, PaymentDate)
SELECT t.OrderID, t.PaymentMethod, t.Amount, t.PaymentDate
FROM tmp_Payments t
LEFT JOIN Payments p
ON t.OrderID = p.OrderID AND t.PaymentDate = p.PaymentDate
WHERE p.PaymentID IS NULL;

DROP TABLE tmp_Payments;

-- insert data from Shipping.csv

CREATE TEMP TABLE tmp_Shipping (
    ShippingID INTEGER,
    OrderID INTEGER,
    AddressLine1 VARCHAR(255),
    AddressLine2 VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50),
    ShippedDate TIMESTAMP,
    DeliveryDate TIMESTAMP
);

\COPY tmp_Shipping (ShippingID, OrderID, AddressLine1, AddressLine2, City, State, PostalCode, Country, ShippedDate, DeliveryDate)
FROM '~/Downloads/data/Shipping.csv' WITH CSV HEADER;

INSERT INTO Shipping (OrderID, AddressLine1, AddressLine2, City, State, PostalCode, Country, ShippedDate, DeliveryDate)
SELECT t.OrderID, t.AddressLine1, t.AddressLine2, t.City, t.State, t.PostalCode, t.Country, t.ShippedDate, t.DeliveryDate
FROM tmp_Shipping t
LEFT JOIN Shipping s
ON t.OrderID = s.OrderID AND t.AddressLine1 = s.AddressLine1
WHERE s.ShippingID IS NULL;

DROP TABLE tmp_Shipping;

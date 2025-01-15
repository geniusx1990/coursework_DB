
CREATE EXTENSION dblink;

-- Data transfer from OLTP to OLAP
-- 1. DimDate
INSERT INTO DimDate (DateKey, Year, Quarter, Month, Day, Week, DayName, IsWeekend)
SELECT *
FROM dblink('dbname=arts user=may',
            'SELECT DISTINCT OrderDate,
                    EXTRACT(YEAR FROM OrderDate),
                    EXTRACT(QUARTER FROM OrderDate),
                    EXTRACT(MONTH FROM OrderDate),
                    EXTRACT(DAY FROM OrderDate),
                    EXTRACT(WEEK FROM OrderDate),
                    TO_CHAR(OrderDate, ''Day''),
                    CASE WHEN EXTRACT(DOW FROM OrderDate) IN (0, 6) THEN TRUE ELSE FALSE END
             FROM Orders')
AS t(DateKey DATE, Year INT, Quarter INT, Month INT, Day INT, Week INT, DayName VARCHAR(10), IsWeekend BOOLEAN)
ON CONFLICT (DateKey) DO NOTHING;


-- 2. DimArtist (SCD Type 2)
INSERT INTO DimArtist (ArtistID, FullName, Country, StartDate, EndDate, IsCurrent)
SELECT DISTINCT *
FROM dblink('dbname=arts user=may',
            'SELECT ArtistID,
                    FullName,
                    Country,
                    CURRENT_DATE AS StartDate,
                    NULL::DATE AS EndDate,
                    TRUE AS IsCurrent
             FROM Artists')
AS t(ArtistID INT, FullName VARCHAR(100), Country VARCHAR(50), StartDate DATE, EndDate DATE, IsCurrent BOOLEAN)
WHERE NOT EXISTS (
    SELECT 1 FROM DimArtist da
    WHERE da.ArtistID = t.ArtistID AND da.IsCurrent = TRUE
);

-- 3. DimCategory
INSERT INTO DimCategory (CategoryName, Description)
SELECT *
FROM dblink('dbname=arts user=may',
            'SELECT DISTINCT CategoryName, Description FROM Categories')
AS t(CategoryName VARCHAR(50), Description TEXT)
WHERE NOT EXISTS (
    SELECT 1
    FROM DimCategory dc
    WHERE dc.CategoryName = t.CategoryName
);


-- 4. DimCustomer
INSERT INTO DimCustomer (UserID, FullName, Email, Role)
SELECT *
FROM dblink('dbname=arts user=may',
            'SELECT UserID, FullName, Email, Role FROM Users')
AS t(UserID INT, FullName VARCHAR(100), Email VARCHAR(100), Role user_role)
WHERE NOT EXISTS (
    SELECT 1
    FROM DimCustomer dc
    WHERE dc.UserID = t.UserID
);

-- 5. FactSales
INSERT INTO FactSales (DateKey, ArtistKey, CategoryKey, CustomerKey, ArtworkID, Quantity, TotalAmount)
SELECT 
    t.DateKey,
    da.ArtistKey,
    dc.CategoryKey,
    dcu.CustomerKey,
    t.ArtworkID,
    t.Quantity,
    t.TotalAmount
FROM dblink('dbname=arts user=may',
            'SELECT o.OrderDate AS DateKey,
                    a.ArtistID,
                    c.CategoryName,
                    u.UserID,
                    oi.ArtworkID,
                    oi.Quantity,
                    oi.Price * oi.Quantity AS TotalAmount
             FROM Orders o
             JOIN OrderItems oi ON o.OrderID = oi.OrderID
             JOIN Artworks aw ON oi.ArtworkID = aw.ArtworkID
             JOIN Artists a ON aw.ArtistID = a.ArtistID
             JOIN Categories c ON aw.CategoryID = c.CategoryID
             JOIN Users u ON o.UserID = u.UserID')
AS t(DateKey DATE, ArtistID INT, CategoryName VARCHAR(50), UserID INT, ArtworkID INT, Quantity INT, TotalAmount DECIMAL(10, 2))
JOIN DimArtist da ON t.ArtistID = da.ArtistID AND da.IsCurrent = TRUE
JOIN DimCategory dc ON t.CategoryName = dc.CategoryName
JOIN DimCustomer dcu ON t.UserID = dcu.UserID
WHERE NOT EXISTS (
    SELECT 1
    FROM FactSales fs
    WHERE fs.DateKey = t.DateKey
      AND fs.ArtistKey = da.ArtistKey
      AND fs.CategoryKey = dc.CategoryKey
      AND fs.CustomerKey = dcu.CustomerKey
      AND fs.ArtworkID = t.ArtworkID
);


-- 6. FactPayments
INSERT INTO FactPayments (DateKey, CustomerKey, PaymentMethod, Amount)
SELECT 
    t.DateKey,
    dcu.CustomerKey,
    t.PaymentMethod,
    t.Amount
FROM dblink('dbname=arts user=may',
            'SELECT p.PaymentDate AS DateKey, 
                    o.UserID, 
                    p.PaymentMethod, 
                    p.Amount
             FROM Payments p
             JOIN Orders o ON p.OrderID = o.OrderID')
AS t(DateKey DATE, UserID INT, PaymentMethod VARCHAR(50), Amount DECIMAL(10, 2))
JOIN DimCustomer dcu ON t.UserID = dcu.UserID
WHERE NOT EXISTS (
    SELECT 1
    FROM FactPayments fp
    WHERE fp.DateKey = t.DateKey
      AND fp.CustomerKey = dcu.CustomerKey
      AND fp.PaymentMethod = t.PaymentMethod
      AND fp.Amount = t.Amount
);
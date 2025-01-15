-- OLTP QUERIES
-- Top-selling artworks
SELECT 
    aw.Title AS ArtworkTitle,
    ar.FullName AS ArtistName,
    SUM(oi.Quantity) AS TotalSold,
    SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM 
    OrderItems oi
JOIN 
    Artworks aw ON oi.ArtworkID = aw.ArtworkID
JOIN 
    Artists ar ON aw.ArtistID = ar.ArtistID
GROUP BY 
    aw.Title, ar.FullName
ORDER BY 
    TotalSold DESC
LIMIT 5;


-- history of client orders
SELECT 
    u.FullName AS CustomerName,
    u.Email,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.PaymentStatus,
    o.ShippingStatus
FROM 
    Users u
JOIN 
    Orders o ON u.UserID = o.UserID
WHERE 
    u.Email = 'john.doe@example.com'
ORDER BY 
    o.OrderDate DESC;


-- Top users by total order amount
SELECT 
    u.FullName AS UserName,
    u.Email AS UserEmail,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent
FROM 
    Users u
JOIN 
    Orders o ON u.UserID = o.UserID
GROUP BY 
    u.FullName, u.Email
ORDER BY 
    TotalSpent DESC
LIMIT 5;


-- OLAP QUERIES
-- Sales Analysis by Categories
SELECT 
    dc.CategoryName,
    SUM(fs.TotalAmount) AS TotalSales
FROM 
    FactSales fs
JOIN 
    DimCategory dc ON fs.CategoryKey = dc.CategoryKey
GROUP BY 
    dc.CategoryName
ORDER BY 
    TotalSales DESC;


-- Top Artists by Sales
SELECT 
    da.FullName AS ArtistName,
    SUM(fs.TotalAmount) AS TotalSales
FROM 
    FactSales fs
JOIN 
    DimArtist da ON fs.ArtistKey = da.ArtistKey
GROUP BY 
    da.FullName
ORDER BY 
    TotalSales DESC
LIMIT 5;

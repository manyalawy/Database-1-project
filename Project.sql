CREATE DATABASE Project

CREATE TABLE Users
(
Username VARCHAR(20) PRIMARY KEY,
Passowrd VARCHAR(20) NOT NULL,
First_Name VARCHAR(20) NOT NULL,
Last_Name VARCHAR(20) NOT NULL,
Email VARCHAR(60)
);

CREATE TABLE User_Mobile_Numbers
(
Username VARCHAR(20),
Mobile_Number VARCHAR(20),
PRIMARY KEY(Mobile_Number, Username),
FOREIGN KEY(Username) REFERENCES Users
);

CREATE TABLE User_Addresses(
Username VARCHAR(20),
Address VARCHAR(100),
);

CREATE TABLE Customer
(
Username VARCHAR(20) PRIMARY KEY,
Points int default 0,
FOREIGN KEY(Username) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE Admins
(
admin_username VARCHAR(20) PRIMARY KEY,
FOREIGN KEY(admin_username) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE Vendor
(
Username VARCHAR(20) PRIMARY KEY,
Activated BIT,
Company_Name VARCHAR(20),
Bank_Acc_No VARCHAR(20),
admin_username VARCHAR(20),
FOREIGN KEY(Username) REFERENCES Users(Username) ON DELETE CASCADE,
FOREIGN KEY(admin_username) REFERENCES Admins(admin_username)
);

CREATE TABLE Delivery_Person
(
Username VARCHAR(20) PRIMARY KEY,
Is_Activated BIT,
FOREIGN KEY(Username) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE Credit_Card
(
Number VARCHAR(20) PRIMARY KEY,
Expiry_Date DATE,
CVV_Code INT
);

CREATE TABLE Delivery
(
ID int PRIMARY KEY IDENTITY,
Time_Duration INT,
Fees int,
Username VARCHAR(20),
FOREIGN KEY(Username) REFERENCES Admins ON DELETE CASCADE
);



CREATE TABLE Giftcard
(
Code VARCHAR(10) PRIMARY KEY,
Expiry_Date DATE NOT NULL,
Amount INT NOT NULL,
Username VARCHAR(20) ,
FOREIGN KEY(Username) REFERENCES Admins ON DELETE CASCADE
);

CREATE TABLE Orders
(
Order_No INT PRIMARY KEY IDENTITY,
Order_Date DATE NOT NULL,
Total_Amount INT NOT NULL,
Cash_Amount INT,
Credit_Amount INT,
Payment_Type VARCHAR(20) NOT NULL,
Order_Status VARCHAR(50) NOT NULL,
Remaining_Days INT,
Time_Limit INT,
gc_code VARCHAR(10),
Customer_Name VARCHAR(20) NOT NULL,
Delivery_ID int NOT NULL,
CreditCard_Number VARCHAR(20),
FOREIGN KEY (Customer_Name) REFERENCES Customer ON DELETE CASCADE,
FOREIGN KEY (Delivery_ID) REFERENCES Delivery  ,
FOREIGN KEY (gc_code) REFERENCES Giftcard ,
FOREIGN KEY (CreditCard_Number) REFERENCES Credit_Card  ON DELETE CASCADE


);

CREATE TABLE Product
(
Serial_No INT PRIMARY KEY IDENTITY ,
Product_Name VARCHAR(100) NOT NULL,
Category VARCHAR(40) NOT NULL,
Product_Description VARCHAR(300),
Final_price INT NOT NULL,
Color VARCHAR(15),
Available VARCHAR(15) NOT NULL,
Rate INT CHECK (Rate<=10 AND Rate>=1),
Vendor_Username VARCHAR(20),
Customer_Username VARCHAR(20),
Customer_order_id INT ,
FOREIGN KEY (Vendor_Username) REFERENCES Vendor ,
FOREIGN KEY (Customer_order_id) REFERENCES Orders ,
FOREIGN KEY (Customer_Username) REFERENCES Customer
);


CREATE TABLE CustomerAddstoCartProduct
(
Serial_No INT,
Customer_Name VARCHAR(20) NOT NULL,
PRIMARY KEY(Customer_Name, Serial_No),
FOREIGN KEY(Serial_No) REFERENCES Product ON DELETE CASCADE,
FOREIGN KEY (Customer_Name) REFERENCES Customer ON DELETE CASCADE
);

CREATE TABLE Todays_Deals
(
Deal_ID INT PRIMARY KEY ,
Deal_Amount INT,
Expiry_Date DATE,
Admin_Username VARCHAR(20),
FOREIGN KEY (Admin_Username) REFERENCES Admins ON DELETE CASCADE
);

CREATE TABLE Todays_Deals_Product
(
Deal_ID INT ,
Serial_No INT,
issue_date DATE,
PRIMARY KEY(Serial_No, Deal_ID),
FOREIGN KEY (Deal_ID) REFERENCES Todays_Deals ON DELETE CASCADE,
FOREIGN KEY (Serial_No) REFERENCES Product ON DELETE CASCADE
);

CREATE TABLE Offer
(
Offer_ID INT PRIMARY KEY ,
Offer_Amount INT,
Expiry_Date DATE
);

CREATE TABLE OffersOnProduct
(
Offer_ID INT ,
Serial_No INT,
PRIMARY KEY(Serial_No, Offer_ID),
FOREIGN KEY(Serial_No) REFERENCES Product ON DELETE CASCADE,
FOREIGN KEY(Offer_ID) REFERENCES Offer ON DELETE CASCADE
);


CREATE TABLE Customer_Question_Product
(
Serial_No INT,
Customer_Name VARCHAR(20),
Question VARCHAR(100),
Answer VARCHAR(150),
PRIMARY KEY(Serial_No, Customer_Name),
FOREIGN KEY(Serial_No) REFERENCES Product ON DELETE CASCADE,
FOREIGN KEY(Customer_Name) REFERENCES Customer ON DELETE CASCADE
);

CREATE TABLE Wishlist
(
Username VARCHAR(20),
Name VARCHAR(20),
PRIMARY KEY(Username, Name),
FOREIGN KEY(Username) REFERENCES Customer ON DELETE CASCADE
);

CREATE TABLE Wishlist_Product
(
Username VARCHAR(20),
Wish_Name VARCHAR(20),
Serial_No INT,
PRIMARY KEY(Username, Wish_Name, Serial_No),
FOREIGN KEY(Username, Wish_Name) REFERENCES Wishlist(Username, Name) ON DELETE CASCADE,

FOREIGN KEY(Serial_No) REFERENCES Product ON DELETE CASCADE,
);

CREATE TABLE Admin_Customer_Giftcard
(
Code VARCHAR(10),
Customer_name VARCHAR(20),
Admin_Username VARCHAR(20),
remaining_points INT,
PRIMARY KEY(Code, Admin_Username, Customer_name),
FOREIGN KEY(Code) REFERENCES GiftCard ON DELETE CASCADE ,
FOREIGN KEY(Customer_Name) REFERENCES Customer ,
FOREIGN KEY(Admin_Username) REFERENCES Admins
);

CREATE TABLE Admin_Delivery_Order
(
Delivery_Username VARCHAR(20),
Order_No INT,
Admin_Username VARCHAR(20),
Delivery_Window VARCHAR(50),
PRIMARY KEY(Delivery_Username,Order_No),
FOREIGN KEY(Delivery_Username) REFERENCES Delivery_Person ,
FOREIGN KEY(Order_No) REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(Admin_Username) REFERENCES Admins
);

CREATE TABLE Customer_CreditCard
(
Customer_Name VARCHAR(20),
CC_Number VARCHAR(20),
PRIMARY KEY(Customer_Name,CC_Number),
FOREIGN KEY(Customer_Name) REFERENCES Customer ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(CC_Number) REFERENCES Credit_Card ON DELETE CASCADE ON UPDATE CASCADE
);

go
CREATE PROC customerRegister
@username VARCHAR(20),
@first_name VARCHAR(20),
@last_name VARCHAR(20),
@password VARCHAR(20),
@email VARCHAR(50)
AS
INSERT INTO Users(Username,Passowrd,First_Name,Last_Name,Email)
VALUES(@username,@password, @first_name,@last_name,@email)
INSERT INTO Customer(Username)
VALUES(@username)

GO
CREATE PROC addMobile
@username VARCHAR(20),
@mobile_number VARCHAR(20)
AS
INSERT INTO User_Mobile_Numbers(Username, Mobile_Number)
VALUES(@username, @mobile_number)

GO
CREATE PROC vendorRegister
@username VARCHAR(20),
@first_name VARCHAR(20),
@last_name VARCHAR(20),
@password VARCHAR(20),
@email VARCHAR(50),
@company_name VARCHAR(20),
@bank_acc_no VARCHAR(20)
AS
INSERT INTO Users(Username,Passowrd,First_Name,Last_Name,Email)
VALUES(@username,@password, @first_name,@last_name,@email)
INSERT INTO Vendor(Username,Company_Name,Bank_Acc_No) VALUES(@username, @company_name,@bank_acc_no)

GO
CREATE PROC userLogin
@username VARCHAR(20),
@password VARCHAR(20),
@success BIT OUTPUT,
@type INT OUTPUT
AS
IF EXISTS(SELECT * FROM Users WHERE @username = Username and @password = Passowrd )
BEGIN
SET @success = 1

IF EXISTS(SELECT * FROM Customer WHERE @username = Username )
begin

SET @type = 0
end

IF EXISTS(SELECT * FROM Admins WHERE @username = admin_username )
begin
SET @type = 2
END

IF EXISTS(SELECT * FROM Vendor WHERE @username = Username)
BEGIN
SET @type = 1
END

IF EXISTS(SELECT * FROM Delivery_Person WHERE @username = Username)
BEGIN
SET @type = 3
END
END
ELSE
BEGIN
SET @success = 0
END



GO
CREATE PROC add_my_address
@username VARCHAR(20),
@address VARCHAR(20)
AS
IF EXISTS (SELECT * FROM Users WHERE @username = Username)
BEGIN
INSERT into User_Addresses(Username,Address) VALUES (@username, @address)
END

-- page 2
GO
CREATE PROC showProducts
AS
SELECT * FROM Product

GO
CREATE PROC ShowProductsbyPrice
AS
SELECT * FROM Product
ORDER by final_price asc

GO
CREATE PROC searchbyname
@text VARCHAR(20)
AS
SELECT * FROM Product WHERE @text LIKE [Product_Name]

GO
CREATE PROC AddQuestion
@serial INT,
@customer VARCHAR(20),
@question VARCHAR(50)
AS
INSERT INTO Customer_Question_Product (Serial_No,Customer_Name, Question) VALUES (@serial,@customer, @question)

GO
CREATE PROC addToCart
@customername varchar(20),
@serial int
AS
INSERT into CustomerAddstoCartProduct (Serial_No,Customer_Name) VALUES (@serial,@customername)

GO
CREATE proc removefromCart
@customername varchar(20),
@serial int
AS
DELETE FROM CustomerAddstoCartProduct WHERE Customer_Name = @customername AND Serial_No = @serial

GO
CREATE PROC createWishlist
@customername varchar(20),
@name varchar(20)
AS
IF (not exists (SELECT * FROM Wishlist WHERE @customername = Username and @name = Name)) AND (EXISTS (SELECT * FROM Users WHERE Username = @customername))
BEGIN
INSERT into Wishlist (Username,Name) VALUES (@customername,@name)
END
ELSE
BEGIN
PRINT('Wishlist name already exists')
END

GO
CREATE PROC AddtoWishlist
@customername varchar(20),
@wishlistname varchar(20),
@serial int
AS
IF (EXISTS(SELECT* FROM Customer WHERE @customername = Username)) AND (EXISTS(SELECT* FROM Wishlist WHERE Name = @wishlistname)) AND (EXISTS(SELECT* FROM Product WHERE Serial_No = @serial))
BEGIN
INSERT INTO  Wishlist_Product (Username,Wish_Name,Serial_No) VALUES (@customername,@wishlistname, @serial)
END
ELSE
BEGIN
PRINT 'error'
END

GO
CREATE PROC RemovefromWishlist
@customername varchar(20),
@wishlistname varchar(20),
@serial int
AS
DELETE from Wishlist_Product WHERE @customername = Username AND @wishlistname = Wish_Name AND Serial_No = @serial

Go
CREATE PROC showWishlistProduct
@CustomerName VARCHAR(20),
@Name VARCHAR(20)
AS
SELECT *
FROM Wishlist
WHERE Username = @CustomerName AND Name = @Name

Go
CREATE PROC ViewMyCart
@Customer VARCHAR(20)
AS
SELECT *
FROM CustomerAddstoCartProduct
WHERE @Customer = Customer_Name

Go
CREATE PROC CalculatepriceOrder
@CustomerName VARCHAR(20),
@Sum DECIMAL(10,2) OUTPUT
AS
SELECT @Sum = SUM(P.Final_Price)
FROM  Product P
		INNER JOIN  CustomerAddstoCartProduct C ON C.Serial_No = P.Serial_No
	WHERE @CustomerName = C.Customer_Name


GO
CREATE PROC ProductsInOrder --questionn
@CustomerName VARCHAR(20),
@OrderID INT
AS
UPDATE Product
SET Available = 0
FROM Product P
	INNER JOIN CustomerAddstoCartProduct C ON P.Serial_No = C.Serial_No

DELETE CustomerAddstoCartProduct
FROM CustomerAddstoCartProduct C1
	INNER JOIN CustomerAddstoCartProduct C2 ON C1.Serial_No = C2.Serial_No
WHERE @CustomerName <> Customer_Name

SELECT P.Product_Name
FROM Product P
	INNER JOIN CustomerAddstoCartProduct C ON C.Serial_No = P.Serial_No


GO
CREATE PROC EmptyCart
@CustomerName VARCHAR(20)
AS
DELETE
FROM CustomerAddstoCartProduct
WHERE @CustomerName = Customer_Name

GO
CREATE PROC MakeOrder
@CustomerName VARCHAR(20)
AS
DECLARE @Price INT
EXEC CalculatepriceOrder @CustomerName, @Price OUTPUT
EXEC ProductsInOrder @CustomerName
INSERT INTO Orders
(Total_Amount,Cash_Amount,Credit_Amount,Payment_Type,Order_Status,Remaining_Days,
Time_Limit,Customer_Name,Delivery_ID,CreditCard_Number,Order_Date)
VALUES(@Price,NULL,NULL,NULL,'Not processed',NULL,NULL,@CustomerName,NULL,NULL,CURDATE())
EXEC EmptyCart @CustomerName = @CustomerName;


GO
CREATE PROC CancelOrder
@OrderID INT
AS
DELETE
FROM Orders
WHERE @OrderID = Order_No AND (Order_Status = 'Not processed' OR Order_Status = 'In Process') -- NOT SURE

GO
CREATE PROC ReturnProduct  --MAKE SURE
@Serial_No INT,
@Order_ID  INT
AS

IF EXISTS(SELECT * FROM Orders O INNER JOIN Admin_Customer_Giftcard A
			ON O.Customer_Name = A.Customer_name  INNER JOIN Giftcard G ON A.Code = G.Code
			WHERE @Order_ID = Order_No
			AND   G.Expiry_Date > getdate()
			AND	  O.Total_Amount > O.Cash_Amount + O.Credit_Amount)
BEGIN
UPDATE Product
SET Available = 1,
	Customer_Username = NULL,
	Customer_order_id = NULL,
	Rate = NULL
WHERE Serial_No = @Serial_No

UPDATE Orders
SET Total_Amount = 0,
	Cash_Amount = 0,
	Order_Status = NULL,
	Remaining_Days = NULL,
	Time_Limit = NULL,
	Delivery_ID = NULL,
	CreditCard_Number = NULL,
	Order_Date = NULL
WHERE Order_No = @Order_ID

UPDATE Admin_Customer_Giftcard
SET remaining_points = remaining_points + G.Amount
FROM Admin_Customer_Giftcard A INNER JOIN Giftcard G ON G.Code = A.Code
	INNER JOIN Orders O ON O.Customer_Name = A.Customer_name
WHERE @Order_ID = O.Order_No

UPDATE Customer
SET Points = A.remaining_points
FROM Admin_Customer_Giftcard A INNER JOIN Customer C ON C.Username = A.Customer_name
	INNER JOIN Orders O ON O.Customer_Name = A.Customer_name
WHERE O.Order_No = @Order_ID

END
ELSE
BEGIN
UPDATE Product
SET Available = 1,
	Customer_Username = NULL,
	Customer_order_id = NULL,
	Rate = NULL
WHERE Serial_No = @Serial_No
UPDATE Orders
SET Total_Amount = 0,
	Cash_Amount = 0,
	Order_Status = NULL,
	Remaining_Days = NULL,
	Time_Limit = NULL,
	Delivery_ID = NULL,
	CreditCard_Number = NULL,
	Order_Date = NULL
WHERE Order_No = @Order_ID
END



GO
CREATE PROC ShowProductsIBought
@CustomerName VARCHAR(20)
AS
SELECT *
FROM Orders
WHERE Customer_Name = @CustomerName


GO
CREATE PROC Rate
@SerialNo INT,
@Rate INT,
@CustomerName VARCHAR(20)
AS
UPDATE Product
SET Rate = @Rate
WHERE @CustomerName = Customer_Username AND @SerialNo = Serial_No


GO
CREATE PROC SpecifyAmount			--MAKE SURE
@CustomerName VARCHAR(20),
@OrderID INT,
@Cash DECIMAL(10,2),
@Credit DECIMAL(10,2)
AS
IF EXISTS(SELECT * FROM Orders WHERE Order_No = @OrderID
			AND Total_Amount < Credit_Amount + Cash_Amount)
BEGIN
UPDATE Orders
	SET gc_code = A.Code,
	Cash_Amount = @Cash,
	Credit_Amount = @Credit
	FROM Orders O INNER JOIN Admin_Customer_Giftcard A ON O.Customer_Name = A.Customer_name
	WHERE O.Customer_Name = @CustomerName AND O.Order_No = @OrderID

UPDATE Admin_Customer_Giftcard
	SET remaining_points = remaining_points - G.Amount
	FROM Admin_Customer_Giftcard A INNER JOIN Giftcard G ON A.Code = G.Code
	WHERE A.Customer_name = @CustomerName

UPDATE Customer
SET Points = A.remaining_points
	FROM Customer C INNER JOIN Admin_Customer_Giftcard A ON A.Customer_name = C.Username
	WHERE C.Username = @CustomerName
END
ELSE
BEGIN
UPDATE Orders
	SET Cash_Amount = @Cash,
	Credit_Amount = @Credit
	WHERE Order_No = @OrderID AND Customer_Name = @CustomerName
END

GO
CREATE PROC AddCreditCard
@CreditCardNumber VARCHAR(20),
@ExpiryDate DATE,
@CVV VARCHAR(4),
@CustomerName VARCHAR(20)
AS
INSERT INTO Credit_Card
VALUES(@CreditCardNumber, @ExpiryDate, @CVV)

INSERT INTO Customer_CreditCard
VALUES(@CustomerName, @CreditCardNumber)

GO
CREATE PROC ChooseCreditCard
@CreditCard VARCHAR(20),
@OrderID INT
AS
UPDATE Orders
SET CreditCard_Number = @CreditCard
WHERE Order_No = @OrderID

GO
CREATE PROC ViewDeliveryTypes
AS
SELECT type, Time_Duration, Fees
FROM Delivery

GO
CREATE PROC SpecifyDeliveryType
@OrderID INT,
@DeliveryID INT
AS
DECLARE @DAYS INT
UPDATE Orders					 -------------------- MAKE SURE
SET Delivery_ID = @DeliveryID,
	Remaining_Days = Time_Duration
	FROM Delivery
WHERE Order_No = @OrderID AND Delivery_ID = @DeliveryID

GO
CREATE PROC TrackRemainingDays   -------------------- HELPPPP -- questionn
@OrderID INT,
@CustomerName VARCHAR(20),
@Days INT OUTPUT
AS
UPDATE Orders
SET Remaining_Days =

GO
CREATE PROC Reccommend
@CustomerName VARCHAR(20)
AS
SELECT P.Category, COUNT(*) AS TOTAL
FROM Product P
	INNER JOIN CustomerAddstoCartProduct C ON P.Serial_No = C.Serial_No
WHERE @CustomerName = C.Customer_Name
GROUP BY P.Category

GO
CREATE PROC PostProduct
@vendorUsername VARCHAR(20),
@product_name VARCHAR(20),
@category VARCHAR(20),
@product_description TEXT,
@price DECIMAL(10,2),
@color VARCHAR(20)
AS
INSERT INTO Product
(Vendor_Username, Product_Name, Category, Product_Description, Final_price, Color)
VALUES(@vendorUsername, @product_name, @category, @product_description, @price, @color)

GO
CREATE PROC VendorViewProducts
@VendorName VARCHAR(20)
AS
SELECT *
FROM Product
WHERE Vendor_Username = @VendorName

GO
CREATE PROC EditProduct
@vendorname varchar(20),
@serialnumber int,
@product_name varchar(20),
@category varchar(20),
@product_description text,
@price decimal(10,2),
@color varchar(20)
AS
UPDATE Product
SET Serial_No = @serialnumber,
	Product_Name = @product_name,
	Category = @category,
	Product_Description = @product_description,
	Price = @price,
	Color = @color
WHERE @vendorname = Vendor_Username


GO
CREATE PROC DeleteProduct
@VendorName VARCHAR(20),
@SerialNumber INT
AS
DELETE FROM Product
WHERE Vendor_Username = @VendorName AND Serial_No = @SerialNumber


GO
CREATE PROC ViewQuestions
@VendorName VARCHAR(20)
AS
SELECT c.*
FROM Customer_Question_Product c INNER JOIN Product p on c.Serial_No = p.Serial_No
WHERE p.Vendor_Username = @VendorName

GO
CREATE PROC AnswerQuestions --questionn
@VendorName VARCHAR(20),
@SerialNo INT,
@customerName VARCHAR(20),
@Answer TEXT
AS
UPDATE Customer_Question_Product
SET Answer = @Answer
WHERE Vendor = @VendorName AND Serial_No = @SerialNo AND Customer_Name = @customerName

GO
CREATE PROC AddOffer
@OfferAmount INT,
@Expiry_Date Datetime
AS
INSERT INTO Offer (Offer_Amount, Expiry_Date)
VALUES(@OfferAmount, @Expiry_Date)


GO
CREATE PROC CheckOfferOnProduct
@Serial INT,
@ActiveOffer BIT OUTPUT
AS
IF EXISTS(SELECT *
FROM OffersOnProduct O1
	INNER JOIN Offer O2 ON O1.Offer_ID = O2.Offer_ID
WHERE O1.Serial_No = @Serial
)SET @ActiveOffer = 1
ELSE SET @ActiveOffer = 0

GO
CREATE PROC CheckAndRemoveExpiredOffer
@OfferID INT
AS
DELETE FROM Offer
WHERE Offer_ID = Offer_ID AND Expiry_Date <= getdate()


GO
CREATE PROC ApplyOffer     --CHECKK
@VendorName VARCHAR(20),
@OfferId INT,
@Serial INT

AS
declare @ActiveOffer BIT
EXEC CheckOfferOnProduct @Serial, @ActiveOffer output
EXEC CheckAndRemoveExpiredOffer @OfferId
UPDATE Product
SET Final_price = Price - (Price * O1.Offer_Amount)  -- CHECK TESTCASES
FROM Offer O1
	INNER JOIN OffersOnProduct O ON O1.Offer_ID = O.Offer_ID
	INNER JOIN Product P ON P.Serial_No = O.Serial_No
WHERE P.Vendor_Username = @VendorName
AND P.Serial_No = @Serial
AND O.Offer_ID = @OfferId


GO
CREATE PROC ActivateVendors
@Admin_Username VARCHAR(20),
@Vendor_Username VARCHAR(20)
AS
UPDATE Vendor
SET Activated = 1
WHERE Username = @Vendor_Username AND admin_username = @Admin_Username


GO
CREATE PROC InviteDeliveryPerson
@Delivery_Username VARCHAR(20),
@Delivery_Email VARCHAR(50)
AS
INSERT INTO Users(Username,Email)
VALUES(@Delivery_Username, @Delivery_Email)

INSERT INTO Delivery_Person
VALUES(@Delivery_Username, 0)



GO
CREATE PROC ReviewOrders
AS
Select *
FROM Orders


GO
CREATE PROC UpdateOrderStatusInProcess
@Order_No INT
AS
UPDATE Orders
SET Order_Status = 'In process'
WHERE Order_No = @Order_No


GO
CREATE PROC AddDelivery
@Delivery_Type VARCHAR(20),
@Time_Duration INT,
@Fees Decimal(5,3),
@Admin_USername VARCHAR(20)
AS
INSERT INTO Delivery
VALUES(@Delivery_Type, @Time_Duration, @Fees, @Admin_USername)



GO
CREATE PROC AssignOrdertoDelivery
@Delivery_Username VARCHAR(20),
@Order_No INT,
@Admin_Username VARCHAR(20)
AS
INSERT INTO Admin_Delivery_Order
VALUES(@Delivery_Username, @Order_No, @Admin_Username, NULL)


GO
CREATE PROC CreateTodaysDeal
@Deal_Amount INT,
@Admin_Username VARCHAR(20),
@Expiry_Date DATETIME
AS
INSERT INTO Todays_Deals (Deal_Amount,Admin_Username,Expiry_Date)
VALUES(@Deal_Amount, @Admin_Username, @Expiry_Date)

GO
CREATE PROC AddTodaysDealOnProduct
@Deal_ID INT,
@Serial_No INT
AS
INSERT INTO Todays_Deals_Product(Deal_ID, Serial_No, issue_date)
VALUES(@Deal_ID, @Serial_No, GETDATE())


GO
CREATE PROC CheckTodaysDealOnProduct
@Serial_No INT,
@ActiveDeal BIT OUTPUT
AS
IF EXISTS(SELECT * FROM Todays_Deals_Product T1 INNER JOIN Todays_Deals T2
ON T1.Deal_ID = T2.Deal_ID WHERE Serial_No = @Serial_No AND T1.issue_date < T2.Expiry_Date)
BEGIN
SET @ActiveDeal = 1
END

GO
CREATE PROC RemoveExpiredDeal
@Deal_ID INT
AS
DELETE FROM Todays_Deals
WHERE Deal_ID = @Deal_ID    -- yes////DO I HAVE TO MAKE SURE IF IT IS EXPIRED?

GO
CREATE PROC CreateGiftCard
@Code VARCHAR(10),
@Expiry_Date DATETIME,
@Amount INT,
@Admin_Username VARCHAR(20)
AS
INSERT INTO Giftcard
VALUES(@Code, @Expiry_Date, @Amount, @Admin_Username)

GO
CREATE PROC RemoveExpiredGiftCard
@Code VARCHAR(10)
AS
DELETE FROM Giftcard
WHERE Code = @Code AND getdate() <= Expiry_Date

GO
CREATE PROC CheckGiftCardOnCustomer          -- EH ESTEKHDAMHA
@Code VARCHAR(10),
@ActiveGiftCard BIT OUTPUT
AS
IF EXISTS(SELECT * FROM Admin_Customer_Giftcard WHERE Code = @Code)
SET @ActiveGiftCard = 1

GO
CREATE PROC GiveGiftCardtoCustomer
@Code VARCHAR(10),
@Customer_Name VARCHAR(20),
@Admin_Username VARCHAR(20)
AS
DECLARE @Points INT
SELECT @POINTS = G.Amount FROM Giftcard G INNER JOIN Admin_Customer_Giftcard A ON G.Code = A.Code
INSERT INTO Admin_Customer_Giftcard
VALUES (@Code, @Customer_Name, @Admin_Username, @Points)


-- page 8
GO
CREATE PROC  acceptAdminInvitation
@delivery_username VARCHAR(20)
AS
UPDATE Delivery_Person SET Is_Activated = 1 WHERE @delivery_username = Username

GO
CREATE PROC deliveryPersonUpdateInfo
@username varchar(20),
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@email varchar(50)
AS
DELETE from Users WHERE @username = Username
INSERT into Users(Username, First_Name, Last_Name , Passowrd , Email) VALUES (@username , @first_name , @last_name , @password , @email)

GO
CREATE PROC viewmyorders
@deliveryperson varchar(20)
AS
SELECT o.* FROM
(Admin_Delivery_Order a INNER JOIN Delivery_Person d on d.Username = a.Delivery_Username )
INNER JOIN Orders o ON o.Order_No = a.Order_No

GO CREATE PROC specifyDeliveryWindow
@delivery_username varchar(20),@order_no int,@delivery_window varchar(50)
AS
INSERT into Admin_Delivery_Order(Delivery_Username, Order_No , Delivery_Window) VALUES(@delivery_username , @order_no , @delivery_window)

GO CREATE PROC updateOrderStatusOutforDelivery
@order_no int
AS
UPDATE orders
set Order_Status = 'Out for delivery' WHERE Order_No = @order_no

GO
CREATE PROC updateOrderStatusDelivered
@order_no int
AS
UPDATE orders
set Order_Status = 'Delivered' WHERE Order_No = @order_no

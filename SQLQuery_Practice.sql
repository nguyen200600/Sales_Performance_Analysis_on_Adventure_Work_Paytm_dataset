--CORRECT HOMEWORK LESSON 1

/* Task 1: Retrieve data for transportation reports 
1.1 Retrieve a list of cities: Initially, you need to produce a list of all of you customers' locations. 
Write a Transact-SQL query that queries the SalesLT.Address table and retrieves the values for City and StateProvince
, removing duplicates , then sorts in ascending order of StateProvince and descending order of City. */

-- Thứ tự execution của SQL: 
-- FROM -> WHERE -> SELECT (DISTINCT)-> ORDER BY -> LIMIT(TOP N [PERCENT])

SELECT TOP 5 * FROM SalesLT.Address --> nếu mn gắp table mới thì SELECT TOP 5/10 xem format của data 

SELECT DISTINCT -- loại bỏ các dòng dữ liệu bị trùng giá trị ở các columns trong lệnh SELECT 
    City
    , StateProvince
FROM SalesLT.Address
ORDER BY StateProvince ASC , city DESC

SELECT DISTINCT -- remove duplicates 
     StateProvince
    , City
FROM SalesLT.Address
ORDER BY StateProvince ASC , City DESC

/* 1.2 Retrieve the heaviest products information 
Transportation costs are increasing and you need to identify the heaviest products. 
Retrieve the names, weight of the top ten percent of products by weight. */


SELECT  * FROM SalesLT.Product -- 295 rows 

SELECT TOP 10 PERCENT
     Name 
    , Weight 
FROM SalesLT.Product 
ORDER BY Weight DESC
-- 30 rows 



/* Task 2: Retrieve product data 
2.1 Filter products by color and size  
Retrieve the product number and name of the products 
that have a color of black, red, or white and a size of S or M */

SELECT TOP 5 * FROM SalesLT.Product


SELECT 
    Name
    , ProductNumber
    , Color
    , Size
FROM 
    SalesLT.Product
WHERE 
    Color IN ('Black', 'Red', 'White')
    AND Size IN ('S','M')

/*2.2 Filter products by color, size and product number 
Retrieve the ProductID, ProductNumber and Name of the products, 
- that must have Product number begins with 'BK-' 
- followed by any character other than 'T' : kí tự thứ 4 khác T
- and ends with a '-' followed by any two numerals. - và 2 chữ số 
- And satisfy one of the following conditions: color of black, red, or white, size is S or M and */

-- way 1: 

-- AND ProductNumber LIKE '%-[a-e][a-e]' -- Kết thúc bởi dấu '-' và 2 chữ cái trong dãy a,b,c,d,e

SELECT ProductID
    , ProductNumber
    , Name 
FROM SalesLT.product
WHERE ProductNumber LIKE 'BK-%'
    AND ProductNumber NOT LIKE '___T%' -- kí tự thứ 4 khác chữ T
    AND ProductNumber LIKE '%-[0-9][0-9]' -- Kết thúc bởi dấu '-' và 2 chữ số
    AND ( Color IN ('Black', 'Red', 'White') OR Size IN ('S','M') )

-- 50 rows 
    
-- way 2
SELECT    
    ProductID
    , ProductNumber
    , Color
    , Size
    , Name 
FROM SalesLT.Product
WHERE
    ProductNumber  LIKE 'BK-[^T]%-[0-9][0-9]'
    AND ( Color IN ('Black', 'Red', 'White')
        OR Size IN ('S','M'))

/*2.3 Retrieve specific products by product ID  
Retrieve the product ID, product number, name, and list price of products whose 
- product name contains "HL " or "Mountain", --> WHERE Name LIKE 
- product number is at least 8 characters --> WHERE ProductNumber 
- and never have been ordered. */ --> 

SELECT  * FROM SalesLT.Product --> Dimension--> chiều dữ về sản phẩm --> mỗi sản phẩm có 1 dòng 
--> 295 dòng tức là có tất cả 295 sản phẩm 

SELECT DISTINCT ProductID FROM SalesLT.SalesOrderDetail --> 142 sản phẩm đã được bán  
--> 153 sản phẩm chưa dc bán 

SELECT ProductID   
    , name 
    , ListPrice
FROM SalesLT.Product
WHERE (Name LIKE '%HL%' OR Name LIKE '%Mountain%')
AND ProductNumber LIKE '________%' -- có ít nhất 8 kí tự 
AND ProductID NOT IN ( SELECT DISTINCT ProductID 
                        FROM SalesLT.SalesOrderDetail) -- tìm những sản phẩm khôn thuộc danh sách 142 sản phẩm đã bán

-- đáp án: 39 rows --> 39 sản phẩm thỏa yêu cầu 

-- CORRECT HOMEWORK LESSON 2
-- Task 1:

/* 1.1 Retrieve customer names and phone numbers 
Each customer has an assigned salesperson. You must write a query to create a call sheet that lists: 
    - The salesperson 
    - A column named CustomerName that displays how the customer contact should be greeted 
    (for example, Mr Smith) 
    - The customer’s phone number. */
-- + 
-- CONCAT(col1, col2, col3) ghep cac String va khong bi NULL
SELECT TOP 5 * FROM SalesLT.Customer -- FROM -> WHERE --> SELECT --> ORDER BY --> LIMIT (TOP)

SELECT 
    CustomerID
    , SalesPerson
    , Title
    , Phone
    , ISNULL(Title, ' ') + LastName AS CustomerName
    , CONCAT(Title,' ', LastName) CustomerName_1 -- ignore NULL
    , CONCAT_WS(' ', Title, LastName) AS CustomerName_2 -- ignore NULL 
FROM SalesLT.Customer

-- CONCAT: Lệnh dùng để ghép các columns --> 
-- CONCAT_WS(special_letters, column1, column2, column3, ..)
--- Syntax: CONCAT(column1, column2, ...)

/* 1.2 Retrieve the heaviest products information 
Transportation costs are increasing and you need to identify the heaviest products. 
Retrieve the names, weight of the top ten percent of products by weight.  
Then, add new column named Number of sell days (caculated from SellStartDate and SellEndDate)
 of these products (if sell end date isn't defined then get Today date)  */
SELECT * FROM SalesLT.Product

-- CASE WHEN 
-- IIF 

SELECT TOP 10 PERCENT
    ProductID
    , Name 
    , Weight 
    , SellStartDate
    , SellEndDate
    , CASE 
        WHEN SellEndDate IS NULL THEN DATEDIFF(day, SellStartDate, CURRENT_TIMESTAMP)
        ELSE DATEDIFF(day, SellStartDate, SellEndDate)
        END AS number_of_sell_days
    , DATEDIFF(day, SellStartDate, ISNULL(SellEndDate, CURRENT_TIMESTAMP)) AS number_of_sell_days_1
    , IIF(SellEndDate IS NULL, DATEDIFF(day, SellStartDate, CURRENT_TIMESTAMP), 
            DATEDIFF(day, SellStartDate, SellEndDate) ) AS number_of_sell_days_2
FROM SalesLT.Product
ORDER BY Weight DESC

-- total rows: 295 rows --> 10% là ~ 30 rows 

-- Task 2:
/* Retrieve a list of customer companies 
You have been asked to provide a list of all customer companies in the format 
Customer ID : Company Name - for example, 78: Preferred Bikes. */

SELECT * FROM SalesLT.Customer
-- way1: ghép bằng phép +  --> Phải chuyển đổi cho đồng data types (CustomerID --> nvarchar)
-- way2: Ghép bằng CONCAT --> Khong can quan bi conflict datatype


SELECT
    CustomerID
    , Companyname
    , CAST(CustomerID AS nvarchar) + ': ' + CompanyName AS FormatedName
    , CONCAT(CustomerID, ': ', CompanyName) AS FormatedName_1
FROM SalesLT.Customer


-- 2.2 
/* Retrieve a list of sales order revisions 
The SalesLT.SalesOrderHeader table contains records of sales orders. 
You have been asked to retrieve data for a report that shows: 
    - The sales order number and revision number in the format () – for example SO71774 (2). 
    - The order date converted to ANSI standard 102 format (yyyy.mm.dd – for example 2015.01.31). */

SELECT top 10 * FROM SalesLT.SalesOrderHeader


SELECT 
    SalesOrderNumber+'('+CAST(revisionNumber AS nvarchar)+')'AS SalesOrder 
   , CONVERT(nvarchar,OrderDate,102) AS OrderDate_ANSI
FROM SalesLT.SalesOrderHeader

--Task 3: 
-- 3.1 
/* Retrieve customer contact names with middle names if known 
You have been asked to write a query that returns a list of customer names. 
The list must consist of a single column in the format first last (for example Keith Harris) 
if the middle name is unknown, 
or first middle last (for example Jane M. Gates) if a middle name is known.  */

SELECT * FROM SalesLT.Customer

SELECT 
    FirstName
    , MiddleName
    , LastName
    , CONCAT(FirstName,' ', MiddleName, ' ', LastName) AS full_name
    , CONCAT_WS(' ', FirstName, MiddleName, LastName) AS full_name_2
FROM SalesLT.Customer 

-- 3.2 
/* Retrieve primary contact details 
Customers may provide Adventure Works with an email address, a phone number, or both. 
If an email address is available, then it should be used as the primary contact method; 
if not, then the phone number should be used. You must write a query that returns a 
list of customer IDs in one column, 
and a second column named PrimaryContact that contains the email address if known, 
and otherwise the phone number. */


SELECT 
    CASE WHEN EmailAddress IS NULL THEN Phone 
    ELSE EmailAddress 
    END pri_contact 
    , COALESCE(EmailAddress, Phone) AS pri_contact_1
    , IIF(EmailAddress IS NULL, Phone, EmailAddress) AS pri_contact_2
FROM SalesLT.Customer

-- other ways
SELECT TOP 10 
    CustomerID 
    , EmailAddress
    , Phone            
    , ISNULL(EmailAddress, Phone) AS PrimaryContact_1
    ,(CASE 
        WHEN EmailAddress IS NOT NULL THEN EmailAddress 
        ELSE Phone 
    END) AS PrimaryContact_2
    , COALESCE(EmailAddress, Phone) AS PrimaryContact_3
FROM SalesLT.Customer 

-- TOP: Limit result

SELECT TOP 10 * FROM SalesLT.Customer  

--3.3 
/* As you continue to work with the Adventure Works customer, product and sales data, 
you must create queries for reports that have been requested by the sales team.
Retrieve a list of customers with no address
o	A sales employee has noticed that Adventure Works does not have address information for all customers. 
You must write a query that returns a list of customer IDs, company names, 
contact names (first name and last name), and phone numbers for customers with no address stored 
in the database. */

SELECT * FROM SalesLT.Customer --> 847 rows --> Cty có tổng 847 khách hàng 
SELECT * FROM SalesLT.CustomerAddress --> 417 rows --> 407 customer có address --> (may be) 430 customer không có address 

Select DISTINCT CustomerID 
from SalesLT.CustomerAddress --> 407 khach hang co Address

--- Your code here
select CustomerID
    , CompanyName
    , FirstName + LastName as Contact_Name
    , Phone
from SalesLT.Customer
where CustomerID NOT IN (Select DISTINCT CustomerID 
                        from SalesLT.CustomerAddress) -- 407 rows -- 407 khách hàng có địa chỉ 
-- 440 rows --> 440 khách hàng không có Address

Select DISTINCT CustomerID 
from SalesLT.CustomerAddress

-- CORRECT HOMEWORK: 

/* Task 1: Generate invoice reports
Adventure Works Cycles sells directly to retailers, who must be invoiced for their orders. 
You have been tasked with writing a query to generate a list of invoices to be sent to customers.
1.1 Retrieve customer orders
o	As an initial step towards generating the invoice report, write a query that returns the company name 
from the SalesLT.Customer table, and the sales order ID and total due from the SalesOrderHeader table.
 */ 
 
--- Your code here

-- b1: FROM SalesLT.Customer, SalesLT.SalesOrderHeader
-- b2: INNER JOIN 2 table 

SELECT TOP 5 * FROM SalesLT.Customer -- dim
SELECT TOP 5 * FROM SalesLT.SalesOrderHeader -- fact 

SELECT 
    CompanyName
    , SalesOrderID 
    , TotalDue
FROM SalesLT.SalesOrderHeader AS header
JOIN SalesLT.Customer AS cus 
    ON header.CustomerID = cus.CustomerID

SELECT  CompanyName
    , SalesOrderID 
    , TotalDue
FROM SalesLT.SalesOrderHeader AS header
FULL JOIN SalesLT.Customer AS cus 
    ON header.CustomerID = cus.CustomerID
WHERE SalesOrderID IS NOT NULL 

-- 32 rows 

/* 1.2 Retrieve customer orders with addresses
o	Extend your customer orders query to include the Main Office address for each customer, 
including the full street address, city, state or province, postal code, and country or region
o	Tip: Note that each customer can have multiple addressees in the SalesLT.Address table, 
so the database developer has created the SalesLT.CustomerAddress table to enable a many-to-many 
relationship between customers and addresses. Your query will need to include both of these tables, 
and should filter the results so that only Main Office addresses are included.

 */ 
--- Your code here

SELECT TOP 5 * FROM SalesLT.CustomerAddress
SELECT TOP 5 * FROM SalesLT.Address
SELECT TOP 5 * FROM SalesLT.SalesOrderHeader

SELECT 
    cus.CustomerID
    , AddressLine1
    , City
    , StateProvince 
    , CountryRegion
    , PostalCode
FROM SalesLT.Customer  AS cus 
LEFT JOIN SalesLT.CustomerAddress AS cus_address
    ON cus.CustomerID = cus_address.CustomerID
LEFT JOIN SalesLT.Address AS adress 
    ON cus_address.AddressID = adress.AddressID
INNER JOIN SalesLT.SalesOrderHeader AS header -- Lưu ý chỗ này 
    ON cus.CustomerID = header.CustomerID
WHERE AddressType = 'Main Office'

-- 857 rows: tất cả khách hàng của cty
-- đáp án thì có 32 rows: vì đây là 32 khách hàng có orders

/* Task 2: Retrieve customer data
As you continue to work with the Adventure Works customer, product and sales data, 
you must create queries for reports that have been requested by the sales team.
  
Retrieve a list of products
○ A sales manager needs a list of ordered product with more information. 
You must write a query that returns a 
list of product name (is generated by the string preceded by the '-' character (example: HL Road Frame)), 
only started selling in 2006, Product model name contains "Road", 
CategoryName contains "Bikes" and  ListPrice value with integer part equal to 2443

*/
SELECT TOP 5 * FROM SalesLT.Product -- có tất cả là 295 sản phẩm 
SELECT TOP 5 * FROM SalesLT.ProductModel -- bằng cột ProductModelID
SELECT TOP 5 * FROM SalesLT.ProductCategory -- bằng cột CategoryID
SELECT * FROM SalesLT.SalesOrderDetail -- chứa các sản phẩm đã dc ordered

--- Your code here
-- Xuất phát từ bảng SalesOrderDetail (De lay cac san pham dc ordered) 
--> Product --> Model --> Category 

SELECT DISTINCT 
    detail.ProductID
    , pro.Name AS product_name
    , model.Name AS model_name
    , cat.Name AS cat_name
    , ListPrice
    -- , CHARINDEX('-', pro.Name)
    , CASE 
        WHEN CHARINDEX('-', pro.Name) = 0 THEN pro.Name
        ELSE SUBSTRING(pro.Name, 1, CHARINDEX('-', pro.Name) -1)
    END AS modified_name_1
    , LEFT (pro.Name, IIF( CHARINDEX('-', pro.Name) = 0, LEN(pro.Name), CHARINDEX('-', pro.Name) -1 )) AS modified_name_2
FROM SalesLT.SalesOrderDetail AS detail -- Chú ý chỗ này 
INNER JOIN SalesLT.Product  AS pro 
    ON detail.ProductID = pro.ProductID
INNER JOIN SalesLT.ProductModel AS model 
    ON pro.ProductModelID = model.ProductModelID
INNER JOIN SalesLT.ProductCategory AS cat 
    ON pro.ProductCategoryID = cat.ProductCategoryID
WHERE YEAR(SellStartDate) = 2006 -- SellStartDate BETWEEN '2006-01-01' AND '2006-12-31'
    AND model.Name LIKE '%Road%'
    AND cat.Name LIKE '%Bikes%'
    AND CAST(ListPrice AS INT) = 2443
    -- AND FLOOR (ListPrice) = 2443 -- LIKE '2443%'

-- đáp án: 5 rows

-- PART 2: payTM 

/* Task 1: Retrieve reports on transaction scenarios
1.1 Retrieve a report that includes the following information: 
customer_id, transaction_id, scenario_id, transaction_type, sub_category, category. 
These transactions must meet the following conditions: 
•	Were created in Jan 2019 
•	Transaction type is not payment */ 

-- Your code here

SELECT TOP 5 * FROM fact_transaction_2019 -- fact
SELECT TOP 5 * FROM dim_scenario -- dim 

SELECT 
    customer_id
    , transaction_id
    , fact.scenario_id
    , transaction_type
    , sub_category
    , category
    , transaction_time
FROM fact_transaction_2019 AS fact 
LEFT JOIN dim_scenario AS scena 
    ON fact.scenario_id = scena.scenario_id
WHERE transaction_time BETWEEN '2019-01-01' AND '2019-02-01'
    --MONTH(transaction_time) = 1 -- transaction_time < '2019-02-01'
    AND transaction_type != 'Payment'
ORDER BY transaction_time DESC

-- khác biệt between giữa datetime và int 

-- 7619 rows

SELECT DISTINCT transaction_type
FROM dim_scenario

-- 7619 rows 

/* 1.2 Retrieve a report that includes the following information: 
customer_id, transaction_id, scenario_id, transaction_type, category, payment_method. 
These transactions must meet the following conditions: 
•	Were created from Jan to June 2019
•	Had category type is shopping
•	Were paid by Bank account
*/ 
-- Your code here
SELECT TOP 5 * FROM fact_transaction_2019
SELECT TOP 5 * FROM dim_scenario
SELECT TOP 5 * FROM dim_payment_channel

SELECT 
    customer_id
    , transaction_id
    , fact.scenario_id
    , transaction_type
    , category
    , payment_method
FROM fact_transaction_2019 AS fact 
LEFT JOIN dim_scenario AS scena 
    ON fact.scenario_id = scena.scenario_id
LEFT JOIN dim_payment_channel AS channel 
    ON fact.payment_channel_id = channel.payment_channel_id
WHERE transaction_time < '2019-07-01' -- MONTH(transaction_time) <= 6 
    AND category = 'Shopping'
    AND payment_method = 'Bank account'

category LIKE 'Shopping' -- LIKE sẽ chạy lâu hơn với phép = 
MONTH(transaction_time) IN (1,2,3,4,5,6) -- cách IN nhiều giá trị nó sẽ xử lý lâu hơn 

-- 600 rows

/* 1.3 Retrieve a report that includes the following information: 
customer_id, transaction_id, scenario_id, payment_method and payment_platform. 
These transactions must meet the following conditions: 
•	Were created in Jan 2019 and Jan 2020
•	Had payment platform is android
*/ 
-- Your code here
SELECT TOP 5 * FROM dim_platform
SELECT TOP 5 * FROM fact_transaction_2019 -- 300K rows
SELECT TOP 5 * FROM fact_transaction_2020 -- 700K rows 

-- way 1: UNION trước 2 fact tables sau đó mới đi JOIN và đặt điều kiện 
fact_19 UNION fact_20 - JOIN dim_platform 

-- way 2: JOIN từng table fact với dim sau đó UNION lại --> performance tốt hơn cách 1 
fact_19 JOIN dim_platform , đặt các điều ios 
fact_20 JOIN dim_platform , đặt các điều ios
UNION 2 kết quả trên

-- way1 : Union xong rồi mới JOIN 
SELECT *
FROM 
    ( SELECT * 
    FROM fact_transaction_2019
    UNION 
    SELECT * 
    FROM fact_transaction_2020 ) AS fact_table -- > 1 triệu dòng thì sẽ nhiều và chạy lâu hơn 
LEFT JOIN dim_platform AS platform 
    ON fact_table.platform_id = platform.platform_id
LEFT JOIN dim_payment_channel AS channel 
    ON fact_table.payment_channel_id = channel.payment_channel_id
WHERE payment_platform = 'android' AND MONTH (transaction_time) = 1

-- 35,297, 2s

-- way 2: 
SELECT customer_id, transaction_id, scenario_id, payment_method, payment_platform
FROM fact_transaction_2019 AS fact_19 
JOIN dim_platform AS plat 
ON fact_19.platform_id = plat.platform_id 
JOIN dim_payment_channel AS channel 
    ON fact_19.payment_channel_id = channel.payment_channel_id
WHERE payment_platform = 'android' AND MONTH(transaction_time) = 1 -- 9,929 rows thỏa mãn trong 2019
UNION -- gop lai bang UNION
SELECT customer_id, transaction_id, scenario_id, payment_method, payment_platform
FROM fact_transaction_2020 fact_20
JOIN dim_platform plat 
ON fact_20.platform_id = plat.platform_id 
JOIN dim_payment_channel channel 
    ON fact_20.payment_channel_id = channel.payment_channel_id
WHERE payment_platform = 'android' AND MONTH(transaction_time) = 1 -- 25,368 rows thỏa mãn trong 2020

-- 35,297 rows , 2s

-- FROM-> JOIN -> WHERE -> SELECT -> UNION

-- cách viết sai 
SELECT transaction_id
FROM fact_transaction_2019 fact_19 -- 396K
UNION 
SELECT transaction_id
FROM fact_transaction_2020 fact_20 
JOIN dim_platform plat 
ON fact_20.platform_id = plat.platform_id 
JOIN dim_payment_channel AS channel 
    ON fact_20.payment_channel_id = channel.payment_channel_id
WHERE payment_platform = 'ios' AND MONTH(transaction_time) = 1 -- 31,955

-- 428,772



/* 1.4 Retrieve a report that includes the following information: 
customer_id, transaction_id, scenario_id, payment_method and payment_platform. 
These transactions must meet the following conditions: 
•	Include all transactions of the customer group created in January 2019 (Group A) 
and additional transactions of this customers (Group A) continue to make transactions in January 2020.
•	Payment platform is iOS */ 

-- ví dụ tháng 1/2019 có 1000 customers --> lấy hết giao dịch (1/2019)
-- Đi tìm thêm các giao dịch của 1000 customers trên phát sinh trong tháng 1/2020 

-- Your code here:
-- Đi tìm danh sách khách hàng trong tháng 1 2019: 
SELECT DISTINCT customer_id
FROM fact_transaction_2019 AS fact_19 
LEFT JOIN dim_platform AS platform 
    ON fact_19.platform_id = platform.platform_id
LEFT JOIN dim_payment_channel AS channel 
    ON fact_19.payment_channel_id = channel.payment_channel_id
WHERE MONTH(transaction_time) = 1
    AND payment_platform = 'ios' -- group A có 3,419 customers


SELECT customer_id, transaction_id, scenario_id, payment_method, payment_platform
FROM fact_transaction_2019 AS fact_19 
LEFT JOIN dim_platform AS platform 
    ON fact_19.platform_id = platform.platform_id
LEFT JOIN dim_payment_channel AS channel 
    ON fact_19.payment_channel_id = channel.payment_channel_id
WHERE MONTH(transaction_time) = 1
    AND payment_platform = 'ios' -- 11,783 rows của Group A phát sinh trong tháng 1/2019
UNION
SELECT customer_id, transaction_id, scenario_id, payment_method, payment_platform -- 9,007 rows 
FROM fact_transaction_2020 AS fact_20 
LEFT JOIN dim_platform AS platform 
    ON fact_20.platform_id = platform.platform_id
LEFT JOIN dim_payment_channel AS channel 
    ON fact_20.payment_channel_id = channel.payment_channel_id
WHERE MONTH(transaction_time) = 1
    AND payment_platform = 'ios'
    AND customer_id IN ( SELECT DISTINCT customer_id
                    FROM fact_transaction_2019 AS fact_19 
                    LEFT JOIN dim_platform AS platform 
                        ON fact_19.platform_id = platform.platform_id
                    LEFT JOIN dim_payment_channel AS channel 
                        ON fact_19.payment_channel_id = channel.payment_channel_id
                    WHERE MONTH(transaction_time) = 1
                        AND payment_platform = 'ios'
                        ) -- 8,179 giao dịch của group A phát sinh giao dịch trong 1/2020
-- đáp án: 19,962 rows

-- CORRECT HOMEWORK 4: SUBQUERY - GROUP BY - CTE 

/* Task 1: Retrieve an overview report of payment types
1.1.	Paytm has a wide variety of transaction types in its business. 
Your manager wants to know the contribution (by percentage) of each transaction type to total transactions. 
Retrieve a report that includes the following information: transaction type, 
number of transaction and proportion of each type in total. 
These transactions must meet the following conditions: 
•	Were created in 2019 
•	Were paid successfully
Show only the results of the top 5 types with the highest percentage of the total. */ 

-- Your code here
-- b1: JOIN 3 tables: fact_transaction_2019, dim_scenario, status --> LEFT JOIN từ fact và lấy success 
-- b2: Gom nhóm theo transaction type -> tính số giao dịch --> GROUP BY , COUNT (transaction_id)
-- b3: Tính tổng số giao dịch success của 2019 --> SUBQUERY để đếm số giao dịch 2019 
-- b4: Tỉnh tỉ trọng = b1/b2 
-- b5: Chọn top 5 cao nhất --> SELECT TOP 5 , ORDER BY ... 

WITH joined_table AS ( -- b1
SELECT fact_19.*, transaction_type
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
    ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS stat 
    ON fact_19.status_id = stat.status_id
WHERE status_description = 'success' 
)
, total_table AS (
SELECT transaction_type -- group by cái gì select cái đó
    , COUNT(transaction_id) AS number_trans
    , (SELECT COUNT(transaction_id) FROM joined_table) AS total_trans
FROM joined_table
GROUP BY transaction_type
)
SELECT TOP 5 
    *
    , FORMAT ( number_trans*1.0/total_trans, 'p') AS pct  --> SQL trả ra INT, 0.4732
FROM total_table
ORDER BY number_trans DESC 


/* 1.2.	After your manager looks at the results of these top 5 types, 
he wants to deep dive more to gain more insights. 
Retrieve a more detailed report with following information: transaction type, category, 
number of transaction and proportion of each category in the total of that transaction type.
These transactions must meet the following conditions: 
•	Were created in 2019 
•	Were paid successfully */ 

-- Your code here
-- b1: JOIN facc19 , scenario, status 
-- b2: Group by theo type, category để tìm mỗi category có bao nhiêu trans 
-- b3: Group by theo type để tìm mỗi type có bao nhiêu trans 
-- b4: JOIN 2 kết quả trên lại 
-- b5: tính pct 

WITH join_table AS ( -- b1
SELECT fact_19.*, transaction_type, category
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
    ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS stat 
    ON fact_19.status_id = stat.status_id
WHERE status_description = 'success' 
)
, count_category AS ( -- b2
SELECT transaction_type, category
    , COUNT(transaction_id) AS number_trans_category
FROM join_table 
GROUP BY transaction_type, category
) 
, count_type AS ( -- b3
SELECT transaction_type
    , COUNT(transaction_id) AS number_trans_type
FROM join_table 
GROUP BY transaction_type
)
SELECT count_category.*, number_trans_type -- b4
    , FORMAT( number_trans_category*1.0/number_trans_type, 'p') AS pct 
FROM count_category 
FULL JOIN count_type 
ON count_category.transaction_type = count_type.transaction_type
WHERE number_trans_type IS NOT NULL AND number_trans_category IS NOT NULL 
ORDER BY number_trans_category*1.0/number_trans_type DESC


/* Task 2: Retrieve an overview report of customer’s payment behaviors
2.1. Paytm has acquired a lot of customers. 
Retrieve a report that includes the following information: the number of transactions, 
the number of payment scenarios, the number of transaction types, 
the number of payment category and the total of charged amount of each customer.

•	Were created in 2019
•	Had status description is successful
•	Had transaction type is payment
•	Only show Top 10 highest customers by the number of transactions */

-- Your code here
-- b1: Join tables 
-- b2: Đặt điều kiện status và type 
-- b3: group by customer_id --> COUNT và SUM để tính các chỉ số

SELECT 
    -- TOP 10 
    customer_id
    , COUNT(transaction_id) AS number_trans
    , COUNT(DISTINCT fact_19.scenario_id) AS number_scenarios
    , COUNT(DISTINCT scena.category) AS number_categories
    , SUM(charged_amount*1.0) AS total_amount
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
ORDER BY number_trans DESC

/* 2.2.	After looking at the above metrics of customer’s payment behaviors, 
we want to analyze the distribution of each metric. Before calculating and plotting the distribution 
to check the frequency of values in each metric, we need to group the observations into range.
2.2.1.	 How can we group the observations in the most logical way? Binning is useful 
to help us deal with problem. To use binning method, we need to determine how many bins for 
each distribution of each field.
Retrieve a report that includes the following columns: metric, minimum value, maximum value 
and average value of these metrics:

•	The total charged amount
•	The number of transactions
•	The number of payment scenarios
•	The number of payment categories  */ 

-- The number of transactions

WITH summary_table AS (
SELECT customer_id
    , COUNT(transaction_id) AS number_trans
    , COUNT(DISTINCT fact_19.scenario_id) AS number_scenarios
    , COUNT(DISTINCT scena.category) AS number_categories
    , SUM(charged_amount) AS total_amount
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT 'The number of transaction' AS metric 
    , MIN(number_trans) AS min_value
    , MAX(number_trans) AS max_value
    , AVG(number_trans) AS avg_value
FROM summary_table
UNION 
SELECT 'The number of scenarios' AS metric
    , MIN(number_scenarios) AS min_value
    , MAX(number_scenarios) AS max_value
    , AVG(number_scenarios) AS avg_value
FROM summary_table
UNION 
SELECT 'The number of categories' AS metric
    , MIN(number_categories) AS min_value
    , MAX(number_categories) AS max_value
    , AVG(number_categories) AS avg_value
FROM summary_table
UNION 
SELECT 'The total charged amount' AS metric
    , MIN(total_amount) AS min_value
    , MAX(total_amount) AS max_value
    , AVG(1.0*total_amount) AS avg_value
FROM summary_table


/* Bin the total charged amount and number of transactions then calculate the frequency of each field in each metric

Metric 3: The total charged amount */ 

WITH summary_table AS (
SELECT customer_id
    , SUM(charged_amount) AS total_amount
    , CASE
        WHEN SUM(charged_amount) < 1000000 THEN '0-01M'
        WHEN SUM(charged_amount) >= 1000000 AND SUM(charged_amount) < 2000000 THEN '01M-02M'
        WHEN SUM(charged_amount) >= 2000000 AND SUM(charged_amount) < 3000000 THEN '02M-03M'
        WHEN SUM(charged_amount) >= 3000000 AND SUM(charged_amount) < 4000000 THEN '03M-04M'
        WHEN SUM(charged_amount) >= 4000000 AND SUM(charged_amount) < 5000000 THEN '04M-05M'
        WHEN SUM(charged_amount) >= 5000000 AND SUM(charged_amount) < 6000000 THEN '05M-06M'
        WHEN SUM(charged_amount) >= 6000000 AND SUM(charged_amount) < 7000000 THEN '06M-07M'
        WHEN SUM(charged_amount) >= 7000000 AND SUM(charged_amount) < 8000000 THEN '07M-08M'
        WHEN SUM(charged_amount) >= 8000000 AND SUM(charged_amount) < 9000000 THEN '08M-09M'
        WHEN SUM(charged_amount) >= 9000000 AND SUM(charged_amount) < 10000000 THEN '09M-10M'
        WHEN SUM(charged_amount) >= 10000000 THEN 'more > 10M'
        END AS charged_amount_range
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT charged_amount_range
    , COUNT(customer_id) AS number_customers
FROM summary_table
GROUP BY charged_amount_range 
ORDER BY charged_amount_range

-- Metric 1: The number of payment categories */ 
WITH summary_table AS (
SELECT customer_id
    , COUNT(DISTINCT scena.category) AS number_categories
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT number_categories
    , COUNT(customer_id) AS number_customers
FROM summary_table
GROUP BY number_categories 
ORDER BY number_categories

-- Metric 2: The number of payment scenarios
WITH summary_table AS (
SELECT customer_id
    , COUNT(DISTINCT fact_19.scenario_id) AS number_scenarios
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT number_scenarios
    , COUNT(customer_id) AS number_customers
FROM summary_table
GROUP BY number_scenarios 
ORDER BY number_scenarios


---------------------------------MIDTERM TEST-----------------------------------------

SELECT
    customer_id
    , transaction_id
    , scena.scenario_id
    , transaction_type
    , sub_category
    , category
FROM fact_transaction_2019 AS fact_19
    LEFT JOIN dim_scenario AS scena
    ON fact_19.scenario_id = scena.scenario_id
WHERE MONTH(transaction_time) = 2
    AND transaction_type IS NOT NULL

--From payment transaction history in February 2019. Find the top 10% of failed transactions with the highest transaction value.

SELECT TOP 10 PERCENT
    customer_id, transaction_id, charged_amount, status_description, transaction_type
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta ON fact_19.status_id = sta.status_id 
WHERE transaction_type='Payment'
AND status_description!='Success'
AND MONTH(transaction_time)=2
ORDER BY charged_amount DESC

-----------------------------------------------------------------------------------

SELECT TOP 10
    customer_id
    , COUNT(transaction_id) AS number_trans
    , COUNT(DISTINCT fact_20.scenario_id) AS number_scenarios
    , COUNT(DISTINCT scena.category) AS number_categories
    , SUM(charged_amount*1.0) AS total_amount
FROM fact_transaction_2020 AS fact_20
LEFT JOIN dim_scenario AS scena 
        ON fact_20.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_20.status_id = sta.status_id 
WHERE transaction_time BETWEEN '2020-01-01' AND '2020-03-31'
    AND status_description = 'Success'
    AND transaction_type = 'Payment'
GROUP BY customer_id
ORDER BY total_amount DESC

----------------------------------------------------------------------------------

WITH join_table AS
    (
    SELECT
        customer_id
        , SUM(charged_amount*1.0) AS total_amount
    FROM fact_transaction_2020 AS fact_20
    LEFT JOIN dim_scenario AS scena 
        ON fact_20.scenario_id = scena.scenario_id
    LEFT JOIN dim_status AS sta 
        ON fact_20.status_id = sta.status_id 
    WHERE transaction_time BETWEEN '2020-01-01' AND '2020-03-31'
        AND status_description = 'Success'
        AND transaction_type = 'Payment'
    GROUP BY customer_id 
    )
    
SELECT
    customer_id
    , total_amount
    , (SELECT AVG(total_amount) FROM join_table) AS avg_amount
    , CASE WHEN total_amount <= (SELECT AVG(total_amount) FROM join_table) THEN 'lower_than_avg'
        ELSE 'greater_than_avg' 
        END AS group_customer
FROM join_table
 
----------------------------------------------------------------------------------
GO
WITH join_table AS
    (   SELECT
        customer_id
        , SUM(charged_amount*1.0) AS total_amount
    FROM fact_transaction_2020 AS fact_20
    LEFT JOIN dim_scenario AS scena 
        ON fact_20.scenario_id = scena.scenario_id
    LEFT JOIN dim_status AS sta 
        ON fact_20.status_id = sta.status_id 
    WHERE transaction_time BETWEEN '2020-01-01' AND '2020-03-31'
        AND status_description = 'Success'
        AND transaction_type = 'Payment'
    GROUP BY customer_id    )
    , group_cus AS
    (   SELECT
        customer_id , total_amount
        , (SELECT AVG(total_amount) FROM join_table) AS avg_amount
        , CASE WHEN total_amount <= (SELECT AVG(total_amount) FROM join_table) THEN 'lower_than_avg'
            ELSE 'greater_than_avg' 
            END AS group_customer
    FROM join_table    )
    , pct_cus AS
    (   SELECT
    group_customer , COUNT(customer_id) AS number_cus
    , (SELECT COUNT(customer_id) FROM group_cus) AS total_cus
FROM group_cus
GROUP BY group_customer    )

SELECT *
    , CONVERT (varchar, CAST((number_cus * 100.00 /total_cus) AS decimal(10,2))) + ' %' AS pct
FROM pct_cus

----------------------------------------------------------------------------------

-- RANKING FUNCTION: Hàm xếp hạng 

/*
Exercise 22: part 1
Đánh giá tốc độ tăng trưởng theo từng tháng của sản phẩm Telecom (chỉ tính các giao dịch thành công) 
thông qua các chỉ số:
- Số lượng giao dịch
- Số lượng khách hàng
- Tổng số tiền

--- part 2: 
Sau đó hãy hiển thị thêm các columns sau:
- accummulated_number_trans: Tổng số lượng giao dịch cộng dồn theo tháng
- accummulated_number_customer: Tổng số khách hàng cộng dồn theo tháng
- accummulated_total_amount: Tổng số tiền cộng dồn theo tháng
*/
GO
-- part 1: 
-- cách 1 : GROUP BY 
WITH summary_month AS (
SELECT MONTH(transaction_time) AS month 
    , COUNT (transaction_id) AS number_trans 
    , COUNT (DISTINCT customer_id) AS number_customer 
    , SUM (1.0* charged_amount) AS total_amount
FROM fact_transaction_2019 
GROUP BY MONTH(transaction_time)
) -- part 2
SELECT *
    , SUM (number_trans) OVER (ORDER BY month ASC ) AS accummulating_trans
    , SUM (number_customer) OVER (ORDER BY month ASC ) AS accummulating_customer
    , SUM (total_amount) OVER (ORDER BY month ASC ) AS accummulating_amount
    , SUM (number_customer) OVER () AS total_customer 
FROM summary_month

-- Ví dụ thêm:
-- Tạo 1 column tính tổng số khách hàng của cả năm 
-- Tính số lượng khách hàng theo từng H1, H2
GO

WITH summary_month AS (
SELECT IIF (MONTH(transaction_time) <7, 'H1', 'H2') AS half_year 
    , MONTH(transaction_time) AS month
    , COUNT (transaction_id) AS number_trans 
    -- , COUNT (DISTINCT customer_id) AS number_customer 
    -- , SUM (1.0* charged_amount) AS total_amount
FROM fact_transaction_2019 
GROUP BY IIF(MONTH(transaction_time) <7, 'H1', 'H2'),
        MONTH(transaction_time)
)
SELECT *
    , SUM (number_trans) OVER (ORDER BY month ASC ) AS accummulating_trans_year
    , SUM (number_trans) OVER (PARTITION BY half_year ORDER BY month ASC) accummulating_trans_half_year
    , SUM (number_trans) OVER () AS total_trans_year
    , SUM (number_trans) OVER (PARTITION BY half_year) AS total_trans_h1_h2
FROM summary_month
GO
/*
Exercise 22: part 1
Đánh giá tốc độ tăng trưởng theo từng tháng
thông qua các chỉ số:
- Số lượng giao dịch
- Số lượng khách hàng
- Tổng số tiền */

--- Tính part 1 bằng WINDOW FUNCTION 
-- DISTICT không apply vào WINDOW FUNCTION 
WITH rank_cus AS (
SELECT 
month (transaction_time) AS month
, count (transaction_id) OVER (PARTITION BY month(transaction_time)) as total_trans
, DENSE_RANK() OVER (PARTITION BY month(transaction_time) ORDER BY customer_id) as rank_customer
, sum(charged_amount*1.0) OVER (PARTITION BY month(transaction_time)) as total_amount
FROM fact_transaction_2019 AS fact_19
JOIN dim_scenario AS scena 
ON fact_19.scenario_id = scena.scenario_id
WHERE category = 'Telco')

SELECT DISTINCT month, total_trans, total_amount
    , MAX(rank_customer) OVER (PARTITION BY month) AS number_customer
FROM rank_cus
ORDER BY month

/* Exercise 23: Dựa trên ví dụ bài 22 (tính số lượng khách hàng theo tháng)
Hãy đánh giá yếu tố số lượng khách hàng theo từng tháng của năm 2020 tăng hay giảm bao nhiêu % 
so với cùng kì năm trước. (Tức tháng 1/2020 tăng trưởng bao nhiêu % so với tháng 1 năm 2019)
*/
-- b1: Đếm số khách hàng theo tháng của 2 năm (2019 và 2020)
WITH summary_month AS (
SELECT YEAR (transaction_time) AS YEAR 
    , MONTH(transaction_time) AS month 
    , COUNT (DISTINCT customer_id) AS number_customer 
FROM ( SELECT * FROM fact_transaction_2019 
        UNION 
        SELECT * FROM fact_transaction_2020) AS total_fact
JOIN dim_scenario AS scena 
ON total_fact.scenario_id = scena.scenario_id
WHERE category = 'Telco'
GROUP BY YEAR (transaction_time), MONTH(transaction_time)
--ORDER BY YEAR,month
) -- b2: Tìm số lượng khách hàng cùng năm trước?
, previous_table AS 
( SELECT * 
    , LAG(number_customer, 12) OVER (ORDER BY year ASC, month ASC) AS previous_result
FROM summary_month
)  -- b3: tính tỉ lệ tăng trưởng = kì hiện tại/kì trước - 1
SELECT *
    , FORMAT ( 1.0*number_customer/previous_result - 1, 'p') AS diff_pct
FROM previous_table

-- LEAD (column_value, N)
GO
/* Exercise 24: Tính khoảng cách trung bình giữa các lần thanh toán theo từng khách hàng trong nhóm Telecom. */

WITH previous_table AS (
SELECT customer_id
    , transaction_id
    , transaction_time
    , previous_time = LAG (transaction_time, 1) OVER (PARTITION BY customer_id ORDER BY transaction_time)
FROM fact_transaction_2019 AS total_fact
JOIN dim_scenario AS scena 
ON total_fact.scenario_id = scena.scenario_id
WHERE category = 'Telco'
) 
, gap_table AS (
SELECT *
    , DATEDIFF (day,previous_time, transaction_time ) AS gap_day
FROM previous_table
) 
SELECT customer_id
    , AVG(gap_day) AS avg_time
FROM gap_table
GROUP BY customer_id
HAVING AVG(gap_day) IS NOT NULL

-- CORRECT HOMEWORK 6 + Lesson 7: Time Series Analysis

/* 1.1.	Simple trend
Task: You need to analyze the trend of payment transactions of Billing category from 2019 to 2020. 
First, let’s show the trend of the number of successful transaction by month. */ 
-- các loại hóa đơn: 

-- b1: data source fact 19 và fact 20 , dim scenario 
-- b2: 
--- cách 1: Gộp 2 bảng 19 và 20 lại --> toàn bộ fact transaction --> JOIN để tìm Billing: UNION fact 19 và fact 20 ; LEFT JOIN dim scenario 
--- cách 2: JOIN lần lượt từng bảng fact với scenario --> UNION 2 data tables lại  | LEFT JOIN từ fact sang dim và UNION sau
-- b3: gom nhóm theo tháng và đếm số giao dịch --> GROUP BY month và COUNT(transaction_id)

-- Đáp án 

-- cách 1: UNION 2 bảng trước --> JOIN --> gom nhóm tính toán

WITH fact_table AS ( -- 1,198,484 rows 
SELECT transaction_id, transaction_time, status_id, scenario_id
FROM fact_transaction_2019 -- 396k rows 
UNION 
SELECT transaction_id, transaction_time, status_id, scenario_id
FROM fact_transaction_2020 )  -- 700k rows) 
SELECT 
    Year(transaction_time) AS year, Month(transaction_time) AS month
    , CONVERT(nvarchar(6), transaction_time, 112) AS time_calendar
    , COUNT(transaction_id) AS number_trans
FROM fact_table 
JOIN dim_scenario AS sce ON fact_table.scenario_id = sce.scenario_id 
WHERE status_id = 1 AND category = 'Billing' 
GROUP BY Year(transaction_time), Month(transaction_time), CONVERT(nvarchar(6), transaction_time, 112)
ORDER BY year, month
-- 4s 

-- cách 2: JOIN từng bảng FACT với Scenario và đặt điều kiện Billing --> UNION
WITH fact_table AS (
SELECT fact_19.*, category
FROM fact_transaction_2019 fact_19 
JOIN dim_scenario sce 
ON fact_19.scenario_id = sce.scenario_id
WHERE status_id = 1 AND category = 'Billing' 
UNION
SELECT fact_20.*, category
FROM fact_transaction_2020 fact_20 
JOIN dim_scenario sce 
ON fact_20.scenario_id = sce.scenario_id
WHERE status_id = 1 AND category = 'Billing' 
)
SELECT     Year(transaction_time) AS year, Month(transaction_time) AS month
    , CONVERT(nvarchar(6), transaction_time, 112) AS time_calendar
    , COUNT(transaction_id) AS number_trans
FROM fact_table
GROUP BY Year(transaction_time), Month(transaction_time), CONVERT(nvarchar(6), transaction_time, 112)
ORDER BY year, month
-- 3s: 

-- 1.2 

WITH fact_table AS (
SELECT *
FROM fact_transaction_2019 
UNION 
SELECT *
FROM fact_transaction_2020 )
SELECT 
    YEAR(transaction_time) AS year, MONTH(transaction_time) AS month
    , sub_category
    , COUNT(transaction_id) AS number_trans
FROM fact_table 
JOIN dim_scenario AS sce ON fact_table.scenario_id = sce.scenario_id
WHERE status_id = 1 AND category = 'Billing'
GROUP BY YEAR(transaction_time), MONTH(transaction_time), sub_category
ORDER BY year, month 

-- COUNT(transaction_id) OVER ( PARTITION BY month, sub_category) AS number_trans

-- Modifying kết quả (PIVOT TABLE)

-- cách 1: pivot bằng cách group by và aggregate có case when --> MS SQL Server , Postgres SQL, MySQL (Ưu tiên cách này, dùng ở đâu cũng dc)

WITH fact_table AS (
SELECT *
FROM fact_transaction_2019 
UNION 
SELECT *
FROM fact_transaction_2020 )
, sub_month AS (
SELECT 
    YEAR(transaction_time) AS year, MONTH(transaction_time) AS month
    , sub_category
    , COUNT(transaction_id) AS number_trans
FROM fact_table 
JOIN dim_scenario AS sce ON fact_table.scenario_id = sce.scenario_id
WHERE status_id = 1 AND category = 'Billing'
GROUP BY YEAR(transaction_time), MONTH(transaction_time), sub_category
)
SELECT year, month 
    , SUM ( CASE WHEN sub_category = 'Electricity' THEN number_trans END ) AS elec_trans
    , SUM ( CASE WHEN sub_category = 'Internet' THEN number_trans END ) AS internet_trans
    , SUM ( CASE WHEN sub_category = 'Water' THEN number_trans END ) AS water_trans
FROM sub_month
GROUP BY year, month 
ORDER BY year, month



-- cách 2: dùng hàm PIVOT của MS SQL Server 

Cú pháp : 
SELECT ... 
FROM 
PIVOT (
    Aggregate function 
    FOR column_pivot IN ("Electricity", "Internet", "Water")
)

WITH fact_table AS (
SELECT *
FROM fact_transaction_2019 
UNION 
SELECT *
FROM fact_transaction_2020 )
, sub_month AS (
SELECT 
    YEAR(transaction_time) AS year, MONTH(transaction_time) AS month
    , sub_category
    , COUNT(transaction_id) AS number_trans
FROM fact_table 
JOIN dim_scenario AS sce ON fact_table.scenario_id = sce.scenario_id
WHERE status_id = 1 AND category = 'Billing'
GROUP BY YEAR(transaction_time), MONTH(transaction_time), sub_category
)
SELECT year, month -- non-pivot columns 
    , "Electricity" AS elec_trans
    , "Internet" AS inter_trans
    , "Water" AS water_trans
FROM ( 
    SELECT year, month, sub_category, number_trans 
    FROM sub_month
) AS source_table 
PIVOT (
    SUM(number_trans) -- aggregate funtion 
    FOR sub_category IN ( "Electricity", "Internet", "Water" ) -- khai báo column muốn pivot, cụ thể là muốn pivot giá trị nào 
) AS pivot_table 
ORDER BY year, month 


-- 1.3 Percent of total 
WITH fact_table AS (
SELECT *
FROM fact_transaction_2019 
UNION 
SELECT *
FROM fact_transaction_2020 )
, sub_count AS (
SELECT 
    YEAR(transaction_time) year, MONTH(transaction_time) month
    , sub_category
    , COUNT(transaction_id) AS number_trans
FROM fact_table 
JOIN dim_scenario AS sce ON fact_table.scenario_id = sce.scenario_id
WHERE status_id = 1 AND category = 'Billing'
GROUP BY YEAR(transaction_time), MONTH(transaction_time), sub_category
)
, sub_month AS (
SELECT Year 
    , month 
    , SUM( CASE WHEN sub_category = 'Electricity' THEN number_trans ELSE 0 END ) AS electricity_trans
    , SUM( CASE WHEN sub_category = 'Internet' THEN number_trans ELSE 0 END ) AS internet_trans
    , SUM( CASE WHEN sub_category = 'Water' THEN number_trans ELSE 0 END ) AS water_trans
FROM sub_count
GROUP BY year, month
)
, total_month AS ( 
    SELECT * 
    , ISNULL(electricity_trans,0) + ISNULL(internet_trans,0) + ISNULL(water_trans,0) AS total_trans_month
FROM sub_month
)
SELECT *
    , FORMAT(1.0*electricity_trans/total_trans_month, 'p') AS elec_pct
    , FORMAT(1.0*internet_trans/total_trans_month, 'p') AS iternet_pct
    , FORMAT(1.0*water_trans/total_trans_month, 'p') AS water_pct
FROM total_month

-- 1.4 

WITH fact_table AS (
SELECT * FROM fact_transaction_2019
UNION 
SELECT * FROM fact_transaction_2020
)
, customer_month AS (
SELECT MONTH(transaction_time) month, YEAR(transaction_time) year
    , COUNT( DISTINCT customer_id ) AS number_customer -- đếm số lượng khách hàng 
FROM fact_table
JOIN dim_scenario AS scena ON fact_table.scenario_id = scena.scenario_id
WHERE category = 'Billing' AND status_id = 1 AND sub_category IN ('Electricity', 'Internet',  'Water')
GROUP BY MONTH(transaction_time), YEAR(transaction_time)
)
SELECT *
    , start_point = (SELECT number_customer FROM customer_month WHERE year = 2019 AND month = 1)
    , start_point_1 = FIRST_VALUE(number_customer) OVER (ORDER BY year, month)
    , FORMAT (1.0*number_customer/FIRST_VALUE(number_customer) OVER (ORDER BY year, month) -1 , 'p') AS diff_pct
FROM customer_month 

-- 2. Rolling time window

/* 2.1 Task: Select only these sub-categories in the list (Electricity, Internet and Water), 
you need to calculate the number of successful paying customers for each week number from 2019 to 2020). 
Then get rolling annual paying users of total. */ 

select datepart(week, '2022-09-27');

WITH fact_table AS (
SELECT * FROM fact_transaction_2019
UNION 
SELECT * FROM fact_transaction_2020
)
, week_user AS (
SELECT YEAR(transaction_time) year, DATEPART(week, transaction_time) AS week_number
    , COUNT( DISTINCT customer_id ) AS number_customer
FROM fact_table
JOIN dim_scenario AS scena ON fact_table.scenario_id = scena.scenario_id
WHERE category = 'Billing' AND status_id = 1 AND sub_category IN ('Electricity', 'Internet',  'Water')
GROUP BY YEAR(transaction_time), DATEPART(week, transaction_time)
-- ORDER BY year, week_number
)
SELECT *
    , SUM(number_customer) OVER ( PARTITION BY year ORDER BY week_number ASC ) AS rolling_customer_year
FROM week_user


/* 2.2
Task: Based on the previous query, calculate the average number of customers for the last 4 weeks in each observation week. 
Then compare the difference between the current value and the average value of the last 4 weeks.
*/ 

WITH fact_table AS (
SELECT * FROM fact_transaction_2019
UNION 
SELECT * FROM fact_transaction_2020
)
, week_user AS (
SELECT YEAR(transaction_time) year, DATEPART(week, transaction_time) AS week_number
    , COUNT( DISTINCT customer_id ) AS number_customer
FROM fact_table
JOIN dim_scenario AS scena ON fact_table.scenario_id = scena.scenario_id
WHERE category = 'Billing' AND status_id = 1 AND sub_category IN ('Electricity', 'Internet',  'Water')
GROUP BY YEAR(transaction_time), DATEPART(week, transaction_time)
)
-- Cần tính trung bình 4 tuần gần nhất --> trả kết quả về dòng hiện tại 
SELECT *
    , AVG(number_customer) OVER ( PARTITION BY year ORDER BY week_number ASC 
                                    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS avg_last_4_weeks
FROM week_user

-- Khi mà chúng ta cần tính rolling time window: WINDOW FUNCTION với ROWS BETWEEN N/UNBOUDED PRECEDING/FOLLOWING AND CURENT ROW 
-- PREDING: từ dòng hiện tại trở về trước
-- FOLLOWING: Từ dòng hiện tại trở về sau


-- Chúng ta chỉ có 1 pp tạo bảng trung gian: CTE: 
---> bất tiện ở chỗ: câu lệnh càng dài càng cần nhiều CTE 

---> Mình sẽ dùng bảng tạm: Local table 
Cú pháp: 

SELECT ... 
INTO #local_table_name 
FROM ... 
JOIN ... 
GROUP ...


WITH fact_table AS (
SELECT * FROM fact_transaction_2019
UNION 
SELECT * FROM fact_transaction_2020
)
SELECT YEAR(transaction_time) year, DATEPART(week, transaction_time) AS week_number
    , COUNT( DISTINCT customer_id ) AS number_customer
INTO #week_table 
FROM fact_table
JOIN dim_scenario AS scena ON fact_table.scenario_id = scena.scenario_id
WHERE category = 'Billing' AND status_id = 1 AND sub_category IN ('Electricity', 'Internet')
GROUP BY YEAR(transaction_time), DATEPART(week, transaction_time)


SELECT *
    , AVG(number_customer) OVER ( PARTITION BY year ORDER BY week_number ASC 
                                    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS avg_last_4_weeks
FROM #week_table 

-- Bây giờ muốn thay đổi dữ liệu trong bảng local thì làm sao? 

--> Phải xóa bảng --> INTO lại

DROP TABLE #week_table 

-- phương pháp 2: Tạo bảng tạm : Tạo VIEWS -- sẽ hướng dẫn trong buổi 9 
--> read: 


﻿-- LESSON 7: Correct homework and query notes -- 

-- 1.1 
-- Basic retention curve
-- 1.1 A:

-- Way 1: 
-- b1: Đi tìm tập customers 1/2019 mua Telco card thành công : 2,111 customers 
WITH customer_list AS (
SELECT DISTINCT customer_id
FROM fact_transaction_2019 fact 
JOIN dim_scenario sce ON fact.scenario_id = sce.scenario_id
WHERE sub_category = 'Telco Card' AND status_id = 1 AND MONTH(transaction_time) = 1
)
, full_trans AS ( -- b2: Đi tìm tất cả giao dịch của tập trên : JOIN với fact_2019: 19,634 trans của tập trên 
SELECT fact.*
FROM customer_list 
JOIN fact_transaction_2019 fact 
ON customer_list.customer_id = fact.customer_id
JOIN dim_scenario sce 
ON fact.scenario_id = sce.scenario_id
WHERE sub_category = 'Telco Card' AND status_id = 1
) 
-- b3: Đếm xem từng tháng có bao nhiêu khách hàng
SELECT MONTH(transaction_time) - 1 AS subsequence_month
    , COUNT( DISTINCT customer_id) AS retained_users
FROM full_trans 
GROUP BY MONTH(transaction_time) - 1
ORDER BY subsequence_month

-- way2: 
WITH period_table AS (
SELECT customer_id
    , transaction_id
    , transaction_time
    , MIN( MONTH(transaction_time)) OVER (PARTITION BY customer_id) AS first_month
    , DATEDIFF(month, MIN( transaction_time) OVER (PARTITION BY customer_id), transaction_time) AS subsequence_month
FROM fact_transaction_2019 fact 
JOIN dim_scenario sce ON fact.scenario_id = sce.scenario_id
WHERE sub_category = 'Telco Card' AND status_id = 1
)
SELECT subsequence_month
    , COUNT( DISTINCT customer_id) AS retained_users
FROM period_table
WHERE first_month = 1
GROUP BY subsequence_month
ORDER BY subsequence_month


-- 1.1 B: 
WITH period_table AS (
SELECT customer_id, transaction_id, transaction_time
    , MIN(transaction_time) OVER( PARTITION BY customer_id) AS first_time
    , DATEDIFF(month, MIN(transaction_time) OVER( PARTITION BY customer_id), transaction_time) AS subsequent_month
FROM fact_transaction_2019 fact 
JOIN dim_scenario sce ON fact.scenario_id = sce.scenario_id
WHERE sub_category = 'Telco Card' AND status_id = 1
)
, retained_user AS (
SELECT subsequent_month
    , COUNT( DISTINCT customer_id) AS retained_users
FROM period_table
WHERE MONTH(first_time) = 1
GROUP BY subsequent_month
-- ORDER BY subsequent_month
)
SELECT *
    , FIRST_VALUE(retained_users) OVER( ORDER BY subsequent_month) AS original_users
    , MAX(retained_users) OVER() AS original_users_2
    , (SELECT COUNT(DISTINCT customer_id)
        FROM period_table 
        WHERE MONTH(first_time) = 1) AS original_users_3
    , FORMAT(1.0*retained_users/FIRST_VALUE(retained_users) OVER( ORDER BY subsequent_month ASC), 'p') AS pct_retained_users
FROM retained_user

-- 1.2 A
WITH period_table AS (
SELECT customer_id, transaction_id, transaction_time
    , MIN(MONTH( transaction_time)) OVER( PARTITION BY customer_id) AS first_month
    , DATEDIFF(month, MIN(transaction_time) OVER( PARTITION BY customer_id), transaction_time) AS subsequent_month
FROM fact_transaction_2019 fact 
JOIN dim_scenario sce ON fact.scenario_id = sce.scenario_id
WHERE sub_category = 'Telco Card' AND status_id = 1
)
, retained_user AS (
SELECT first_month AS acquisition_month
    , subsequent_month
    , COUNT( DISTINCT customer_id) AS retained_users
FROM period_table
GROUP BY first_month , subsequent_month
-- ORDER BY acquisition_month, subsequent_month
)
SELECT *
    , FIRST_VALUE(retained_users) OVER( PARTITION BY acquisition_month ORDER BY subsequent_month) AS original_users
    , FORMAT(1.0*retained_users/FIRST_VALUE(retained_users) OVER( PARTITION BY acquisition_month ORDER BY subsequent_month), 'p') AS pct_retained_users
INTO #retention_month -- lưu vào bảng local 
FROM retained_user

SELECT * FROM #retention_month

-- DROP TABLE #retention_month
-- 1.2 B Pivot table 

SELECT acquisition_month
    , original_users
    , "0", "1", "2", "3","4", "5", "6", "7","8", "9", "10", "11"
FROM (
    SELECT acquisition_month, subsequent_month, original_users,  pct_retained_users
    FROM #retention_month
) AS source_table 
PIVOT ( -- MIN, MAX, AVG, SUM, COUNT
    MIN(pct_retained_users)
    FOR subsequent_month IN ("0", "1", "2", "3","4", "5", "6", "7","8", "9", "10", "11")
) pivot_table
ORDER BY acquisition_month

-- User segmentation 
-- RFM Segmenation
-- 2.1 Tính các chỉ số RFM 

WITH fact_table AS ( -- 173,774 rows 
    SELECT  fact_19.*
    FROM fact_transaction_2019 fact_19 
    JOIN dim_scenario sce ON fact_19.scenario_id = sce.scenario_id
    WHERE sub_category = 'Telco Card' AND status_id = 1 -- 59,082 rows 
UNION
    SELECT  fact_20.*
    FROM fact_transaction_2020 fact_20 
    JOIN dim_scenario sce ON fact_20.scenario_id = sce.scenario_id
    WHERE sub_category = 'Telco Card' AND status_id = 1 -- 114,692 rows
)
, rfm_metric AS ( -- tính các metrics theo từng khách hàng 
SELECT customer_id
    , DATEDIFF (day, MAX (transaction_time), '2020-12-31') AS recency -- khoảng cách từ 
    , COUNT (DISTINCT CONVERT(varchar(10), transaction_time, 102)) AS frequency -- đếm số ngày thanh toán, CONVERT về DATE 
    , SUM(1.0*charged_amount) AS monetary
FROM fact_table
GROUP BY customer_id
)
, rfm_rank AS (
SELECT *
    , PERCENT_RANK() OVER ( ORDER BY recency ASC ) AS r_percent_rank
    , PERCENT_RANK() OVER ( ORDER BY frequency DESC ) AS f_percent_rank
    , PERCENT_RANK() OVER ( ORDER BY monetary DESC ) AS m_percent_rank
FROM rfm_metric
)
, rfm_tier AS ( 
SELECT *
    , CASE WHEN r_percent_rank > 0.75 THEN 4
        WHEN r_percent_rank > 0.5 THEN 3
        WHEN r_percent_rank > 0.25 THEN 2
        ELSE 1 END AS r_tier
    , CASE WHEN f_percent_rank > 0.75 THEN 4
        WHEN f_percent_rank > 0.5 THEN 3
        WHEN f_percent_rank > 0.25 THEN 2
        ELSE 1 END AS f_tier
    , CASE WHEN m_percent_rank > 0.75 THEN 4
        WHEN m_percent_rank > 0.5 THEN 3
        WHEN m_percent_rank > 0.25 THEN 2
        ELSE 1 END AS m_tier
FROM rfm_rank
)
, rfm_group AS ( 
SELECT * 
    , CONCAT(r_tier, f_tier, m_tier) AS rfm_score -- tạo 1 cái score
FROM rfm_tier
) -- Step 3: Grouping these customers based on segmentation rules
, segment_table AS (
SELECT *
    , CASE 
        WHEN rfm_score  =  111 THEN 'Best Customers'
        WHEN rfm_score LIKE '[3-4][3-4][1-4]' THEN 'Lost Bad Customer'
        WHEN rfm_score LIKE '[3-4]2[1-4]' THEN 'Lost Customers'
        WHEN rfm_score LIKE  '21[1-4]' THEN 'Almost Lost' -- sắp lost 
        WHEN rfm_score LIKE  '11[2-4]' THEN 'Loyal Customers'
        WHEN rfm_score LIKE  '[1-2][1-3]1' THEN 'Big Spenders'
        WHEN rfm_score LIKE  '[1-2]4[1-4]' THEN 'New Customers' 
        WHEN rfm_score LIKE  '[3-4]1[1-4]' THEN 'Hibernating'
        WHEN rfm_score LIKE  '[1-2][2-3][2-4]' THEN 'Potential Loyalists'
    ELSE 'unknown'
    END AS segment -- cố gắng ưu tiên tìm những segment muốn đầu tiên trước.
FROM rfm_group
)
SELECT
    segment
    , COUNT( customer_id) AS number_users 
    , SUM( COUNT( customer_id)) OVER() AS total_users
    , FORMAT( 1.0*COUNT( customer_id) / SUM( COUNT( customer_id)) OVER(), 'p') AS pct
FROM segment_table
GROUP BY segment
ORDER BY number_users DESC

-- Bài 1.2 

WITH fact_table AS
(SELECT
    customer_id
    , transaction_id
    , scena.scenario_id
    , transaction_type
    , sub_category
    , category
    , status_description
FROM fact_transaction_2020 AS fact_2020
LEFT JOIN dim_scenario AS scena
ON fact_2020.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS status
ON fact_2020.status_id = status.status_id
WHERE transaction_type IS NOT NULL)
SELECT
    transaction_type
    , count (transaction_id) AS nb_trans
    , count (CASE WHEN status_description = 'Success' THEN transaction_id END) AS nb_success_trans
    , (1.0*count (CASE WHEN status_description = 'Success' THEN transaction_id END)/count (transaction_id)) AS success_rate
FROM fact_table
GROUP BY transaction_type
ORDER BY nb_trans DESC



-- Bài 2
WITH fact_table AS
(SELECT fact_2019.* FROM fact_transaction_2019 AS fact_2019
LEFT JOIN dim_scenario as scena
ON fact_2019.scenario_id = scena.scenario_id
WHERE status_id = 1
AND category = 'Billing'
UNION
SELECT fact_2020.* FROM fact_transaction_2020 AS fact_2020
LEFT JOIN dim_scenario as scena
ON fact_2020.scenario_id = scena.scenario_id
WHERE status_id = 1
AND category = 'Billing')
, rfm_metric AS
(SELECT
    customer_id
    , DATEDIFF(day, max(transaction_time), '2020-12-31') AS recency
    , COUNT ( transaction_id) AS frequency
    , sum (1.0*charged_amount) AS monetary
FROM fact_table
GROUP BY customer_id)
, rfm_tier AS
(SELECT *
    , PERCENT_RANK () OVER (ORDER BY recency ASC) AS r_percent_rank
    , PERCENT_RANK () OVER (ORDER BY frequency DESC) AS f_percent_rank
    , PERCENT_RANK () OVER (ORDER BY monetary DESC) AS m_percent_rank
FROM rfm_metric)
, rfm_rank AS
(SELECT *
, CASE 
        WHEN r_percent_rank > 0.75 THEN 4
        WHEN r_percent_rank > 0.5 THEN 3
        WHEN r_percent_rank > 0.25 THEN 2
        ELSE 1
        END AS r_tier
, CASE 
        WHEN f_percent_rank > 0.75 THEN 4
        WHEN f_percent_rank > 0.5 THEN 3
        WHEN f_percent_rank > 0.25 THEN 2
        ELSE 1
        END AS f_tier
, CASE 
        WHEN m_percent_rank > 0.75 THEN 4
        WHEN m_percent_rank > 0.5 THEN 3
        WHEN m_percent_rank > 0.25 THEN 2
        ELSE 1
        END AS m_tier
FROM rfm_tier)
, rfm_group AS
(SELECT *
, CONCAT (r_tier, f_tier, m_tier) AS rfm_score
FROM rfm_rank)
, rfm_table AS
(
SELECT *
, CASE WHEN rfm_score = 111 THEN 'Best customers'
    WHEN rfm_score LIKE '[3-4][3-4][1-4]' THEN 'Lost Bad customers'
    WHEN rfm_score LIKE '[3-4]2[1-4]' THEN 'Lost customers'
    WHEN rfm_score LIKE '21[1-4]' THEN 'Almost lost'
    WHEN rfm_score LIKE '11[2-4]' THEN 'Loyal customers'
    WHEN rfm_score LIKE '[1-2][1-3]1' THEN 'Big Spender'
    WHEN rfm_score LIKE '[1-2]4[1-4]' THEN 'New customers'
    WHEN rfm_score LIKE '[3-4]1[1-4]' THEN 'Hibernating'
    WHEN rfm_score LIKE '[1-2][2-3][2-4]' THEN 'Potencial Loyalist'
    ELSE 'unknown'
    END AS segmen
FROM rfm_group)
SELECT
    segmen
    , count (customer_id) AS number_users
    , sum (count(customer_id)) OVER () AS total_users
    , FORMAT (1.0*count (customer_id)/sum (count(customer_id)) OVER (),'p') AS pct
FROM rfm_table
GROUP BY segmen
















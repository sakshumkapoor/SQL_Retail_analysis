use db_retail
-- Q1- begin 

select  count (*) from Customer 
union
select count (*) from  dbo.pci 
union
select count (*) from  Transactions 
 
--Q1 end

--Q2 begin

alter table transactions
alter column total_amt float  null 

select *from Transactions 
where total_amt < 0 

-- Q2 END

--Q3 Begin



update customer
set DOB = CONVERT(date, DOB , 105)

alter table customer
alter column DOB date

update transactions
set tran_date = CONVERT(date, tran_date , 105)

alter table transactions
alter column tran_date date

--Q3 END

--Q4 begin 
select DATEDIFF ( year , ( select top 1 tran_date from transactions order by tran_date ) , ( select top 1 tran_date from transactions order by tran_date desc) ) as YEARS,
 DATEDIFF ( month , ( select top 1 tran_date from transactions order by tran_date ) , ( select top 1 tran_date from transactions order by tran_date desc) ) as MONTHS,
DATEDIFF ( DAY , ( select top 1 tran_date from transactions order by tran_date ) , ( select top 1 tran_date from transactions order by tran_date desc) ) as DAYS
-- Q4 end still working
--Q5 Begin 
select prod_cat from pci
where prod_subcat = 'DIY'

--Q5 End 


-- DATA ANALYSIS BEGIN 


--Q1  begin 

select top 1 count  (transaction_id) as channel , store_type  
from transactions
group by store_type
order by channel desc 

-- Q1 end 

-- Q2 begin 
select top 2 count( customer_id) as count  , Gender  from customer
group by gender
order by count desc  
   
-- Q2 end 
 
--Q3 Begin 
 


select top 1 count(customer_id) as count , city_code from customer
group by city_code
order by count desc

-- Q3 end 

-- Q4 begin 
select prod_cat , count ( prod_subcat ) as count_of_subcat from pci 
group by prod_cat
having prod_cat = 'books'

 
--Q4 end

-- Q5 Begin 
SELECT TOP 1 * 
FROM Transactions
ORDER BY QTY DESC
-- Q5 end 

-- Q6 begin 
select 	 SUM(total_amt) AS TOTAL_SALES , prod_cat  from Transactions left join pci 
on Transactions.prod_cat_code = pci.prod_cat_code
and Transactions.prod_subcat_code = pci.prod_sub_cat_code
group by prod_cat
HAVING prod_cat IN ('ELECTRONICS', 'BOOKS')
-- Q6 END	

--Q 7 BEGIN
select cust_id, COUNT(transaction_id) AS Count_of_Transactions
from Transactions
where Qty >= 0
group by cust_id
having COUNT(transaction_id) > 10
-- Q 7 END

-- Q8 BEGIN 
SELECT SUM(TOTAL_AMT) AS AMOUNT FROM Transactions
INNER join pci ON transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code
WHERE PROD_CAT IN ('CLOTHING','ELECTRONICS') AND STORE_TYPE = 'FLAGSHIP STORE'

--- Q8 END 
-- Q9 Begin 
select  prod_subcat, SUM(total_amt)as revenue from  Transactions
left join Customer on Transactions.cust_id = Customer.customer_Id
left join  pci ON transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code where Gender = 'M' and prod_cat = 'Electronics'
group by prod_subcat

-- Q9 end 

--Q10 Begin 
update Transactions
set Qty = CONVERT(int, Qty)

alter table transactions
alter column qty int

	   
select top 5 prod_subcat, sum(total_amt) / ( select SUM(total_amt) from Transactions)*100 as '% of sales',
sum(case  when total_amt < 0  then (total_amt) else 0 end ) / ( select SUM(total_amt) from Transactions where total_amt<0)*100 as ' % of return'
from Transactions
join pci on transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code 
group by prod_subcat
order by '% of sales' desc

-- Q10 end 

-- Q11 Begin
			 
create view ages 
as
select total_amt , tran_date  , dob , year(getdate() )- (case when MONTH(DOB)>=MONTH(GETDATE())  then  YEAR(DOB) 
else (Year(DOB)+1) end) as age
from Transactions 
left join Customer
on Transactions.cust_id= Customer.customer_Id 
where tran_date  >= DATEADD(day, -30 , (select max(tran_date) from transactions))
			 
select  SUM(total_amt)   from  ages 
where age>= 25 and age <= 35
		
-- Q11 End 

		  
--Q12 Begin 
SELECT top 1 prod_cat , SUM( case when total_amt<0 then total_amt else 0 end) as returns from  Transactions
left join pci ON transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code
where tran_date >= DATEADD(month , -3, (select max(tran_date) from transactions))
group by prod_cat
order by returns 
--- Q12 end 

-- Q13 Begin 
select	top 1 Store_type , SUM(total_amt) as [Sales Amount], SUM(qty)as [Quantity Sold] from Transactions
group by Store_type
order by [Sales Amount] desc, [Quantity Sold] desc
-- Q13 END


-- Q14 Begin 
					
SELECT PROD_CAT, AVG(TOTAL_AMT) AS AVERAGE
FROM Transactions
left join pci ON transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code
GROUP BY PROD_CAT
HAVING AVG(TOTAL_AMT)> (SELECT AVG(TOTAL_AMT) FROM Transactions)

-- Q14 end

-- Q15 Begin 
SELECT prod_cat, prod_subcat, AVG(total_amt) AS AVERAGE_REV, SUM(total_amt) AS REVENUE
FROM Transactions
left join pci ON transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code
WHERE prod_cat IN
(
SELECT TOP 5 
PROD_CAT
FROM Transactions 
left join pci ON transactions.prod_cat_code = pci.prod_cat_code 
AND transactions.prod_subcat_code  = pci.prod_sub_cat_code
GROUP BY PROD_CAT
ORDER BY SUM(QTY) DESC
)
GROUP BY PROD_CAT, PROD_SUBCAT 

-- Q15 end 
			 
			
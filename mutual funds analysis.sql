# creating the database
create database mutualfunds_analysis;
use mutualfunds_analysis;


# importing our dataset
select * from comprehensive_mutual_funds_data;
Rename table comprehensive_mutual_funds_data to mutual_funds;

select * from mutual_funds;


# Cleaning the dataset

# Replacing the '-' with 0
Update mutual_funds  
Set sortino = REPLACE(sortino, '-', '0'),  
    alpha = REPLACE(alpha, '-', '0'),  
    sd = REPLACE(sd, '-', '0'),  
    beta = REPLACE(beta, '-', '0'),  
    sharpe = REPLACE(sharpe, '-', '0');
    
# Checking if the values have been successfully replaced
select * from mutual_funds 
where sortino='-'
or alpha='-'
or sd='-'
or beta='-'
or sharpe='-';

# Deleitng those rows which have blanks in the column returns_3yr
Delete from mutual_funds
where returns_3yr is null
or returns_3yr ='';


# Analysis part

# 1. Which mutual funds have the highest returns in each sub-category over the last 5 years?

SELECT category, scheme_name, returns_1yr as returns, '1 year' as period
from mutual_funds
where returns_1yr = (Select max(returns_1yr) from mutual_funds where category = mutual_funds.category)
union
SELECT category, scheme_name, returns_3yr as returns, '3 year' as period
from mutual_funds
where returns_3yr = (Select max(returns_3yr) from mutual_funds where category = mutual_funds.category)
union
SELECT category, scheme_name, returns_5yr as returns, '5 year' as period
from mutual_funds
where returns_5yr = (Select max(returns_5yr) from mutual_funds where category = mutual_funds.category)
order by category,period;


# 2. Which funds have a high risk but also high returns?
select * from mutual_funds;
select scheme_name, category,sd, returns_5yr
from mutual_funds
where sd > 15 and returns_5yr > 15;



# 3. Which AMC (Asset Management Company) has the highest average 3-year returns?
select amc_name, returns_3yr
from mutual_funds
where returns_3yr = (select max(returns_3yr) from mutual_funds);





# 4. How have Sectoral/Thematic funds performed over the past 3 years compared to Flexi Cap funds?
select sub_category, avg(returns_3yr) as avg_returns
from mutual_funds
where sub_category in ('Sectoral / Thematic Mutual Funds', 'Flexi Cap Funds')
group by sub_category;


# 5. Which fund manager has the highest average returns across all funds they manage?
select fund_manager, (avg(returns_1yr)+ avg(returns_3yr)+ avg(returns_5yr)) / 3 as avg_returns
from mutual_funds
group by fund_manager
order by avg_returns desc
limit 1;




# 6. How have Arbitrage funds performed in the last 1 year compared to their 5-year returns?
select sub_category, avg(returns_1yr), avg(returns_5yr)
from mutual_funds
where sub_category = 'Arbitrage Mutual Funds';






# 7. Do funds with a higher Beta (>1) tend to have higher or lower returns over 3 and 5 years?
select case
when beta > 1 then 'High Beta'
else 'low beta'
end as beta_category,
avg(returns_3yr), avg(returns_5yr)
from mutual_funds
group by beta_category;


# 8. What is the average 1-year return for funds with a risk level of 6 compared to funds with a risk level of 3?
select avg(returns_1yr), risk_level
from mutual_funds
where risk_level in ('3', '6')
group by risk_level;

# 9. What is the distribution of fund ages (fund_age_yr) across different risk levels?
select fund_age_yr, risk_level,
case
when risk_level between 0 and 1 then 'High risk'
when risk_level between 2 and 3 then 'Medium risk'
else 'Low risk'
end as risk_category
from mutual_funds
order by risk_category;

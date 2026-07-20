alter table deals
alter column name varchar(100) not null

alter table deals
alter column start_date date not null

alter table deals
add constraint chk_deals_status
check (status in ('Won','Lost','Proposal','Negotiation'))

alter table deals
add constraint chk_deals_dates
check (end_date is null or end_date >= start_date)

alter table products
add constraint chk_products_price
check (price > 0)

alter table products
add constraint uq_products_name unique (name)


-- proc to add a product to a deal
create or alter proc  Add_Product_Deal
    @DealID int,
    @ProductID int
as
begin
if exists (select 1 from Deals where deal_id = @DealID)
  begin
   if exists (select 1 from Products where product_id=@ProductID)
   begin
      insert into Deals_Products (deal_id, product_id)  values (@DealID, @ProductID);
      print 'Product added to deal successfully.'
   end
   else 
   begin
      print 'Error: Product ID Does not exist.'
   end
   end
   else
   begin
   print 'Error: Deal ID does not exist.'
  end
end
exec Add_Product_Deal 8,9
-- trigger update end date for deal
create or alter trigger update_endDate_for_closeDeal
on Deals
after update
as
begin
if update(status)
  begin
   update Deals
   set end_date = getdate()
   from Deals D
   join inserted i ON D.deal_id = i.deal_id
   where i.status IN ('Won', 'Lost')
  end
end
-- check trigger on update 

update Deals set status='Won' where deal_id=1

--Number Of All Deal
create or alter function countalldeals()
returns int
as
begin
    declare @count_deal int
    select @count_deal = count(d.deal_id)
    from deals d
    return @count_deal
end
 select  dbo.countalldeals() as numberDeals

--Number Of Deal Won  
create or alter function count_won_deals()
returns int
as
begin
    declare @count_won_deal int
    select @count_won_deal = count(d.deal_id)
    from deals d
    where d.status = 'Won'
    return @count_won_deal
end
select dbo.count_won_deals() as count_won_deals

--Number Of Deal Lost 
create or alter function count_lost_deals()
returns int
as
begin
    declare @count_lost_deal int
    select @count_lost_deal = count(d.deal_id)
    from deals d
    where d.status = 'Lost'

    return @count_lost_deal
end

select dbo.count_lost_deals() as count_lost_deals

--Count and Percent Per Every Status
create view count_per_Every_Status as 
select status,count(*) as dealcount,
cast(count(*) * 100.0 / sum(count(*)) over ()as decimal(5,2)) as statuspercentage
from Deals
group by status
select * from count_per_Every_Status

--Revenue For Won Deals   
create or alter function total_per_won_deals()
returns decimal(18,2)
as
begin
    declare @total_per_won_deals decimal(18,2)
    select @total_per_won_deals = sum(p.price)
    from deals d
    join deals_products dp on d.deal_id = dp.deal_id
    join products p on p.product_id = dp.product_id
    where d.status = 'Won'
    return @total_per_won_deals
end
select dbo.total_per_won_deals() as total_per_won_deals
--Total value of each deal

create or alter view total_deal_value
as
select d.deal_id,d.name,d.status,sum(p.price) as total_deal_value
from dbo.deals d
join dbo.deals_products dp on d.deal_id = dp.deal_id
join dbo.products p on dp.product_id = p.product_id
group by d.deal_id, d.name, d.status

select * from total_deal_value

select * from total_deal_value
where status = 'won'

select round(avg(total_deal_value), 2) as avg_deal_value
from total_deal_value

select round(avg(total_deal_value), 2) as avg_deal_value
from total_deal_value where status='Won'

--Total revenue per month 
create or alter view total_revenue_per_month
as
select year(d.start_date) as year,month(d.start_date) as month,sum(p.price) as monthly_revenue
from deals d
join Deals_Products dp on d.deal_id = dp.deal_id
join products p on dp.product_id = p.product_id
where d.status = 'Won'
group by year(d.start_date), month(d.start_date)

 select * from total_revenue_per_month order by year,month 

 select * from total_revenue_per_month where year=2025 and month=7

--Highest value deal
create or alter function top_deal()
returns table
as
return
(
    select top 1 
        d.deal_id,
        d.name,
        sum(p.price) as total_value
    from deals d
    join deals_products dp on d.deal_id = dp.deal_id
    join products p on dp.product_id = p.product_id
    group by d.deal_id, d.name
    order by total_value desc
)
select * from dbo.top_deal() as Top_deal

--function Revenue for one Deal
create or alter function get_revenue_per_deal(@DealID int)
returns table
as
return
    select d.deal_id,d.name,d.status, sum(p.price) as total_revenue
    from deals d
    join Deals_Products dp on d.deal_id = dp.deal_id
    join products p on dp.product_id = p.product_id
    where d.deal_id = @DealID 
    group by d.deal_id, d.name,d.status

select  * from get_revenue_per_deal(5)

--- Average of Won Deals
create or alter function average_rvenue()
returns decimal(18,2)
as
begin
    declare @average_rvenue decimal(18,2)
    select @average_rvenue = avg(rvenue_deal)
    from rvenue_for_won_deals
    return @average_rvenue
end
select dbo.average_rvenue() as average_rvenue


--value for Loss Deals
create or alter function total_revenue_lost_deals()
returns decimal(18,2)
as
begin
    declare @total_revenue decimal(18,2);

    select @total_revenue = sum(p.price)
    from dbo.deals d
    join dbo.deals_products dp on d.deal_id = dp.deal_id
    join dbo.products p on dp.product_id = p.product_id
    where d.status = 'lost';

    return @total_revenue;
end

declare @x int
select  @x=dbo.total_revenue_lost_deals()
select @x as total_revenue_lost_deals

--Win Rate 
create or alter function win_rate()
returns decimal(5,2)
as
begin
    declare @total int
    declare @won int
    declare @rate decimal(5,2)
    set @total = dbo.countalldeals()
    set @won   = dbo.count_won_deals()
    if @total = 0
        set @rate = 0
    else
        set @rate = (@won * 100.0) / @total
    return @rate
end
select dbo.win_rate() as Win_Rate


--Lost Rate
create or alter function lost_rate()
returns decimal(5,2)
as
begin
    declare @total int
    declare @lose int
    declare @rate decimal(5,2)
    set @total = dbo.countalldeals()
    set @lose   = dbo.count_lost_deals()
    if @total = 0
        set @rate = 0
    else
        set @rate = (@lose * 100.0) / @total
    return @rate
end
select dbo.lost_rate() as Win_Rate

---Best-selling product
create or alter view Best_SellingProduct as 
    select p.name,count(*) as times_sold
    from Deals_Products dp
    join products p on dp.product_id = p.product_id
    join deals d on dp.deal_id = d.deal_id
    where d.status = 'Won'
    group by p.name

select * from Best_SellingProduct order by times_sold desc

--Distribution of deals by size(small,medium,large)
create view Distribution_Deal as 
select deal_size,count(*) as total_deals
from (select d.deal_id,
case 
    when sum(p.price) < 5000 then 'Small'
    when sum(p.price) between 5000 and 15000 then 'Medium'
    else 'Large'
    end as deal_size
    from deals d
    join Deals_Products dp on d.deal_id = dp.deal_id
    join products p on dp.product_id = p.product_id
    group by d.deal_id
) t
group by deal_size

select * from Distribution_Deal

--Total revenue per product
create view Total_revenue_per_product as 
select 
    p.name,
    sum(p.price) as total_revenue
from Deals_Products dp
join products p on dp.product_id = p.product_id
join deals d on dp.deal_id = d.deal_id
where d.status = 'Won'
group by p.name

select *  from Total_revenue_per_product order by total_revenue desc



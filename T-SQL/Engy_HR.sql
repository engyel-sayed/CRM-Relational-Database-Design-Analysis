/*----------Data Integrity Layer-------*/
/*create salary and hire_date*/
alter table Employees
add Salary int

alter table Employees
add Hire_Date date

alter table Employees
add 
constraint c1_Salary default 8000 for Salary ,
constraint c2_SalaryMin check (Salary >= 8000)

alter table Employees
add constraint c3_Hire default getdate() for Hire_Date


/*-----------------Business Intelligence Layer-----------*/
/*display all employee*/
create view vw_display_employee
as
select e.name as emp_name , e.employee_id , e.email ,
d.dept_id , d.name as departname
from Employees e 
left join 
Departments d
on d.dept_id = e.dept_id

--Display data
select *
from vw_display_employee

/*total activity and deals for employee*/      
create or alter view vw_emp_total_activity_deals 
as
select e.name , e.dept_id , count(d.activity_id) as total_activity ,
COUNT(d.deal_id) as total_deals 
,ROW_NUMBER () OVER(ORDER BY count(d.activity_id) desc) as order_column 
from Employees e 
left join 
Deal_Interactions d
on e.employee_id = d.employee_id
group by e.name , e.dept_id

--Display data
select *
from vw_emp_total_activity_deals
 

/*employees and there status in each department*/ 
create or alter view vw_empployeeStatus
as
select d.name , e.status , COUNT(e.employee_id) as totalemp
from Departments d 
left join 
Employees e
on d.dept_id = e.dept_id
group by d.name , e.status

--display
select * from vw_empployeeStatus
/*--------------Business Logic Layer------------------*/
/*employees without tasks*/     
create function Getempwithoutload()
Returns table
  as
  return
  (
	 select e.*
	 from Employees e
	 where e.employee_id not in(select d.employee_id
	 from Deal_Interactions d)
)
--use function
select * from Getempwithoutload()

/*case there is an old role employee has left the role*/                                            
 create proc p1 @oldrole nvarchar(30) ,@curentempid int, @newrole nvarchar(30) 
as
if exists (select * from Employees e where e.role = @oldrole and e.employee_id = @curentempid )
begin
update Employees
set role = @newrole
where role = @oldrole and employee_id = @curentempid
print 'update done'
end
else
print 'sorry employee not in this role'

--use procedure
exec p1 'Sales Rep' , 5 , 'Support Agent'

/*total employee per department*/     
create proc employeeperdepartment
as
select d.dept_id, d.name , count(e.employee_id) as total_employee
from Employees e , Departments d
where d.dept_id = e.dept_id
group by d.dept_id, d.name

--use procedure
exec employeeperdepartment

/*AnnualIncrease for employee*/  
create or alter proc p3_AnnualIncrease
as
update Employees
set Salary = Salary * 1.10
where status = 'Active' and YEAR(GETDATE()) - YEAR(Hire_Date) >=1

--use Procedure
exec p3_AnnualIncrease

/*-----------------Protection Layer-----------------*/
/*SalaryProtection*/
create trigger t1_SalaryProtection
on Employees
after update
as
    if exists
    (
        select i.employee_id , i.name
        from inserted i
        join deleted d
        on i.employee_id = d.employee_id
        where i.Salary < d.Salary
    )
    begin
        print('Salary cannot be decreased.')
        rollback
        return
    end

--test
update Employees
set Salary =8000
where employee_id = 1

/*Salaryincrease*/
create trigger t2_Salaryincrease
on Employees
after update
as
     if exists
    (
        select i.employee_id , i.name
        from inserted i
        join deleted d
        on i.employee_id = d.employee_id
        where i.Salary > d.Salary * 1.20
    )
    begin
        Print('Salary increase exceeds 20%% limit.')
        rollback
        return
    end
--test
update Employees
set Salary = Salary * 1.30
where employee_id = 2
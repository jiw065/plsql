Create table Employee (Id int, Name varchar(255), Salary int, DepartmentId int);
Create table Department (Id int, Name varchar(255));
Truncate table Employee;
insert into Employee (Id, Name, Salary, DepartmentId) values ('1', 'Joe', '70000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('2', 'Jim', '90000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('3', 'Henry', '80000', '2');
insert into Employee (Id, Name, Salary, DepartmentId) values ('4', 'Sam', '60000', '2');
insert into Employee (Id, Name, Salary, DepartmentId) values ('5', 'Max', '90000', '1');
Truncate table Department;
insert into Department (Id, Name) values ('1', 'IT');
insert into Department (Id, Name) values ('2', 'Sales');

select d.name,e1.name,e1.salary from employee e1, department d,
(select e.departmentid,max(e.salary) msal from employee e
group by e.departmentid) t
where e1.departmentid = d.id
and e1.salary = t.msal
and d.id = t.departmentid;

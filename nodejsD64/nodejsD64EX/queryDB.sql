-- Create Table

create table employees(
                          id bigserial not null,
                          name text,
                          salary int,
                          active boolean default true,
                          constraint pk_employee primary key (id)
);
create table departments(
                            id bigserial not null,
                            name text,
                            active boolean default true,
                            constraint pk_department primary key (id)
);

-- Add Data

insert into departments (name) values ('HR'),
                                      ('Sale'),
                                      ('Marketing'),
                                      ('IT'),
                                      ('Production'),
                                      ('R&D');
insert into employees (name, salary) values ('A', 5),
                                            ('B', 7),
                                            ('C', 10),
                                            ('D', 12),
                                            ('E', 15),
                                            ('F', 22),
                                            ('G', 8),
                                            ('H', 31),
                                            ('I', 34),
                                            ('J', 4),
                                            ('K', 39);

-- Mỗi nhân viên trong 1 phòng ban

alter table employees add column department_id bigint;
update employees set department_id = FLOOR(RANDOM() * 6) + 1 where true;

-- Query

-- Danh sách nhân viên và phòng ban của họ
select employees.id, employees.name, departments.name as department
from employees join departments on departments.id = employees.department_id
where true
order by employees.id;

-- Nhân viên có lương lớn hơn 10tr
select employees.id, employees.name, employees.salary
from employees
where employees.salary > 10
order by employees.id;

-- Đếm số nhân viên trong mỗi phòng ban
select departments.name, count(employees.name) as count
from departments join employees on employees.department_id = departments.id
where true
group by departments.name;

-- Cập nhật lương của 1 nhân viên cụ thể
update employees set salary = 17 where name = 'E';

-- Xóa 1 phòng ban (cùng với các nhân viên thuộc phòng ban đó). VD: Phòng ban Marketing
-- delete from employees where department_id = (select id from departments
--                                                        where name = 'Marketing');
-- delete from departments where name = 'Marketing';
-- Thực thế không sử dụng lệnh delete
update employees set active = false where department_id = (select id from departments
                                                           where name = 'Marketing');
update departments set active = false where name = 'Marketing';

--

select * from departments order by departments.id;
select * from employees order by employees.id;
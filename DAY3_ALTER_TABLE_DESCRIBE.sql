
-- create students table
create table Students
(RollNumber  int primary key,
    sname varchar(50), 
       Address varchar(100),
          ContactNumber varchar(15));


-- create faculty table
create table  Faculties
(FacultyId int primary key,
    fName varchar(50) not null, 
       class varchar(25),
           email varchar(100) );


describe Students;
describe Faculties;

-----------------------------
insert into Students (RollNumber, sname, Address, ContactNumber)
values(12, 'Abhishek', 'New Delhi', '658689489'), 
          (25, 'Aman', 'Bengaluru', '3256987412'),
          (36, 'Anshul', 'Hyderabad', '258746985'),
          (65, 'Anand', 'Kolkata', '236541987'),
          (69, 'Abhishek', 'New Delhi', '254136854');

insert into Faculties (FacultyId, fName, class, email)
values(1, 'Shah', 'Math', 'shah@xyz.com'),
          (2, 'Kumar', 'Hindi', 'kumar@xyz.com'),
          (3,'Dahiya', 'English', 'dahiya@xyz.com'),
          (4, 'Gairols', 'Science', 'gairols@xyz.com');

select * from Students;
select * from Faculties;



--------------------------------
-- altering the table to add new column
alter table Students
add  DOB date;

describe Students;

----------------------------
-- alter the table tp drop the ccolumn which u feel is not necessary
alter table Students
drop column Contactnumbers;

describe Students;
------------------------------
-- changing datatype of a column

alter table Students
modify column DOB year;

describe Students;

---------------------
-- renaming a column

alter table Students
rename column sname to FullName;

describe Students;


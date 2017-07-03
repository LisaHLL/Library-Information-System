drop table Books;
drop table Author;
drop table Borrower;
drop table Issue;
drop table Pending_request;


CREATE TABLE Books
(
book_id number PRIMARY KEY,
book_title varchar2(50),
author_id number,
year_of_publication number,
edition number,
status varchar2(20)
);

CREATE TABLE Author
(
author_id number PRIMARY KEY,
Name varchar2(30)
);

CREATE TABLE Borrower
(
borrower_id number PRIMARY KEY,
name varchar2(30),
status varchar2(20)
);

CREATE TABLE Issue
(
book_id number,
borrower_id number,
issue_date date,
return_date date,
PRIMARY KEY (book_id, borrower_id, issue_date)
);

CREATE TABLE Pending_request
(
book_id number,
requester_id number,
request_date date,
Issue_date date,
PRIMARY KEY (book_id, requester_id, request_date)
);

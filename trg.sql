rem EE562 Project 2
rem HSIANG-LING LIN
rem lin643@ecn2

CREATE TRIGGER trg_maxbooks
BEFORE INSERT ON Issue
FOR EACH ROW

DECLARE
x number;
y varchar2(20);
BEGIN 
	SELECT COUNT(Issue.borrower_id) INTO x
	FROM Issue
	WHERE Issue.borrower_id= :new.borrower_id;
	
	SELECT Borrower.status INTO y
	FROM Borrower
	WHERE Borrower.borrower_id= :new.borrower_id;
	
	IF (y='student' AND x>=2)
	 Then raise_application_error(-20000,'exceed 2');
	ELSIF (y='faculty' AND x>=3)
	 THEN raise_application_error(-20001,'exceed 3');

	END IF;

END ;
/ 



CREATE TRIGGER trg_charge
AFTER INSERT ON Issue
FOR EACH ROW

BEGIN
     UPDATE Books
     SET status='charged'
     WHERE book_id= :new.book_id;
END;
/



CREATE TRIGGER trg_notcharge
AFTER UPDATE OF return_date ON Issue
FOR EACH ROW

BEGIN
     UPDATE Books
     SET status='notcharged';
END;
/



CREATE TRIGGER  trg_renew
BEFORE INSERT ON Pending_request
FOR EACH ROW
DECLARE
x varchar2(20);
y number;
z number;
w number;
u number;


BEGIN

	
	SELECT Books.status INTO x 
	FROM Books	
	WHERE Books.book_id= :new.book_id;
	
	
	SELECT COUNT(*) INTO y
	FROM Issue I
	WHERE I.borrower_id= :new.requester_id AND I.return_date is NULL;
	

	SELECT COUNT(*) INTO z
	FROM Pending_request P
	WHERE P.requester_id= :new.requester_id AND P.Issue_date is NULL;
	
	SELECT COUNT(*) INTO w
	FROM Pending_request P
	WHERE P.requester_id= :new.requester_id AND P.book_id= :new.book_id AND P.issue_date is NULL;
	
	SELECT COUNT(*) INTO u
	FROM Issue I
	WHERE I.borrower_id= :new.requester_id AND I.book_id= :new.book_id AND I.return_date is NULL;



	IF x='charged' AND (y+z)>6
	THEN raise_application_error(-20003,'the number of your borrowed books and requested books has reached 7');
	ELSIF x='charged' AND w=1
	THEN raise_application_error(-20005,'you have been requested the book before');
	ELSIF x='charged' AND u=1   
	THEN raise_application_error(-20002,'you can not renew the book');
	

	END IF;
END;
/


rem EE562 Project 2
rem HSIANG-LING LIN
rem lin643@ecn2

SET SERVEROUTPUT ON
CREATE FUNCTION fun_issue_book
	(borrower_id IN number, b_id IN number, currentdate IN date)
RETURN NUMBER

IS
x varchar2(20);

BEGIN
	SELECT Books.status INTO x  
	FROM Books
	WHERE Books.book_id=b_id;

	IF (x='not charged')
	THEN 
	 INSERT INTO Issue values (b_id, borrower_id, currentdate, NULL);
	 RETURN 1;
	ELSIF (x='charged')
	THEN 
	 INSERT INTO Pending_request values (b_id, borrower_id, currentdate,NULL);
	 RETURN 0;

	END IF;

END;
/


CREATE FUNCTION fun_issue_anyedition
	(bor_id IN number, book_title IN varchar2, author_name IN varchar2, currentdate IN date)
RETURN NUMBER

IS 
 	
x number;
y number;
z number;
		
BEGIN
	begin
	SELECT Bx.book_id into x
	FROM Books Bx, Author A
	WHERE Bx.status!='charged' AND Bx.book_title=book_title AND A.Name=author_name AND Bx.author_id=A.author_id AND Bx.edition=(SELECT MAX(Books.edition)
														  		       FROM Books, Author
														  		       WHERE Books.status!='charged' AND Books.book_title=book_title AND Author.Name=author_name AND 																									Books.author_id=Author.author_id);
	exception
	when no_data_found then
	x :=NULL;
	END;

	begin
	SELECT MAX(I.book_id) into y
	FROM Issue I, Books B, Author A
	WHERE B.book_title=book_title AND A.Name=author_name AND I.book_id=B.book_id AND B.author_id=A.author_id AND I.return_date is NULL
				    AND I.issue_date <= ALL (SELECT I2.issue_date
				    			     FROM Issue I2, Books B2, Author A2
				   		             WHERE B2.book_title=book_title AND A2.Name=author_name AND A2.author_id=B2.author_id AND B2.book_id=I2.book_id AND I2.return_date is NULL);
	exception
	when no_data_found then
	y :=NULL;
	end;

	IF x is NULL
	THEN
	z :=fun_issue_book(bor_id,y, currentdate);
	RETURN 0;
	ELSIF x is not NULL
	THEN
	INSERT INTO Issue VALUES(x, bor_id, currentdate, NULL);
	RETURN 1;
	
	END IF;
END;
/



CREATE FUNCTION fun_most_popular
	(month IN varchar2)
RETURN NUMBER

IS 
x number:=fun_month_to_number(month);
y number;
z number;

l_return SYS_REFCURSOR;

BEGIN
DBMS_OUTPUT.PUT_LINE('Most popular book :');


	OPEN l_return FOR
 
		SELECT I.book_id, extract(year FROM I.issue_date) AS year
		FROM Issue I
		WHERE extract(month FROM I.issue_date)=x AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=x))
		GROUP BY I.book_id, extract(year FROM I.issue_date)
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=x AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);


LOOP
fetch l_return into y,z;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||y||' '||month||' '||z);
END LOOP;

RETURN 0;

END fun_most_popular;
/



CREATE FUNCTION fun_return_book
	(b_id number, r_date date)
RETURN NUMBER

IS
x number;
	

BEGIN
	begin
	SELECT Pending_request.requester_id into x
	FROM Pending_request
	WHERE Pending_request.book_id=b_id AND Pending_request.Issue_date is NULL AND Pending_request.request_date=(SELECT MIN(P.request_date) FROM Pending_request P WHERE P.book_id=b_id AND P.Issue_date is NULL);
	
	exception
	when no_data_found then
	x :=NULL;
	END;



	IF x is NULL 
	THEN
		UPDATE Issue
		SET return_date=r_date
		WHERE book_id=b_id AND return_date is NULL; 
		RETURN 1;
	ELSIF x is not NULL
	THEN
		UPDATE Issue
		SET return_date=r_date
		WHERE book_id=b_id AND return_date is NULL;
		INSERT INTO Issue values (b_id, x, r_date, NULL);
		UPDATE Pending_request 
		SET Issue_date=r_date
		WHERE requester_id=x AND book_id=b_id AND Issue_date is NULL;
		
		RETURN 0;
	END IF;

END;
/




CREATE FUNCTION fun_month_to_number
	(m IN varchar2)
RETURN NUMBER
IS

BEGIN
	IF m='JAN'
	THEN return 01;
	ELSIF m='FEB'
	THEN return 02;
	ELSIF m='MAR'
	THEN return 03;
	ELSIF m='APR'
	THEN return 04;
	ELSIF m='MAY'
	THEN return 05;
	ELSIF m='JUN'
	THEN return 06;
	ELSIF m='JUL'
	THEN return 07;
	ELSIF m='AUG'
	THEN return 08;
	ELSIF m='SEP'
	THEN return 09;
	ELSIF m='OCT'
	THEN return 10;
	ELSIF m='NOV'
	THEN return 11;
	ELSIF m='DEC'
	THEN return 12;
	
	END IF;
END fun_month_to_number;
/

	

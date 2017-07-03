rem EE562 Project 2
rem HSIANG-LING LIN
rem lin643@ecn2

SET SERVEROUTPUT ON
CREATE PROCEDURE pro_print_borrower

IS


CURSOR x_cur IS
	SELECT B.name, Bx.book_title, I.issue_date
	FROM Borrower B, Issue I, Books Bx
	WHERE I.return_date is NULL AND B.borrower_id=I.borrower_id AND I.book_id=Bx.book_id;
	
b_name varchar2(30);
b_title varchar2(50);
i_date date;
y number;


BEGIN
	OPEN x_cur;
	DBMS_OUTPUT.PUT_LINE('Borrower Name |Book title         | <=5 |        <=10       | <=15 |      >15 ');
	DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------------------------');
	LOOP
	 FETCH x_cur into b_name, b_title, i_date;
	 EXIT WHEN x_cur%NOTFOUND;
	 y := trunc(sysdate)-to_date(i_date,'MM/DD/YY');
	 IF (y<=5)
	 THEN DBMS_OUTPUT.PUT_LINE(b_name||'   '||b_title||' '||y);
	 ELSIF(y between 6 AND 10)
	 THEN DBMS_OUTPUT.PUT_LINE(b_name||'   '||b_title||'                '||y);
	 ELSIF(y between 11 AND 15)
	 THEN DBMS_OUTPUT.PUT_LINE(b_name||'   '||b_title||'                                '||y);
	 ELSIF(y>15)
	 THEN DBMS_OUTPUT.PUT_LINE(b_name||'   '||b_title||'                                           '||y);
	 END IF;
	END LOOP;
	CLOSE x_cur;



END;
/




CREATE PROCEDURE pro_print_fine
	(currentdate IN date)

IS 
d date;
d2 date;
name varchar2(30);
id number;

CURSOR a_cur IS
	
	
	SELECT B.name, I.book_id, I.issue_date, I.return_date
	FROM Issue I, Borrower B
	WHERE (I.return_date-I.issue_date>5 AND I.borrower_id=B.borrower_id) OR (I.issue_date+5<currentdate AND I.return_date is NULL AND I.borrower_id=B.borrower_id);
	
BEGIN
	OPEN a_cur;
	LOOP
	 FETCH a_cur INTO name, id, d, d2;
	 EXIT WHEN a_cur%NOTFOUND;
	 IF d2 IS NULL
	 THEN DBMS_OUTPUT.PUT_LINE('NAME:'||name||'     BOOK ID:'||id||'     ISSUE DATE:'||d||'        FINE'||(currentdate-d)*5);
	 ELSE
	 DBMS_OUTPUT.PUT_LINE('NAME:'||name||'     BOOK ID:'||id||'     ISSUE DATE:'||d||'        FINE'||(d2-d)*5);
	 
	 END IF;
	END LOOP;
	CLOSE a_cur;

END;
/


CREATE PROCEDURE pro_listborr_mon
	(borrower_id IN number, mon IN varchar2)

IS
x number :=fun_month_to_number(mon);
ber_id number;
name varchar2(30);
b_id number;
b_title varchar2(50);
i_date date;
r_date date;


CURSOR b_cur IS
	SELECT I.borrower_id, B.name, I.book_id, Bx.book_title, I.issue_date, I.return_date
	FROM Issue I, Borrower B, Books Bx
	WHERE extract(month FROM I.issue_date)=x AND I.borrower_id=B.borrower_id AND I.book_id=Bx.book_id;

BEGIN
	OPEN b_cur;
	DBMS_OUTPUT.PUT_LINE('Borrower ID | Borrower Name | Book ID | Book Title |    Issue Date |    Return Date   ');
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
	LOOP
	 FETCH b_cur INTO ber_id, name, b_id, b_title, i_date, r_date;
	 EXIT WHEN b_cur%NOTFOUND;
	 DBMS_OUTPUT.PUT_LINE(ber_id||'            '||name||'    '||b_id||'    '||b_title||'   '||i_date||'             '||r_date);
	END LOOP; 
	CLOSE b_cur;

END;
/

CREATE PROCEDURE pro_listborr

IS

name varchar2(30);
b_id number;
i_date date;

CURSOR c_cur IS
	SELECT B.name, I.book_id, I.issue_date
	FROM Borrower B, Issue I
	WHERE I.borrower_id=B.borrower_id AND  I.return_date IS NULL;


BEGIN

	OPEN c_cur;
	DBMS_OUTPUT.PUT_LINE('BORROWER NAME      BOOK ID        ISSUE DATE');
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
	LOOP
	 FETCH c_cur INTO name, b_id, i_date;
	 EXIT WHEN c_cur%NOTFOUND;
	 DBMS_OUTPUT.PUT_LINE(name||'          '||b_id||'           '||i_date);
	END LOOP;
	CLOSE c_cur;

END;
/



CREATE PROCEDURE pro_list_popular

IS 

x number;
y number;
z number;
w varchar2(30);
m number;

l_return SYS_REFCURSOR;

BEGIN
		OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=1 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=1)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=1 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=2 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=2)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=2 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;
 
		OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=3 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=3)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=3 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=4 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=4)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=4 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=5 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=5)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=5 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=6 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=6)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=6 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;
 
		OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=7 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=7)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=7 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=8 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=8)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=8 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=9 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=9)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=9 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=10 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=10)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=10 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;
 
		OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=11 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=11)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=11 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

		OPEN l_return FOR
 
		SELECT I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		FROM Issue I,Books Bx, Author A
		WHERE extract(month FROM I.issue_date)=12 AND (extract(year FROM I.issue_date) IN(SELECT extract(year from I2.issue_date)
												FROM Issue I2
												WHERE extract(month from I2.issue_date)=12)) AND Bx.book_id=I.book_id AND Bx.author_id=A.author_id
		GROUP BY I.book_id, extract(month from I.issue_date), extract(year FROM I.issue_date),Bx.edition, A.Name
		HAVING COUNT(*)>= ALL (SELECT COUNT(*)
				       FROM Issue I3
				       WHERE extract(month from I3.issue_date)=12 AND extract(year from I3.issue_date)=extract(year from I.issue_date)
	 			       GROUP BY I3.book_id)
		order by extract(year from I.issue_date);
		
LOOP
fetch l_return into x,y,z,m,w;
exit when l_return%notfound;
DBMS_OUTPUT.PUT_LINE('Book Id:'||x||'  month/year:'||y||'/'||z||' Edition:'||m||' Author:'||w);
END LOOP;

END;
/



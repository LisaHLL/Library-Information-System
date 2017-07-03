rem EE562 Project 2
rem HSIANG-LING LIN
rem lin643@ecn2

SET SERVEROUTPUT ON
@populate
@trg
@fun
@pro
ALTER SESSION SET NLS_DATE_FORMAT='MM/DD/YY';
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_book(1,4,'3/3/08'));

EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_book(2,1,'4/3/05'));

EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_book(3,2,'3/8/05'));

EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_book(5,4,'5/6/05'));

EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_book(7,15,'5/6/05'));

EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(2,'DATA MANAGEMENT','C.J. DATES','3/3/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(4,'CALCULUS','H. ANTON','3/4/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(5,'ORACLE','ORACLE PRESS','3/4/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(10,'IEEE MULTIMEDIA','IEEE','2/27/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(2,'MIS MANAGEMENT','C.J. CATES','5/3/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(4,'CALCULUS II','H. ANTON','3/4/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(10,'ORACLE','ORACLE PRESS','3/4/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(5,'IEEE MULTIMEDIA','IEEE','2/26/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(2,'DATA STRUCTURE','W. GATES','3/3/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(4,'CALCULUS III','H. ANTON','4/4/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(11,'ORACLE','ORACLE PRESS','3/8/05'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_issue_anyedition(6,'IEEE MULTIMEDIA','IEEE','2/17/05'));

begin

pro_print_borrower;
pro_print_fine('4/5/05');


end;
/

EXEC DBMS_OUTPUT.PUT_LINE(fun_return_book(1,'10/11/15'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_return_book(2,'10/11/15'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_return_book(4,'10/11/15'));
EXEC DBMS_OUTPUT.PUT_LINE(fun_return_book(10,'10/11/15'));

SELECT* FROM Pending_request;
SELECT* FROM Issue;

begin

pro_listborr_mon(1,'FEB');
pro_listborr_mon(1,'MAR');

end;
/
begin

pro_listborr;

end;
/
begin

pro_list_popular;

end;
/


SELECT AVG(P.Issue_date-P.request_date)
FROM Pending_request P;

SELECT B.name, B.borrower_id
FROM Pending_request P, Borrower B
WHERE issue_date-request_date=(SELECT max(issue_date-request_date)
			       FROM Pending_request) AND P.requester_id=B.borrower_id;


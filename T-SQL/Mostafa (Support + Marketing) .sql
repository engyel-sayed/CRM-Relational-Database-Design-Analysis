-- Mostafa Khaled Sayed (Team 5 )
-- CRM (Support - Marketing)  : 
---------------------------------------------------------
-- [CONSTRAINS]

--[1] Ticket statue date Integrity (Check Constrain ) :
ALTER table Support_Tickets
ADD CONSTRAINT Statue_Validation
Check (status IN ('Open','Resolved','Closed','In progress'));
GO 

-- test case 
INSERT into Support_Tickets (issue_description,status,client_id,employee_id) 
Values ('Mouse broken' , 'finished ',1,3) ; 
---------------------------------------------------------
--[2] Check Budget (Check Constrain ) :
Alter TABLE Marketing_Campaigns
add CONSTRAINT Check_budgett
check (budget >=0) ; 
Go 

-- test case 
INSERT into Marketing_Campaigns (name,budget) 
Values ('test ',-1000) ; 

---------------------------------------------------------
--[3] Check date (Check Constrain ) :

Alter table Marketing_Campaigns
add CONSTRAINT Check_date 
check (end_date >= start_date);

---- test case 
Insert into Marketing_Campaigns (name,end_date,start_date)
VALUES('Hurghada' ,'2026-06-01' ,'2026-08-31' )
GO

---------------------------------------------------------
---------------------------------------------------------
--[Functions]
-- 1 calculate ticket age (scalar function)

CREATE FUNCTION Hours (@TicketID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Hours INT;
    SELECT @Hours = DATEDIFF(HOUR, created_at, GETDATE())
    FROM Support_Tickets
    WHERE ticket_id = @TicketID;
    RETURN @Hours;
END;
GO

SELECT  dbo.Hours(6) AS 'Age_In_Hours'


select * from Support_Tickets
---------------------------------------------------------
---------------------------------------------------------
--[view] show only open and in progress status tickets 
GO

CREATE VIEW vw_Active_Support_Queue
AS
SELECT 
    t.ticket_id,
    c.name AS Client_Name,   
    t.issue_description,
    t.priority,
    t.status,
    t.created_at,
    dbo.Hours(t.ticket_id) AS Hours_Open 
FROM Support_Tickets t
JOIN Clients c ON t.client_id = c.client_id
WHERE t.status IN ('Open', 'In Progress'); 
GO

------TEST------
SELECT * FROM vw_Active_Support_Queue;

---------------------------------------------------------
-- stored procedure(Button to close tickets)
---------------------------------------------------------

GO 
CREATE PROCEDURE sp_CloseTicket
    @TicketID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Support_Tickets WHERE ticket_id = @TicketID)
    BEGIN
        PRINT 'Error: Ticket ID not found!';
        RETURN; 
    END
    UPDATE Support_Tickets
    SET status = 'Closed'
    WHERE ticket_id = @TicketID;

    PRINT 'Success: Ticket #' + CAST(@TicketID AS VARCHAR) + ' has been closed.';
END;
GO

-- ==========================================
-- testing
-- ==========================================

Execute sp_CloseTicket @TicketID = 6;

SELECT * FROM Support_Tickets WHERE ticket_id = 6;

UPDATE Support_Tickets 
set status = 'open'
where ticket_id = 6

---------------------------------------------------------
-- Trigger : sign closed tickets date (automation)
---------------------------------------------------------

ALTER TABLE Support_Tickets
ADD closed_at DATETIME NULL;
GO 

Create TRIGGER trg_AutoCloseDate
ON Support_Tickets
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(status) RETURN;
    UPDATE t
    SET t.closed_at = GETDATE()
    FROM Support_Tickets t
    INNER JOIN inserted i ON t.ticket_id = i.ticket_id
    WHERE i.status = 'Closed';
END;
GO


---------------------------------------------------------
-- Cursor  : feedback where closed tickets
---------------------------------------------------------

DECLARE @TicketID INT;
DECLARE @ClientEmail VARCHAR(100);
DECLARE FeedbackCursor CURSOR FOR
SELECT 
    t.ticket_id, 
    c.email
FROM Support_Tickets t
INNER JOIN Clients c ON t.client_id = c.client_id
WHERE t.status = 'Closed' 
  AND t.feedback_sent = 0; 

OPEN FeedbackCursor;
FETCH NEXT FROM FeedbackCursor INTO @TicketID, @ClientEmail;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Sending Feedback Request to: ' + @ClientEmail + ' (For Ticket #' + CAST(@TicketID AS VARCHAR) + ')';
    UPDATE Support_Tickets
    SET feedback_sent = 1
    WHERE ticket_id = @TicketID;

    FETCH NEXT FROM FeedbackCursor INTO @TicketID, @ClientEmail;
END;






CLOSE FeedbackCursor;
DEALLOCATE FeedbackCursor;

select * from Support_Tickets





















SELECT name 
FROM sys.triggers 
WHERE parent_id = OBJECT_ID('Support_Tickets');


DROP TRIGGER trg_AutoCloseDate;
DROP TRIGGER trg_AutoCloseDatee;
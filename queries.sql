USE library_db;

-- 1. Basic SELECT
SELECT * FROM books LIMIT 10;

-- 2. Join: list loans with member and book info
SELECT l.loan_id, b.title, CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       l.loan_date, l.due_date, l.return_date, l.status
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
ORDER BY l.loan_date DESC;

-- 3. Aggregate: top borrowed books (count of loans)
SELECT b.book_id, b.title, COUNT(*) AS times_borrowed
FROM loans ln
JOIN books b ON ln.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC
LIMIT 10;

-- 4. Subquery: members who have active loans
SELECT DISTINCT m.member_id, m.first_name, m.last_name
FROM members m
WHERE EXISTS (
  SELECT 1 FROM loans l WHERE l.member_id = m.member_id AND l.status = 'loaned'
);

-- 5. Overdue report (due_date < today and not returned)
SELECT l.loan_id, b.title, CONCAT(m.first_name,' ',m.last_name) AS member, l.due_date
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE();

-- 6. Update available copies when a loan is created (example only)
-- (This should be done in a transaction or stored procedure)
UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = 1 AND available_copies > 0;

-- 7. Create a view for overdue loans
CREATE OR REPLACE VIEW vw_overdue_loans AS
SELECT l.loan_id, b.title, m.member_id, CONCAT(m.first_name,' ',m.last_name) AS member_name,
       l.due_date, DATEDIFF(CURRENT_DATE(), l.due_date) AS days_overdue
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE();

SELECT * FROM vw_overdue_loans;

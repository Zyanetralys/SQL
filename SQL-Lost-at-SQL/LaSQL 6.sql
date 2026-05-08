/*
Select all of the circuits where the area is 'pod 03' or the status is NOT green.
*/

SELECT *
FROM circuits
WHERE area = 'pod 03' OR status <> 'green';

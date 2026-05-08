/*
Count the crew based on their last known location AND their status.

(Use the staff_name column in your count - we could use any column to count but we're going to use staff_name).

Call the column you make 'crew_count'.

Chapter 8

Sinclair's parties are wading through the flooded halls, dragging their crewmates back to the escape pods.

Even with the information you're sending through - they are fast running out of time. You've got to make a call.

"OK Sinclair - call the parties, tell them to leave the dead, prioritise the injured, and tell anyone healthy they have to make their own way to the pods. I'll send you through new numbers to prioritise the floors."

You're not sure if she can hear you over the clamour her end of the line but you shout over it anyway.

"Do not send anyone for me! Do you hear me Helga?" No response.

You need to find out how many of the crew are in different places, AND what different states of health. Group by the the last_location column and the status column. Count the staff_name column and call it crew_count. 
*/

SELECT last_location, status, COUNT(*) AS crew_count
FROM crew
GROUP BY last_location, status;

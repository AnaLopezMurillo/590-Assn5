# Assignment 5

By: Isabel Lopez Murillo and Caitlyn Kim

### Design Rationale

We ended up running into several different issues like the barber just sleeping without checking if there are more customers in the queue, so from there we decided to explicitly design a waiting room. The waiting list works as a FIFO queue where customers' hair is cut based on priority of when they arrived. Once a customer is done, the waiting room process will send the next customer in the queue to the barber, who cuts their hair for a random time between 0-3 seconds. 

We also had confusion when trying to track which customers went where, so we designed an id system where we know which customer is where through reporting which customer id is being served.

# Hotel-Database-Project
The design of a relational-document database. <br/>
It represents relational-document hotel database. It contains only two main departments - reception and additional services. <br/>

This database project focuses on combining the advantages of the relational and document models. The document model is more flexible in terms of data storage. 
This means that any type of document can be loaded into the database, without the need to specify its structure.
As a result, you do not have to re-create the schema in the database for every small change, as when using the relational model alone. 
Furthermore, it allows all object data to be stored in a single document.
This is ideal when generating reports related to the implemented USALI standard, where there are many different variables and economic indicators that, once calculated for a given time period, need to be stored in a single document. 
In addition, the implementation of the document model allows for the collection of large amounts of unrelated, complex information with different structures, so it is ideal for storing guest surveys that contain an evaluation of many different aspects of the hotel's performance in a heterogeneous form.

Using a document model for dynamically changing attributes of ancillary services makes them easier to manage and faster to read.
In addition, changing the attributes of one service does not affect the others. When using the relational model alone, managing a large number of attributes is inefficient and affects reading performance.
However, the relational model is simple to implement and easy to understand, and thanks to the principles of normalisation, it prevents information distortion, reduces data redundancy and allows consistency. 
In the relational model, tables are independent of each other and can be modified in any way. 
This makes it an easy way to organise data on specific company processes. Separate tables store data on guests, employees, rooms, services or payments made. 
Data from multiple tables can be combined with each other in various queries. Well-written queries allow relatively fast access to specific information, especially in the case of an extensive database. 
Furthermore, a relational database is a better choice as the complexity of queries increases.
A document database does not offer, among other things, complex joins, subqueries and nested queries in the WHERE clause. 
Combining the relational model with the document model allows the database system under design to be appropriately matched to the requirements placed upon it. 
This hybrid approach provides greater flexibility in handling different types of data, guarantees read and write consistency without performance degradation, and allows data from relational and document formats to be combined in the same SQL queries, e.g. comparing individual economic indicators found in XML reports with their current values, which are calculated from the contents of many different tables.

This project is based on my knowledge of hotel industry, I am not a professional. Creating this project is just fun for me. </br>




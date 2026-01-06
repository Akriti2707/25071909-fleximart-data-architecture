# NoSQL Database Analysis – FlexiMart

## Section A: Limitations of RDBMS

The current relational database design works well for structured sales data, but it becomes restrictive when managing a highly diverse product catalog. Different product types often require different attributes. For example, laptops may need RAM, processor, and storage fields, while shoes require size, color, and material. In a relational database, supporting these variations typically requires many nullable columns or multiple subtype tables, which increases schema complexity and maintenance effort.

Frequent schema changes are another limitation. Adding a new product type or attribute requires altering table definitions, which can be disruptive in production environments and may require application downtime. This makes rapid iteration difficult as the product catalog evolves.

Additionally, storing customer reviews in a relational model is inefficient. Reviews would need a separate table with foreign keys, and retrieving products along with their reviews requires joins that become expensive as data volume grows. Nested data structures such as reviews and ratings are not naturally supported in relational systems, leading to increased query complexity and reduced flexibility.

---

## Section B: Benefits of NoSQL (MongoDB)

MongoDB addresses these limitations by using a flexible, document-based schema. Each product can store its attributes as needed without enforcing a fixed structure. This allows laptops, clothing, and groceries to coexist in the same collection while still storing category-specific fields. New attributes can be added without modifying existing documents or schemas, enabling faster development and easier catalog expansion.

MongoDB also supports embedded documents, which makes it well suited for storing customer reviews directly within product documents. Reviews can be stored as an array of sub-documents, allowing products and their reviews to be retrieved in a single query. This reduces the need for joins and simplifies application logic.

Another key advantage is horizontal scalability. MongoDB is designed to scale across multiple nodes using sharding, which makes it suitable for handling large volumes of product data and high read/write traffic. This is particularly useful for growing e-commerce platforms with expanding catalogs and user activity.

---

## Section C: Trade-offs

While MongoDB offers flexibility, it also has trade-offs compared to MySQL. One disadvantage is weaker enforcement of data consistency. Relational databases provide strong schema validation and referential integrity through constraints and foreign keys, which MongoDB does not enforce by default. This places more responsibility on the application layer to maintain data quality.

Another disadvantage is the complexity of analytical queries. Aggregations across large datasets, especially those involving multiple dimensions, are often easier and more performant in relational databases. For reporting and financial analysis, SQL-based systems are generally better suited than document-oriented databases.

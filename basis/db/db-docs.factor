! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes kernel help.markup help.syntax sequences
alien assocs strings math multiline quotations ;
IN: db

HELP: db
{ $description "The " { $snippet "db" } " class is the superclass of all other database classes. It stores a " { $snippet "handle" } " to the database as well as insert, update, and delete queries." } ;

HELP: new-db
{ $values { "class" class } { "obj" object } }
{ $description "Creates a new database object from a given class with caches for prepared statements. Does not actually connect to the database until " { $link db-open } " or " { $link with-db } " is called." } ;

HELP: db-open
{ $values { "db" db } { "db" db } }
{ $description "Opens a database using the configuration data stored in a " { $link db } " tuple. The database object now references a database handle that must be cleaned up. Therefore, it is better to use the " { $link with-db } " combinator than calling this word directly." } ;

HELP: db-close
{ $values { "handle" alien } }
{ $description "Closes a database using the handle provided. Use of the " { $link with-db } " combinator is preferred over manually opening and closing databases so that resources are not leaked." } ;

HELP: dispose-statements
{ $values { "assoc" assoc } }
{ $description "Disposes an associative list of statements." } ;

HELP: db-dispose
{ $values { "db" db } }
{ $description "Disposes of all the statements stored in the " { $link db } " object." } ;

HELP: statement
{ $description "A " { $snippet "statement" } " stores the information about a statemen, such as the SQL statement text, the in/out parameters, and type information." } ;

HELP: result-set
{ $description "An object encapsulating a raw SQL result object. There are two ways in which a result set can be accessed, but they are specific to the database backend in use."
    { $subsection "db-random-access-result-set" }
    { $subsection "db-sequential-result-set" }
} ;

HELP: new-result-set
{ $values
     { "query" "a query" } { "handle" alien } { "class" class }
     { "result-set" result-set } }
{ $description "Creates a new " { $link result-set } " object of type " { $snippet "class" } "." } ;

HELP: new-statement
{ $values { "sql" string } { "in" sequence } { "out" sequence } { "class" class } { "statement" statement } }
{ $description "Makes a new statement object from the given parameters." } ;

HELP: <simple-statement>
{ $values { "string" string } { "in" sequence } { "out" sequence }
    { "statement" statement } }
{ $description "Makes a new simple statement object from the given parameters." } ;

HELP: <prepared-statement>
{ $values { "string" string } { "in" sequence } { "out" sequence }
    { "statement" statement } }
{ $description "Makes a new prepared statement object from the given parameters." } ;

HELP: prepare-statement
{ $values { "statement" statement } }
{ $description "For databases which implement a method on this generic, it does some internal processing to ready the statement for execution." } ;

HELP: query-results
{ $values { "query" object }
    { "result-set" result-set }
}
{ $description "Returns a " { $link result-set } " object representing the reults of a SQL query." } ;

HELP: #rows
{ $values { "result-set" result-set } { "n" integer } }
{ $description "Returns the number of rows in a result set." } ;

HELP: #columns
{ $values { "result-set" result-set } { "n" integer } }
{ $description "Returns the number of columns in a result set." } ;

HELP: row-column
{ $values { "result-set" result-set } { "column" integer }
    { "obj" object }
}
{ $description "Returns the value indexed by " { $snippet "column" } " in the current row of a " { $link result-set } "." } ;

HELP: row-column-typed
{ $values { "result-set" result-set } { "column" integer }
    { "sql" "sql" } }
{ $description "Returns the value indexed by " { $snippet "column" } " in the current row of a " { $link result-set } " and converts the result based on a type stored in the " { $link result-set } "'s " { $slot "out-params" } "." } ;

HELP: advance-row
{ $values { "result-set" result-set } }
{ $description "Advanced the pointer to an underlying SQL result set stored in a " { $link result-set } " object." } ;

HELP: more-rows?
{ $values { "result-set" result-set } { "?" "a boolean" } }
{ $description "Returns true if the " { $link result-set } " has more rows to traverse." } ;



HELP: begin-transaction
{ $description "Begins a new transaction. User code should make use of the " { $link with-transaction } " combinator." } ;

HELP: commit-transaction
{ $description "Commits a transaction. User code should make use of the " { $link with-transaction } " combinator." } ;

HELP: in-transaction
{ $description "A variable that is set true when a transaction is in progress." } ;

HELP: in-transaction?
{ $values
     { "?" "a boolean" } }
{ $description "Returns true if there is currently a transaction in progress in this scope." } ;

HELP: query-each
{ $values
     { "statement" statement } { "quot" quotation } }
{ $description "A combinator that calls a quotation on a sequence of SQL statments to their results query results." } ;

HELP: query-map
{ $values
     { "statement" statement } { "quot" quotation }
     { "seq" sequence } }
{ $description "A combinator that maps a sequence of SQL statments to their results query results." } ;

HELP: rollback-transaction
{ $description "Rolls back a transaction; no data is committed to the database. User code should make use of the " { $link with-transaction } " combinator." } ;

HELP: sql-command
{ $values
     { "sql" string } }
{ $description "Executes a SQL string using the databse in the " { $link db } " symbol." } ;

HELP: sql-query
{ $values
     { "sql" string }
     { "rows" "an array of arrays of strings" } }
{ $description "Runs a SQL query of raw text in the database in the " { $link db } " symbol. Each row is returned as an array of strings; no type-conversions are done on the resulting data." } ;

{ sql-command sql-query } related-words

HELP: sql-row
{ $values
     { "result-set" result-set }
     { "seq" sequence } }
{ $description "Returns the current row in a " { $link result-set } " as an array of strings." } ;

HELP: sql-row-typed
{ $values
     { "result-set" result-set }
     { "seq" sequence } }
{ $description "Returns the current row in a " { $link result-set } " as an array of typed Factor objects." } ;

{ sql-row sql-row-typed } related-words

HELP: with-db
{ $values
     { "db" db } { "quot" quotation } }
{ $description "Calls the quotation with a database bound to the " { $link db } " symbol. The database called is based on the " { $snippet "class" } " with the " } ;

HELP: with-transaction
{ $values
     { "quot" quotation } }
{ $description "" } ;

ARTICLE: "db" "Database library"
{ $subsection "db-custom-database-combinators" }
{ $subsection "db-protocol" }
{ $subsection "db-result-sets" }
{ $subsection "db-lowlevel-tutorial" }
"Higher-level database:"
{ $vocab-subsection "Database types" "db.types" }
{ $vocab-subsection "High-level tuple/database integration" "db.tuples" }
! { $subsection "db-tuples" }
! { $subsection "db-tuples-protocol" }
! { $subsection "db-tuples-tutorial" }
"Supported database backends:"
{ $vocab-subsection "SQLite" "db.sqlite" }
{ $vocab-subsection "PostgreSQL" "db.postgresql" }
"To add support for another database to Factor:"
{ $subsection "db-porting-the-library" }
;

ARTICLE: "db-random-access-result-set" "Random access result sets"
"Random-access result sets do not have to be traversed in order. For instance, PostgreSQL's result set object can be accessed as a matrix with i,j coordinates."
$nl
"Databases which work in this way must provide methods for the following traversal words:"
{ $subsection #rows }
{ $subsection #columns }
{ $subsection row-column }
{ $subsection row-column-typed } ;

ARTICLE: "db-sequential-result-set" "Sequential result sets"
"Sequential result sets can be iterated one element after the next. SQLite's result sets offer this method of traversal."
$nl
"Databases which work in this way must provide methods for the following traversal words:"
{ $subsection more-rows? }
{ $subsection advance-row }
{ $subsection row-column }
{ $subsection row-column-typed } ;

ARTICLE: "db-result-sets" "Result sets"
"Result sets are the encapsulated, database-specific results from a SQL query."
$nl
"Two possible protocols for iterating over result sets exist:"
{ $subsection "db-random-access-result-set" }
{ $subsection "db-sequential-result-set" }
"Query the number of rows or columns:"
{ $subsection #rows }
{ $subsection #columns }
"Traversing a result set:"
{ $subsection advance-row }
{ $subsection more-rows? }
"Pulling out a single row of results:"
{ $subsection row-column }
{ $subsection row-column-typed } ;

ARTICLE: "db-protocol" "Low-level database protocol"
"The high-level protocol (see " { $vocab-link "db.tuples" } ") uses this low-level protocol for executing statements and queries." $nl
"Opening a database:"
{ $subsection db-open }
"Closing a database:"
{ $subsection db-close }

"Performing a query:"
{ $subsection query-results }

"Handling query results:"
{ $subsection "db-result-sets" }

 ;

ARTICLE: "db-lowlevel-tutorial" "Low-level database tutorial"
"Although Factor makes integrating a database with its object system easy (see " { $vocab-link "db.tuples" } "), sometimes you may want to write SQL directly and get the results back as arrays of strings, for instance, when interfacing with a legacy database that doesn't easily map to " { $snippet "tuples" } "."
;

ARTICLE: "db-porting-the-library" "Porting the database library"
"There are two layers to implement when porting the database library."
{ $subsection "db-protocol" }
;

ARTICLE: "db-custom-database-combinators" "Custom database combinators"
"Every database library requires some effort on the programmer's part to initialize and open a database. SQLite uses files on your harddisk, so a simple pathname is all the setup required. With PostgreSQL, you log in to a networked server as a user on a specfic port." $nl

"Make a " { $snippet "with-" } " combinator to open and close a database so that resources are not leaked."
{ $code <"
USING: db.sqlite db io.files ;
: with-sqlite-db ( quot -- )
    "my-database.db" temp-file sqlite-db rot with-db ;"> } 

{ $code <"
USING: db.postgresql db ;
: with-postgresql-db ( quot -- )
    { "localhost" "db-username" "db-password" "db-name" }
    postgresql-db rot with-db ;">
}

;

ABOUT: "db"

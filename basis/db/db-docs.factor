! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien assocs classes db.private help.markup help.syntax
kernel math quotations sequences strings ;
IN: db

HELP: db-connection
{ $description "The " { $snippet "db-connection" } " class is the superclass of all other database classes. It stores a " { $snippet "handle" } " to the database as well as insert, update, and delete queries. Stores the current database object as a dynamic variable." } ;

HELP: new-db-connection
{ $values { "class" class } { "obj" db-connection } }
{ $description "Creates a new database object from a given class with caches for prepared statements. Does not actually connect to the database until " { $link db-open } " or " { $link with-db } " is called." }
{ $notes "User-defined databases must call this constructor word instead of " { $link new } "." } ;

HELP: db-open
{ $values { "db" "a database configuration object" } { "db-connection" db-connection } }
{ $description "Opens a database using the configuration data stored in a " { $snippet "database configuration object" } " tuple. The database object now references a database handle that must be cleaned up. Therefore, it is better to use the " { $link with-db } " combinator than calling this word directly." } ;

HELP: db-close
{ $values { "handle" alien } }
{ $description "Closes a database using the handle provided. Use of the " { $link with-db } " combinator is preferred over manually opening and closing databases so that resources are not leaked." } ;

{ db-open db-close with-db } related-words

HELP: dispose-statements
{ $values { "assoc" assoc } }
{ $description "Disposes an associative list of statements." } ;

HELP: statement
{ $description "A " { $snippet "statement" } " stores the information about a statement, such as the SQL statement text, the in/out parameters, and type information." } ;

HELP: result-set
{ $description "An object encapsulating a raw SQL result object. There are two ways in which a result set can be accessed, but they are specific to the database backend in use."
{ $subsections
    "db-random-access-result-set"
    "db-sequential-result-set"
}
} ;

HELP: new-result-set
{ $values
    { "query" "a query" } { "handle" alien } { "class" class }
    { "result-set" result-set } }
{ $description "Creates a new " { $link result-set } " object of type " { $snippet "class" } "." } ;

HELP: new-statement
{ $values { "sql" string } { "in" sequence } { "out" sequence } { "class" class } { "statement" statement } }
{ $description "Makes a new statement object from the given parameters." } ;

HELP: bind-statement
{ $values
    { "obj" object } { "statement" statement } }
{ $description "Sets the statement's " { $slot "bind-params" } " and calls " { $link bind-statement* } " to do the database-specific bind. Sets " { $slot "bound?" } " to true if binding succeeds." } ;

HELP: bind-statement*
{ $values
    { "statement" statement } }
{ $description "Does a low-level bind of the SQL statement's tuple parameters if the database requires. Some databases should treat this as a no-op and bind instead when the actual statement is run." } ;

HELP: <simple-statement>
{ $values { "string" string } { "in" sequence } { "out" sequence }
    { "statement" statement } }
{ $description "Makes a new simple statement object from the given parameters." }
{ $warning "Using a simple statement can lead to SQL injection attacks in PostgreSQL. The Factor database implementation for SQLite only uses " { $link <prepared-statement> } " as the sole kind of statement; simple statements alias to prepared ones." } ;

HELP: <prepared-statement>
{ $values { "string" string } { "in" sequence } { "out" sequence }
    { "statement" statement } }
{ $description "Makes a new prepared statement object from the given parameters. A prepared statement's parameters will be escaped by the database backend to avoid SQL injection attacks. Prepared statements should be preferred over simple statements." } ;

HELP: prepare-statement
{ $values { "statement" statement } }
{ $description "For databases which implement a method on this generic, it does some internal processing to ready the statement for execution." } ;

HELP: low-level-bind
{ $values
    { "statement" statement } }
{ $description "For use with prepared statements, methods on this word should bind the datatype in the SQL spec to its identifier in the SQL string. To name bound variables, SQLite uses identifiers in the form of " { $snippet ":name" } ", while PostgreSQL uses increasing numbers beginning with a dollar sign, e.g. " { $snippet "$1" } "." } ;

HELP: query-results
{ $values { "query" object }
    { "result-set" result-set }
}
{ $description "Returns a " { $link result-set } " object representing the results of an SQL query. See " { $link "db-result-sets" } "." } ;

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
{ $values { "result-set" result-set } { "?" boolean } }
{ $description "Returns true if the " { $link result-set } " has more rows to traverse." } ;



HELP: begin-transaction
{ $description "Begins a new transaction. User code should make use of the " { $link with-transaction } " combinator." } ;

HELP: commit-transaction
{ $description "Commits a transaction. User code should make use of the " { $link with-transaction } " combinator." } ;

HELP: in-transaction
{ $description "A variable that is set true when a transaction is in progress." } ;

HELP: in-transaction?
{ $values
    { "?" boolean } }
{ $description "Returns true if there is currently a transaction in progress in this scope." } ;

HELP: query-each
{ $values
    { "result-set" result-set } { "quot" quotation } }
{ $description "Applies the quotation to each row of the " { $link result-set } " in order." } ;

HELP: query-map
{ $values
    { "result-set" result-set } { "quot" quotation }
    { "seq" sequence } }
{ $description "Applies the quotation to each row of the " { $link result-set } " in order." } ;

HELP: rollback-transaction
{ $description "Rolls back a transaction; no data is committed to the database. User code should make use of the " { $link with-transaction } " combinator." } ;

HELP: sql-command
{ $values
    { "sql" string } }
{ $description "Executes an SQL string using the database in the " { $link db-connection } " symbol." } ;

HELP: sql-query
{ $values
    { "sql" string }
    { "rows" "an array of arrays of strings" } }
{ $description "Runs an SQL query of raw text in the database in the " { $link db-connection } " symbol. Each row is returned as an array of strings; no type-conversions are done on the resulting data." } ;

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
    { "db" "a database configuration object" } { "quot" quotation } }
{ $description "Calls the quotation with a database bound to the " { $link db-connection } " symbol. See " { $link "db-custom-database-combinators" } " for help setting up database access." } ;

HELP: with-transaction
{ $values
    { "quot" quotation } }
{ $description "Calls the quotation inside a database transaction and commits the result to the database after the quotation finishes. If the quotation throws an error, the transaction is aborted." } ;

ARTICLE: "db" "Database library"
"Accessing a database:"
{ $subsections "db-custom-database-combinators" }
"Higher-level database help:"
{ $vocab-subsections
    { "Database types" "db.types" }
    { "High-level tuple/database integration" "db.tuples" }
}
"Low-level database help:"
{ $subsections
    "db-protocol"
    "db-result-sets"
    "db-lowlevel-tutorial"
}
"Supported database backends:"
{ $vocab-subsections
    { "SQLite" "db.sqlite" }
    { "PostgreSQL" "db.postgresql" }
} ;

ARTICLE: "db-random-access-result-set" "Random access result sets"
"Random-access result sets do not have to be traversed in order. For instance, PostgreSQL's result set object can be accessed as a matrix with i,j coordinates."
$nl
"Databases which work in this way must provide methods for the following traversal words:"
{ $subsections
    #rows
    #columns
    row-column
    row-column-typed
} ;

ARTICLE: "db-sequential-result-set" "Sequential result sets"
"Sequential result sets can be iterated one element after the next. SQLite's result sets offer this method of traversal."
$nl
"Databases which work in this way must provide methods for the following traversal words:"
{ $subsections
    more-rows?
    advance-row
    row-column
    row-column-typed
} ;

ARTICLE: "db-result-sets" "Result sets"
"Result sets are the encapsulated, database-specific results from an SQL query."
$nl
"Two possible protocols for iterating over result sets exist:"
{ $subsections
    "db-random-access-result-set"
    "db-sequential-result-set"
}
"Query the number of rows or columns:"
{ $subsections
    #rows
    #columns
}
"Traversing a result set:"
{ $subsections
    advance-row
    more-rows?
}
"Pulling out a single row of results:"
{ $subsections
    row-column
    row-column-typed
} ;

ARTICLE: "db-protocol" "Low-level database protocol"
"The high-level protocol (see " { $vocab-link "db.tuples" } ") uses this low-level protocol for executing statements and queries." $nl
"Opening a database:"
{ $subsections db-open }
"Closing a database:"
{ $subsections db-close }
"Creating statements:"
{ $subsections
    <simple-statement>
    <prepared-statement>
}
"Using statements with the database:"
{ $subsections
    prepare-statement
    bind-statement*
    low-level-bind
}
"Performing a query:"
{ $subsections query-results }
"Handling query results:"
{ $subsections "db-result-sets" }
;
! { $subsection bind-tuple }

ARTICLE: "db-lowlevel-tutorial" "Low-level database tutorial"
"Although Factor makes integrating a database with its object system easy (see " { $vocab-link "db.tuples" } "), sometimes you may want to write SQL directly and get the results back as arrays of strings, for instance, when interfacing with a legacy database that doesn't easily map to " { $snippet "tuples" } "." $nl
"Executing an SQL command:"
{ $subsections sql-command }
"Executing a query directly:"
{ $subsections sql-query }
"Here's an example usage where we'll make a book table, insert some objects, and query them." $nl
"First, let's set up a custom combinator for using our database. See " { $link "db-custom-database-combinators" } " for more details."
{ $code "USING: db.sqlite db io.files io.files.temp ;
: with-book-db ( quot -- )
    \"book.db\" temp-file <sqlite-db> swap with-db ; inline" }
"Now let's create the table manually:"
{ $code "\"create table books
    (id integer primary key, title text, author text, date_published timestamp,
     edition integer, cover_price double, condition text)\"
    [ sql-command ] with-book-db" }
"Time to insert some books:"
{ $code "\"insert into books
    (title, author, date_published, edition, cover_price, condition)
    values('Factor for Sheeple', 'Mister Stacky Pants', date('now'), 1, 13.37, 'mint')\"
[ sql-command ] with-book-db" }
"Now let's select the book:"
{ $code "\"select id, title, cover_price from books;\" [ sql-query ] with-book-db" }
"Notice that the result of this query is a Factor array containing the database rows as arrays of strings. We would have to convert the " { $snippet "cover_price" } " from a string to a number in order to use it in a calculation." $nl
"In conclusion, this method of accessing a database is supported, but it is fairly low-level and generally specific to a single database. The " { $vocab-link "db.tuples" } " vocabulary is a good alternative to writing SQL by hand." ;

ARTICLE: "db-custom-database-combinators" "Custom database combinators"
"Every database library requires some effort on the programmer's part to initialize and open a database. SQLite uses files on your harddisk, so a simple pathname is all the setup required. With PostgreSQL, you log in to a networked server as a user on a specific port." $nl

"Make a " { $snippet "with-" } " combinator to open and close a database so that resources are not leaked." $nl

"SQLite example combinator:"
{ $code "USING: db.sqlite db io.files io.files.temp ;
: with-sqlite-db ( quot -- )
    \"my-database.db\" temp-file <sqlite-db> swap with-db ; inline" }

"PostgreSQL example combinator:"
{ $code "USING: db.postgresql db ;
: with-postgresql-db ( quot -- )
    <postgresql-db>
        \"localhost\" >>host
        5432 >>port
        \"erg\" >>username
        \"secrets?\" >>password
        \"factor-test\" >>database
    swap with-db ; inline"
} ;

ABOUT: "db"

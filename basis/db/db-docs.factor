! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes kernel help.markup help.syntax sequences
alien assocs strings math multiline ;
IN: db

HELP: db
{ $description "The " { $snippet "db" } " class is the superclass of all other database classes.  It stores a " { $snippet "handle" } " to the database as well as insert, update, and delete queries." } ;

HELP: new-db
{ $values { "class" class } { "obj" object } }
{ $description "Creates a new database object from a given class." } ;

HELP: make-db*
{ $values { "seq" sequence } { "db" object } { "db" object } }
{ $description "Takes a sequence of parameters specific to each database and a class name of the database, and constructs a new database object." } ;

HELP: make-db
{ $values { "seq" sequence } { "class" class } { "db" db } }
{ $description "Takes a sequence of parameters specific to each database and a class name of the database, and constructs a new database object." } ;

HELP: db-open
{ $values { "db" db } { "db" db } }
{ $description "Opens a database using the configuration data stored in a " { $link db } " tuple." } ;

HELP: db-close
{ $values { "handle" alien } }
{ $description "Closes a database using the handle provided." } ;

HELP: dispose-statements
{ $values { "assoc" assoc } }
{ $description "Disposes an associative list of statements." } ;

HELP: db-dispose
{ $values { "db" db } }
{ $description "Disposes of all the statements stored in the " { $link db } " object." } ;

HELP: statement
{ $description "A " { $snippet "statement" } " stores the information about a statemen, such as the SQL statement text, the in/out parameters, and type information." } ;

HELP: simple-statement
{ $description } ;

HELP: prepared-statement
{ $description } ;

HELP: result-set
{ $description } ;

HELP: construct-statement
{ $values { "sql" string } { "in" sequence } { "out" sequence } { "class" class } { "statement" statement } }
{ $description "Makes a new statement object from the given parameters." } ;

HELP: <simple-statement>
{ $values { "string" string } { "in" sequence } { "out" sequence } }
{ $description "Makes a new simple statement object from the given parameters." } ;

HELP: <prepared-statement>
{ $values { "string" string } { "in" sequence } { "out" sequence } }
{ $description "Makes a new prepared statement object from the given parameters." } ;

HELP: prepare-statement
{ $values { "statement" statement } }
{ $description "For databases which implement a method on this generic, it does some internal processing to ready the statement for execution." } ;

HELP: bind-statement*
{ $values { "statement" statement } }
{ $description "" } ;

HELP: low-level-bind
{ $values { "statement" statement } }
{ $description "" } ;

HELP: bind-tuple
{ $values { "tuple" tuple } { "statement" statement } }
{ $description "" } ;

HELP: query-results
{ $values { "query" object } { "statement" statement } }
{ $description "" } ;

HELP: #rows
{ $values { "result-set" result-set } { "n" integer } }
{ $description "Returns the number of rows in a result set." } ;

HELP: #columns
{ $values { "result-set" result-set } { "n" integer } }
{ $description "Returns the number of columns in a result set." } ;

HELP: row-column
{ $values { "result-set" result-set } { "column" integer } }
{ $description "" } ;

HELP: row-column-typed
{ $values { "result-set" result-set } { "column" integer } }
{ $description "" } ;

HELP: advance-row
{ $values { "result-set" result-set } }
;

HELP: more-rows?
{ $values { "result-set" result-set } { "column" integer } }
;

HELP: execute-statement*
{ $values { "statement" statement } { "type" object } }
{ $description } ;

HELP: execute-statement
{ $values { "statement" statement } }
{ $description } ;

ARTICLE: "db" "Low-level database library"
{ $subsection "db-custom-database-combinators" }
{ $subsection "db-protocol" }
{ $subsection "db-lowlevel-tutorial" }
"Higher-level database:"
{ $vocab-subsection "Database types" "db.types" }
{ $vocab-subsection "High-level tuple/database integration" "db.tuples" }
"Supported database backends:"
{ $vocab-subsection "SQLite" "db.sqlite" }
{ $vocab-subsection "PostgreSQL" "db.postgresql" }
"To add support for another database to Factor:"
{ $subsection "db-porting-the-library" }
;

ARTICLE: "db-protocol" "Low-level database protocol"
"The high-level protocol (see " { $vocab-link "db.tuples" } ") uses this low-level protocol for executing statements and queries."
;

ARTICLE: "db-lowlevel-tutorial" "Low-level database tutorial"
"Although Factor makes integrating a database with its object system easy (see " { $vocab-link "db.tuples" } "), sometimes you may want to write SQL directly and get the results back as arrays of strings, for instance, when interfacing with a legacy database that doesn't easily map to " { $snippet "tuples" } "."
;

ARTICLE: "db-porting-the-library" "Porting the database library"
"This section is not yet written."
;


ARTICLE: "db-custom-database-combinators" "Custom database combinators"
"Every database library requires some effort on the programmer's part to initialize and open a database.  SQLite uses files on your harddisk, so a simple pathname is all the setup required. With PostgreSQL, you log in to a networked server as a user on a specfic port." $nl

"Make a " { $snippet "with-" } " word to open, close, and use your database."
{ $code <"
: with-my-database ( quot -- )
    { "my-database.db" temp-file } 
"> }


;

ABOUT: "db"

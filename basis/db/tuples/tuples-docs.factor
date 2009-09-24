! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax io.streams.string kernel
quotations sequences strings math db.types db.tuples.private db ;
IN: db.tuples

HELP: random-id-generator
{ $description "Used to tell " { $link eval-generator } " to generate a random number for use as a key." } ;

HELP: create-sql-statement
{ $values
     { "class" class }
     { "object" object } }
{ $description "Generates the SQL code for creating a table for a given class." } ;

HELP: drop-sql-statement
{ $values
     { "class" class }
     { "object" object } }
{ $description "Generates the SQL code for dropping a table for a given class." } ;

HELP: insert-tuple-set-key
{ $values
     { "tuple" tuple } { "statement" statement } }
{ $description "Inserts a tuple and sets its primary key in one word. This is necessary for some databases." } ;

HELP: <count-statement>
{ $values
     { "query" query }
     { "statement" statement } }
{ $description "A database-specific hook for generating the SQL for a count statement." } ;

HELP: <delete-tuples-statement>
{ $values
     { "tuple" tuple } { "class" class }
     { "object" object } }
{ $description "A database-specific hook for generating the SQL for an delete statement." } ;

HELP: <insert-db-assigned-statement>
{ $values
     { "class" class }
     { "object" object } }
{ $description "A database-specific hook for generating the SQL for an insert statement with a database-assigned primary key." } ;

HELP: <insert-user-assigned-statement>
{ $values
     { "class" class }
     { "object" object } }
{ $description "A database-specific hook for generating the SQL for an insert statement with a user-assigned primary key." } ;

HELP: <select-by-slots-statement>
{ $values
     { "tuple" tuple } { "class" class }
     { "tuple" tuple } }
{ $description "A database-specific hook for generating the SQL for a select statement." } ;

HELP: <update-tuple-statement>
{ $values
     { "class" class }
     { "object" object } }
{ $description "A database-specific hook for generating the SQL for an update statement." } ;


HELP: define-persistent
{ $values
     { "class" class } { "table" string } { "columns" "an array of slot specifiers" } }
{ $description "Defines a relation from a Factor " { $snippet "tuple class" } " to a SQL database table name. The format for the slot specifiers is as follows:"
{ $list
    { "a slot name from the " { $snippet "tuple class" } }
    { "the name of a database column that maps to the slot" }        { "a database type (see " { $link "db.types" } ")" }
} "Throws an error if the slot name (column one from each row) is not a slot in the tuple or its superclases." }
{ $examples
    { $unchecked-example "USING: db.tuples db.types ;"
        "TUPLE: boat id year name ;"
        "boat \"BOAT\" {"
        "    { \"id\" \"ID\" +db-assigned-id+ }"
        "    { \"year\" \"YEAR\" INTEGER }"
        "    { \"name\" \"NAME\" TEXT }"
        "} define-persistent"
        ""
    }
} ;

HELP: create-table
{ $values
     { "class" class } }
{ $description "Creates a SQL table from a mapping defined by " { $link define-persistent } ". If the table already exists, the database will likely throw an error." } ;

HELP: ensure-table
{ $values
     { "class" class } }
{ $description "Creates a SQL table from a mapping defined by " { $link define-persistent } ". If the table already exists, the error is silently ignored." } ;

HELP: ensure-tables
{ $values
     { "classes" "a sequence of classes" } }
{ $description "Creates a SQL table from a mapping defined by " { $link define-persistent } ". If a table already exists, the error is silently ignored." } ;

HELP: recreate-table
{ $values
     { "class" class } }
{ $description "Drops an existing table and re-creates it from a mapping defined by " { $link define-persistent } ". If the table does not exist the error is silently ignored." }
{ $warning { $emphasis "THIS WORD WILL DELETE YOUR DATA." } $nl
" Use " { $link ensure-table } " unless you want to delete the data in this table." } ;

{ create-table ensure-table ensure-tables recreate-table } related-words

HELP: drop-table
{ $values
     { "class" class } }
{ $description "Drops an existing table which deletes all of the data. The database will probably throw an error if the table does not exist." }
{ $warning { $emphasis "THIS WORD WILL DELETE YOUR DATA." } } ;

HELP: insert-tuple
{ $values
     { "tuple" tuple } }
{ $description "Inserts a tuple into a database if a relation has been defined with " { $link define-persistent } ". If a mapping states that the database assigns a primary key to the tuple, this value will be set after this word runs." }
{ $notes "Objects should only be inserted into a database once per object. To store the object after the initial insert, call " { $link update-tuple } "." } ;

HELP: update-tuple
{ $values
     { "tuple" tuple } }
{ $description "Updates a tuple that has already been inserted into a database. The tuple must have a primary key that has been set by " { $link insert-tuple } " or that is user-defined." } ;

HELP: delete-tuples
{ $values
     { "tuple" tuple } }
{ $description "Uses the " { $snippet "tuple" } " as an exemplar object and deletes any objects that have the same slots set. If a slot is not " { $link f } ", then it is used to generate a SQL statement that deletes tuples." }
{ $warning "This word will delete your data." } ;

{ insert-tuple update-tuple delete-tuples } related-words

HELP: select-tuple
{ $values
     { "query/tuple" tuple }
     { "tuple/f" "a tuple or f" } }
{ $description "A SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". Returns a single tuple from the database if it matches the query constructed from the exemplar tuple." } ;

HELP: select-tuples
{ $values
     { "query/tuple" tuple }
     { "tuples" "an array of tuples" } }
{ $description "A SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". Returns a multiple tuples from the database that match the query constructed from the exemplar tuple." } ;

HELP: count-tuples
{ $values
     { "query/tuple" tuple }
     { "n" integer } }
{ $description "Returns the number of items that would be returned if the query were a select query. Counting the tuples with this word is more efficient than calling " { $link length } " on the result of " { $link select-tuples } "." } ;

{ select-tuple select-tuples count-tuples } related-words



ARTICLE: "db-tuples" "High-level tuple/database integration"
"Start with a tutorial:"
{ $subsection "db-tuples-tutorial" }
"Database types supported:"
{ $subsection "db.types" }
"Useful words:"
{ $subsection "db-tuples-words" }
"For porting db.tuples to other databases:"
{ $subsection "db-tuples-protocol" }
;

ARTICLE: "db-tuples-words" "High-level tuple/database words"
"Making tuples work with a database:"
{ $subsection define-persistent }
"Creating tables:"
{ $subsection create-table }
{ $subsection ensure-table }
{ $subsection ensure-tables }
{ $subsection recreate-table }
"Dropping tables:"
{ $subsection drop-table }
"Inserting a tuple:"
{ $subsection insert-tuple }
"Updating a tuple:"
{ $subsection update-tuple }
"Deleting tuples:"
{ $subsection delete-tuples }
"Querying tuples:"
{ $subsection select-tuple }
{ $subsection select-tuples }
{ $subsection count-tuples } ;

ARTICLE: "db-tuples-protocol" "Tuple database protocol"
"Creating a table:"
{ $subsection create-sql-statement }
"Dropping a table:"
{ $subsection drop-sql-statement }
"Inserting a tuple:"
{ $subsection <insert-db-assigned-statement> }
{ $subsection <insert-user-assigned-statement> }
"Updating a tuple:"
{ $subsection <update-tuple-statement> }
"Deleting tuples:"
{ $subsection <delete-tuples-statement> }
"Selecting tuples:"
{ $subsection <select-by-slots-statement> }
"Counting tuples:"
{ $subsection <count-statement> } ;

ARTICLE: "db-tuples-tutorial" "Tuple database tutorial"
"Let's make a tuple and store it in a database. To follow along, click on each code example and run it in the listener. If you forget to run an example, just start at the top and run them all again in order." $nl
"We're going to store books in this tutorial."
{ $code "TUPLE: book id title author date-published edition cover-price condition ;" }
"The title, author, and publisher should be strings; the date-published a timestamp; the edition an integer; the cover-price a float. These are the Factor types for which we will need to look up the corresponding " { $link "db.types" } ". " $nl
"To actually bind the tuple slots to the database types, we'll use " { $link define-persistent } "."
{ $code
"""USING: db.tuples db.types ;
book "BOOK"
{
    { "id" "ID" +db-assigned-id+ }
    { "title" "TITLE" VARCHAR }
    { "author" "AUTHOR" VARCHAR }
    { "date-published" "DATE_PUBLISHED" TIMESTAMP }
    { "edition" "EDITION" INTEGER }
    { "cover-price" "COVER_PRICE" DOUBLE }
    { "condition" "CONDITION" VARCHAR }
} define-persistent""" }
"That's all we'll have to do with the database for this tutorial. Now let's make a book."
{ $code """USING: calendar namespaces ;
T{ book
    { title "Factor for Sheeple" }
    { author "Mister Stacky Pants" }
    { date-published T{ timestamp { year 2009 } { month 3 } { day 3 } } }
    { edition 1 }
    { cover-price 13.37 }
} book set
""" }
"Now we've created a book. Let's save it to the database."
{ $code """USING: db db.sqlite fry io.files ;
: with-book-tutorial ( quot -- )
     '[ "book-tutorial.db" temp-file <sqlite-db> _ with-db ] call ;

[
    book recreate-table
    book get insert-tuple
] with-book-tutorial
""" }
"Is it really there?"
{ $code """[
    T{ book { title "Factor for Sheeple" } } select-tuples .
] with-book-tutorial""" }
"Oops, we spilled some orange juice on the book cover."
{ $code """book get "Small orange juice stain on cover" >>condition""" }
"Now let's save the modified book."
{ $code """[
    book get update-tuple
] with-book-tutorial""" }
"And select it again. You can query the database by any field -- just set it in the exemplar tuple you pass to " { $link select-tuples } "."
{ $code """[
    T{ book { title "Factor for Sheeple" } } select-tuples
] with-book-tutorial""" }
"Let's drop the table because we're done."
{ $code """[
    book drop-table
] with-book-tutorial""" }
"To summarize, the steps for using Factor's tuple database are:"
{ $list
    "Make a new tuple to represent your data"
    { "Map the Factor types to the database types with " { $link define-persistent } }
    { "Make a custom database combinator (see" { $link "db-custom-database-combinators" } ") to open your database and run a " { $link quotation } }
    { "Create a table with " { $link create-table } ", " { $link ensure-table } ", or " { $link recreate-table } }
    { "Start making and storing objects with " { $link insert-tuple } ", " { $link update-tuple } ", " { $link delete-tuples } ", and " { $link select-tuples } }
} ;

ABOUT: "db-tuples"

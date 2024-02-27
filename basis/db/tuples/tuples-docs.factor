! Copyright (C) 2008 Doug Coleman.
! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: classes db db.tuples.private db.types help.markup
help.syntax kernel math quotations sequences strings ;
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
    { "statement" tuple } }
{ $description "A database-specific hook for generating the SQL for a select statement." } ;

HELP: <update-tuple-statement>
{ $values
    { "class" class }
    { "object" object } }
{ $description "A database-specific hook for generating the SQL for an update statement." } ;


HELP: define-persistent
{ $values
    { "class" class } { "table" string } { "columns" "an array of slot specifiers" } }
{ $description "Defines a relation from a Factor " { $snippet "tuple class" } " to an SQL database table name. The format for the slot specifiers is as follows:"
{ $list
    { "a slot name from the " { $snippet "tuple class" } }
    { "the name of a database column that maps to the slot" }
    { "a database type (see " { $link "db.types" } ")" }
} "Throws an error if the slot name (column one from each row) is not a slot in the tuple or its superclases." }
{ $examples
    { $code "USING: db.tuples db.types ;"
        "TUPLE: boat id year name ;"
        "boat \"BOAT\" {"
        "    { \"id\" \"ID\" +db-assigned-id+ }"
        "    { \"year\" \"YEAR\" INTEGER }"
        "    { \"name\" \"NAME\" TEXT }"
        "} define-persistent"
    }
} ;

HELP: create-table
{ $values
    { "class" class } }
{ $description "Creates an SQL table from a mapping defined by " { $link define-persistent } ". If the table already exists, the database will likely throw an error." } ;

HELP: ensure-table
{ $values
    { "class" class } }
{ $description "Creates an SQL table from a mapping defined by " { $link define-persistent } ". If the table already exists, the error is silently ignored." } ;

HELP: ensure-tables
{ $values
    { "classes" "a sequence of classes" } }
{ $description "Creates an SQL table from a mapping defined by " { $link define-persistent } ". If a table already exists, the error is silently ignored." } ;

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

HELP: update-tuples
{ $values
    { "query/tuple" tuple }
    { "quot" { $quotation ( tuple -- tuple'/f ) } } }
{ $description "An SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". The " { $snippet "quot" } " is applied to each tuple from the database that matches the query, and the changed tuple is stored back to the database. If the " { $snippet "quot" } " returns " { $link f } ", the tuple is dropped, and its data remains unmodified in the database."
$nl
"The word is equivalent to the following code:"
{ $code "query/tuple select-tuples quot map sift [ update-tuple ] each" }
"The difference is that " { $snippet "update-tuples" } " handles query results one by one, thus avoiding the overhead of allocating the intermediate array of tuples, which " { $link select-tuples } " would do. This is important when processing large amounts of data in limited memory." } ;

HELP: delete-tuples
{ $values
    { "tuple" tuple } }
{ $description "Uses the " { $snippet "tuple" } " as an exemplar object and deletes any objects that have the same slots set. If a slot is not " { $link f } ", then it is used to generate an SQL statement that deletes tuples." }
{ $warning "This word will delete your data." } ;

HELP: reject-tuples
{ $values
    { "query/tuple" tuple }
    { "quot" { $quotation ( tuple -- ? ) } } }
{ $description "An SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". The " { $snippet "quot" } " is applied to each tuple from the database that matches the query, and if it returns a true value, the row is deleted from the database."
$nl
"The word is equivalent to the following code:"
{ $code "query/tuple select-tuples quot filter [ delete-tuples ] each" }
"The difference is that " { $snippet "reject-tuples" } " handles query results one by one, thus avoiding the overhead of allocating the intermediate array of tuples, which " { $link select-tuples } " would do. This is important when processing large amounts of data in limited memory." }
{ $warning "This word will delete your data." } ;

{ insert-tuple update-tuple update-tuples delete-tuples reject-tuples } related-words

HELP: each-tuple
{ $values
    { "query/tuple" tuple }
    { "quot" { $quotation ( tuple -- ) } } }
{ $description "An SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". The " { $snippet "quot" } " is applied to each tuple from the database that matches the query constructed from the exemplar tuple." } ;

HELP: select-tuple
{ $values
    { "query/tuple" tuple }
    { "tuple/f" { $maybe tuple } } }
{ $description "An SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". Returns a single tuple from the database if it matches the query constructed from the exemplar tuple." } ;

HELP: select-tuples
{ $values
    { "query/tuple" tuple }
    { "tuples" "an array of tuples" } }
{ $description "An SQL query is constructed from the slots of the exemplar tuple that are not " { $link f } ". Returns an array of multiple tuples from the database that match the query constructed from the exemplar tuple." } ;

HELP: count-tuples
{ $values
    { "query/tuple" tuple }
    { "n" integer } }
{ $description "Returns the number of items that would be returned if the query were a select query. Counting the tuples with this word is more efficient than calling " { $link length } " on the result of " { $link select-tuples } "." } ;

{ each-tuple select-tuple select-tuples count-tuples } related-words



ARTICLE: "db-tuples" "High-level tuple/database integration"
"Start with a tutorial:"
{ $subsections "db-tuples-tutorial" }
"Database types supported:"
{ $subsections "db.types" }
"Useful words:"
{ $subsections "db-tuples-words" }
"For porting " { $vocab-link "db.tuples" } " to other databases:"
{ $subsections "db-tuples-protocol" }
;

ARTICLE: "db-tuples-words" "High-level tuple/database words"
"Making tuples work with a database:"
{ $subsections define-persistent }
"Creating tables:"
{ $subsections
    create-table
    ensure-table
    ensure-tables
    recreate-table
}
"Dropping tables:"
{ $subsections drop-table }
"Inserting a tuple:"
{ $subsections insert-tuple }
"Updating tuples:"
{ $subsections
    update-tuple
    update-tuples
}
"Deleting tuples:"
{ $subsections
    delete-tuples
    reject-tuples
}
"Querying tuples:"
{ $subsections
    each-tuple
    select-tuple
    select-tuples
    count-tuples
} ;

ARTICLE: "db-tuples-protocol" "Tuple database protocol"
"Creating a table:"
{ $subsections create-sql-statement }
"Dropping a table:"
{ $subsections drop-sql-statement }
"Inserting a tuple:"
{ $subsections
    <insert-db-assigned-statement>
    <insert-user-assigned-statement>
}
"Updating a tuple:"
{ $subsections <update-tuple-statement> }
"Deleting tuples:"
{ $subsections <delete-tuples-statement> }
"Selecting tuples:"
{ $subsections <select-by-slots-statement> }
"Counting tuples:"
{ $subsections <count-statement> } ;

ARTICLE: "db-tuples-tutorial" "Tuple database tutorial"
"Let's make a tuple and store it in a database. To follow along, click on each code example and run it in the listener. If you forget to run an example, just start at the top and run them all again in order." $nl
"We're going to store books in this tutorial."
{ $code "TUPLE: book id title author date-published edition cover-price condition ;" }
"The title, author, and publisher should be strings; the date-published a timestamp; the edition an integer; the cover-price a float. These are the Factor types for which we will need to look up the corresponding " { $link "db.types" } "." $nl
"To actually bind the tuple slots to the database types, we'll use " { $link define-persistent } "."
{ $code
"USING: db.tuples db.types ;
book \"BOOK\"
{
    { \"id\" \"ID\" +db-assigned-id+ }
    { \"title\" \"TITLE\" VARCHAR }
    { \"author\" \"AUTHOR\" VARCHAR }
    { \"date-published\" \"DATE_PUBLISHED\" TIMESTAMP }
    { \"edition\" \"EDITION\" INTEGER }
    { \"cover-price\" \"COVER_PRICE\" DOUBLE }
    { \"condition\" \"CONDITION\" VARCHAR }
} define-persistent" }
"That's all we'll have to do with the database for this tutorial. Now let's make a book."
{ $code "USING: calendar namespaces ;
T{ book
    { title \"Factor for Sheeple\" }
    { author \"Mister Stacky Pants\" }
    { date-published T{ timestamp { year 2009 } { month 3 } { day 3 } } }
    { edition 1 }
    { cover-price 13.37 }
} book set" }
"Now we've created a book. Let's save it to the database."
{ $code "USING: db db.sqlite fry io.files.temp ;
: with-book-tutorial ( quot -- )
    '[ \"book-tutorial.db\" temp-file <sqlite3-db> _ with-db ] call ; inline

[
    book recreate-table
    book get insert-tuple
] with-book-tutorial" }
"Is it really there?"
{ $code "[
    T{ book { title \"Factor for Sheeple\" } } select-tuples .
] with-book-tutorial" }
"Oops, we spilled some orange juice on the book cover."
{ $code "book get \"Small orange juice stain on cover\" >>condition" }
"Now let's save the modified book."
{ $code "[
    book get update-tuple
] with-book-tutorial" }
"And select it again. You can query the database by any field -- just set it in the exemplar tuple you pass to " { $link select-tuples } "."
{ $code "[
    T{ book { title \"Factor for Sheeple\" } } select-tuples
] with-book-tutorial" }
"Let's drop the table because we're done."
{ $code "[
    book drop-table
] with-book-tutorial" }
"To summarize, the steps for using Factor's tuple database are:"
{ $list
    "Make a new tuple to represent your data"
    { "Map the Factor types to the database types with " { $link define-persistent } }
    { "Make a custom database combinator (see " { $link "db-custom-database-combinators" } ") to open your database and run a " { $link quotation } }
    { "Create a table with " { $link create-table } ", " { $link ensure-table } ", or " { $link recreate-table } }
    { "Start making and storing objects with " { $link insert-tuple } ", " { $link update-tuple } ", " { $link delete-tuples } ", and " { $link select-tuples } }
} ;

ABOUT: "db-tuples"

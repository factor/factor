! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes hashtables help.markup help.syntax io.streams.string
kernel sequences strings math ;
IN: db.types

HELP: +db-assigned-id+
{ $description "The database assigns a primary key to the object. The primary key is most likely a big integer, but is database-dependent." } ;

HELP: +default+
{ $description "Allows a default value for a column to be provided." } ;

HELP: +not-null+
{ $description "Ensures that a column is not null." } ;

HELP: +null+
{ $description "Allows a column to be null." } ;

HELP: +primary-key+
{ $description "Makes a column a primary key. Only one column may be a primary key." } ;

HELP: +random-id+
{ $description "Factor chooses a random number and tries to insert the tuple into the database with this number as its primary key. The default number of retries to find a unique random number is 10, though in practice it will almost certainly succeed on the first try." } ;

HELP: +user-assigned-id+
{ $description "The user is responsible for choosing a primary key for tuples inserted with this database type. Keys must be unique or else the database will throw an error. Usually it is better to use a " { $link +db-assigned-id+ } "." } ;

HELP: <generator-bind>
{ $values { "slot-name" object } { "key" object } { "generator-singleton" object } { "type" object } { "generator-bind" generator-bind } }
{ $description "An internal constructor for creating objects containing parameters used for binding generated values to a tuple query." } ;

HELP: <literal-bind>
{ $values { "key" object } { "type" object } { "value" object } { "literal-bind" literal-bind } }
{ $description "An internal constructor for creating objects containing parameters used for binding literal values to a tuple query." } ;

HELP: BIG-INTEGER
{ $description "A 64-bit integer. Whether this number is signed or unsigned depends on the database backend." } ;

HELP: BLOB
{ $description "A byte array." } ;

HELP: BOOLEAN
{ $description "Either true or false." } ;

HELP: DATE
{ $description "A date without a time component." } ;

HELP: DATETIME
{ $description "A date and a time." } ;

HELP: DOUBLE
{ $description "Corresponds to Factor's 64-bit floating-point numbers." } ;

HELP: FACTOR-BLOB
{ $description "A serialized Factor object." } ;

HELP: INTEGER
{ $description "A small integer, at least 32 bits in length. Whether this number is signed or unsigned depends on the database backend." } ;

HELP: NULL
{ $description "The SQL null type." } ;

HELP: REAL
{ $description "A real number of unlimited precision. May not be supported on all databases." } ;

HELP: SIGNED-BIG-INTEGER
{ $description "For portability, if a number is known to be 64bit and signed, then this datatype may be used. Some databases, like SQLite, cannot store arbitrary bignums as BIGINT types. If storing arbitrary bignums, use " { $link FACTOR-BLOB } "." } ;

HELP: TEXT
{ $description "Stores a string that is longer than a " { $link VARCHAR } ". SQLite uses this type for strings; it does not handle " { $link VARCHAR } " strings." } ;

HELP: TIME
{ $description "A timestamp without a date component." } ;

HELP: TIMESTAMP
{ $description "A Factor timestamp." } ;

HELP: UNSIGNED-BIG-INTEGER
{ $description "For portability, if a number is known to be 64bit, then this datatype may be used. Some databases, like SQLite, cannot store arbitrary bignums as BIGINT types. If storing arbitrary bignums, use " { $link FACTOR-BLOB } "." } ;

{ INTEGER SIGNED-BIG-INTEGER UNSIGNED-BIG-INTEGER } related-words

HELP: URL
{ $description "A Factor " { $link "urls" } " object." } ;

HELP: VARCHAR
{ $description "The SQL varchar type. This type can take an integer as an argument." }
{ $examples { $unchecked-example "{ VARCHAR 256 }" "" } } ;

HELP: user-assigned-id-spec?
{ $values
     { "specs" "a sequence of SQL specs" }
     { "?" "a boolean" } }
{ $description "Tests if any of the SQL specs has the type " { $link +user-assigned-id+ } "." } ;

HELP: bind#
{ $values
     { "spec" "a SQL spec" } { "obj" object } }
{ $description "A generic word that lets a database construct a literal binding." } ;

HELP: bind%
{ $values
     { "spec" "a SQL spec" } }
{ $description "A generic word that lets a database output a binding." } ;

HELP: db-assigned-id-spec?
{ $values
     { "specs" "a sequence of SQL specs" }
     { "?" "a boolean" } }
{ $description "Tests if any of the SQL specs has the type " { $link +db-assigned-id+ } "." } ;

HELP: find-primary-key
{ $values
     { "specs" "a sequence of SQL specs" }
     { "seq" "a sequence of SQL specs" } }
{ $description "Returns the rows from the SQL specs array that are part of the primary key. Composite primary keys are supported, so this word must return a sequence." }
{ $notes "This is a low-level word." } ;

HELP: get-slot-named
{ $values
     { "name" "a slot name" } { "tuple" tuple }
     { "value" "the value stored in the slot" } }
{ $description "Returns the value stored in a tuple slot, where the tuple slot is a string." } ;

HELP: no-sql-type
{ $values
     { "type" "a SQL type" } }
{ $description "Throws an error containing a SQL type that is unsupported or the result of a typo." } ;

HELP: normalize-spec
{ $values
     { "spec" "a SQL spec" } }
{ $description "Normalizes a SQL spec." } ;

HELP: offset-of-slot
{ $values
     { "string" string } { "tuple" tuple }
     { "n" integer } }
{ $description "Returns the offset of a tuple slot accessed by name." } ;

HELP: primary-key?
{ $values
     { "spec" "a SQL spec" }
     { "?" "a boolean" } }
{ $description "Returns true if a SQL spec is a primary key." } ;

HELP: relation?
{ $values
     { "spec" "a SQL spec" }
     { "?" "a boolean" } }
{ $description "Returns true if a SQL spec is a relation." } ;

HELP: unknown-modifier
{ $values { "modifier" string } }
{ $description "Throws an error containing an unknown SQL modifier." } ;

ARTICLE: "db.types" "Database types"
"The " { $vocab-link "db.types" } " vocabulary maps Factor types to database types." $nl
"Primary keys:"
{ $subsections
    +db-assigned-id+
    +user-assigned-id+
    +random-id+
}
"Null and boolean types:"
{ $subsections
    NULL
    BOOLEAN
}
"Text types:"
{ $subsections
    VARCHAR
    TEXT
}
"Number types:"
{ $subsections
    INTEGER
    BIG-INTEGER
    SIGNED-BIG-INTEGER
    UNSIGNED-BIG-INTEGER
    DOUBLE
    REAL
}
"Calendar types:"
{ $subsections
    DATE
    DATETIME
    TIME
    TIMESTAMP
}
"Factor byte-arrays:"
{ $subsections BLOB }
"Arbitrary Factor objects:"
{ $subsections FACTOR-BLOB }
"Factor URLs:"
{ $subsections URL } ;

ABOUT: "db.types"

! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes hashtables help.markup help.syntax io.streams.string kernel sequences strings ;
IN: db.types

HELP: (lookup-type)
{ $values
     { "obj" object }
     { "string" string } }
{ $description "" } ;

HELP: +autoincrement+
{ $description "" } ;

HELP: +db-assigned-id+
{ $description "" } ;

HELP: +default+
{ $description "" } ;

HELP: +foreign-id+
{ $description "" } ;

HELP: +has-many+
{ $description "" } ;

HELP: +not-null+
{ $description "" } ;

HELP: +null+
{ $description "" } ;

HELP: +primary-key+
{ $description "" } ;

HELP: +random-id+
{ $description "" } ;

HELP: +serial+
{ $description "" } ;

HELP: +unique+
{ $description "" } ;

HELP: +user-assigned-id+
{ $description "" } ;

HELP: <generator-bind>
{ $description "" } ;

HELP: <literal-bind>
{ $description "" } ;

HELP: <low-level-binding>
{ $description "" } ;

HELP: BIG-INTEGER
{ $description "" } ;

HELP: BLOB
{ $description "" } ;

HELP: BOOLEAN
{ $description "" } ;

HELP: DATE
{ $description "" } ;

HELP: DATETIME
{ $description "" } ;

HELP: DOUBLE
{ $description "" } ;

HELP: FACTOR-BLOB
{ $description "" } ;

HELP: INTEGER
{ $description "" } ;

HELP: NULL
{ $description "" } ;

HELP: REAL
{ $description "" } ;

HELP: SIGNED-BIG-INTEGER
{ $description "" } ;

HELP: TEXT
{ $description "" } ;

HELP: TIME
{ $description "" } ;

HELP: TIMESTAMP
{ $description "" } ;

HELP: UNSIGNED-BIG-INTEGER
{ $description "" } ;

HELP: URL
{ $description "" } ;

HELP: VARCHAR
{ $description "" } ;

HELP: assigned-id-spec?
{ $values
     { "spec" null }
     { "?" "a boolean" } }
{ $description "" } ;

HELP: bind#
{ $values
     { "spec" null } { "obj" object } }
{ $description "" } ;

HELP: bind%
{ $values
     { "spec" null } }
{ $description "" } ;

HELP: compound
{ $values
     { "string" string } { "obj" object }
     { "hash" hashtable } }
{ $description "" } ;

HELP: db-assigned-id-spec?
{ $values
     { "spec" null }
     { "?" "a boolean" } }
{ $description "" } ;

HELP: double-quote
{ $values
     { "string" string }
     { "new-string" null } }
{ $description "" } ;

HELP: find-primary-key
{ $values
     { "specs" null }
     { "obj" object } }
{ $description "" } ;

HELP: find-random-generator
{ $values
     { "seq" sequence }
     { "obj" object } }
{ $description "" } ;

HELP: generator-bind
{ $description "" } ;

HELP: get-slot-named
{ $values
     { "name" null } { "obj" object }
     { "value" null } }
{ $description "" } ;

HELP: join-space
{ $values
     { "string1" string } { "string2" string }
     { "new-string" null } }
{ $description "" } ;

HELP: literal-bind
{ $description "" } ;

HELP: lookup-create-type
{ $values
     { "obj" object }
     { "string" string } }
{ $description "" } ;

HELP: lookup-modifier
{ $values
     { "obj" object }
     { "string" string } }
{ $description "" } ;

HELP: lookup-type
{ $values
     { "obj" object }
     { "string" string } }
{ $description "" } ;

HELP: low-level-binding
{ $description "" } ;

HELP: modifiers
{ $values
     { "spec" null }
     { "string" string } }
{ $description "" } ;

HELP: no-sql-type
{ $description "" } ;

HELP: normalize-spec
{ $values
     { "spec" null } }
{ $description "" } ;

HELP: number>string*
{ $values
     { "n/string" null }
     { "string" string } }
{ $description "" } ;

HELP: offset-of-slot
{ $values
     { "string" string } { "obj" object }
     { "n" null } }
{ $description "" } ;

HELP: paren
{ $values
     { "string" string }
     { "new-string" null } }
{ $description "" } ;

HELP: persistent-table
{ $values
    
     { "hash" hashtable } }
{ $description "" } ;

HELP: primary-key?
{ $values
     { "spec" null }
     { "?" "a boolean" } }
{ $description "" } ;

HELP: random-id-generator
{ $description "" } ;

HELP: relation?
{ $values
     { "spec" null }
     { "?" "a boolean" } }
{ $description "" } ;

HELP: remove-db-assigned-id
{ $values
     { "specs" null }
     { "obj" object } }
{ $description "" } ;

HELP: remove-id
{ $values
     { "specs" null }
     { "obj" object } }
{ $description "" } ;

HELP: remove-relations
{ $values
     { "specs" null }
     { "newcolumns" null } }
{ $description "" } ;

HELP: set-slot-named
{ $values
     { "value" null } { "name" null } { "obj" object } }
{ $description "" } ;

HELP: single-quote
{ $values
     { "string" string }
     { "new-string" null } }
{ $description "" } ;

HELP: spec>tuple
{ $values
     { "class" class } { "spec" null }
     { "tuple" null } }
{ $description "" } ;

HELP: sql-spec
{ $description "" } ;

HELP: tuple>filled-slots
{ $values
     { "tuple" null }
     { "alist" "an array of key/value pairs" } }
{ $description "" } ;

HELP: tuple>params
{ $values
     { "specs" null } { "tuple" null }
     { "obj" object } }
{ $description "" } ;

HELP: unknown-modifier
{ $description "" } ;

ARTICLE: "db.types" "Database types"
"The " { $vocab-link "db.types" } " vocabulary maps Factor types to database types."
;

ABOUT: "db.types"
